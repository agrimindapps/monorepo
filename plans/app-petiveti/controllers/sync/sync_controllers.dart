// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'animals_sync_controller.dart';
import 'consultas_sync_controller.dart';
import 'despesas_sync_controller.dart';
import 'lembretes_sync_controller.dart';
import 'medicamentos_sync_controller.dart';
import 'pesos_sync_controller.dart';
import 'vacinas_sync_controller.dart';

// Service base
export '../../../core/services/sync_firebase_service.dart';
/// Arquivo de índice para controllers de sincronização do app-petiveti
/// Exporta todos os controllers que usam SyncFirebaseService


// Controllers de sincronização
export 'animals_sync_controller.dart';
export 'consultas_sync_controller.dart';
export 'despesas_sync_controller.dart';
export 'lembretes_sync_controller.dart';
export 'medicamentos_sync_controller.dart';
export 'pesos_sync_controller.dart';
export 'vacinas_sync_controller.dart';

// Imports dos controllers para usar no dependency injection

/// Classe utilitária para inicializar todos os controllers sync
class PetivetiSyncControllers {
  /// Inicializar todos os controllers sync do app-petiveti
  /// Este método deve ser chamado no main.dart ou no init do app
  static Future<void> initializeAll() async {
    try {
      debugPrint('🚀 Inicializando controllers sync do app-petiveti...');

      // Os controllers serão inicializados automaticamente quando
      // Get.put() for chamado para cada um deles

      debugPrint('✅ Controllers sync do app-petiveti prontos para uso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar controllers sync: $e');
      rethrow;
    }
  }

  /// Registrar todos os controllers no GetX (dependency injection)
  static void registerControllers() {
    try {
      // Usar Get.lazyPut para inicialização sob demanda
      Get.lazyPut<AnimalsSyncController>(() => AnimalsSyncController());
      Get.lazyPut<ConsultasSyncController>(() => ConsultasSyncController());
      Get.lazyPut<DespesasSyncController>(() => DespesasSyncController());
      Get.lazyPut<LembretesSyncController>(() => LembretesSyncController());
      Get.lazyPut<MedicamentosSyncController>(
          () => MedicamentosSyncController());
      Get.lazyPut<VacinasSyncController>(() => VacinasSyncController());
      Get.lazyPut<PesosSyncController>(() => PesosSyncController());

      debugPrint('📦 Controllers sync registrados no GetX');
    } catch (e) {
      debugPrint('❌ Erro ao registrar controllers: $e');
      rethrow;
    }
  }

  /// Obter instância de controller específico
  static T getController<T>() {
    return Get.find<T>();
  }

  /// Verificar se controller está registrado
  static bool isControllerRegistered<T>() {
    return Get.isRegistered<T>();
  }

  /// Remover todos os controllers (para testes ou cleanup)
  static void disposeAll() {
    try {
      Get.delete<AnimalsSyncController>();
      Get.delete<ConsultasSyncController>();
      Get.delete<DespesasSyncController>();
      Get.delete<LembretesSyncController>();
      Get.delete<MedicamentosSyncController>();
      Get.delete<VacinasSyncController>();
      Get.delete<PesosSyncController>();

      debugPrint('🗑️ Controllers sync removidos');
    } catch (e) {
      debugPrint('❌ Erro ao remover controllers: $e');
    }
  }
}
