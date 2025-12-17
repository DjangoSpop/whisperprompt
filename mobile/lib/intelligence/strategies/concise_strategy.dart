/// Concise Enhancement Strategy
///
/// Removes filler words, compresses to essentials, and creates
/// brief, to-the-point prompts.

import '../models/intent.dart';
import '../models/enhancement.dart' show EnhancementStrategyType;
import 'base_strategy.dart';

class ConciseStrategy extends EnhancementStrategy {
  @override
  EnhancementStrategyType get strategyType => EnhancementStrategyType.concise;

  @override
  String get name => 'Concise';

  @override
  String get description => 'Brief and to the point';

  @override
  String get iconName => 'compress';

  /// Filler words to remove
  static const _fillerWords = [
    'um',
    'uh',
    'like',
    'you know',
    'sort of',
    'kind of',
    'i mean',
    'basically',
    'actually',
    'literally',
    'so',
    'well',
    'just',
    'maybe',
    'perhaps',
  ];

  /// Verbose phrases and their concise replacements
  static const _verboseReplacements = {
    'i would like to': 'want to',
    'i am going to': 'will',
    'i need to': 'need',
    'can you please': 'please',
    'would you be able to': 'can you',
    'in order to': 'to',
    'due to the fact that': 'because',
    'at this point in time': 'now',
    'for the purpose of': 'for',
    'in the event that': 'if',
    'with regard to': 'about',
    'a number of': 'several',
    'make a decision': 'decide',
    'come to a conclusion': 'conclude',
  };

  @override
  String enhance(String rawText, IntentAnalysis intent) {
    var text = rawText;

    // Remove leading/trailing whitespace
    text = text.trim();

    // Convert to lowercase for processing
    var lowerText = text.toLowerCase();

    // Remove filler words
    for (final filler in _fillerWords) {
      final pattern = RegExp('\\b$filler\\b', caseSensitive: false);
      text = text.replaceAll(pattern, '');
    }

    // Replace verbose phrases
    for (final entry in _verboseReplacements.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    // Remove redundant words (duplicate words)
    text = _removeDuplicateWords(text);

    // Remove extra spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Ensure starts with capital
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    // Ensure ends with period if it doesn't have punctuation
    if (text.isNotEmpty &&
        !text.endsWith('.') &&
        !text.endsWith('?') &&
        !text.endsWith('!')) {
      text += '.';
    }

    // If text is too short after compression, use original with minimal cleanup
    if (text.length < 10 && rawText.length > 20) {
      return _minimalCleanup(rawText);
    }

    return text;
  }

  /// Remove duplicate consecutive words
  String _removeDuplicateWords(String text) {
    final words = text.split(' ');
    final result = <String>[];

    for (int i = 0; i < words.length; i++) {
      if (i == 0 || words[i].toLowerCase() != words[i - 1].toLowerCase()) {
        result.add(words[i]);
      }
    }

    return result.join(' ');
  }

  /// Minimal cleanup without aggressive compression
  String _minimalCleanup(String text) {
    var cleaned = text.trim();

    // Remove obvious filler words only
    for (final filler in ['um', 'uh', 'like']) {
      final pattern = RegExp('\\b$filler\\b', caseSensitive: false);
      cleaned = cleaned.replaceAll(pattern, '');
    }

    // Clean up spacing
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Capitalize first letter
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    // Add period if needed
    if (cleaned.isNotEmpty &&
        !cleaned.endsWith('.') &&
        !cleaned.endsWith('?') &&
        !cleaned.endsWith('!')) {
      cleaned += '.';
    }

    return cleaned;
  }
}
