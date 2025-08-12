// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/services/sync_firebase_service.dart';
import '../database/23_abastecimento_model.dart';
import '../repository/veiculos_repository.dart';

/// Controller reativo MIGRADO para usar SyncFirebaseService diretamente
///
/// Esta é a versão 2.0 que substitui o RealtimeController + Repositories
/// por uma abordagem simplificada usando apenas SyncFirebaseService.
class RealtimeAbastecimentosController extends GetxController {
  late final SyncFirebaseService<AbastecimentoCar> _syncService;
  final VeiculosRepository _veiculosRepository = VeiculosRepository();

  // Estado reativo (compatível com versão anterior)
  final RxList<AbastecimentoCar> items = <AbastecimentoCar>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOnline = false.obs;
  final RxString syncStatus = 'Inicializando...'.obs;

  // Estado específico do gasometer (mantido igual)
  final RxString selectedVeiculoId = ''.obs;
  final RxMap<DateTime, List<AbastecimentoCar>> abastecimentosAgrupados =
      RxMap<DateTime, List<AbastecimentoCar>>();
  final RxMap<String, double> monthlyAnalytics = RxMap<String, double>();
  final RxList<DateTime> availableMonths = <DateTime>[].obs;
  final Rx<DateTime?> selectedMonth = Rx<DateTime?>(null);

  // Getters computados (mantidos iguais)
  List<AbastecimentoCar> get abastecimentosDoVeiculo {
    if (selectedVeiculoId.value.isEmpty) return items;
    return items
        .where((item) => item.veiculoId == selectedVeiculoId.value)
        .toList();
  }

  List<AbastecimentoCar> get abastecimentosDoMes {
    if (selectedMonth.value == null) return abastecimentosDoVeiculo;

    return abastecimentosDoVeiculo.where((item) {
      final dataItem = DateTime.fromMillisecondsSinceEpoch(item.data);
      final mesItem = DateTime(dataItem.year, dataItem.month);
      return mesItem == selectedMonth.value;
    }).toList();
  }

  bool get hasAbastecimentos => abastecimentosDoVeiculo.isNotEmpty;
  bool get hasSelectedVehicle => selectedVeiculoId.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeSyncService();
  }

  /// Inicializar SyncFirebaseService (substitui múltiplos repositórios)
  Future<void> _initializeSyncService() async {
    try {
      isLoading.value = true;

      // Criar instância do SyncFirebaseService
      _syncService = SyncFirebaseService.getInstance<AbastecimentoCar>(
        'gasometer_abastecimentos',
        (map) => AbastecimentoCar.fromMap(map),
        (item) => item.toMap(),
      );

      // Inicializar serviço
      await _syncService.initialize();

      // Configurar listeners para streams
      _setupStreamListeners();

      // Carregar dados iniciais
      await _loadInitialData();

      // Inicializar veículo selecionado
      await _initializeSelectedVehicle();
    } catch (e) {
      _handleError('Erro ao inicializar sincronização', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Configurar listeners para streams do SyncFirebaseService
  void _setupStreamListeners() {
    // Stream de dados - substitui watchAll() do repositório
    _syncService.dataStream.listen(
      (List<AbastecimentoCar> newItems) {
        items.value = newItems;
        isLoading.value = false;
        hasError.value = false;
        _onItemsUpdated(newItems);
      },
      onError: (error) {
        _handleError('Erro no stream de dados', error);
      },
    );

    // Stream de conectividade
    _syncService.connectivityStream.listen(
      (bool online) {
        isOnline.value = online;
        _updateStatusMessage();
      },
    );

    // Stream de status de sincronização
    _syncService.syncStatusStream.listen(
      (SyncStatus status) {
        syncStatus.value = _getSyncStatusText(status);
        _updateStatusMessage();
      },
    );
  }

  /// Carregar dados iniciais
  Future<void> _loadInitialData() async {
    try {
      final initialItems = await _syncService.findAll();
      items.value = initialItems;
      debugPrint('📦 ${initialItems.length} abastecimentos carregados');
    } catch (e) {
      _handleError('Erro ao carregar dados iniciais', e);
    }
  }

  /// Inicializar veículo selecionado (mantido igual)
  Future<void> _initializeSelectedVehicle() async {
    try {
      final vehicleId = await _veiculosRepository.getSelectedVeiculoId();
      if (vehicleId.isNotEmpty) {
        await setVeiculoSelecionado(vehicleId);
      }
    } catch (e) {
      debugPrint('❌ Erro ao inicializar veículo selecionado: $e');
    }
  }

  /// Callback quando items são atualizados
  void _onItemsUpdated(List<AbastecimentoCar> newItems) {
    debugPrint('🔄 ${newItems.length} abastecimentos sincronizados');

    if (hasSelectedVehicle) {
      _updateDerivedData();
    }
  }

  /// Atualizar dados derivados (mantido similar)
  Future<void> _updateDerivedData() async {
    if (!hasSelectedVehicle) return;

    try {
      // Agrupar abastecimentos por mês
      final agrupados = _groupAbastecimentosByMonth(abastecimentosDoVeiculo);
      abastecimentosAgrupados.value = agrupados;

      // Atualizar lista de meses disponíveis
      final meses = agrupados.keys.toList();
      meses.sort((a, b) => b.compareTo(a)); // Mais recente primeiro
      availableMonths.value = meses;

      // Se não há mês selecionado e há meses disponíveis, selecionar o mais recente
      if (selectedMonth.value == null && meses.isNotEmpty) {
        selectedMonth.value = meses.first;
      }

      // Atualizar analytics do mês selecionado
      if (selectedMonth.value != null) {
        _updateMonthlyAnalytics();
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar dados derivados: $e');
    }
  }

  /// Agrupar abastecimentos por mês
  Map<DateTime, List<AbastecimentoCar>> _groupAbastecimentosByMonth(
      List<AbastecimentoCar> abastecimentos) {
    final Map<DateTime, List<AbastecimentoCar>> agrupados = {};

    for (final abastecimento in abastecimentos) {
      final data = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
      final mesAno = DateTime(data.year, data.month);

      if (!agrupados.containsKey(mesAno)) {
        agrupados[mesAno] = [];
      }
      agrupados[mesAno]!.add(abastecimento);
    }

    // Ordenar cada lista por data
    agrupados.forEach((key, value) {
      value.sort((a, b) => b.data.compareTo(a.data));
    });

    return agrupados;
  }

  /// Atualizar analytics mensais
  void _updateMonthlyAnalytics() {
    if (!hasSelectedVehicle || selectedMonth.value == null) return;

    try {
      final abastecimentosDoMesAtual = abastecimentosDoMes;

      if (abastecimentosDoMesAtual.isEmpty) {
        monthlyAnalytics.value = {
          'totalGastoMes': 0.0,
          'totalLitrosMes': 0.0,
          'precoMedioLitro': 0.0,
          'mediaConsumoMes': 0.0,
        };
        return;
      }

      final totalGastoMes = abastecimentosDoMesAtual.fold(
          0.0, (sum, item) => sum + item.valorTotal);
      final totalLitrosMes =
          abastecimentosDoMesAtual.fold(0.0, (sum, item) => sum + item.litros);
      final precoMedioLitro =
          totalLitrosMes > 0 ? totalGastoMes / totalLitrosMes : 0.0;

      // Calcular consumo médio
      double mediaConsumoMes = 0.0;
      if (abastecimentosDoMesAtual.length > 1) {
        final sorted = abastecimentosDoMesAtual.toList();
        sorted.sort((a, b) => a.data.compareTo(b.data));
        final kmInicial = sorted.first.odometro;
        final kmFinal = sorted.last.odometro;
        final distanciaPercorrida = kmFinal - kmInicial;

        if (distanciaPercorrida > 0 && totalLitrosMes > 0) {
          mediaConsumoMes = distanciaPercorrida / totalLitrosMes;
        }
      }

      monthlyAnalytics.value = {
        'totalGastoMes': totalGastoMes,
        'totalLitrosMes': totalLitrosMes,
        'precoMedioLitro': precoMedioLitro,
        'mediaConsumoMes': mediaConsumoMes,
      };
    } catch (e) {
      debugPrint('❌ Erro ao calcular analytics mensais: $e');
    }
  }

  // Métodos públicos (interface mantida compatível)

  /// Definir veículo selecionado
  Future<void> setVeiculoSelecionado(String veiculoId) async {
    try {
      selectedVeiculoId.value = veiculoId;
      await _veiculosRepository.setSelectedVeiculoId(veiculoId);

      // Reset mês selecionado
      selectedMonth.value = null;

      // Forçar atualização dos dados
      await _updateDerivedData();
    } catch (e) {
      _handleError('Erro ao selecionar veículo', e);
    }
  }

  /// Definir mês selecionado
  Future<void> setMesSelecionado(DateTime mes) async {
    try {
      selectedMonth.value = mes;
      _updateMonthlyAnalytics();
    } catch (e) {
      _handleError('Erro ao selecionar mês', e);
    }
  }

  /// Adicionar novo abastecimento (usando SyncFirebaseService)
  Future<void> adicionarAbastecimento({
    required String veiculoId,
    required int data,
    required double odometro,
    required double litros,
    required double valorTotal,
    required bool tanqueCheio,
    required double precoPorLitro,
    String? posto,
    String? observacao,
    required int tipoCombustivel,
  }) async {
    try {
      isLoading.value = true;

      final abastecimento = AbastecimentoCar(
        id: '', // Será gerado automaticamente pelo SyncFirebaseService
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        veiculoId: veiculoId,
        data: data,
        odometro: odometro,
        litros: litros,
        valorTotal: valorTotal,
        tanqueCheio: tanqueCheio,
        precoPorLitro: precoPorLitro,
        posto: posto,
        observacao: observacao,
        tipoCombustivel: tipoCombustivel,
      );

      final id = await _syncService.create(abastecimento);

      // Atualizar odômetro do veículo
      await _updateVehicleOdometer(abastecimento);

      // Mostrar feedback de sucesso
      _showSuccessMessage(
          'Abastecimento de ${litros.toStringAsFixed(1)}L adicionado');

      debugPrint('✅ Abastecimento criado com ID: $id');
    } catch (e) {
      _handleError('Erro ao adicionar abastecimento', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Editar abastecimento existente (usando SyncFirebaseService)
  Future<void> editarAbastecimento(
    String id,
    AbastecimentoCar abastecimentoAtualizado,
  ) async {
    try {
      isLoading.value = true;

      // Atualizar timestamp
      abastecimentoAtualizado.updatedAt = DateTime.now().millisecondsSinceEpoch;

      await _syncService.update(id, abastecimentoAtualizado);

      _showSuccessMessage('Abastecimento atualizado');
    } catch (e) {
      _handleError('Erro ao editar abastecimento', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Remover abastecimento (usando SyncFirebaseService)
  Future<void> removerAbastecimento(String id) async {
    try {
      isLoading.value = true;

      await _syncService.delete(id);

      _showSuccessMessage('Abastecimento removido');
    } catch (e) {
      _handleError('Erro ao remover abastecimento', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Obter último abastecimento
  Future<AbastecimentoCar?> getUltimoAbastecimento() async {
    if (!hasSelectedVehicle) return null;

    try {
      final abastecimentos = abastecimentosDoVeiculo;
      if (abastecimentos.isEmpty) return null;

      // Encontrar o mais recente
      abastecimentos.sort((a, b) => b.data.compareTo(a.data));
      return abastecimentos.first;
    } catch (e) {
      _handleError('Erro ao buscar último abastecimento', e);
      return null;
    }
  }

  /// Exportar dados para CSV (simplificado)
  Future<String?> exportarCSV() async {
    if (!hasSelectedVehicle) {
      Get.snackbar('Aviso', 'Selecione um veículo primeiro');
      return null;
    }

    try {
      // Implementação básica de export CSV
      final abastecimentos = abastecimentosDoVeiculo;
      if (abastecimentos.isEmpty) {
        Get.snackbar('Aviso', 'Nenhum abastecimento para exportar');
        return null;
      }

      final csv = _generateCSV(abastecimentos);
      _showSuccessMessage('CSV gerado com ${abastecimentos.length} registros');
      return csv;
    } catch (e) {
      _handleError('Erro ao exportar CSV', e);
      return null;
    }
  }

  /// Forçar sincronização
  Future<void> forceSync() async {
    try {
      isLoading.value = true;
      await _syncService.forceSync();
      _showSuccessMessage('Sincronização forçada concluída');
    } catch (e) {
      _handleError('Erro na sincronização forçada', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Recarregar dados
  @override
  Future<void> refresh() async {
    await _loadInitialData();
    await _updateDerivedData();
  }

  // Métodos utilitários (mantidos iguais)

  String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  String formatarData(int timestamp) {
    final data = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String getNomeCombustivel(int tipo) {
    switch (tipo) {
      case 0:
        return 'Gasolina';
      case 1:
        return 'Etanol';
      case 2:
        return 'Diesel';
      case 3:
        return 'GNV';
      case 4:
        return 'Elétrico';
      case 5:
        return 'Híbrido';
      default:
        return 'Desconhecido';
    }
  }

  // Métodos privados

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

  void _updateStatusMessage() {
    // Lógica adicional se necessário
  }

  void _handleError(String message, dynamic error) {
    hasError.value = true;
    errorMessage.value = '$message: ${error.toString()}';
    isLoading.value = false;

    debugPrint('❌ $message: $error');

    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _updateVehicleOdometer(AbastecimentoCar abastecimento) async {
    try {
      await _veiculosRepository.updateOdometroAtual(
        abastecimento.veiculoId,
        abastecimento.odometro,
      );
    } catch (e) {
      debugPrint(
          '⚠️ Aviso: Não foi possível atualizar odômetro do veículo: $e');
    }
  }

  String _generateCSV(List<AbastecimentoCar> abastecimentos) {
    final buffer = StringBuffer();

    // Cabeçalho
    buffer.writeln(
        'Data,Odometro,Litros,Valor Total,Preço por Litro,Posto,Combustível,Observação');

    // Dados
    for (final item in abastecimentos) {
      final data = formatarData(item.data);
      final posto = item.posto?.replaceAll(',', ';') ?? '';
      final observacao = item.observacao?.replaceAll(',', ';') ?? '';
      final combustivel = getNomeCombustivel(item.tipoCombustivel);

      buffer.writeln(
          '$data,${item.odometro},${item.litros},${item.valorTotal},${item.precoPorLitro},$posto,$combustivel,$observacao');
    }

    return buffer.toString();
  }

  /// Obter informações de debug do SyncFirebaseService
  Map<String, dynamic> getDebugInfo() {
    return _syncService.getDebugInfo();
  }

  @override
  void onClose() {
    _syncService.dispose();
    super.onClose();
  }
}
