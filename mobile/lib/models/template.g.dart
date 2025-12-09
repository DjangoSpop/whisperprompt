// GENERATED CODE - This is a stub file
// Run: flutter pub run build_runner build

part of 'template.dart';

TemplateCategory _$TemplateCategoryFromJson(Map<String, dynamic> json) => TemplateCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      templateCount: json['template_count'] as int?,
    );

Map<String, dynamic> _$TemplateCategoryToJson(TemplateCategory instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'icon': instance.icon,
      'description': instance.description,
      'order': instance.order,
      'template_count': instance.templateCount,
    };

VariableSchema _$VariableSchemaFromJson(Map<String, dynamic> json) => VariableSchema(
      name: json['name'] as String,
      type: json['type'] as String,
      required: json['required'] as bool,
      voiceHint: json['voice_hint'] as String,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      defaultValue: json['default'],
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$VariableSchemaToJson(VariableSchema instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'required': instance.required,
      'voice_hint': instance.voiceHint,
      'options': instance.options,
      'default': instance.defaultValue,
      'examples': instance.examples,
    };

PromptTemplate _$PromptTemplateFromJson(Map<String, dynamic> json) => PromptTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      categoryName: json['category_name'] as String?,
      isPremium: json['is_premium'] as bool,
      usageCount: json['usage_count'] as int,
      estimatedTokens: json['estimated_tokens'] as int,
    );

Map<String, dynamic> _$PromptTemplateToJson(PromptTemplate instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category_name': instance.categoryName,
      'is_premium': instance.isPremium,
      'usage_count': instance.usageCount,
      'estimated_tokens': instance.estimatedTokens,
    };

PromptTemplateDetail _$PromptTemplateDetailFromJson(Map<String, dynamic> json) => PromptTemplateDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      category: TemplateCategory.fromJson(json['category'] as Map<String, dynamic>),
      userPromptDisplay: json['user_prompt_display'] as String,
      variablesSchema: (json['variables_schema'] as List<dynamic>)
          .map((e) => VariableSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedTokens: json['estimated_tokens'] as int,
      bestFor: (json['best_for'] as List<dynamic>).map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isPremium: json['is_premium'] as bool,
      usageCount: json['usage_count'] as int,
    );

Map<String, dynamic> _$PromptTemplateDetailToJson(PromptTemplateDetail instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category': instance.category.toJson(),
      'user_prompt_display': instance.userPromptDisplay,
      'variables_schema': instance.variablesSchema.map((e) => e.toJson()).toList(),
      'estimated_tokens': instance.estimatedTokens,
      'best_for': instance.bestFor,
      'tags': instance.tags,
      'is_premium': instance.isPremium,
      'usage_count': instance.usageCount,
    };
