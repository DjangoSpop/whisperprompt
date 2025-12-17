/// Text-to-speech service provider
///
/// Provides singleton instance of TtsService for voice output.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/tts_service.dart';

/// Provider for TtsService singleton
///
/// This will be overridden in main.dart with an initialized instance
final ttsServiceProvider = Provider<TtsService>((ref) {
  throw UnimplementedError(
    'ttsServiceProvider must be overridden in ProviderScope',
  );
});
