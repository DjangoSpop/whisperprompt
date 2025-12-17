/// Step-by-Step Enhancement Strategy
///
/// Breaks prompts into clear, numbered sequential instructions
/// or structured steps for better clarity.

import '../models/intent.dart';
import '../models/enhancement.dart' show EnhancementStrategyType;
import 'base_strategy.dart';

class StepwiseStrategy extends EnhancementStrategy {
  @override
  EnhancementStrategyType get strategyType => EnhancementStrategyType.stepwise;

  @override
  String get name => 'Step-by-Step';

  @override
  String get description => 'Clear sequential steps';

  @override
  String get iconName => 'list_alt';

  @override
  String enhance(String rawText, IntentAnalysis intent) {
    var text = rawText.trim();

    // Ensure proper capitalization
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    // Add step-by-step structure based on output type
    switch (intent.outputType) {
      case OutputType.code:
        return _formatAsCodeSteps(text, intent);
      case OutputType.steps:
        return _formatAsDetailedSteps(text);
      case OutputType.explanation:
        return _formatAsExplanationSteps(text);
      default:
        return _formatAsGeneralSteps(text);
    }
  }

  /// Format for code-related requests
  String _formatAsCodeSteps(String text, IntentAnalysis intent) {
    return '''$text

Please provide:
1. Understand the requirements and constraints
2. Design the solution architecture
3. Implement the code with best practices
4. Include error handling and edge cases
5. Add tests and documentation''';
  }

  /// Format for step-by-step instructions
  String _formatAsDetailedSteps(String text) {
    // Check if text already mentions steps
    if (text.toLowerCase().contains('step')) {
      return '''Break down the following into clear, sequential steps:

$text

Format as:
- Step 1: [First action]
- Step 2: [Second action]
- Step 3: [Third action]
And so on...''';
    }

    return '''Provide a step-by-step guide for: $text

Include:
1. Prerequisites and requirements
2. Detailed steps with explanations
3. Expected outcomes for each step
4. Common pitfalls to avoid
5. Verification and next steps''';
  }

  /// Format for explanations
  String _formatAsExplanationSteps(String text) {
    return '''Explain: $text

Structure your explanation as follows:
1. Overview: What it is and why it matters
2. Key Concepts: Core principles and terminology
3. How It Works: Detailed breakdown
4. Practical Examples: Real-world applications
5. Summary: Key takeaways''';
  }

  /// General step-by-step format
  String _formatAsGeneralSteps(String text) {
    return '''Address the following systematically:

$text

Please organize your response into clear sections:
1. Context and background
2. Main points or actions
3. Supporting details
4. Conclusions and recommendations''';
  }
}
