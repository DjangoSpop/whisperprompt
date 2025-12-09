import 'package:json_annotation/json_annotation.dart';
import 'template.dart';

part 'session.g.dart';

@JsonSerializable()
class VoiceInput {
  final String id;
  @JsonKey(name: 'variable_name')
  final String variableName;
  @JsonKey(name: 'audio_duration_ms')
  final int audioDurationMs;
  @JsonKey(name: 'transcription_status')
  final String transcriptionStatus;
  @JsonKey(name: 'transcribed_text')
  final String? transcribedText;
  @JsonKey(name: 'celery_task_id')
  final String? celeryTaskId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;

  VoiceInput({
    required this.id,
    required this.variableName,
    required this.audioDurationMs,
    required this.transcriptionStatus,
    this.transcribedText,
    this.celeryTaskId,
    required this.createdAt,
    this.processedAt,
  });

  factory VoiceInput.fromJson(Map<String, dynamic> json) =>
      _$VoiceInputFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceInputToJson(this);

  bool get isPending => transcriptionStatus == 'pending';
  bool get isProcessing => transcriptionStatus == 'processing';
  bool get isCompleted => transcriptionStatus == 'completed';
  bool get isFailed => transcriptionStatus == 'failed';
}

@JsonSerializable()
class WhisperSession {
  final String id;
  final PromptTemplateDetail? template;
  final String status;
  @JsonKey(name: 'variables_input')
  final Map<String, dynamic> variablesInput;
  @JsonKey(name: 'variables_processed')
  final Map<String, dynamic> variablesProcessed;
  @JsonKey(name: 'generated_prompt')
  final String? generatedPrompt;
  @JsonKey(name: 'voice_inputs')
  final List<VoiceInput>? voiceInputs;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  WhisperSession({
    required this.id,
    this.template,
    required this.status,
    required this.variablesInput,
    required this.variablesProcessed,
    this.generatedPrompt,
    this.voiceInputs,
    required this.createdAt,
    this.completedAt,
  });

  factory WhisperSession.fromJson(Map<String, dynamic> json) =>
      _$WhisperSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WhisperSessionToJson(this);

  bool get isStarted => status == 'started';
  bool get isCollectingVariables => status == 'variables_collecting';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

@JsonSerializable()
class SessionStatus {
  @JsonKey(name: 'session_id')
  final String sessionId;
  final String status;
  @JsonKey(name: 'variables_status')
  final Map<String, VariableStatus> variablesStatus;
  @JsonKey(name: 'ready_to_generate')
  final bool readyToGenerate;
  @JsonKey(name: 'template_name')
  final String templateName;

  SessionStatus({
    required this.sessionId,
    required this.status,
    required this.variablesStatus,
    required this.readyToGenerate,
    required this.templateName,
  });

  factory SessionStatus.fromJson(Map<String, dynamic> json) =>
      _$SessionStatusFromJson(json);
  Map<String, dynamic> toJson() => _$SessionStatusToJson(this);
}

@JsonSerializable()
class VariableStatus {
  final String status;
  @JsonKey(name: 'transcribed_text')
  final String? transcribedText;
  final bool required;

  VariableStatus({
    required this.status,
    this.transcribedText,
    required this.required,
  });

  factory VariableStatus.fromJson(Map<String, dynamic> json) =>
      _$VariableStatusFromJson(json);
  Map<String, dynamic> toJson() => _$VariableStatusToJson(this);
}

@JsonSerializable()
class GeneratePromptResponse {
  @JsonKey(name: 'session_id')
  final String sessionId;
  final String status;
  final String prompt;
  @JsonKey(name: 'variables_used')
  final Map<String, dynamic> variablesUsed;
  @JsonKey(name: 'history_id')
  final String historyId;
  final Map<String, dynamic> metadata;

  GeneratePromptResponse({
    required this.sessionId,
    required this.status,
    required this.prompt,
    required this.variablesUsed,
    required this.historyId,
    required this.metadata,
  });

  factory GeneratePromptResponse.fromJson(Map<String, dynamic> json) =>
      _$GeneratePromptResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratePromptResponseToJson(this);
}
