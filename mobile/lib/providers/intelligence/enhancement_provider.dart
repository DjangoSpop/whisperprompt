/// Prompt enhancement provider
///
/// Provides singleton instance of PromptEnhancer and enhancement functionality.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../intelligence/prompt_enhancer.dart';
import '../../intelligence/models/enhancement.dart';
import 'intent_provider.dart';

/// Provider for PromptEnhancer singleton
final promptEnhancerProvider = Provider<PromptEnhancer>((ref) {
  final intentDetector = ref.watch(intentDetectorProvider);
  return PromptEnhancer(intentDetector: intentDetector);
});

/// Provider for enhancing prompt text
///
/// Usage:
/// ```dart
/// final result = await ref.read(enhancePromptProvider(
///   rawText: 'i need to write code for sorting',
///   templateCategory: 'coding',
/// ).future);
/// ```
final enhancePromptProvider = FutureProvider.family<EnhancementResult, ({
  String rawText,
  String? templateCategory,
}))((ref, params) async {
  final enhancer = ref.watch(promptEnhancerProvider);
  return enhancer.enhance(
    params.rawText,
    templateCategory: params.templateCategory,
  );
});

/// Provider for regenerating with specific strategy
final regenerateWithStrategyProvider = FutureProvider.family<PromptVariant, ({
  String rawText,
  EnhancementStrategyType strategy,
  String? templateCategory,
}))((ref, params) async {
  final enhancer = ref.watch(promptEnhancerProvider);
  return enhancer.regenerateWithStrategy(
    params.rawText,
    params.strategy,
    templateCategory: params.templateCategory,
  );
});

/// Provider for parsing refinement commands
final parseRefinementCommandProvider = Provider.family<RefinementCommand, String>(
  (ref, command) {
    final enhancer = ref.watch(promptEnhancerProvider);
    return enhancer.parseRefinementCommand(command);
  },
);
