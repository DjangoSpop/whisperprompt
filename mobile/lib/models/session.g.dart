// GENERATED CODE - Stub file
part of 'session.dart';

VoiceInput _$VoiceInputFromJson(Map<String, dynamic> json) => VoiceInput(
      id: json['id'] as String,
      variableName: json['variable_name'] as String,
      audioDurationMs: json['audio_duration_ms'] as int,
      transcriptionStatus: json['transcription_status'] as String,
      transcribedText: json['transcribed_text'] as String?,
      celeryTaskId: json['celery_task_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] == null ? null : DateTime.parse(json['processed_at'] as String),
    );

Map<String, dynamic> _$VoiceInputToJson(VoiceInput instance) => <String, dynamic>{
      'id': instance.id,
      'variable_name': instance.variableName,
      'audio_duration_ms': instance.audioDurationMs,
      'transcription_status': instance.transcriptionStatus,
      'transcribed_text': instance.transcribedText,
      'celery_task_id': instance.celeryTaskId,
      'created_at': instance.createdAt.toIso8601String(),
      'processed_at': instance.processedAt?.toIso8601String(),
    };

WhisperSession _$WhisperSessionFromJson(Map<String, dynamic> json) => WhisperSession(
      id: json['id'] as String,
      template: json['template'] == null ? null : PromptTemplateDetail.fromJson(json['template'] as Map<String, dynamic>),
      status: json['status'] as String,
      variablesInput: json['variables_input'] as Map<String, dynamic>,
      variablesProcessed: json['variables_processed'] as Map<String, dynamic>,
      generatedPrompt: json['generated_prompt'] as String?,
      voiceInputs: (json['voice_inputs'] as List<dynamic>?)?.map((e) => VoiceInput.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$WhisperSessionToJson(WhisperSession instance) => <String, dynamic>{
      'id': instance.id,
      'template': instance.template?.toJson(),
      'status': instance.status,
      'variables_input': instance.variablesInput,
      'variables_processed': instance.variablesProcessed,
      'generated_prompt': instance.generatedPrompt,
      'voice_inputs': instance.voiceInputs?.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

SessionStatus _$SessionStatusFromJson(Map<String, dynamic> json) => SessionStatus(
      sessionId: json['session_id'] as String,
      status: json['status'] as String,
      variablesStatus: (json['variables_status'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, VariableStatus.fromJson(e as Map<String, dynamic>)),
      ),
      readyToGenerate: json['ready_to_generate'] as bool,
      templateName: json['template_name'] as String,
    );

Map<String, dynamic> _$SessionStatusToJson(SessionStatus instance) => <String, dynamic>{
      'session_id': instance.sessionId,
      'status': instance.status,
      'variables_status': instance.variablesStatus.map((k, e) => MapEntry(k, e.toJson())),
      'ready_to_generate': instance.readyToGenerate,
      'template_name': instance.templateName,
    };

VariableStatus _$VariableStatusFromJson(Map<String, dynamic> json) => VariableStatus(
      status: json['status'] as String,
      transcribedText: json['transcribed_text'] as String?,
      required: json['required'] as bool,
    );

Map<String, dynamic> _$VariableStatusToJson(VariableStatus instance) => <String, dynamic>{
      'status': instance.status,
      'transcribed_text': instance.transcribedText,
      'required': instance.required,
    };

GeneratePromptResponse _$GeneratePromptResponseFromJson(Map<String, dynamic> json) => GeneratePromptResponse(
      sessionId: json['session_id'] as String,
      status: json['status'] as String,
      prompt: json['prompt'] as String,
      variablesUsed: json['variables_used'] as Map<String, dynamic>,
      historyId: json['history_id'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GeneratePromptResponseToJson(GeneratePromptResponse instance) => <String, dynamic>{
      'session_id': instance.sessionId,
      'status': instance.status,
      'prompt': instance.prompt,
      'variables_used': instance.variablesUsed,
      'history_id': instance.historyId,
      'metadata': instance.metadata,
    };
