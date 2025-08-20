// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Tipos de erro por criticidade
enum ErrorCriticality {
  /// Erro crítico que impede funcionamento do app
  critical,
  /// Erro importante mas app pode continuar com funcionalidade degradada
  major,
  /// Erro menor que não afeta funcionamento principal
  minor,
  /// Warning que não impede funcionamento
  warning,
}

/// Categorias de erro para melhor organização
enum ErrorCategory {
  initialization,
  database,
  network,
  authentication,
  business,
  ui,
  unknown,
}

/// Estratégias de retry
enum RetryStrategy {
  none,
  immediate,
  exponential,
  linear,
}

/// Modelo de erro padronizado
class AppErrorInfo {
  final String id;
  final String message;
  final String? details;
  final ErrorCriticality criticality;
  final ErrorCategory category;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  AppErrorInfo({
    required this.id,
    required this.message,
    this.details,
    required this.criticality,
    required this.category,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory methods para diferentes tipos de erro
  factory AppErrorInfo.critical({
    required String message,
    String? details,
    ErrorCategory category = ErrorCategory.unknown,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppErrorInfo(
      id: _generateErrorId(),
      message: message,
      details: details,
      criticality: ErrorCriticality.critical,
      category: category,
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  factory AppErrorInfo.major({
    required String message,
    String? details,
    ErrorCategory category = ErrorCategory.unknown,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppErrorInfo(
      id: _generateErrorId(),
      message: message,
      details: details,
      criticality: ErrorCriticality.major,
      category: category,
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  factory AppErrorInfo.minor({
    required String message,
    String? details,
    ErrorCategory category = ErrorCategory.unknown,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppErrorInfo(
      id: _generateErrorId(),
      message: message,
      details: details,
      criticality: ErrorCriticality.minor,
      category: category,
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static String _generateErrorId() {
    return 'ERR_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  String toString() {
    return 'AppErrorInfo(id: $id, criticality: $criticality, category: $category, message: $message)';
  }
}

/// Configuração de retry
class RetryConfig {
  final RetryStrategy strategy;
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;

  const RetryConfig({
    this.strategy = RetryStrategy.exponential,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
  });

  static const immediate = RetryConfig(
    strategy: RetryStrategy.immediate,
    maxAttempts: 1,
  );

  static const exponential = RetryConfig(
    strategy: RetryStrategy.exponential,
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    backoffMultiplier: 2.0,
  );

  static const linear = RetryConfig(
    strategy: RetryStrategy.linear,
    maxAttempts: 3,
    initialDelay: Duration(seconds: 2),
  );
}

/// Gerenciador central de erros
class ErrorManager extends GetxService {
  static ErrorManager get instance => Get.find<ErrorManager>();

  final List<AppErrorInfo> _errorHistory = [];
  final RxList<AppErrorInfo> _activeErrors = <AppErrorInfo>[].obs;
  final RxBool _hasUnhandledErrors = false.obs;

  // Getters
  List<AppErrorInfo> get errorHistory => List.unmodifiable(_errorHistory);
  List<AppErrorInfo> get activeErrors => _activeErrors;
  bool get hasUnhandledErrors => _hasUnhandledErrors.value;
  List<AppErrorInfo> get criticalErrors =>
      _activeErrors.where((e) => e.criticality == ErrorCriticality.critical).toList();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔧 ErrorManager inicializado');
  }

  /// Registra um erro no sistema
  void reportError(AppErrorInfo error) {
    debugPrint('🚨 [${error.criticality.name.toUpperCase()}] ${error.message}');
    if (error.details != null) {
      debugPrint('   Detalhes: ${error.details}');
    }
    if (error.originalError != null) {
      debugPrint('   Erro original: ${error.originalError}');
    }

    _errorHistory.add(error);
    _activeErrors.add(error);
    _hasUnhandledErrors.value = true;

    // Log adicional para erros críticos
    if (error.criticality == ErrorCriticality.critical) {
      debugPrint('💥 ERRO CRÍTICO: ${error.message}');
      _showCriticalErrorDialog(error);
    }

    // Limitar histórico a 100 erros
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }
  }

  /// Executa operação com retry automático
  Future<T> executeWithRetry<T>({
    required String operationName,
    required Future<T> Function() operation,
    RetryConfig config = const RetryConfig(),
    ErrorCategory category = ErrorCategory.unknown,
    Map<String, dynamic>? context,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (attempt < config.maxAttempts) {
      attempt++;
      
      try {
        debugPrint('🔄 Executando $operationName (tentativa $attempt/${config.maxAttempts})');
        final result = await operation();
        
        if (attempt > 1) {
          debugPrint('✅ $operationName bem-sucedido na tentativa $attempt');
        }
        
        return result;
      } catch (e, stackTrace) {
        debugPrint('❌ $operationName falhou na tentativa $attempt: $e');

        if (attempt >= config.maxAttempts) {
          // Última tentativa falhou
          final error = AppErrorInfo.major(
            message: 'Falha em $operationName após $attempt tentativas',
            details: e.toString(),
            category: category,
            originalError: e,
            stackTrace: stackTrace,
            context: {
              ...?context,
              'operation': operationName,
              'attempts': attempt,
              'retryConfig': config.strategy.name,
            },
          );
          
          reportError(error);
          rethrow;
        }

        // Calcular delay para próxima tentativa
        if (attempt < config.maxAttempts && config.strategy != RetryStrategy.none) {
          switch (config.strategy) {
            case RetryStrategy.immediate:
              delay = Duration.zero;
              break;
            case RetryStrategy.exponential:
              delay = Duration(
                milliseconds: (delay.inMilliseconds * config.backoffMultiplier).round()
                    .clamp(0, config.maxDelay.inMilliseconds),
              );
              break;
            case RetryStrategy.linear:
              delay = config.initialDelay;
              break;
            case RetryStrategy.none:
              break;
          }

          if (delay > Duration.zero) {
            debugPrint('⏳ Aguardando ${delay.inMilliseconds}ms antes da próxima tentativa');
            await Future.delayed(delay);
          }
        }
      }
    }

    throw StateError('Código não deveria chegar aqui');
  }

  /// Executa operação com fallback em caso de erro
  Future<T> executeWithFallback<T>({
    required String operationName,
    required Future<T> Function() operation,
    required T Function() fallback,
    ErrorCategory category = ErrorCategory.unknown,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      final error = AppErrorInfo.minor(
        message: 'Fallback ativado para $operationName',
        details: e.toString(),
        category: category,
        originalError: e,
        stackTrace: stackTrace,
        context: {
          ...?context,
          'operation': operationName,
          'fallbackUsed': true,
        },
      );
      
      reportError(error);
      
      debugPrint('🔄 Usando fallback para $operationName');
      return fallback();
    }
  }

  /// Marca erro como tratado
  void markErrorAsHandled(String errorId) {
    _activeErrors.removeWhere((error) => error.id == errorId);
    
    if (_activeErrors.isEmpty) {
      _hasUnhandledErrors.value = false;
    }
  }

  /// Limpa todos os erros ativos
  void clearActiveErrors() {
    _activeErrors.clear();
    _hasUnhandledErrors.value = false;
  }

  /// Obtém estatísticas de erro
  Map<String, dynamic> getErrorStats() {
    final stats = <String, dynamic>{};
    
    // Total de erros
    stats['total'] = _errorHistory.length;
    stats['active'] = _activeErrors.length;
    
    // Por criticidade
    final byCriticality = <String, int>{};
    for (final error in _errorHistory) {
      byCriticality[error.criticality.name] = 
          (byCriticality[error.criticality.name] ?? 0) + 1;
    }
    stats['by_criticality'] = byCriticality;
    
    // Por categoria
    final byCategory = <String, int>{};
    for (final error in _errorHistory) {
      byCategory[error.category.name] = 
          (byCategory[error.category.name] ?? 0) + 1;
    }
    stats['by_category'] = byCategory;
    
    return stats;
  }

  /// Mostra diálogo para erros críticos
  void _showCriticalErrorDialog(AppErrorInfo error) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Erro Crítico'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text(
                'Detalhes: ${error.details}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              markErrorAsHandled(error.id);
              Get.back();
            },
            child: const Text('OK'),
          ),
          if (kDebugMode)
            TextButton(
              onPressed: () {
                debugPrint('Error Details: ${error.toString()}');
                debugPrint('Stack Trace: ${error.stackTrace}');
                Get.back();
              },
              child: const Text('Debug'),
            ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    debugPrint('🔧 ErrorManager finalizado');
    super.onClose();
  }
}
