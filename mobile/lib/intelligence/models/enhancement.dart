/// Prompt enhancement and variant generation models
///
/// This module defines the data structures for generating and managing
/// multiple optimized variants of user prompts.

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'intent.dart';

part 'enhancement.g.dart';

/// Strategy used to enhance a prompt
enum EnhancementStrategy {
  /// Remove filler words, compress to essentials
  @JsonValue('concise')
  concise,

  /// Add professional terminology, structure, context
  @JsonValue('expert')
  expert,

  /// Break into numbered sequential instructions
  @JsonValue('stepwise')
  stepwise,

  /// Add creative prompts, examples, open-ended language
  @JsonValue('creative')
  creative,

  /// Add precision requirements, constraints, format specs
  @JsonValue('technical')
  technical,
}

/// A single enhanced variant of a prompt
@JsonSerializable()
class PromptVariant {
  /// Unique identifier for this variant
  final String id;

  /// Strategy used to create this variant
  final EnhancementStrategy strategy;

  /// The enhanced prompt text
  final String text;

  /// Quality score (0-100, higher is better)
  final int qualityScore;

  /// Token count estimate
  final int estimatedTokens;

  /// What improvements were made
  final Map<String, dynamic> improvements;

  /// When this variant was created
  final DateTime createdAt;

  /// Whether this variant was selected by the user
  bool isSelected;

  PromptVariant({
    String? id,
    required this.strategy,
    required this.text,
    required this.qualityScore,
    required this.estimatedTokens,
    this.improvements = const {},
    DateTime? createdAt,
    this.isSelected = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory PromptVariant.fromJson(Map<String, dynamic> json) =>
      _$PromptVariantFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PromptVariantToJson(this);

  /// Get human-readable strategy name
  String get strategyName {
    switch (strategy) {
      case EnhancementStrategy.concise:
        return 'Concise';
      case EnhancementStrategy.expert:
        return 'Expert';
      case EnhancementStrategy.stepwise:
        return 'Step-by-Step';
      case EnhancementStrategy.creative:
        return 'Creative';
      case EnhancementStrategy.technical:
        return 'Technical';
    }
  }

  /// Get strategy description
  String get strategyDescription {
    switch (strategy) {
      case EnhancementStrategy.concise:
        return 'Brief and to the point';
      case EnhancementStrategy.expert:
        return 'Professional and detailed';
      case EnhancementStrategy.stepwise:
        return 'Clear sequential steps';
      case EnhancementStrategy.creative:
        return 'Imaginative and open-ended';
      case EnhancementStrategy.technical:
        return 'Precise with specifications';
    }
  }

  /// Create a copy with updated fields
  PromptVariant copyWith({
    String? id,
    EnhancementStrategy? strategy,
    String? text,
    int? qualityScore,
    int? estimatedTokens,
    Map<String, dynamic>? improvements,
    DateTime? createdAt,
    bool? isSelected,
  }) {
    return PromptVariant(
      id: id ?? this.id,
      strategy: strategy ?? this.strategy,
      text: text ?? this.text,
      qualityScore: qualityScore ?? this.qualityScore,
      estimatedTokens: estimatedTokens ?? this.estimatedTokens,
      improvements: improvements ?? this.improvements,
      createdAt: createdAt ?? this.createdAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() => 'PromptVariant($strategyName, score: $qualityScore, tokens: $estimatedTokens)';
}

/// Result of prompt enhancement containing all generated variants
@JsonSerializable()
class EnhancementResult {
  /// Original raw text before enhancement
  final String originalText;

  /// All generated variants
  final List<PromptVariant> variants;

  /// Intent analysis used for enhancement
  final IntentAnalysis intent;

  /// Recommended variant (highest quality score)
  final String recommendedVariantId;

  /// Processing time in milliseconds
  final int processingTimeMs;

  /// When this enhancement was performed
  final DateTime createdAt;

  EnhancementResult({
    required this.originalText,
    required this.variants,
    required this.intent,
    required this.recommendedVariantId,
    required this.processingTimeMs,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory EnhancementResult.fromJson(Map<String, dynamic> json) =>
      _$EnhancementResultFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$EnhancementResultToJson(this);

  /// Get the recommended variant
  PromptVariant get recommended {
    return variants.firstWhere(
      (v) => v.id == recommendedVariantId,
      orElse: () => variants.first,
    );
  }

  /// Get currently selected variant (or recommended if none selected)
  PromptVariant get selected {
    try {
      return variants.firstWhere((v) => v.isSelected);
    } catch (_) {
      return recommended;
    }
  }

  /// Select a variant by ID
  void selectVariant(String variantId) {
    for (var variant in variants) {
      variant.isSelected = variant.id == variantId;
    }
  }

  /// Get variant by strategy
  PromptVariant? getVariantByStrategy(EnhancementStrategy strategy) {
    try {
      return variants.firstWhere((v) => v.strategy == strategy);
    } catch (_) {
      return null;
    }
  }

  /// Create a copy with updated fields
  EnhancementResult copyWith({
    String? originalText,
    List<PromptVariant>? variants,
    IntentAnalysis? intent,
    String? recommendedVariantId,
    int? processingTimeMs,
    DateTime? createdAt,
  }) {
    return EnhancementResult(
      originalText: originalText ?? this.originalText,
      variants: variants ?? this.variants,
      intent: intent ?? this.intent,
      recommendedVariantId: recommendedVariantId ?? this.recommendedVariantId,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'EnhancementResult(${variants.length} variants, ${processingTimeMs}ms)';
}

/// Refinement command from user to modify enhancement
@JsonSerializable()
class RefinementCommand {
  /// Command text (e.g., "make it shorter", "more technical")
  final String command;

  /// Detected strategy from command
  final EnhancementStrategy? targetStrategy;

  /// Confidence of strategy detection (0.0 - 1.0)
  final double confidence;

  /// When this command was issued
  final DateTime timestamp;

  RefinementCommand({
    required this.command,
    this.targetStrategy,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create from JSON
  factory RefinementCommand.fromJson(Map<String, dynamic> json) =>
      _$RefinementCommandFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$RefinementCommandToJson(this);
}
