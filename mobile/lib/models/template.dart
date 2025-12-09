import 'package:json_annotation/json_annotation.dart';

part 'template.g.dart';

@JsonSerializable()
class TemplateCategory {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String description;
  final int order;
  @JsonKey(name: 'template_count')
  final int? templateCount;

  TemplateCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.description,
    required this.order,
    this.templateCount,
  });

  factory TemplateCategory.fromJson(Map<String, dynamic> json) =>
      _$TemplateCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateCategoryToJson(this);
}

@JsonSerializable()
class VariableSchema {
  final String name;
  final String type;
  final bool required;
  @JsonKey(name: 'voice_hint')
  final String voiceHint;
  final List<String>? options;
  final dynamic defaultValue;
  final List<String>? examples;

  VariableSchema({
    required this.name,
    required this.type,
    required this.required,
    required this.voiceHint,
    this.options,
    this.defaultValue,
    this.examples,
  });

  factory VariableSchema.fromJson(Map<String, dynamic> json) =>
      _$VariableSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$VariableSchemaToJson(this);

  bool get isChoice => type == 'choice';
  bool get isText => type == 'text';
  bool get isBoolean => type == 'boolean';
}

@JsonSerializable()
class PromptTemplate {
  final String id;
  final String name;
  final String slug;
  final String description;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'usage_count')
  final int usageCount;
  @JsonKey(name: 'estimated_tokens')
  final int estimatedTokens;

  PromptTemplate({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.categoryName,
    required this.isPremium,
    required this.usageCount,
    required this.estimatedTokens,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) =>
      _$PromptTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$PromptTemplateToJson(this);
}

@JsonSerializable()
class PromptTemplateDetail {
  final String id;
  final String name;
  final String slug;
  final String description;
  final TemplateCategory category;
  @JsonKey(name: 'user_prompt_display')
  final String userPromptDisplay;
  @JsonKey(name: 'variables_schema')
  final List<VariableSchema> variablesSchema;
  @JsonKey(name: 'estimated_tokens')
  final int estimatedTokens;
  @JsonKey(name: 'best_for')
  final List<String> bestFor;
  final List<String> tags;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'usage_count')
  final int usageCount;

  PromptTemplateDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.userPromptDisplay,
    required this.variablesSchema,
    required this.estimatedTokens,
    required this.bestFor,
    required this.tags,
    required this.isPremium,
    required this.usageCount,
  });

  factory PromptTemplateDetail.fromJson(Map<String, dynamic> json) =>
      _$PromptTemplateDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PromptTemplateDetailToJson(this);

  List<VariableSchema> get requiredVariables =>
      variablesSchema.where((v) => v.required).toList();

  List<VariableSchema> get optionalVariables =>
      variablesSchema.where((v) => !v.required).toList();
}
