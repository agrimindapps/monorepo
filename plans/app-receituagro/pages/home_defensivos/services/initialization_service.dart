// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/loading_state.dart';

/// Service responsável pela lógica de inicialização com retry e timeout
/// Extrai a lógica complexa de inicialização do controller
class InitializationService {
  final List<String> _stateTransitionLog = <String>[];
  
  /// Executa inicialização com retry automático e timeout progressivo
  Future<void> performInitializationWithRetry<T>({
    required Future<T> Function() initializationTask,
    required Future<bool> Function() preConditionsValidator,
    required Future<bool> Function(T result) successValidator,
    required Function(LoadingState state) onStateChange,
    required Function(String error) onError,
    required Function() onClearError,
    int maxAttempts = 3,
    int baseTimeoutSeconds = 30,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        onStateChange(LoadingState.loading);
        onClearError();
        
        // Step 1: Validate pre-conditions
        if (!await preConditionsValidator()) {
          throw StateError('Pre-conditions validation failed');
        }
        
        // Step 2: Execute main initialization task with progressive timeout
        final timeoutDuration = Duration(
          seconds: baseTimeoutSeconds + (attempts * 10)
        );
        
        final result = await initializationTask().timeout(timeoutDuration);
        
        // Step 3: Validate successful initialization
        if (await successValidator(result)) {
          onStateChange(LoadingState.success);
          _logStateTransition('Initialization completed successfully after ${attempts + 1} attempts');
          return; // Success, exit retry loop
        } else {
          throw StateError('Initialization validation failed');
        }
        
      } catch (e) {
        attempts++;
        final isLastAttempt = attempts >= maxAttempts;
        
        _logStateTransition('Attempt $attempts failed: ${e.toString()}');
        
        if (isLastAttempt) {
          final errorMsg = 'Initialization failed after $attempts attempts: ${e.toString()}';
          onError(errorMsg);
          onStateChange(LoadingState.error);
          return;
        }
        
        // Exponential backoff
        final backoffDelay = Duration(milliseconds: 1000 * (1 << attempts));
        _logStateTransition('Retrying in ${backoffDelay.inMilliseconds}ms...');
        await Future.delayed(backoffDelay);
      }
    }
  }
  
  /// Valida pré-condições básicas para inicialização
  Future<bool> validatePreConditions() async {
    try {
      // Check if we have context for navigation
      if (Get.context == null) {
        _logStateTransition('Pre-condition failed: Get.context is null');
        return false;
      }
      
      // Additional pre-conditions can be added here
      _logStateTransition('Pre-conditions validation passed');
      return true;
    } catch (e) {
      _logStateTransition('Pre-condition error: ${e.toString()}');
      return false;
    }
  }
  
  /// Obtém o log completo de transições de estado
  List<String> getStateTransitionLog() {
    return _stateTransitionLog.toList();
  }
  
  /// Limpa o log de transições
  void clearStateTransitionLog() {
    _stateTransitionLog.clear();
  }
  
  void _logStateTransition(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message';
    _stateTransitionLog.add(logEntry);
    debugPrint('InitializationService: $logEntry');
  }
}