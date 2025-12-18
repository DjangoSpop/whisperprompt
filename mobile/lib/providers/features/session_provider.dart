/// Session provider for managing voice session flow
///
/// Handles the complete session lifecycle:
/// 1. Create session
/// 2. Record voice for each variable
/// 3. Upload audio to backend
/// 4. Poll for transcription status
/// 5. Generate enhancement variants
/// 6. Save to history

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import '../../services/voice_service.dart';
import '../../models/template.dart';
import '../../models/session.dart';
import '../../intelligence/prompt_enhancer.dart';
import '../../intelligence/models/session_version.dart';
import '../../core/errors/app_error.dart';
import '../core/api_provider.dart';
import '../core/voice_provider.dart';
import '../intelligence/enhancement_provider.dart';
import 'session_state.dart';

/// Session provider
final sessionProvider =
    StateNotifierProvider.autoDispose<SessionNotifier, SessionState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final voice = ref.watch(voiceServiceProvider);
  final enhancer = ref.watch(promptEnhancerProvider);

  return SessionNotifier(
    api: api,
    voice: voice,
    enhancer: enhancer,
  );
});

/// Session state notifier
class SessionNotifier extends StateNotifier<SessionState> {
  final ApiService _api;
  final VoiceService _voice;
  final PromptEnhancer _enhancer;

  /// Timer for polling transcription status
  Timer? _pollingTimer;

  /// Timer for recording duration
  Timer? _recordingTimer;

  SessionNotifier({
    required ApiService api,
    required VoiceService voice,
    required PromptEnhancer enhancer,
  })  : _api = api,
        _voice = voice,
        _enhancer = enhancer,
        super(const SessionState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }

  /// Create a new session
  Future<void> createSession(PromptTemplateDetail template) async {
    try {
      state = SessionState(
        flowState: SessionFlowState.idle,
        template: template,
      );

      // Create session via API
      final session = await _api.createSession(template.slug);

      // Initialize variable states
      final variables = <String, VariableState>{};
      for (final schema in template.variablesSchema) {
        variables[schema.name] = VariableState(name: schema.name);
      }

      // Set first variable as current
      final firstVar =
          template.variablesSchema.isNotEmpty ? template.variablesSchema.first.name : null;

      state = state.copyWith(
        session: session,
        variables: variables,
        currentVariable: firstVar,
      );

      // Initialize session memory
      final memory = SessionMemory(
        sessionId: session.id,
        templateSlug: template.slug,
      );

      state = state.copyWith(memory: memory);
    } catch (e) {
      _handleError(e);
    }
  }

  /// Start recording for current variable
  Future<void> startRecording() async {
    if (state.currentVariable == null) {
      _handleError(AppError.validation(message: 'No variable selected'));
      return;
    }

    try {
      // Check microphone permission
      final hasPermission = await _voice.hasPermission();
      if (!hasPermission) {
        final granted = await _voice.requestPermission();
        if (!granted) {
          _handleError(AppError.permission(
            permissionName: 'Microphone',
            actions: [],
          ));
          return;
        }
      }

      // Start recording
      await _voice.startRecording();

      // Update state
      final variables = Map<String, VariableState>.from(state.variables);
      variables[state.currentVariable!] = variables[state.currentVariable!]!
          .copyWith(isRecording: true);

      state = state.copyWith(
        flowState: SessionFlowState.recording,
        variables: variables,
        recordingDuration: 0,
      );

      // Start recording timer
      _startRecordingTimer();
    } catch (e) {
      _handleError(AppError.audio(
        message: 'Failed to start recording: ${e.toString()}',
        actions: [],
        originalException: e,
      ));
    }
  }

  /// Stop recording and upload
  Future<void> stopRecording() async {
    if (state.currentVariable == null) return;

    try {
      _recordingTimer?.cancel();

      // Stop recording
      final audioPath = await _voice.stopRecording();

      if (audioPath == null) {
        _handleError(AppError.audio(
          message: 'Recording failed - no audio captured',
          actions: [],
        ));
        return;
      }

      // Check if file exists and has content
      final file = File(audioPath);
      if (!await file.exists() || await file.length() == 0) {
        _handleError(AppError.audio(
          message: 'Recording failed - empty audio file',
          actions: [],
        ));
        return;
      }

      // Update state with audio path
      final variables = Map<String, VariableState>.from(state.variables);
      variables[state.currentVariable!] = variables[state.currentVariable!]!
          .copyWith(
        isRecording: false,
        audioPath: audioPath,
      );

      state = state.copyWith(
        flowState: SessionFlowState.uploading,
        variables: variables,
      );

      // Upload audio
      await _uploadAudio(state.currentVariable!, audioPath);
    } catch (e) {
      _handleError(AppError.audio(
        message: 'Failed to stop recording: ${e.toString()}',
        actions: [],
        originalException: e,
      ));
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await _voice.cancelRecording();

      final variables = Map<String, VariableState>.from(state.variables);
      if (state.currentVariable != null) {
        variables[state.currentVariable!] = variables[state.currentVariable!]!
            .copyWith(isRecording: false);
      }

      state = state.copyWith(
        flowState: SessionFlowState.idle,
        variables: variables,
        recordingDuration: 0,
      );
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  /// Upload audio for a variable
  Future<void> _uploadAudio(String variableName, String audioPath) async {
    if (state.session == null) return;

    try {
      final file = File(audioPath);
      final durationMs = state.recordingDuration;

      // Upload with progress tracking
      await _api.uploadVoiceInput(
        sessionId: state.session!.id,
        variableName: variableName,
        audioFile: file,
        audioDurationMs: durationMs,
        onProgress: (progress) {
          final variables = Map<String, VariableState>.from(state.variables);
          variables[variableName] = variables[variableName]!
              .copyWith(uploadProgress: progress);
          state = state.copyWith(variables: variables);
        },
      );

      // Mark as transcribing
      final variables = Map<String, VariableState>.from(state.variables);
      variables[variableName] = variables[variableName]!.copyWith(
        uploadProgress: 1.0,
        transcriptionStatus: 'pending',
      );

      state = state.copyWith(
        flowState: SessionFlowState.transcribing,
        variables: variables,
      );

      // Start polling for status
      _startPolling();
    } catch (e) {
      _handleError(AppError.network(
        message: 'Failed to upload audio: ${e.toString()}',
        originalException: e,
      ));
    }
  }

  /// Start polling for transcription status
  void _startPolling() {
    _pollingTimer?.cancel();

    state = state.copyWith(isPolling: true);

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _pollStatus();
    });
  }

  /// Stop polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    state = state.copyWith(isPolling: false);
  }

  /// Poll session status
  Future<void> _pollStatus() async {
    if (state.session == null) {
      _stopPolling();
      return;
    }

    try {
      final status = await _api.getSessionStatus(state.session!.id);

      // Update variable states from backend
      final variables = Map<String, VariableState>.from(state.variables);

      for (final voiceInput in status.variablesStatus.entries) {
        final varName = voiceInput.key;
        final varStatus = voiceInput.value;

        if (variables.containsKey(varName)) {
          variables[varName] = variables[varName]!.copyWith(
            transcriptionStatus: varStatus['status'],
            transcribedText: varStatus['text'],
          );
        }
      }

      state = state.copyWith(variables: variables);

      // Check if all variables are completed
      if (state.allVariablesCompleted && status.readyToGenerate) {
        _stopPolling();
        await _generateEnhancement();
      }
    } catch (e) {
      debugPrint('Polling error: $e');
      // Don't stop polling on transient errors
    }
  }

  /// Generate enhancement after all variables transcribed
  Future<void> _generateEnhancement() async {
    if (state.session == null || state.template == null) return;

    try {
      state = state.copyWith(flowState: SessionFlowState.enhancing);

      // Collect all transcribed text
      final transcribedTexts = state.variables.values
          .where((v) => v.transcribedText != null)
          .map((v) => v.transcribedText!)
          .join(' ');

      // Generate enhancement variants
      final enhancement = await _enhancer.enhance(
        transcribedTexts,
        templateCategory: state.template!.categoryName,
      );

      // Create first version in session memory
      final version = PromptVersion(
        versionNumber: 1,
        text: enhancement.recommended.text,
        intent: enhancement.intent,
        variants: enhancement.variants,
        selectedVariantId: enhancement.recommendedVariantId,
        estimatedTokens: enhancement.recommended.estimatedTokens,
      );

      final memory = state.memory!.copyWith(
        versions: [version],
      );

      state = state.copyWith(
        flowState: SessionFlowState.completed,
        intent: enhancement.intent,
        enhancement: enhancement,
        memory: memory,
      );

      // Generate prompt on backend for history
      await _generatePromptOnBackend();
    } catch (e) {
      _handleError(AppError.unknown(
        message: 'Failed to generate enhancement: ${e.toString()}',
        originalException: e,
      ));
    }
  }

  /// Generate prompt on backend to save to history
  Future<void> _generatePromptOnBackend() async {
    if (state.session == null) return;

    try {
      await _api.generatePrompt(state.session!.id);
    } catch (e) {
      debugPrint('Error generating prompt on backend: $e');
      // Non-critical error, don't fail the session
    }
  }

  /// Refine with a specific strategy
  Future<void> refineWithStrategy(String rawCommand) async {
    if (state.enhancement == null || state.memory == null) return;

    try {
      // Parse refinement command
      final command = _enhancer.parseRefinementCommand(rawCommand);

      String refinedText;

      if (command.targetStrategy != null) {
        // Use specific strategy
        final variant = await _enhancer.regenerateWithStrategy(
          state.enhancement!.originalText,
          command.targetStrategy!,
          templateCategory: state.template?.categoryName,
        );
        refinedText = variant.text;
      } else {
        // Re-generate all variants
        final newEnhancement = await _enhancer.enhance(
          state.enhancement!.originalText,
          templateCategory: state.template?.categoryName,
        );
        refinedText = newEnhancement.recommended.text;
      }

      // Create new version
      final newVersionNumber = state.memory!.versions.length + 1;
      final newVersion = PromptVersion(
        versionNumber: newVersionNumber,
        text: refinedText,
        refinementCommand: rawCommand,
        estimatedTokens: _enhancer.strategies.first.estimateTokens(refinedText),
      );

      final updatedMemory = state.memory!.copyWith(
        versions: [...state.memory!.versions, newVersion],
      );

      state = state.copyWith(memory: updatedMemory);
    } catch (e) {
      _handleError(AppError.unknown(
        message: 'Failed to refine: ${e.toString()}',
        originalException: e,
      ));
    }
  }

  /// Select a different variant
  void selectVariant(String variantId) {
    if (state.enhancement == null) return;

    state.enhancement!.selectVariant(variantId);
    state = state.copyWith(enhancement: state.enhancement);

    // Update current version in memory
    if (state.memory != null && state.memory!.versions.isNotEmpty) {
      final currentVersion = state.memory!.current;
      final updatedVersion = currentVersion.copyWith(
        selectedVariantId: variantId,
        text: state.enhancement!.selected.text,
      );

      final versions = [...state.memory!.versions];
      versions[versions.length - 1] = updatedVersion;

      final updatedMemory = state.memory!.copyWith(versions: versions);
      state = state.copyWith(memory: updatedMemory);
    }
  }

  /// Move to next variable
  void nextVariable() {
    if (state.template == null || state.currentVariable == null) return;

    final currentIndex = state.template!.variablesSchema
        .indexWhere((v) => v.name == state.currentVariable);

    if (currentIndex < state.template!.variablesSchema.length - 1) {
      final nextVar = state.template!.variablesSchema[currentIndex + 1].name;
      state = state.copyWith(
        currentVariable: nextVar,
        flowState: SessionFlowState.idle,
      );
    }
  }

  /// Reset session
  void reset() {
    _pollingTimer?.cancel();
    _recordingTimer?.cancel();
    state = const SessionState();
  }

  /// Start recording timer
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      state = state.copyWith(
        recordingDuration: state.recordingDuration + 100,
      );
    });
  }

  /// Handle errors
  void _handleError(Object error) {
    _stopPolling();
    _recordingTimer?.cancel();

    final appError = error is AppError
        ? error
        : AppError.unknown(
            message: error.toString(),
            originalException: error,
          );

    state = state.copyWith(
      flowState: SessionFlowState.error,
      error: appError.userMessage,
    );

    debugPrint('Session error: ${appError.technicalMessage}');
  }

  /// Clear error and retry
  void clearError() {
    state = state.clearError().copyWith(flowState: SessionFlowState.idle);
  }
}
