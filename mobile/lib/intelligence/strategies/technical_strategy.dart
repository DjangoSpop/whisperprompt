/// Technical Enhancement Strategy
///
/// Adds precision requirements, constraints, format specifications,
/// and technical details for accurate, specification-driven responses.

import '../models/intent.dart';
import '../models/enhancement.dart' show EnhancementStrategyType;
import 'base_strategy.dart';

class TechnicalStrategy extends EnhancementStrategy {
  @override
  EnhancementStrategyType get strategyType => EnhancementStrategyType.technical;

  @override
  String get name => 'Technical';

  @override
  String get description => 'Precise with specifications';

  @override
  String get iconName => 'engineering';

  /// Technical requirement prefixes
  static const _requirementPrefixes = [
    'Specifications:',
    'Requirements:',
    'Technical Details:',
    'Implementation Requirements:',
  ];

  /// Technical aspects to emphasize
  static const _technicalAspects = [
    'Include specific technical details and specifications',
    'Define clear input and output requirements',
    'Specify edge cases and error conditions',
    'Include performance and scalability considerations',
    'Provide technical constraints and assumptions',
  ];

  @override
  String enhance(String rawText, IntentAnalysis intent) {
    var text = rawText.trim();

    // Ensure proper capitalization
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    // Build technical specification structure
    final enhanced = _buildTechnicalSpec(text, intent);

    return enhanced;
  }

  /// Build a technical specification structure
  String _buildTechnicalSpec(String text, IntentAnalysis intent) {
    final buffer = StringBuffer();

    // Main requirement
    buffer.writeln(text);
    buffer.writeln();

    // Add technical requirements section
    final prefixIndex = text.hashCode % _requirementPrefixes.length;
    buffer.writeln(_requirementPrefixes[prefixIndex]);

    // Add intent-specific technical requirements
    final requirements = _getIntentSpecificRequirements(intent);
    for (int i = 0; i < requirements.length; i++) {
      buffer.writeln('${i + 1}. ${requirements[i]}');
    }

    // Add output format specification
    buffer.writeln();
    buffer.writeln('Output Format:');
    buffer.writeln(_getOutputFormat(intent.outputType));

    // Add quality criteria
    buffer.writeln();
    buffer.writeln('Quality Criteria:');
    buffer.writeln('- Accuracy and correctness');
    buffer.writeln('- Completeness of solution');
    buffer.writeln('- Clear documentation');
    buffer.writeln('- Adherence to best practices');

    return buffer.toString().trim();
  }

  /// Get intent-specific technical requirements
  List<String> _getIntentSpecificRequirements(IntentAnalysis intent) {
    switch (intent.intentType) {
      case IntentType.coding:
        return [
          'Use appropriate data structures and algorithms',
          'Include type annotations and error handling',
          'Follow language-specific best practices',
          'Optimize for performance and readability',
          'Include unit tests or test cases',
        ];

      case IntentType.writing:
        return [
          'Define target audience and tone',
          'Specify word count or length requirements',
          'Include SEO keywords if applicable',
          'Define structure (intro, body, conclusion)',
          'Specify formatting requirements',
        ];

      case IntentType.business:
        return [
          'Include data-driven insights and metrics',
          'Define success criteria and KPIs',
          'Consider stakeholder perspectives',
          'Provide actionable recommendations',
          'Include risk assessment',
        ];

      case IntentType.education:
        return [
          'Define learning objectives clearly',
          'Specify difficulty level and prerequisites',
          'Include examples and exercises',
          'Provide assessment criteria',
          'Consider various learning styles',
        ];

      case IntentType.marketing:
        return [
          'Define target demographics',
          'Specify channels and mediums',
          'Include call-to-action requirements',
          'Define brand voice and guidelines',
          'Specify success metrics (CTR, conversions)',
        ];

      case IntentType.general:
        return [
          'Provide clear context and background',
          'Define scope and boundaries',
          'Specify level of detail required',
          'Include relevant constraints',
          'Define expected deliverables',
        ];
    }
  }

  /// Get output format based on output type
  String _getOutputFormat(OutputType outputType) {
    switch (outputType) {
      case OutputType.code:
        return '''- Language: [Specify programming language]
- Include: Code with comments, usage examples
- Structure: Functions, classes, modules as appropriate''';

      case OutputType.explanation:
        return '''- Structure: Introduction, body, conclusion
- Include: Definitions, examples, diagrams
- Length: Comprehensive but focused''';

      case OutputType.steps:
        return '''- Format: Numbered steps (1, 2, 3...)
- Each step: Action + expected outcome
- Include: Prerequisites, troubleshooting tips''';

      case OutputType.summary:
        return '''- Length: Concise (200-300 words)
- Include: Key points, main conclusions
- Format: Bullet points or short paragraphs''';

      case OutputType.list:
        return '''- Format: Bulleted or numbered list
- Include: Brief descriptions for each item
- Order: Logical sequence or priority''';

      case OutputType.document:
        return '''- Structure: Sections with headers
- Include: Table of contents, references
- Format: Formal document structure''';
    }
  }
}
