import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// The level of a log message, indicating its severity.
enum LogLevel { debug, info, warning, error }

/// A simple static logger utility for consistent logging across the project.
///
/// It supports different log levels and allows for structured logging. In debug
/// mode, it prints to the console. In a real application, this could be
/// extended to send logs to a remote service like Sentry or Firebase Crashlytics.
class Logger {
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  /// Sets the minimum [LogLevel] that will be printed to the console.
  static void setLevel(LogLevel level) => _minLevel = level;

  static bool _shouldLog(LogLevel level) => level.index >= _minLevel.index;

  /// Logs a message with a given level, name, and optional data.
  static void log(
    LogLevel level,
    String message, {
    String name = 'LOG',
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (!_shouldLog(level)) return;

    final timestamp = DateTime.now().toIso8601String();
    String emoji;
    switch (level) {
      case LogLevel.debug:
        emoji = '🐛';
        break;
      case LogLevel.info:
        emoji = 'ℹ️';
        break;
      case LogLevel.warning:
        emoji = '⚠️';
        break;
      case LogLevel.error:
        emoji = '🔥';
        break;
    }

    String logMessage = '$emoji $timestamp [$name] $message';

    if (data != null) {
      try {
        final jsonData = jsonEncode(data);
        logMessage += '\nData: $jsonData';
      } catch (e) {
        logMessage += '\nData: (Failed to encode to JSON)';
      }
    }

    developer.log(
      logMessage,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs a debug message.
  ///
  /// These are typically used for development and diagnostics.
  static void debug(String message, {String name = 'DEBUG'}) {
    log(LogLevel.debug, message, name: name);
  }

  /// Logs an informational message.
  ///
  /// These are used for general application flow events.
  static void info(String message, {String name = 'INFO'}) {
    log(LogLevel.info, message, name: name);
  }

  /// Logs a warning message.
  ///
  /// Warnings indicate potential issues that are not yet errors.
  static void warning(String message, {String name = 'WARNING'}) {
    log(LogLevel.warning, message, name: name);
  }

  /// Logs an error message, with an optional error object and stack trace.
  ///
  /// Errors indicate that something has gone wrong.
  static void error(
    String message, {
    String name = 'ERROR',
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(LogLevel.error, message, name: name, error: error, stackTrace: stackTrace);
  }

  /// Logs a structured error message with a map of additional data.
  static void errorWithMap(
    String message, {
    required Map<String, dynamic> data,
    String name = 'ERROR_MAP',
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.error,
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }
}