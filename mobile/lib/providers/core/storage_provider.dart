/// Storage service provider
///
/// Provides singleton instance of StorageService for local data persistence.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';

/// Provider for StorageService singleton
///
/// This will be overridden in main.dart with an initialized instance
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'storageServiceProvider must be overridden in ProviderScope',
  );
});
