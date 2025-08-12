// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../../../../repository/despesa_repository.dart';
import '../utils/despesas_utils.dart';
import 'despesas_filter_service.dart';

class DespesasService {
  Future<List<DespesaVet>> getDespesasForPeriod({
    required String animalId,
    DateTime? dataInicial,
    DateTime? dataFinal,
    required DespesaRepository repository,
  }) async {
    try {
      final dataInicialMs = dataInicial?.millisecondsSinceEpoch ??
          DateTime.now()
              .subtract(const Duration(days: 30))
              .millisecondsSinceEpoch;
      final dataFinalMs = dataFinal?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;

      return await repository.getDespesas(
        animalId,
        dataInicial: dataInicialMs,
        dataFinal: dataFinalMs,
      );
    } catch (e) {
      debugPrint('Erro ao buscar despesas: $e');
      return [];
    }
  }

  Future<List<DespesaVet>> getAllDespesas({
    required String animalId,
    required DespesaRepository repository,
  }) async {
    try {
      return await repository.getDespesas(animalId);
    } catch (e) {
      debugPrint('Erro ao buscar todas as despesas: $e');
      return [];
    }
  }

  double calculateTotal(List<DespesaVet> despesas) {
    return despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

  double calculateAverage(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return 0.0;
    return calculateTotal(despesas) / despesas.length;
  }

  // Delegate grouping operations to FilterService
  Map<String, double> groupByTipo(List<DespesaVet> despesas) {
    final filterService = DespesasFilterService();
    final grouped = filterService.groupByType(despesas);
    final result = <String, double>{};
    for (final entry in grouped.entries) {
      result[entry.key] = entry.value.fold(0.0, (sum, despesa) => sum + despesa.valor);
    }
    return result;
  }

  Map<String, int> countByTipo(List<DespesaVet> despesas) {
    final filterService = DespesasFilterService();
    return filterService.getTypeCount(despesas);
  }

  Map<String, double> groupByMes(List<DespesaVet> despesas) {
    final filterService = DespesasFilterService();
    return filterService.getMonthlyTotals(despesas);
  }

  // Delegate sorting operations to FilterService
  List<DespesaVet> getRecentes(List<DespesaVet> despesas, {int limit = 10}) {
    final filterService = DespesasFilterService();
    return filterService.getRecentExpenses(despesas, limit: limit);
  }

  DespesaVet? getMaior(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return null;
    return despesas.reduce((a, b) => a.valor > b.valor ? a : b);
  }

  DespesaVet? getMenor(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return null;
    return despesas.reduce((a, b) => a.valor < b.valor ? a : b);
  }

  String getTipoMaisFrequente(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return '';
    
    final counts = countByTipo(despesas);
    if (counts.isEmpty) return '';
    
    String tipoMaisFrequente = counts.keys.first;
    int maiorCount = counts.values.first;
    
    for (final entry in counts.entries) {
      if (entry.value > maiorCount) {
        maiorCount = entry.value;
        tipoMaisFrequente = entry.key;
      }
    }
    
    return tipoMaisFrequente;
  }

  List<DespesaVet> getDespesasDoMes(List<DespesaVet> despesas, DateTime mes) {
    final inicio = DateTime(mes.year, mes.month, 1);
    final fim = DateTime(mes.year, mes.month + 1, 0);
    
    return despesas.where((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.isAfter(inicio.subtract(const Duration(days: 1))) &&
             data.isBefore(fim.add(const Duration(days: 1)));
    }).toList();
  }

  List<DespesaVet> getDespesasDoAno(List<DespesaVet> despesas, int ano) {
    return despesas.where((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.year == ano;
    }).toList();
  }

  Map<int, double> getGastosPorAno(List<DespesaVet> despesas) {
    final result = <int, double>{};
    for (var despesa in despesas) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      result[data.year] = (result[data.year] ?? 0) + despesa.valor;
    }
    return result;
  }

  // Delegate all filtering and sorting operations to FilterService
  List<DespesaVet> filterByDateRange(
    List<DespesaVet> despesas,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filterService = DespesasFilterService();
    return filterService.filterByDateRange(despesas, startDate, endDate);
  }

  List<DespesaVet> filterByTipo(List<DespesaVet> despesas, String tipo) {
    final filterService = DespesasFilterService();
    return filterService.filterByTipo(despesas, tipo);
  }

  List<DespesaVet> filterByValorMinimo(List<DespesaVet> despesas, double valorMinimo) {
    final filterService = DespesasFilterService();
    return filterService.filterByValorMinimo(despesas, valorMinimo);
  }

  List<DespesaVet> filterByValorMaximo(List<DespesaVet> despesas, double valorMaximo) {
    final filterService = DespesasFilterService();
    return filterService.filterByValorMaximo(despesas, valorMaximo);
  }

  List<DespesaVet> sortByData(List<DespesaVet> despesas, {bool ascending = false}) {
    final filterService = DespesasFilterService();
    return filterService.sortByDate(despesas, ascending: ascending);
  }

  List<DespesaVet> sortByValor(List<DespesaVet> despesas, {bool ascending = true}) {
    final filterService = DespesasFilterService();
    return filterService.sortByValue(despesas, ascending: ascending);
  }

  List<DespesaVet> sortByTipo(List<DespesaVet> despesas, {bool ascending = true}) {
    final filterService = DespesasFilterService();
    return filterService.sortByType(despesas, ascending: ascending);
  }

  // Delegate CSV export to Utils
  String exportToCsv(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return '';
    
    const csvHeader = 'Data da Despesa,Tipo,Descrição,Valor\n';
    final csvRows = despesas.map((despesa) {
      final dataDespesa = DespesasUtils.escapeForCsv(
          DespesasUtils.formatarData(despesa.dataDespesa));
      final tipo = DespesasUtils.escapeForCsv(despesa.tipo);
      final descricao = DespesasUtils.escapeForCsv(despesa.descricao);
      final valor = DespesasUtils.formatarValor(despesa.valor);
      return '$dataDespesa,$tipo,$descricao,$valor';
    }).join('\n');
    
    return csvHeader + csvRows;
  }

  // Delegate statistics generation to Utils for consistency
  Map<String, dynamic> generateStatistics(List<DespesaVet> despesas) {
    return DespesasUtils.generateSummary(despesas);
  }

  bool hasRecentDespesas(List<DespesaVet> despesas, {int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return despesas.any((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.isAfter(cutoffDate);
    });
  }

  double getGastoMensal(List<DespesaVet> despesas, [DateTime? targetMonth]) {
    final month = targetMonth ?? DateTime.now();
    final despesasDoMes = getDespesasDoMes(despesas, month);
    return calculateTotal(despesasDoMes);
  }

  double getGastoAnual(List<DespesaVet> despesas, [int? targetYear]) {
    final year = targetYear ?? DateTime.now().year;
    final despesasDoAno = getDespesasDoAno(despesas, year);
    return calculateTotal(despesasDoAno);
  }

  List<String> getTiposUnicos(List<DespesaVet> despesas) {
    final filterService = DespesasFilterService();
    return filterService.getAvailableTypes(despesas);
  }

  Map<String, double> getPercentualPorTipo(List<DespesaVet> despesas) {
    final total = calculateTotal(despesas);
    if (total == 0) return {};
    
    final gastosPorTipo = groupByTipo(despesas);
    final percentuais = <String, double>{};
    
    for (final entry in gastosPorTipo.entries) {
      percentuais[entry.key] = (entry.value / total) * 100;
    }
    
    return percentuais;
  }

  Future<bool> deleteDespesa({
    required DespesaVet despesa,
    required DespesaRepository repository,
  }) async {
    try {
      return await repository.deleteDespesa(despesa);
    } catch (e) {
      debugPrint('Erro ao excluir despesa: $e');
      return false;
    }
  }

  Future<bool> updateDespesa({
    required DespesaVet despesa,
    required DespesaRepository repository,
  }) async {
    try {
      return await repository.updateDespesa(despesa);
    } catch (e) {
      debugPrint('Erro ao atualizar despesa: $e');
      return false;
    }
  }

  Future<bool> addDespesa({
    required DespesaVet despesa,
    required DespesaRepository repository,
  }) async {
    try {
      return await repository.addDespesa(despesa);
    } catch (e) {
      debugPrint('Erro ao adicionar despesa: $e');
      return false;
    }
  }
}
