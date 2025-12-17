/// Intent detection provider
///
/// Provides singleton instance of IntentDetector for analyzing user intent.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../intelligence/intent_detector.dart';
import '../../intelligence/models/intent.dart';

/// Provider for IntentDetector singleton
final intentDetectorProvider = Provider<IntentDetector>((ref) {
  return IntentDetector();
});

/// Provider for analyzing intent from text
///
/// Usage:
/// ```dart
/// final intent = ref.read(analyzeIntentProvider(
///   text: transcription,
///   templateCategory: 'coding',
/// ));
/// ```
final analyzeIntentProvider = Provider.family<IntentAnalysis, ({
  String text,
  String? templateCategory,
}))((ref, params) {
  final detector = ref.watch(intentDetectorProvider);
  return detector.analyze(
    params.text,
    templateCategory: params.templateCategory,
  );
});
