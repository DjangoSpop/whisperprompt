// GENERATED CODE - Stub file
part of 'history.dart';

PromptHistory _$PromptHistoryFromJson(Map<String, dynamic> json) => PromptHistory(
      id: json['id'] as String,
      templateName: json['template_name'] as String,
      templateCategory: json['template_category'] as String,
      promptPreview: json['prompt_preview'] as String,
      isFavorite: json['is_favorite'] as bool,
      copyCount: json['copy_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PromptHistoryToJson(PromptHistory instance) => <String, dynamic>{
      'id': instance.id,
      'template_name': instance.templateName,
      'template_category': instance.templateCategory,
      'prompt_preview': instance.promptPreview,
      'is_favorite': instance.isFavorite,
      'copy_count': instance.copyCount,
      'created_at': instance.createdAt.toIso8601String(),
    };

PromptHistoryDetail _$PromptHistoryDetailFromJson(Map<String, dynamic> json) => PromptHistoryDetail(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      templateName: json['template_name'] as String,
      templateCategory: json['template_category'] as String,
      fullPrompt: json['full_prompt'] as String,
      variablesUsed: json['variables_used'] as Map<String, dynamic>,
      isFavorite: json['is_favorite'] as bool,
      copyCount: json['copy_count'] as int,
      lastCopiedAt: json['last_copied_at'] == null ? null : DateTime.parse(json['last_copied_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PromptHistoryDetailToJson(PromptHistoryDetail instance) => <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'template_name': instance.templateName,
      'template_category': instance.templateCategory,
      'full_prompt': instance.fullPrompt,
      'variables_used': instance.variablesUsed,
      'is_favorite': instance.isFavorite,
      'copy_count': instance.copyCount,
      'last_copied_at': instance.lastCopiedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

HistoryStats _$HistoryStatsFromJson(Map<String, dynamic> json) => HistoryStats(
      totalPrompts: json['total_prompts'] as int,
      favorites: json['favorites'] as int,
      totalCopies: json['total_copies'] as int,
      byCategory: Map<String, int>.from(json['by_category'] as Map),
    );

Map<String, dynamic> _$HistoryStatsToJson(HistoryStats instance) => <String, dynamic>{
      'total_prompts': instance.totalPrompts,
      'favorites': instance.favorites,
      'total_copies': instance.totalCopies,
      'by_category': instance.byCategory,
    };
