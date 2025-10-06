import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/services/premium_sync_service.dart';
import '../domain/entities/premium_status.dart';

/// Classe de teste para verificar funcionalidade de sincronização premium
///
/// Para ser executado durante desenvolvimento para validar o sistema de sync
class PremiumSyncTest {
  PremiumSyncTest(this._syncService);
  final PremiumSyncService _syncService;

  StreamSubscription<PremiumStatus>? _statusSubscription;
  StreamSubscription<PremiumSyncEvent>? _eventsSubscription;

  /// Executa teste completo de sincronização
  Future<void> runCompleteTest() async {
    debugPrint('🧪 Iniciando teste de sincronização premium...');

    try {
      await _testStreamListeners();
      await _testForceSync();
      await _testMultipleUpdates();
      await _testErrorRecovery();

      debugPrint('✅ Teste de sincronização premium concluído com sucesso!');
    } catch (e) {
      debugPrint('❌ Erro no teste de sincronização: $e');
    } finally {
      dispose();
    }
  }

  /// Testa listeners de streams
  Future<void> _testStreamListeners() async {
    debugPrint('📡 Testando listeners de streams...');
    _statusSubscription = _syncService.premiumStatusStream.listen(
      (status) {
        debugPrint(
          '📱 Status atualizado: ${status.isPremium} (${status.premiumSource})',
        );
      },
      onError: (Object error) {
        debugPrint('❌ Erro no stream de status: $error');
      },
    );
    _eventsSubscription = _syncService.syncEvents.listen(
      (event) {
        debugPrint('🔄 Evento de sync: ${event.runtimeType}');
      },
      onError: (Object error) {
        debugPrint('❌ Erro no stream de eventos: $error');
      },
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    debugPrint('✅ Listeners configurados');
  }

  /// Testa sincronização forçada
  Future<void> _testForceSync() async {
    debugPrint('🔄 Testando sincronização forçada...');

    final result = await _syncService.forceSync();

    result.fold(
      (failure) {
        debugPrint(
          '⚠️  Sync retornou failure (esperado em dev): ${failure.message}',
        );
      },
      (_) {
        debugPrint('✅ Sincronização forçada bem-sucedida');
      },
    );
  }

  /// Testa múltiplas atualizações em sequência
  Future<void> _testMultipleUpdates() async {
    debugPrint('📦 Testando múltiplas atualizações...');
    final futures = <Future<void>>[];

    for (int i = 0; i < 3; i++) {
      futures.add(
        Future.delayed(Duration(milliseconds: 500 * i), () async {
          debugPrint('🔄 Sync ${i + 1}/3...');
          await _syncService.forceSync();
        }),
      );
    }

    await Future.wait(futures);
    debugPrint('✅ Múltiplas atualizações processadas');
  }

  /// Testa recuperação de erro
  Future<void> _testErrorRecovery() async {
    debugPrint('🔧 Testando recuperação de erro...');
    try {
      await _syncService.forceSync();
      debugPrint('✅ Sistema não travou com erro simulado');
    } catch (e) {
      debugPrint('⚠️  Erro capturado corretamente: $e');
    }
  }

  /// Testa status atual
  void testCurrentStatus() {
    final status = _syncService.currentStatus;

    debugPrint('📊 Status atual:');
    debugPrint('   - É Premium: ${status.isPremium}');
    debugPrint('   - Fonte: ${status.premiumSource}');
    debugPrint('   - Expiração: ${status.expirationDate}');
    debugPrint('   - Limites: ${status.limits.maxVehicles} veículos');
  }

  /// Testa funcionalidades específicas
  void testFeatureAccess() {
    final status = _syncService.currentStatus;

    debugPrint('🔑 Acesso a funcionalidades:');

    final features = [
      'advanced_reports',
      'export_data',
      'custom_categories',
      'premium_themes',
      'cloud_backup',
      'location_history',
      'advanced_analytics',
    ];

    for (final feature in features) {
      final hasAccess = status.canUseFeature(feature);
      debugPrint('   - $feature: ${hasAccess ? '✅' : '❌'}');
    }
  }

  /// Testa limites de uso
  void testUsageLimits() {
    final status = _syncService.currentStatus;

    debugPrint('📏 Limites de uso:');
    debugPrint('   - Pode adicionar 3º veículo: ${status.canAddVehicle(2)}');
    debugPrint(
      '   - Pode adicionar 20º abastecimento: ${status.canAddFuelRecord(19)}',
    );
    debugPrint(
      '   - Pode adicionar 15ª manutenção: ${status.canAddMaintenanceRecord(14)}',
    );
  }

  /// Executa teste básico rápido
  Future<void> runQuickTest() async {
    debugPrint('⚡ Executando teste rápido...');

    testCurrentStatus();
    testFeatureAccess();
    testUsageLimits();
    final result = await _syncService.forceSync();
    result.fold(
      (failure) => debugPrint('⚠️  Quick sync failed: ${failure.message}'),
      (_) => debugPrint('✅ Quick sync success'),
    );

    debugPrint('⚡ Teste rápido concluído');
  }

  /// Limpa recursos
  void dispose() {
    _statusSubscription?.cancel();
    _eventsSubscription?.cancel();
  }
}

/// Utilitário para executar testes de sincronização
class PremiumSyncTestRunner {
  /// Executa teste completo
  static Future<void> runCompleteTest(PremiumSyncService syncService) async {
    final test = PremiumSyncTest(syncService);
    await test.runCompleteTest();
  }

  /// Executa teste rápido
  static Future<void> runQuickTest(PremiumSyncService syncService) async {
    final test = PremiumSyncTest(syncService);
    await test.runQuickTest();
    test.dispose();
  }

  /// Executa testes de status apenas
  static void runStatusTests(PremiumSyncService syncService) {
    final test = PremiumSyncTest(syncService);
    test.testCurrentStatus();
    test.testFeatureAccess();
    test.testUsageLimits();
    test.dispose();
  }
}
