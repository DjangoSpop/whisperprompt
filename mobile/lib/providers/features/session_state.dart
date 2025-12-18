/// Session state models for state management
///
/// Defines the state machine for the session flow:
/// idle → recording → uploading → transcribing → enhancing → completed

import '../../models/session.dart';
import '../../models/template.dart';
import '../../intelligence/models/intent.dart';
import '../../intelligence/models/enhancement.dart';
import '../../intelligence/models/session_version.dart';

/// Session flow states
enum SessionFlowState {
  /// Initial state, ready to start
  idle,

  /// Recording voice input
  recording,

  /// Uploading audio to backend
  uploading,

  /// Waiting for transcription to complete
  transcribing,

  /// Generating enhancement variants
  enhancing,

  /// Session completed with results
  completed,

  /// Error occurred
  error,
}

/// State for a single variable being collected
class VariableState {
  /// Variable name from schema
  final String name;

  /// Whether this variable is currently being recorded
  final bool isRecording;

  /// Audio file path (if recorded)
  final String? audioPath;

  /// Upload progress (0.0 - 1.0)
  final double uploadProgress;

  /// Transcription status
  final String? transcriptionStatus;

  /// Transcribed text
  final String? transcribedText;

  /// Error message (if any)
  final String? error;

  const VariableState({
    required this.name,
    this.isRecording = false,
    this.audioPath,
    this.uploadProgress = 0.0,
    this.transcriptionStatus,
    this.transcribedText,
    this.error,
  });

  /// Check if variable is completed
  bool get isCompleted =>
      transcriptionStatus == 'completed' && transcribedText != null;

  /// Check if variable is pending upload
  bool get isPendingUpload => audioPath != null && uploadProgress == 0.0;

  /// Check if variable is uploading
  bool get isUploading => uploadProgress > 0.0 && uploadProgress < 1.0;

  /// Check if variable is transcribing
  bool get isTranscribing =>
      transcriptionStatus == 'processing' || transcriptionStatus == 'pending';

  /// Check if variable has error
  bool get hasError => error != null;

  /// Copy with updated fields
  VariableState copyWith({
    String? name,
    bool? isRecording,
    String? audioPath,
    double? uploadProgress,
    String? transcriptionStatus,
    String? transcribedText,
    String? error,
  }) {
    return VariableState(
      name: name ?? this.name,
      isRecording: isRecording ?? this.isRecording,
      audioPath: audioPath ?? this.audioPath,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      transcribedText: transcribedText ?? this.transcribedText,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'VariableState($name, status: $transcriptionStatus, text: $transcribedText)';
}

/// Complete session state
class SessionState {
  /// Current flow state
  final SessionFlowState flowState;

  /// Template being used
  final PromptTemplateDetail? template;

  /// Active session from backend
  final WhisperSession? session;

  /// State of each variable
  final Map<String, VariableState> variables;

  /// Current variable being collected
  final String? currentVariable;

  /// Intent analysis result
  final IntentAnalysis? intent;

  /// Enhancement result with variants
  final EnhancementResult? enhancement;

  /// Session memory (versioning)
  final SessionMemory? memory;

  /// Error message (if any)
  final String? error;

  /// Recording duration in milliseconds
  final int recordingDuration;

  /// Whether polling is active
  final bool isPolling;

  const SessionState({
    this.flowState = SessionFlowState.idle,
    this.template,
    this.session,
    this.variables = const {},
    this.currentVariable,
    this.intent,
    this.enhancement,
    this.memory,
    this.error,
    this.recordingDuration = 0,
    this.isPolling = false,
  });

  /// Check if session is in progress
  bool get isActive => session != null && flowState != SessionFlowState.idle;

  /// Check if all required variables are completed
  bool get allVariablesCompleted {
    if (template == null) return false;

    final requiredVars = template!.variablesSchema
        .where((v) => v.required)
        .map((v) => v.name)
        .toSet();

    return requiredVars.every((name) {
      final varState = variables[name];
      return varState != null && varState.isCompleted;
    });
  }

  /// Get progress percentage (0.0 - 1.0)
  double get progress {
    if (template == null) return 0.0;

    final totalVars = template!.variablesSchema.length;
    if (totalVars == 0) return 1.0;

    final completedVars =
        variables.values.where((v) => v.isCompleted).length;

    return completedVars / totalVars;
  }

  /// Get current variable schema
  VariableSchema? get currentVariableSchema {
    if (currentVariable == null || template == null) return null;

    try {
      return template!.variablesSchema.firstWhere(
        (v) => v.name == currentVariable,
      );
    } catch (_) {
      return null;
    }
  }

  /// Copy with updated fields
  SessionState copyWith({
    SessionFlowState? flowState,
    PromptTemplateDetail? template,
    WhisperSession? session,
    Map<String, VariableState>? variables,
    String? currentVariable,
    IntentAnalysis? intent,
    EnhancementResult? enhancement,
    SessionMemory? memory,
    String? error,
    int? recordingDuration,
    bool? isPolling,
  }) {
    return SessionState(
      flowState: flowState ?? this.flowState,
      template: template ?? this.template,
      session: session ?? this.session,
      variables: variables ?? this.variables,
      currentVariable: currentVariable ?? this.currentVariable,
      intent: intent ?? this.intent,
      enhancement: enhancement ?? this.enhancement,
      memory: memory ?? this.memory,
      error: error ?? this.error,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      isPolling: isPolling ?? this.isPolling,
    );
  }

  /// Clear error
  SessionState clearError() {
    return copyWith(error: null);
  }

  @override
  String toString() =>
      'SessionState(flow: $flowState, session: ${session?.id}, progress: ${(progress * 100).toStringAsFixed(0)}%)';
}
