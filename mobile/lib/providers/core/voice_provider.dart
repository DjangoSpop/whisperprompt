/// Voice recording service provider
///
/// Provides singleton instance of VoiceService for audio recording.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/voice_service.dart';

/// Provider for VoiceService singleton
final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});
