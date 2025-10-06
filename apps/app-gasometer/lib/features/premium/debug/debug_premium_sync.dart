import 'package:core/core.dart' show GetIt;
import 'package:flutter/foundation.dart';

import '../data/services/premium_sync_service.dart';
import '../test/premium_sync_test.dart';

/// Utilitários para debug e teste da sincronização premium
///
/// Para ser usado durante desenvolvimento para validar implementação
class DebugPremiumSync {
  static PremiumSyncService? _syncService;

  /// Inicializa serviço de sync para debug
  static Future<void> init() async {
    if (kDebugMode) {
      try {
        _syncService = GetIt.instance<PremiumSyncService>();
        debugPrint('🔧 Debug Premium Sync inicializado');
      } catch (e) {
        debugPrint('❌ Erro ao inicializar Debug Premium Sync: $e');
      }
    }
  }

  /// Executa teste completo (apenas em debug)
  static Future<void> runCompleteTest() async {
    if (!kDebugMode || _syncService == null) return;

    debugPrint('🧪 Executando teste completo de sincronização premium...');
    await PremiumSyncTestRunner.runCompleteTest(_syncService!);
  }

  /// Executa teste rápido (apenas em debug)
  static Future<void> runQuickTest() async {
    if (!kDebugMode || _syncService == null) return;

    debugPrint('⚡ Executando teste rápido de sincronização premium...');
    await PremiumSyncTestRunner.runQuickTest(_syncService!);
  }

  /// Executa testes de status (apenas em debug)
  static void runStatusTests() {
    if (!kDebugMode || _syncService == null) return;

    debugPrint('📊 Executando testes de status premium...');
    PremiumSyncTestRunner.runStatusTests(_syncService!);
  }

  /// Força sincronização imediata para debug
  static Future<void> forceSync() async {
    if (!kDebugMode || _syncService == null) return;

    debugPrint('🔄 Forçando sincronização premium...');
    final result = await _syncService!.forceSync();

    result.fold(
      (failure) => debugPrint('❌ Sincronização falhou: ${failure.message}'),
      (_) => debugPrint('✅ Sincronização concluída'),
    );
  }

  /// Imprime status atual para debug
  static void printCurrentStatus() {
    if (!kDebugMode || _syncService == null) return;

    final status = _syncService!.currentStatus;

    debugPrint('📱 Status Premium Atual:');
    debugPrint('   🔹 É Premium: ${status.isPremium}');
    debugPrint('   🔹 Fonte: ${status.premiumSource}');
    debugPrint('   🔹 Expirado: ${status.isExpired}');
    if (status.expirationDate != null) {
      debugPrint('   🔹 Expira em: ${status.expirationDate}');
    }
    debugPrint('   🔹 Limites:');
    debugPrint('      - Veículos: ${status.limits.maxVehicles}');
    debugPrint('      - Abastecimentos: ${status.limits.maxFuelRecords}');
    debugPrint('      - Manutenções: ${status.limits.maxMaintenanceRecords}');
  }

  /// Testa funcionalidades específicas para debug
  static void testSpecificFeatures() {
    if (!kDebugMode || _syncService == null) return;

    final status = _syncService!.currentStatus;

    debugPrint('🔑 Teste de Funcionalidades:');

    final testCases = [
      ('Relatórios Avançados', 'advanced_reports'),
      ('Exportação de Dados', 'export_data'),
      ('Categorias Customizadas', 'custom_categories'),
      ('Temas Premium', 'premium_themes'),
      ('Backup na Nuvem', 'cloud_backup'),
      ('Histórico de Localização', 'location_history'),
      ('Analytics Avançado', 'advanced_analytics'),
    ];

    for (final (name, id) in testCases) {
      final hasAccess = status.canUseFeature(id);
      debugPrint('   ${hasAccess ? '✅' : '❌'} $name');
    }

    debugPrint('🚗 Teste de Limites:');
    debugPrint('   - Pode add 5º veículo: ${status.canAddVehicle(4)}');
    debugPrint(
      '   - Pode add 50º abastecimento: ${status.canAddFuelRecord(49)}',
    );
    debugPrint(
      '   - Pode add 30ª manutenção: ${status.canAddMaintenanceRecord(29)}',
    );
  }

  /// Monitora eventos de sincronização (apenas debug)
  static void startEventMonitoring() {
    if (!kDebugMode || _syncService == null) return;

    debugPrint('👀 Iniciando monitoramento de eventos...');

    _syncService!.syncEvents.listen(
      (event) {
        final timestamp = DateTime.now().toString().split(' ')[1];
        debugPrint('[$timestamp] 🔄 ${_formatSyncEvent(event)}');
      },
      onError: (error) {
        debugPrint('❌ Erro no monitoramento: $error');
      },
    );
  }

  /// Formata evento de sync para debug
  static String _formatSyncEvent(PremiumSyncEvent event) {
    switch (event.runtimeType.toString()) {
      case '_UserLoggedIn':
        return 'Usuário logado';
      case '_UserLoggedOut':
        return 'Usuário deslogado';
      case '_StatusUpdated':
        return 'Status atualizado';
      case '_WebhookReceived':
        return 'Webhook recebido';
      case '_SyncStarted':
        return 'Sincronização iniciada';
      case '_SyncCompleted':
        return 'Sincronização concluída';
      case '_SyncFailed':
        return 'Sincronização falhou';
      case '_RetryScheduled':
        return 'Retry agendado';
      default:
        return 'Evento: ${event.runtimeType}';
    }
  }
}

/// Widget de debug para testar sincronização premium na UI
class DebugPremiumSyncButton {
  /// Executa ações de debug baseado no contexto
  static Future<void> onPressed(String action) async {
    switch (action) {
      case 'status':
        DebugPremiumSync.printCurrentStatus();
        break;
      case 'quick_test':
        await DebugPremiumSync.runQuickTest();
        break;
      case 'force_sync':
        await DebugPremiumSync.forceSync();
        break;
      case 'features':
        DebugPremiumSync.testSpecificFeatures();
        break;
      case 'monitor':
        DebugPremiumSync.startEventMonitoring();
        break;
      default:
        debugPrint('❓ Ação de debug desconhecida: $action');
    }
  }
}
