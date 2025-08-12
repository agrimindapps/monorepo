// Project imports:
import '../../../core/interfaces/realtime_repository_interface.dart';
import '../database/23_abastecimento_model.dart';
import 'hive_abastecimentos_adapter.dart';

/// Repositório híbrido para abastecimentos que combina armazenamento local (Hive)
///
/// Estratégia simplificada:
/// 1. Dados sempre salvos no Hive primeiro (offline-first)
/// 2. Interface compatível com RealtimeRepositoryInterface
class HybridAbastecimentosRepository
    implements RealtimeRepositoryInterface<AbastecimentoCar> {
  late final HiveAbastecimentosAdapter _localRepository;

  HybridAbastecimentosRepository() {
    _localRepository = HiveAbastecimentosAdapter();
  }

  String getId(AbastecimentoCar item) => item.id;

  // Implementação da interface RealtimeRepositoryInterface

  @override
  Stream<List<AbastecimentoCar>> watchAll() {
    return _localRepository.watchAll();
  }

  @override
  Stream<AbastecimentoCar?> watchById(String id) {
    return _localRepository.watchById(id);
  }

  @override
  Future<List<AbastecimentoCar>> findAll() {
    return _localRepository.findAll();
  }

  @override
  Future<AbastecimentoCar?> findById(String id) {
    return _localRepository.findById(id);
  }

  @override
  Future<String> create(AbastecimentoCar item) {
    return _localRepository.create(item);
  }

  @override
  Future<void> update(String id, AbastecimentoCar item) {
    return _localRepository.update(id, item);
  }

  @override
  Future<void> delete(String id) {
    return _localRepository.delete(id);
  }

  @override
  Future<void> createBatch(List<AbastecimentoCar> items) {
    return _localRepository.createBatch(items);
  }

  @override
  Future<void> updateBatch(Map<String, AbastecimentoCar> items) {
    return _localRepository.updateBatch(items);
  }

  @override
  Future<void> deleteBatch(List<String> ids) {
    return _localRepository.deleteBatch(ids);
  }

  @override
  Future<void> clear() {
    return _localRepository.clear();
  }

  @override
  Future<void> initialize() {
    return _localRepository.initialize();
  }

  @override
  bool get isInitialized => _localRepository.isInitialized;

  @override
  bool get isOnline => _localRepository.isOnline;

  // Métodos específicos do gasometer para abastecimentos

  /// Buscar abastecimentos por veículo específico
  Future<List<AbastecimentoCar>> getAbastecimentosByVeiculo(
      String veiculoId) async {
    try {
      // Sempre buscar do local primeiro (mais rápido)
      final items = await _localRepository.findAll();
      return items.where((item) => item.veiculoId == veiculoId).toList();
    } catch (e) {
      throw Exception('Erro ao buscar abastecimentos do veículo: $e');
    }
  }

  /// Stream de abastecimentos por veículo específico
  Stream<List<AbastecimentoCar>> watchAbastecimentosByVeiculo(
      String veiculoId) {
    return _localRepository.watchAll().map(
        (items) => items.where((item) => item.veiculoId == veiculoId).toList());
  }

  /// Buscar abastecimentos agrupados por mês (usando adapter local)
  Future<Map<DateTime, List<AbastecimentoCar>>> getAbastecimentosAgrupados(
      String veiculoId) async {
    try {
      final abastecimentos = await getAbastecimentosByVeiculo(veiculoId);

      // Agrupar por mês
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
    } catch (e) {
      throw Exception('Erro ao agrupar abastecimentos: $e');
    }
  }

  /// Obter analytics mensais (delegando para adapter local quando possível)
  Future<Map<String, double>> getMonthlyAnalytics(
      DateTime date, String veiculoId) async {
    try {
      // Tentar usar método otimizado do adapter local
      return await _localRepository.getMonthlyAnalytics(date, veiculoId);
    } catch (e) {
      // Fallback: calcular manualmente
      return await _calculateAnalyticsManually(date, veiculoId);
    }
  }

  /// Calcular analytics manualmente como fallback
  Future<Map<String, double>> _calculateAnalyticsManually(
      DateTime date, String veiculoId) async {
    try {
      final abastecimentos = await getAbastecimentosByVeiculo(veiculoId);

      // Filtrar por mês
      final abastecimentosDoMes = abastecimentos.where((abastecimento) {
        final dataAbastecimento =
            DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
        return dataAbastecimento.year == date.year &&
            dataAbastecimento.month == date.month;
      }).toList();

      if (abastecimentosDoMes.isEmpty) {
        return {
          'totalGastoMes': 0.0,
          'totalLitrosMes': 0.0,
          'precoMedioLitro': 0.0,
          'mediaConsumoMes': 0.0,
        };
      }

      final totalGastoMes =
          abastecimentosDoMes.fold(0.0, (sum, item) => sum + item.valorTotal);
      final totalLitrosMes =
          abastecimentosDoMes.fold(0.0, (sum, item) => sum + item.litros);
      final precoMedioLitro =
          totalLitrosMes > 0 ? totalGastoMes / totalLitrosMes : 0.0;

      // Calcular consumo médio
      double mediaConsumoMes = 0.0;
      if (abastecimentosDoMes.length > 1) {
        abastecimentosDoMes.sort((a, b) => a.data.compareTo(b.data));
        final kmInicial = abastecimentosDoMes.first.odometro;
        final kmFinal = abastecimentosDoMes.last.odometro;
        final distanciaPercorrida = kmFinal - kmInicial;

        if (distanciaPercorrida > 0 && totalLitrosMes > 0) {
          mediaConsumoMes = distanciaPercorrida / totalLitrosMes;
        }
      }

      return {
        'totalGastoMes': totalGastoMes,
        'totalLitrosMes': totalLitrosMes,
        'precoMedioLitro': precoMedioLitro,
        'mediaConsumoMes': mediaConsumoMes,
      };
    } catch (e) {
      throw Exception('Erro ao calcular analytics: $e');
    }
  }

  /// Exportar para CSV (usando adapter local)
  Future<String> exportToCsv(String veiculoId) async {
    try {
      return await _localRepository.exportToCsv(veiculoId);
    } catch (e) {
      throw Exception('Erro ao exportar CSV: $e');
    }
  }

  /// Obter último abastecimento de um veículo
  Future<AbastecimentoCar?> getUltimoAbastecimento(String veiculoId) async {
    try {
      final abastecimentos = await getAbastecimentosByVeiculo(veiculoId);

      if (abastecimentos.isEmpty) return null;

      // Encontrar o mais recente
      abastecimentos.sort((a, b) => b.data.compareTo(a.data));
      return abastecimentos.first;
    } catch (e) {
      throw Exception('Erro ao obter último abastecimento: $e');
    }
  }

  /// Obter lista de meses com abastecimentos
  Future<List<DateTime>> getMonthsList(String veiculoId) async {
    try {
      final abastecimentos = await getAbastecimentosByVeiculo(veiculoId);

      if (abastecimentos.isEmpty) return [];

      final Set<DateTime> meses = {};

      for (final abastecimento in abastecimentos) {
        final data = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
        meses.add(DateTime(data.year, data.month));
      }

      final listaOrdenada = meses.toList();
      listaOrdenada.sort((a, b) => b.compareTo(a)); // Mais recente primeiro

      return listaOrdenada;
    } catch (e) {
      throw Exception('Erro ao obter lista de meses: $e');
    }
  }

  /// Validar dados antes de operações
  bool validarAbastecimento(AbastecimentoCar abastecimento) {
    if (abastecimento.veiculoId.isEmpty) return false;
    if (abastecimento.litros <= 0) return false;
    if (abastecimento.valorTotal <= 0) return false;
    if (abastecimento.odometro <= 0) return false;
    if (abastecimento.precoPorLitro <= 0) return false;

    return true;
  }

  /// Create com validação
  Future<String> createValidated(AbastecimentoCar item) async {
    if (!validarAbastecimento(item)) {
      throw Exception('Dados do abastecimento são inválidos');
    }

    // Garantir que updatedAt seja atual
    item.updatedAt = DateTime.now().millisecondsSinceEpoch;

    return await _localRepository.create(item);
  }

  /// Update com validação
  Future<void> updateValidated(String id, AbastecimentoCar item) async {
    if (!validarAbastecimento(item)) {
      throw Exception('Dados do abastecimento são inválidos');
    }

    // Garantir que updatedAt seja atual
    item.updatedAt = DateTime.now().millisecondsSinceEpoch;

    await _localRepository.update(id, item);
  }

  /// Limpar recursos quando não precisar mais
  void dispose() {
    // Implementar se necessário
  }
}
