/// Base interface for prompt enhancement strategies
///
/// All enhancement strategies must implement this interface to ensure
/// consistent behavior and easy extensibility.

import '../models/intent.dart';
import '../models/enhancement.dart';

/// Abstract base class for all enhancement strategies
abstract class EnhancementStrategy {
  /// Strategy type from enum
  EnhancementStrategyType get strategyType;

  /// Human-readable name for this strategy
  String get name;

  /// Description of what this strategy does
  String get description;

  /// Icon name for UI display
  String get iconName;

  /// Enhance a raw prompt text
  ///
  /// [rawText] - The original transcribed text
  /// [intent] - Detected intent analysis
  ///
  /// Returns enhanced prompt text
  String enhance(String rawText, IntentAnalysis intent);

  /// Compute quality score for the enhanced text
  ///
  /// [original] - Original text
  /// [enhanced] - Enhanced text
  /// [intent] - Intent analysis
  ///
  /// Returns quality score (0-100)
  int computeQualityScore(
      String original, String enhanced, IntentAnalysis intent) {
    int score = 50; // Base score

    // Reward for appropriate length
    final lengthRatio = enhanced.length / original.length;
    if (lengthRatio >= 0.8 && lengthRatio <= 1.5) {
      score += 10;
    }

    // Reward for proper grammar indicators (capitalization, punctuation)
    if (enhanced.isNotEmpty && enhanced[0] == enhanced[0].toUpperCase()) {
      score += 5;
    }
    if (enhanced.endsWith('.') ||
        enhanced.endsWith('?') ||
        enhanced.endsWith('!')) {
      score += 5;
    }

    // Reward for removing filler words
    final fillerWords = ['um', 'uh', 'like', 'you know', 'sort of', 'kind of'];
    bool hasFewer = true;
    for (final filler in fillerWords) {
      if (enhanced.toLowerCase().contains(filler)) {
        hasFewer = false;
        break;
      }
    }
    if (hasFewer) score += 10;

    // Reward for clarity (shorter sentences are clearer)
    final sentences = enhanced.split(RegExp(r'[.!?]')).where((s) => s.trim().isNotEmpty);
    if (sentences.length > 0) {
      final avgLength = enhanced.length / sentences.length;
      if (avgLength < 50) score += 10; // Concise sentences
    }

    // Cap at 100
    return score.clamp(0, 100);
  }

  /// Estimate token count (rough approximation)
  int estimateTokens(String text) {
    // Rough estimate: ~1 token per 4 characters for English
    return (text.length / 4).ceil();
  }

  /// Track improvements made
  Map<String, dynamic> trackImprovements(String original, String enhanced) {
    return {
      'original_length': original.length,
      'enhanced_length': enhanced.length,
      'length_diff': enhanced.length - original.length,
      'original_words': original.split(' ').length,
      'enhanced_words': enhanced.split(' ').length,
      'strategy': name,
    };
  }

  /// Create a PromptVariant from enhanced text
  PromptVariant createVariant(
    String rawText,
    IntentAnalysis intent, {
    bool isSelected = false,
  }) {
    final enhanced = enhance(rawText, intent);
    final quality = computeQualityScore(rawText, enhanced, intent);
    final tokens = estimateTokens(enhanced);
    final improvements = trackImprovements(rawText, enhanced);

    return PromptVariant(
      strategy: strategyType,
      text: enhanced,
      qualityScore: quality,
      estimatedTokens: tokens,
      improvements: improvements,
      isSelected: isSelected,
    );
  }
}
