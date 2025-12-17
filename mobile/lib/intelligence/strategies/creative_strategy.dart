/// Creative Enhancement Strategy
///
/// Adds imaginative, open-ended language and examples to
/// encourage innovative and expressive responses.

import '../models/intent.dart';
import '../models/enhancement.dart' show EnhancementStrategyType;
import 'base_strategy.dart';

class CreativeStrategy extends EnhancementStrategy {
  @override
  EnhancementStrategyType get strategyType => EnhancementStrategyType.creative;

  @override
  String get name => 'Creative';

  @override
  String get description => 'Imaginative and open-ended';

  @override
  String get iconName => 'lightbulb';

  /// Creative prefixes
  static const _creativePrefixes = [
    'Imagine',
    'Envision',
    'Explore innovative ways to',
    'Think creatively about',
    'Brainstorm unique approaches to',
  ];

  /// Creative suffixes
  static const _creativeSuffixes = [
    'Think outside the box and surprise me!',
    'Include unexpected angles and fresh perspectives.',
    'Feel free to be unconventional and original.',
    'Explore multiple creative possibilities.',
    'Don\'t hold back on imaginative ideas!',
  ];

  /// Enhancing words to add creativity
  static const _enhancingWords = {
    'create': 'craft an innovative',
    'make': 'design a unique',
    'write': 'compose an engaging',
    'develop': 'build a creative',
    'design': 'architect an imaginative',
    'build': 'construct an original',
  };

  @override
  String enhance(String rawText, IntentAnalysis intent) {
    var text = rawText.trim();

    // Add creative enhancing words
    for (final entry in _enhancingWords.entries) {
      final pattern = RegExp('\\b${entry.key}\\b', caseSensitive: false);
      if (text.toLowerCase().contains(entry.key)) {
        text = text.replaceAll(pattern, entry.value);
        break; // Only replace once to avoid over-complication
      }
    }

    // Ensure proper capitalization
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    // Add creative framing based on intent
    final enhanced = _addCreativeFraming(text, intent);

    return enhanced;
  }

  /// Add creative framing to the prompt
  String _addCreativeFraming(String text, IntentAnalysis intent) {
    // Select a random prefix and suffix (using hashCode for deterministic "randomness")
    final prefixIndex = text.hashCode % _creativePrefixes.length;
    final suffixIndex = (text.hashCode + 1) % _creativeSuffixes.length;

    final prefix = _creativePrefixes[prefixIndex];
    final suffix = _creativeSuffixes[suffixIndex];

    // Add intent-specific creative elements
    final intentContext = _getCreativeContext(intent);

    // Combine all parts
    final parts = <String>[
      prefix,
      text.toLowerCase().startsWith(prefix.toLowerCase())
          ? text.substring(prefix.length).trim()
          : text,
    ];

    if (intentContext.isNotEmpty) {
      parts.add(intentContext);
    }

    parts.add(suffix);

    return parts.join(' ');
  }

  /// Get creative context based on intent type
  String _getCreativeContext(IntentAnalysis intent) {
    switch (intent.intentType) {
      case IntentType.coding:
        return 'Explore elegant and innovative code solutions.';
      case IntentType.writing:
        return 'Use vivid language and compelling narratives.';
      case IntentType.business:
        return 'Consider disruptive and forward-thinking strategies.';
      case IntentType.marketing:
        return 'Develop attention-grabbing and memorable concepts.';
      case IntentType.education:
        return 'Make it engaging, memorable, and fun to learn.';
      case IntentType.general:
        return 'Think broadly and consider diverse perspectives.';
    }
  }
}
