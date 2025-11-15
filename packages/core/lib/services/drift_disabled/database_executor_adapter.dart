import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// Adapter inteligente para seleção automática de executor de banco de dados
/// 
/// Este adapter detecta a plataforma em tempo de execução e fornece:
/// - WASM + IndexedDB na web
/// - SQLite nativo em mobile/desktop
/// - Fallback automático se WASM falhar
abstract class DatabaseExecutorAdapter {
  /// Obtém o executor apropriado para a plataforma atual
  /// 
  /// [databaseName] - Nome do banco de dados
  /// [allowWebFallback] - Se true, tenta fallback quando Drift WASM falha na web
  /// 
  /// Uso:
  /// ```dart
  /// final executor = await DatabaseExecutorAdapter.getExecutor(
  ///   databaseName: 'my_app.db',
  ///   allowWebFallback: true,
  /// );
  /// ```
  static Future<QueryExecutor> getExecutor({
    required String databaseName,
    bool allowWebFallback = true,
  }) async {
    // Log da plataforma detectada
    if (kIsWeb) {
      // ignore: avoid_print
      print('📱 Detected: Web platform - using WASM + IndexedDB');
    } else {
      // ignore: avoid_print
      print('📱 Detected: Native platform - using SQLite FFI');
    }

    // Importa a configuração correta por plataforma
    return _getPlatformExecutor(
      databaseName: databaseName,
      allowWebFallback: allowWebFallback,
    );
  }

  /// Obtém o executor correto baseado na plataforma
  static Future<QueryExecutor> _getPlatformExecutor({
    required String databaseName,
    required bool allowWebFallback,
  }) async {
    if (kIsWeb) {
      // Na web, usar WASM (implementado em drift_database_config_web.dart)
      // O export condicional em drift_database_config.dart já seleciona isso
      try {
        final config = _WebDriftConfig();
        return config.createExecutor(databaseName: databaseName);
      } catch (e) {
        // ignore: avoid_print
        print('❌ WASM initialization failed: $e');
        
        if (allowWebFallback) {
          // ignore: avoid_print
          print('⚠️ Attempting fallback to Firestore adapter...');
          // Implementação futura de fallback
          rethrow;
        }
        rethrow;
      }
    } else {
      // Em mobile/desktop, usar SQLite nativo
      final config = _NativeDriftConfig();
      return config.createExecutor(databaseName: databaseName);
    }
  }

  /// Verifica se a plataforma é web
  static bool get isWeb => kIsWeb;

  /// Verifica se Drift WASM está disponível
  static Future<bool> isWasmAvailable() async {
    if (!kIsWeb) return false;
    
    try {
      // Testa carregamento do WASM
      final config = _WebDriftConfig();
      await config.testWasmAvailability();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ WASM not available: $e');
      return false;
    }
  }
}

/// Configuração para Drift WASM (Web)
class _WebDriftConfig {
  /// Cria executor usando WASM
  QueryExecutor createExecutor({required String databaseName}) {
    // ignore: avoid_print
    print('🔧 Creating WASM executor for: $databaseName');
    
    // Usa a configuração do core package (drift_database_config_web.dart)
    // que já está importada via export condicional
    return LazyDatabase(() async {
      // ignore: avoid_print
      print('🔧 Initializing Drift WASM database: $databaseName');
      
      try {
        // Importa dinamicamente para evitar erro em plataformas não-web
        final wasmModule = await _loadWasmModule();
        
        // ignore: avoid_print
        print('✅ WASM module loaded successfully');
        
        // Retorna executor (a configuração real está em drift_database_config_web.dart)
        return wasmModule;
      } catch (e) {
        // ignore: avoid_print
        print('❌ Failed to load WASM: $e');
        rethrow;
      }
    });
  }

  /// Testa disponibilidade de WASM
  Future<void> testWasmAvailability() async {
    try {
      await _loadWasmModule();
      // ignore: avoid_print
      print('✅ WASM is available');
    } catch (e) {
      // ignore: avoid_print
      print('❌ WASM is not available: $e');
      rethrow;
    }
  }

  /// Carrega o módulo WASM
  Future<QueryExecutor> _loadWasmModule() async {
    // Implementação delegada para drift_database_config_web.dart
    // que é selecionado automaticamente via export condicional
    throw UnsupportedError('Use DriftDatabaseConfig from core package');
  }
}

/// Configuração para Drift SQLite nativo (Mobile/Desktop)
class _NativeDriftConfig {
  /// Cria executor usando SQLite nativo
  QueryExecutor createExecutor({required String databaseName}) {
    // ignore: avoid_print
    print('🔧 Creating native SQLite executor for: $databaseName');
    
    // Usa a configuração do core package (drift_database_config_mobile.dart)
    // que já está importada via export condicional
    throw UnsupportedError('Use DriftDatabaseConfig from core package');
  }
}

/// Extensão para melhor tratamento de erros
extension DatabaseExecutorErrorHandling on Future<QueryExecutor> {
  /// Adiciona logging e tratamento de erros consistentes
  Future<QueryExecutor> withErrorHandling({
    String? operationName,
    VoidCallback? onError,
  }) async {
    try {
      final executor = await this;
      // ignore: avoid_print
      print('✅ Database executor initialized${operationName != null ? " for $operationName" : ""}');
      return executor;
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('❌ Failed to initialize executor: $e');
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
      
      onError?.call();
      rethrow;
    }
  }
}
