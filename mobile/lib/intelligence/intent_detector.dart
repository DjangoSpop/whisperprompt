/// Intent Detection Engine for AI Whisperer
///
/// Analyzes voice transcriptions to detect user intent, tone, and expected output type.
/// Uses keyword-based pattern matching for speed and determinism.
/// Easily replaceable with LLM-based classification in the future.

import 'models/intent.dart';

/// Intent detection engine
class IntentDetector {
  /// Keyword patterns for each intent type
  static const Map<IntentType, List<String>> _intentKeywords = {
    IntentType.coding: [
      'code',
      'function',
      'script',
      'program',
      'bug',
      'debug',
      'api',
      'database',
      'algorithm',
      'implement',
      'refactor',
      'class',
      'method',
      'variable',
      'syntax',
      'compile',
      'error',
      'exception',
      'test',
      'unit test',
      'programming',
      'developer',
      'software',
      'app',
      'application',
      'website',
      'web',
      'mobile',
      'frontend',
      'backend',
      'fullstack',
      'react',
      'flutter',
      'python',
      'javascript',
      'java',
      'typescript',
    ],
    IntentType.writing: [
      'write',
      'article',
      'blog',
      'post',
      'essay',
      'story',
      'content',
      'copy',
      'draft',
      'edit',
      'paragraph',
      'sentence',
      'document',
      'paper',
      'thesis',
      'report',
      'description',
      'summary',
      'review',
      'critique',
      'author',
      'writer',
      'publish',
      'editorial',
    ],
    IntentType.business: [
      'business',
      'meeting',
      'presentation',
      'proposal',
      'contract',
      'agreement',
      'invoice',
      'quote',
      'memo',
      'corporate',
      'professional',
      'client',
      'customer',
      'stakeholder',
      'executive',
      'manager',
      'team',
      'project',
      'strategy',
      'analysis',
      'kpi',
      'roi',
      'revenue',
      'profit',
      'budget',
      'forecast',
    ],
    IntentType.education: [
      'learn',
      'teach',
      'explain',
      'understand',
      'lesson',
      'tutorial',
      'course',
      'study',
      'student',
      'teacher',
      'professor',
      'education',
      'academic',
      'school',
      'university',
      'college',
      'class',
      'lecture',
      'assignment',
      'homework',
      'exam',
      'quiz',
      'grade',
      'curriculum',
    ],
    IntentType.marketing: [
      'marketing',
      'campaign',
      'advertisement',
      'ad',
      'promotion',
      'social media',
      'instagram',
      'facebook',
      'twitter',
      'linkedin',
      'brand',
      'branding',
      'audience',
      'engagement',
      'conversion',
      'funnel',
      'seo',
      'content strategy',
      'copywriting',
      'email campaign',
      'newsletter',
      'landing page',
    ],
  };

  /// Keyword patterns for tone detection
  static const Map<Tone, List<String>> _toneKeywords = {
    Tone.formal: [
      'professional',
      'formal',
      'corporate',
      'official',
      'business',
      'respectful',
      'polite',
      'proper',
      'appropriate',
      'sir',
      'madam',
      'executive',
      'board',
      'stakeholder',
    ],
    Tone.casual: [
      'casual',
      'friendly',
      'informal',
      'relaxed',
      'conversational',
      'chat',
      'hey',
      'hi',
      'cool',
      'awesome',
      'great',
    ],
    Tone.urgent: [
      'urgent',
      'asap',
      'immediately',
      'emergency',
      'critical',
      'important',
      'deadline',
      'quickly',
      'fast',
      'now',
      'rush',
      'priority',
    ],
    Tone.creative: [
      'creative',
      'imaginative',
      'innovative',
      'unique',
      'original',
      'artistic',
      'expressive',
      'inspiring',
      'idea',
      'brainstorm',
      'concept',
    ],
    Tone.technical: [
      'technical',
      'precise',
      'detailed',
      'specific',
      'accurate',
      'specification',
      'requirement',
      'criteria',
      'parameter',
      'configuration',
    ],
  };

  /// Keyword patterns for output type detection
  static const Map<OutputType, List<String>> _outputKeywords = {
    OutputType.code: [
      'code',
      'script',
      'function',
      'snippet',
      'implementation',
      'program',
    ],
    OutputType.explanation: [
      'explain',
      'describe',
      'elaborate',
      'detail',
      'clarify',
      'why',
      'how',
      'what',
    ],
    OutputType.steps: [
      'steps',
      'guide',
      'tutorial',
      'instructions',
      'procedure',
      'how to',
      'walkthrough',
      'process',
    ],
    OutputType.summary: [
      'summary',
      'brief',
      'overview',
      'tldr',
      'short',
      'concise',
      'key points',
    ],
    OutputType.list: [
      'list',
      'bullet',
      'points',
      'items',
      'enumerate',
      'numbered',
    ],
    OutputType.document: [
      'document',
      'report',
      'paper',
      'memo',
      'letter',
      'email',
    ],
  };

  /// Analyze intent from transcribed text
  ///
  /// [text] - The transcribed user input
  /// [templateCategory] - Optional template category as hint
  ///
  /// Returns an [IntentAnalysis] with detected intent, tone, and output type
  IntentAnalysis analyze(String text, {String? templateCategory}) {
    final lowercaseText = text.toLowerCase();

    // Detect intent type
    final intentResult = _detectIntent(lowercaseText, templateCategory);

    // Detect tone
    final toneResult = _detectTone(lowercaseText);

    // Detect output type
    final outputResult = _detectOutputType(lowercaseText);

    // Compute overall confidence (average of all detections)
    final confidence = (intentResult.confidence +
            toneResult.confidence +
            outputResult.confidence) /
        3;

    return IntentAnalysis(
      intentType: intentResult.intent,
      tone: toneResult.tone,
      outputType: outputResult.outputType,
      confidence: confidence,
      keywords: [
        ...intentResult.keywords,
        ...toneResult.keywords,
        ...outputResult.keywords,
      ],
      metadata: {
        'text_length': text.length,
        'template_category': templateCategory,
        'detection_method': 'keyword_matching',
      },
    );
  }

  /// Detect intent type from text
  _IntentDetectionResult _detectIntent(
      String text, String? templateCategory) {
    // Use template category as strong hint
    if (templateCategory != null) {
      final categoryLower = templateCategory.toLowerCase();
      if (categoryLower.contains('code') || categoryLower.contains('dev')) {
        return _IntentDetectionResult(
          IntentType.coding,
          0.9,
          ['template:$templateCategory'],
        );
      } else if (categoryLower.contains('write') ||
          categoryLower.contains('content')) {
        return _IntentDetectionResult(
          IntentType.writing,
          0.9,
          ['template:$templateCategory'],
        );
      } else if (categoryLower.contains('business')) {
        return _IntentDetectionResult(
          IntentType.business,
          0.9,
          ['template:$templateCategory'],
        );
      }
    }

    // Score each intent type
    final scores = <IntentType, double>{};
    final matchedKeywords = <IntentType, List<String>>{};

    for (final entry in _intentKeywords.entries) {
      final intentType = entry.key;
      final keywords = entry.value;

      int matches = 0;
      final matched = <String>[];

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matches++;
          matched.add(keyword);
        }
      }

      scores[intentType] = matches / keywords.length;
      matchedKeywords[intentType] = matched;
    }

    // Find highest scoring intent
    IntentType bestIntent = IntentType.general;
    double bestScore = 0.0;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestIntent = entry.key;
      }
    }

    // If no clear winner, default to general
    if (bestScore < 0.05) {
      return _IntentDetectionResult(IntentType.general, 0.5, []);
    }

    return _IntentDetectionResult(
      bestIntent,
      (bestScore * 10).clamp(0.0, 1.0),
      matchedKeywords[bestIntent] ?? [],
    );
  }

  /// Detect tone from text
  _ToneDetectionResult _detectTone(String text) {
    final scores = <Tone, double>{};
    final matchedKeywords = <Tone, List<String>>{};

    for (final entry in _toneKeywords.entries) {
      final tone = entry.key;
      final keywords = entry.value;

      int matches = 0;
      final matched = <String>[];

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matches++;
          matched.add(keyword);
        }
      }

      scores[tone] = matches / keywords.length;
      matchedKeywords[tone] = matched;
    }

    // Find highest scoring tone
    Tone bestTone = Tone.formal; // Default to formal
    double bestScore = 0.0;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestTone = entry.key;
      }
    }

    // Check for exclamation marks or all caps (urgency indicators)
    if (text.contains('!') || text == text.toUpperCase()) {
      bestTone = Tone.urgent;
      bestScore = 0.8;
    }

    return _ToneDetectionResult(
      bestTone,
      (bestScore * 10).clamp(0.3, 1.0), // Min 0.3 confidence for tone
      matchedKeywords[bestTone] ?? [],
    );
  }

  /// Detect output type from text
  _OutputDetectionResult _detectOutputType(String text) {
    final scores = <OutputType, double>{};
    final matchedKeywords = <OutputType, List<String>>{};

    for (final entry in _outputKeywords.entries) {
      final outputType = entry.key;
      final keywords = entry.value;

      int matches = 0;
      final matched = <String>[];

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matches++;
          matched.add(keyword);
        }
      }

      scores[outputType] = matches / keywords.length;
      matchedKeywords[outputType] = matched;
    }

    // Find highest scoring output type
    OutputType bestOutput = OutputType.explanation; // Default
    double bestScore = 0.0;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestOutput = entry.key;
      }
    }

    return _OutputDetectionResult(
      bestOutput,
      (bestScore * 10).clamp(0.3, 1.0), // Min 0.3 confidence
      matchedKeywords[bestOutput] ?? [],
    );
  }
}

/// Internal result classes for detection
class _IntentDetectionResult {
  final IntentType intent;
  final double confidence;
  final List<String> keywords;

  _IntentDetectionResult(this.intent, this.confidence, this.keywords);
}

class _ToneDetectionResult {
  final Tone tone;
  final double confidence;
  final List<String> keywords;

  _ToneDetectionResult(this.tone, this.confidence, this.keywords);
}

class _OutputDetectionResult {
  final OutputType outputType;
  final double confidence;
  final List<String> keywords;

  _OutputDetectionResult(this.outputType, this.confidence, this.keywords);
}
