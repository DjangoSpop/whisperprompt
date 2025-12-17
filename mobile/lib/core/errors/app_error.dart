/// Application error models and types
///
/// Defines a structured error taxonomy for AI Whisperer with
/// user-friendly messages and recovery actions.

import 'package:flutter/material.dart';

/// Types of errors that can occur in the app
enum ErrorType {
  /// Network connectivity issues, timeouts
  network,

  /// Microphone or storage permissions denied
  permission,

  /// Invalid user input or data validation failures
  validation,

  /// Backend API errors (500, 502, etc.)
  server,

  /// Authentication failures (token expired, invalid credentials)
  authentication,

  /// User quota exceeded (session limit, rate limit)
  quota,

  /// Audio recording failures, silent input detected
  audio,

  /// Unexpected errors
  unknown,
}

/// Recovery action for an error
class ErrorAction {
  /// Action label shown to user
  final String label;

  /// Callback when user taps the action
  final VoidCallback onTap;

  /// Icon for the action
  final IconData icon;

  const ErrorAction({
    required this.label,
    required this.onTap,
    required this.icon,
  });
}

/// Structured application error
class AppError implements Exception {
  /// Error type for categorization
  final ErrorType type;

  /// User-friendly error message (shown in UI)
  final String userMessage;

  /// Technical error message (for logging/debugging)
  final String technicalMessage;

  /// Recovery actions available to the user
  final List<ErrorAction> actions;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Original exception (if any)
  final Object? originalException;

  /// Stack trace (if any)
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.userMessage,
    required this.technicalMessage,
    this.actions = const [],
    this.statusCode,
    this.originalException,
    this.stackTrace,
  });

  /// Create a network error
  factory AppError.network({
    required String message,
    List<ErrorAction> actions = const [],
    Object? originalException,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.network,
      userMessage: 'Connection lost. Your progress is saved.',
      technicalMessage: message,
      actions: actions,
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Create a permission error
  factory AppError.permission({
    required String permissionName,
    required List<ErrorAction> actions,
    Object? originalException,
  }) {
    return AppError(
      type: ErrorType.permission,
      userMessage: '$permissionName access is required.',
      technicalMessage: 'Permission denied: $permissionName',
      actions: actions,
      originalException: originalException,
    );
  }

  /// Create a validation error
  factory AppError.validation({
    required String message,
    List<ErrorAction> actions = const [],
  }) {
    return AppError(
      type: ErrorType.validation,
      userMessage: message,
      technicalMessage: 'Validation error: $message',
      actions: actions,
    );
  }

  /// Create a server error
  factory AppError.server({
    required int statusCode,
    String? message,
    List<ErrorAction> actions = const [],
    Object? originalException,
  }) {
    return AppError(
      type: ErrorType.server,
      userMessage: 'Server error. Please try again later.',
      technicalMessage: message ?? 'Server error: $statusCode',
      statusCode: statusCode,
      actions: actions,
      originalException: originalException,
    );
  }

  /// Create an authentication error
  factory AppError.authentication({
    required String message,
    required List<ErrorAction> actions,
    Object? originalException,
  }) {
    return AppError(
      type: ErrorType.authentication,
      userMessage: 'Session expired. Please log in again.',
      technicalMessage: message,
      actions: actions,
      originalException: originalException,
    );
  }

  /// Create a quota exceeded error
  factory AppError.quota({
    required String quotaType,
    required int current,
    required int limit,
    required List<ErrorAction> actions,
  }) {
    return AppError(
      type: ErrorType.quota,
      userMessage: '$quotaType limit reached ($current/$limit used).',
      technicalMessage: 'Quota exceeded: $quotaType ($current/$limit)',
      actions: actions,
    );
  }

  /// Create an audio error
  factory AppError.audio({
    required String message,
    required List<ErrorAction> actions,
    Object? originalException,
  }) {
    return AppError(
      type: ErrorType.audio,
      userMessage: message,
      technicalMessage: 'Audio error: $message',
      actions: actions,
      originalException: originalException,
    );
  }

  /// Create an unknown error
  factory AppError.unknown({
    String? message,
    List<ErrorAction> actions = const [],
    Object? originalException,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.unknown,
      userMessage: 'Something went wrong. Please try again.',
      technicalMessage: message ?? 'Unknown error',
      actions: actions,
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Get icon for this error type
  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.authentication:
        return Icons.key_off;
      case ErrorType.quota:
        return Icons.block;
      case ErrorType.audio:
        return Icons.mic_off;
      case ErrorType.unknown:
        return Icons.warning;
    }
  }

  /// Get color for this error type
  Color get color {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.purple;
      case ErrorType.quota:
        return Colors.blue;
      case ErrorType.audio:
        return Colors.orange;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  @override
  String toString() => 'AppError($type): $technicalMessage';
}
