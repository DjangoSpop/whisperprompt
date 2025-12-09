import 'package:json_annotation/json_annotation.dart';

part 'history.g.dart';

@JsonSerializable()
class PromptHistory {
  final String id;
  @JsonKey(name: 'template_name')
  final String templateName;
  @JsonKey(name: 'template_category')
  final String templateCategory;
  @JsonKey(name: 'prompt_preview')
  final String promptPreview;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'copy_count')
  final int copyCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  PromptHistory({
    required this.id,
    required this.templateName,
    required this.templateCategory,
    required this.promptPreview,
    required this.isFavorite,
    required this.copyCount,
    required this.createdAt,
  });

  factory PromptHistory.fromJson(Map<String, dynamic> json) =>
      _$PromptHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PromptHistoryToJson(this);
}

@JsonSerializable()
class PromptHistoryDetail {
  final String id;
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'template_name')
  final String templateName;
  @JsonKey(name: 'template_category')
  final String templateCategory;
  @JsonKey(name: 'full_prompt')
  final String fullPrompt;
  @JsonKey(name: 'variables_used')
  final Map<String, dynamic> variablesUsed;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'copy_count')
  final int copyCount;
  @JsonKey(name: 'last_copied_at')
  final DateTime? lastCopiedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  PromptHistoryDetail({
    required this.id,
    required this.sessionId,
    required this.templateName,
    required this.templateCategory,
    required this.fullPrompt,
    required this.variablesUsed,
    required this.isFavorite,
    required this.copyCount,
    this.lastCopiedAt,
    required this.createdAt,
  });

  factory PromptHistoryDetail.fromJson(Map<String, dynamic> json) =>
      _$PromptHistoryDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PromptHistoryDetailToJson(this);
}

@JsonSerializable()
class HistoryStats {
  @JsonKey(name: 'total_prompts')
  final int totalPrompts;
  final int favorites;
  @JsonKey(name: 'total_copies')
  final int totalCopies;
  @JsonKey(name: 'by_category')
  final Map<String, int> byCategory;

  HistoryStats({
    required this.totalPrompts,
    required this.favorites,
    required this.totalCopies,
    required this.byCategory,
  });

  factory HistoryStats.fromJson(Map<String, dynamic> json) =>
      _$HistoryStatsFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryStatsToJson(this);
}
