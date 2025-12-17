/// Prompt Enhancement Engine for AI Whisperer
///
/// Orchestrates multiple enhancement strategies to generate optimized
/// prompt variants from raw transcriptions.
///
/// Performance target: < 200ms for all variants

import 'dart:async';
import 'models/intent.dart';
import 'models/enhancement.dart';
import 'intent_detector.dart';
import 'strategies/base_strategy.dart';
import 'strategies/concise_strategy.dart';
import 'strategies/expert_strategy.dart';
import 'strategies/stepwise_strategy.dart';
import 'strategies/creative_strategy.dart';
import 'strategies/technical_strategy.dart';

/// Main prompt enhancement engine
class PromptEnhancer {
  /// Intent detector instance
  final IntentDetector _intentDetector;

  /// All available enhancement strategies
  final List<EnhancementStrategy> _strategies;

  PromptEnhancer({
    IntentDetector? intentDetector,
  })  : _intentDetector = intentDetector ?? IntentDetector(),
        _strategies = [
          ConciseStrategy(),
          ExpertStrategy(),
          StepwiseStrategy(),
          CreativeStrategy(),
          TechnicalStrategy(),
        ];

  /// Enhance a raw transcription into multiple optimized variants
  ///
  /// [rawText] - The original transcribed text
  /// [templateCategory] - Optional template category as hint for intent detection
  ///
  /// Returns [EnhancementResult] with all generated variants
  Future<EnhancementResult> enhance(
    String rawText, {
    String? templateCategory,
  }) async {
    final startTime = DateTime.now();

    // Step 1: Detect intent (synchronous, fast)
    final intent = _intentDetector.analyze(
      rawText,
      templateCategory: templateCategory,
    );

    // Step 2: Generate variants in parallel (all strategies run concurrently)
    final variantFutures = _strategies.map((strategy) async {
      return strategy.createVariant(rawText, intent);
    }).toList();

    final variants = await Future.wait(variantFutures);

    // Step 3: Rank variants by quality score
    variants.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));

    // Step 4: Select recommended variant (highest quality)
    final recommended = variants.first;

    // Calculate processing time
    final processingTime = DateTime.now().difference(startTime).inMilliseconds;

    return EnhancementResult(
      originalText: rawText,
      variants: variants,
      intent: intent,
      recommendedVariantId: recommended.id,
      processingTimeMs: processingTime,
    );
  }

  /// Regenerate with a specific strategy
  ///
  /// Useful for "make it shorter", "more technical" commands
  Future<PromptVariant> regenerateWithStrategy(
    String rawText,
    EnhancementStrategyType strategyType, {
    String? templateCategory,
  }) async {
    // Detect intent
    final intent = _intentDetector.analyze(
      rawText,
      templateCategory: templateCategory,
    );

    // Find the strategy
    final strategy = _strategies.firstWhere(
      (s) => s.strategyType == strategyType,
      orElse: () => _strategies.first,
    );

    // Generate variant
    return strategy.createVariant(rawText, intent);
  }

  /// Parse refinement command from user voice
  ///
  /// Examples: "make it shorter", "more technical", "add steps"
  ///
  /// Returns [RefinementCommand] with detected strategy
  RefinementCommand parseRefinementCommand(String command) {
    final lowerCommand = command.toLowerCase();

    EnhancementStrategyType? targetStrategy;
    double confidence = 0.0;

    // Check for strategy-specific keywords
    if (_matchesKeywords(
        lowerCommand, ['short', 'brief', 'concise', 'compress'])) {
      targetStrategy = EnhancementStrategyType.concise;
      confidence = 0.9;
    } else if (_matchesKeywords(
        lowerCommand, ['expert', 'professional', 'detailed', 'advanced'])) {
      targetStrategy = EnhancementStrategyType.expert;
      confidence = 0.9;
    } else if (_matchesKeywords(
        lowerCommand, ['step', 'guide', 'instructions', 'tutorial'])) {
      targetStrategy = EnhancementStrategyType.stepwise;
      confidence = 0.9;
    } else if (_matchesKeywords(
        lowerCommand, ['creative', 'innovative', 'unique', 'imaginative'])) {
      targetStrategy = EnhancementStrategyType.creative;
      confidence = 0.9;
    } else if (_matchesKeywords(lowerCommand,
        ['technical', 'precise', 'specification', 'requirement'])) {
      targetStrategy = EnhancementStrategyType.technical;
      confidence = 0.9;
    } else if (_matchesKeywords(lowerCommand, ['refine', 'improve', 'better'])) {
      // General refinement - will use recommended strategy
      confidence = 0.6;
    }

    return RefinementCommand(
      command: command,
      targetStrategy: targetStrategy,
      confidence: confidence,
    );
  }

  /// Check if command matches any keywords
  bool _matchesKeywords(String command, List<String> keywords) {
    for (final keyword in keywords) {
      if (command.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Get strategy by type
  EnhancementStrategy? getStrategy(EnhancementStrategyType type) {
    try {
      return _strategies.firstWhere((s) => s.strategyType == type);
    } catch (_) {
      return null;
    }
  }

  /// Get all available strategies
  List<EnhancementStrategy> get strategies => List.unmodifiable(_strategies);
}
