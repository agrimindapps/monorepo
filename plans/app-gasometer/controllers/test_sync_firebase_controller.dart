// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/services/sync_firebase_service.dart';
import '../database/23_abastecimento_model.dart';

/// Controller de teste para validar SyncFirebaseService com AbastecimentoCar
///
/// Este controller testa todas as funcionalidades do SyncFirebaseService
/// antes da migração completa da arquitetura.
class TestSyncFirebaseController extends GetxController {
  late final SyncFirebaseService<AbastecimentoCar> _syncService;

  // Estado reativo para UI
  final RxList<AbastecimentoCar> items = <AbastecimentoCar>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOnline = false.obs;
  final RxString syncStatus = 'Inicializando...'.obs;
  final RxString testResults = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSyncService();
  }

  /// Inicializar SyncFirebaseService
  Future<void> _initializeSyncService() async {
    try {
      isLoading.value = true;
      _addTestResult('🚀 Inicializando SyncFirebaseService...');

      // Criar instância do SyncFirebaseService
      _syncService = SyncFirebaseService.getInstance<AbastecimentoCar>(
        'test_gasometer_abastecimentos',
        (map) => AbastecimentoCar.fromMap(map),
        (item) => item.toMap(),
      );

      _addTestResult('✅ Instância criada com sucesso');

      // Inicializar serviço
      await _syncService.initialize();
      _addTestResult('✅ Serviço inicializado');

      // Configurar listeners
      _setupListeners();
      _addTestResult('✅ Listeners configurados');

      // Carregar dados iniciais
      await _loadInitialData();
      _addTestResult('✅ Dados iniciais carregados');

      _addTestResult('🎉 Inicialização completa! Pronto para testes.');
    } catch (e) {
      _addTestResult('❌ Erro na inicialização: $e');
      _handleError('Erro na inicialização', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Configurar listeners para streams
  void _setupListeners() {
    // Stream de dados
    _syncService.dataStream.listen(
      (List<AbastecimentoCar> newItems) {
        items.value = newItems;
        _addTestResult('📦 Dados atualizados: ${newItems.length} itens');
      },
      onError: (error) {
        _addTestResult('❌ Erro no stream de dados: $error');
      },
    );

    // Stream de conectividade
    _syncService.connectivityStream.listen(
      (bool online) {
        isOnline.value = online;
        _addTestResult('🌐 Conectividade: ${online ? 'Online' : 'Offline'}');
      },
    );

    // Stream de status de sync
    _syncService.syncStatusStream.listen(
      (SyncStatus status) {
        syncStatus.value = _getSyncStatusText(status);
        _addTestResult('🔄 Status: ${syncStatus.value}');
      },
    );
  }

  /// Carregar dados iniciais
  Future<void> _loadInitialData() async {
    try {
      final initialItems = await _syncService.findAll();
      items.value = initialItems;
      _addTestResult('📥 ${initialItems.length} itens carregados do local');
    } catch (e) {
      _addTestResult('❌ Erro ao carregar dados iniciais: $e');
    }
  }

  /// Teste 1: Criar novo abastecimento
  Future<void> testCreateAbastecimento() async {
    try {
      isLoading.value = true;
      _addTestResult('🧪 TESTE 1: Criando novo abastecimento...');

      final novoAbastecimento = AbastecimentoCar(
        id: '', // Será gerado automaticamente
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        veiculoId: 'veiculo_teste_001',
        data: DateTime.now().millisecondsSinceEpoch,
        odometro: 15000.0,
        litros: 40.5,
        valorTotal: 250.00,
        tanqueCheio: true,
        precoPorLitro: 6.17,
        posto: 'Posto Teste',
        observacao: 'Teste do SyncFirebaseService',
        tipoCombustivel: 0, // Gasolina
      );

      final id = await _syncService.create(novoAbastecimento);
      _addTestResult('✅ TESTE 1: Abastecimento criado com ID: $id');
      _addTestResult('📊 Total de itens: ${items.length}');
    } catch (e) {
      _addTestResult('❌ TESTE 1: Falhou - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Teste 2: Buscar todos os abastecimentos
  Future<void> testFindAll() async {
    try {
      isLoading.value = true;
      _addTestResult('🧪 TESTE 2: Buscando todos os abastecimentos...');

      final allItems = await _syncService.findAll();
      _addTestResult(
          '✅ TESTE 2: Encontrados ${allItems.length} abastecimentos');

      for (int i = 0; i < allItems.length && i < 3; i++) {
        final item = allItems[i];
        _addTestResult(
            '  📋 Item ${i + 1}: ${item.litros}L - R\$ ${item.valorTotal.toStringAsFixed(2)}');
      }
    } catch (e) {
      _addTestResult('❌ TESTE 2: Falhou - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Teste 3: Atualizar abastecimento
  Future<void> testUpdateAbastecimento() async {
    try {
      if (items.isEmpty) {
        _addTestResult('⚠️ TESTE 3: Sem itens para atualizar');
        return;
      }

      isLoading.value = true;
      _addTestResult('🧪 TESTE 3: Atualizando abastecimento...');

      final itemToUpdate = items.first.clone();
      itemToUpdate.observacao =
          'Atualizado via SyncFirebaseService - ${DateTime.now()}';
      itemToUpdate.updatedAt = DateTime.now().millisecondsSinceEpoch;

      await _syncService.update(itemToUpdate.id, itemToUpdate);
      _addTestResult('✅ TESTE 3: Abastecimento ${itemToUpdate.id} atualizado');
    } catch (e) {
      _addTestResult('❌ TESTE 3: Falhou - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Teste 4: Forçar sincronização
  Future<void> testForceSync() async {
    try {
      isLoading.value = true;
      _addTestResult('🧪 TESTE 4: Forçando sincronização...');

      await _syncService.forceSync();
      _addTestResult('✅ TESTE 4: Sincronização forçada concluída');
    } catch (e) {
      _addTestResult('❌ TESTE 4: Falhou - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Teste 5: Informações de debug
  Future<void> testDebugInfo() async {
    try {
      _addTestResult('🧪 TESTE 5: Informações de debug...');

      final debugInfo = _syncService.getDebugInfo();
      _addTestResult('✅ TESTE 5: Debug info obtido');
      _addTestResult('📊 Collection: ${debugInfo['collectionName']}');
      _addTestResult('📊 Inicializado: ${debugInfo['isInitialized']}');
      _addTestResult('📊 Online: ${debugInfo['isOnline']}');
      _addTestResult('📊 Usuário: ${debugInfo['currentUser'] ?? 'Não logado'}');
      _addTestResult('📊 Status: ${debugInfo['syncStatus']}');
      _addTestResult('📊 Pode sincronizar: ${debugInfo['canSync']}');
      _addTestResult('📊 Itens locais: ${debugInfo['localItemsCount']}');
    } catch (e) {
      _addTestResult('❌ TESTE 5: Falhou - $e');
    }
  }

  /// Executar todos os testes em sequência
  Future<void> runAllTests() async {
    _clearTestResults();
    _addTestResult('🎯 INICIANDO BATERIA DE TESTES COMPLETA');
    _addTestResult('=' * 50);

    await testFindAll();
    await Future.delayed(const Duration(seconds: 1));

    await testCreateAbastecimento();
    await Future.delayed(const Duration(seconds: 2));

    await testUpdateAbastecimento();
    await Future.delayed(const Duration(seconds: 1));

    await testForceSync();
    await Future.delayed(const Duration(seconds: 1));

    await testDebugInfo();

    _addTestResult('=' * 50);
    _addTestResult('🏁 BATERIA DE TESTES CONCLUÍDA');

    // Mostrar resultado final
    Get.snackbar(
      'Testes Concluídos',
      'Bateria de testes do SyncFirebaseService finalizada!',
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Limpar dados de teste
  Future<void> clearTestData() async {
    try {
      isLoading.value = true;
      _addTestResult('🗑️ Limpando dados de teste...');

      await _syncService.clearAllData();
      _addTestResult('✅ Dados de teste limpos');

      items.clear();
    } catch (e) {
      _addTestResult('❌ Erro ao limpar dados: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos utilitários

  void _addTestResult(String message) {
    final timestamp = DateTime.now();
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    testResults.value += '[$formattedTime] $message\n';
    debugPrint('🧪 [TestSyncFirebase] $message');
  }

  void _clearTestResults() {
    testResults.value = '';
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.localOnly:
        return 'Apenas Local';
      case SyncStatus.syncing:
        return 'Sincronizando';
    }
  }

  void _handleError(String message, dynamic error) {
    hasError.value = true;
    errorMessage.value = '$message: ${error.toString()}';

    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    _syncService.dispose();
    super.onClose();
  }
}
