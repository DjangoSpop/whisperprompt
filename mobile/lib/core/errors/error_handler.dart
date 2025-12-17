/// Global error handler for AI Whisperer
///
/// Catches and processes all errors, converting them to AppErrors
/// and displaying user-friendly error messages.

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'app_error.dart';

/// Global error handler singleton
class GlobalErrorHandler {
  GlobalErrorHandler._();
  static final instance = GlobalErrorHandler._();

  /// Error callback for custom handling
  void Function(AppError error)? onError;

  /// Handle any error or exception
  void handleError(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }

    // Convert to AppError
    final appError = _convertToAppError(error, stackTrace);

    // Call custom error handler if set
    onError?.call(appError);

    // TODO: Log to analytics/crashlytics in production
    // AnalyticsService.logError(appError);
  }

  /// Convert any error to AppError
  AppError _convertToAppError(Object error, StackTrace? stackTrace) {
    // Already an AppError
    if (error is AppError) {
      return error;
    }

    // Dio/network errors
    if (error is DioException) {
      return _convertDioError(error);
    }

    // Generic exception
    if (error is Exception) {
      return AppError.unknown(
        message: error.toString(),
        originalException: error,
        stackTrace: stackTrace,
      );
    }

    // Unknown error type
    return AppError.unknown(
      message: error.toString(),
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  /// Convert Dio errors to AppErrors
  AppError _convertDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.network(
          message: 'Request timeout: ${error.message}',
          originalException: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;

        if (statusCode == 401 || statusCode == 403) {
          return AppError.authentication(
            message: 'Authentication failed: $statusCode',
            actions: [], // Actions will be added by UI layer
            originalException: error,
          );
        }

        if (statusCode == 429) {
          return AppError.quota(
            quotaType: 'Rate limit',
            current: 0,
            limit: 0,
            actions: [], // Actions will be added by UI layer
          );
        }

        if (statusCode >= 500) {
          return AppError.server(
            statusCode: statusCode,
            message: 'Server error: ${error.response?.data}',
            originalException: error,
          );
        }

        return AppError.validation(
          message: 'Invalid request: ${error.response?.data}',
        );

      case DioExceptionType.cancel:
        return AppError.unknown(
          message: 'Request cancelled',
          originalException: error,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return AppError.network(
          message: 'Network error: ${error.message}',
          originalException: error,
          stackTrace: error.stackTrace,
        );

      default:
        return AppError.unknown(
          message: 'Dio error: ${error.message}',
          originalException: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  /// Set up global error handlers
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (details) {
      instance.handleError(details.exception, details.stack);
    };

    // Catch errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      instance.handleError(error, stack);
      return true; // Handled
    };
  }
}
