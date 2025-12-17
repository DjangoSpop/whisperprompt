/// Expert Enhancement Strategy
///
/// Adds professional terminology, structure, and context to create
/// sophisticated, expert-level prompts.

import '../models/intent.dart';
import '../models/enhancement.dart' show EnhancementStrategyType;
import 'base_strategy.dart';

class ExpertStrategy extends EnhancementStrategy {
  @override
  EnhancementStrategyType get strategyType => EnhancementStrategyType.expert;

  @override
  String get name => 'Expert';

  @override
  String get description => 'Professional and detailed';

  @override
  String get iconName => 'school';

  /// Professional prefixes based on intent
  static const _intentPrefixes = {
    IntentType.coding: 'As an experienced software engineer,',
    IntentType.writing: 'As a professional writer and content strategist,',
    IntentType.business: 'From a strategic business perspective,',
    IntentType.education: 'With pedagogical expertise,',
    IntentType.marketing: 'Using data-driven marketing principles,',
    IntentType.general: 'With careful consideration,',
  };

  /// Professional suffixes based on output type
  static const _outputSuffixes = {
    OutputType.code: 'Include best practices, error handling, and code comments.',
    OutputType.explanation: 'Provide comprehensive analysis with examples.',
    OutputType.steps: 'Break down into clear, actionable steps with rationale.',
    OutputType.summary: 'Highlight key insights and implications.',
    OutputType.list: 'Organize systematically with clear categories.',
    OutputType.document: 'Structure formally with appropriate sections.',
  };

  /// Casual to professional word replacements
  static const _professionalReplacements = {
    'get': 'obtain',
    'make': 'create',
    'fix': 'resolve',
    'check': 'verify',
    'look at': 'examine',
    'find out': 'determine',
    'use': 'utilize',
    'help': 'assist',
    'show': 'demonstrate',
    'tell': 'inform',
    'ask': 'inquire',
    'need': 'require',
    'want': 'desire',
    'big': 'significant',
    'small': 'minor',
    'good': 'effective',
    'bad': 'ineffective',
  };

  @override
  String enhance(String rawText, IntentAnalysis intent) {
    var text = rawText.trim();

    // Add professional prefix based on intent
    final prefix = _intentPrefixes[intent.intentType] ?? '';

    // Replace casual language with professional terminology
    for (final entry in _professionalReplacements.entries) {
      final pattern = RegExp('\\b${entry.key}\\b', caseSensitive: false);
      text = text.replaceAll(pattern, entry.value);
    }

    // Ensure proper capitalization
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    // Add context and framing
    final contextualPrompt = _addContextualFraming(text, intent);

    // Add professional suffix based on output type
    final suffix = _outputSuffixes[intent.outputType] ?? '';

    // Combine all parts
    final parts = <String>[];
    if (prefix.isNotEmpty) parts.add(prefix);
    parts.add(contextualPrompt);
    if (suffix.isNotEmpty) parts.add(suffix);

    var enhanced = parts.join(' ');

    // Clean up spacing
    enhanced = enhanced.replaceAll(RegExp(r'\s+'), ' ').trim();

    return enhanced;
  }

  /// Add contextual framing based on intent and tone
  String _addContextualFraming(String text, IntentAnalysis intent) {
    // For technical content, add specification language
    if (intent.tone == Tone.technical) {
      return 'provide a detailed technical specification for: $text';
    }

    // For urgent content, add priority language
    if (intent.tone == Tone.urgent) {
      return 'prioritize and address immediately: $text';
    }

    // For creative content, add innovation language
    if (intent.tone == Tone.creative) {
      return 'develop an innovative approach to: $text';
    }

    // For formal content, add professional framing
    if (intent.tone == Tone.formal) {
      return 'professionally address the following matter: $text';
    }

    // Default: clear and structured
    return 'comprehensively address: $text';
  }
}
