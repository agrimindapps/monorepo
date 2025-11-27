import 'package:flutter/foundation.dart';

/// Módulo de sincronização do AgrihUrbi
/// TODO: Implementar sync service com Riverpod providers
abstract class AgrihUrbiSyncDIModule {
  static void init() {
    debugPrint(
      'AgrihUrbiSyncDIModule: Sync service registration skipped (awaiting implementation)',
    );
  }

  /// Inicializa o sync service após o app estar pronto
  static Future<void> initializeSyncService() async {
    // TODO: Implement with Riverpod providers
  }

  /// Executa sync inicial após o usuário fazer login
  static Future<void> performInitialSync() async {
    // TODO: Implement with Riverpod providers
  }

  /// Limpa dados de sync (útil para logout)
  static Future<void> clearSyncData() async {
    // TODO: Implement with Riverpod providers
  }
}
