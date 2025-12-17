/// Core API service provider
///
/// Provides singleton instance of ApiService throughout the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import 'storage_provider.dart';

/// Provider for ApiService singleton
///
/// Automatically injects StorageService for token management
final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService);
});
