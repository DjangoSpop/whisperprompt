import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize storage
  final storageService = StorageService();
  await storageService.init();

  // Initialize TTS
  final ttsService = TtsService();
  await ttsService.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        ttsServiceProvider.overrideWithValue(ttsService),
      ],
      child: const AiWhispererApp(),
    ),
  );
}

// Providers for services
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  throw UnimplementedError();
});
