// Project imports:
import '../../../../models/medicoes_models.dart';
import '../model/medicoes_page_model.dart';
import 'cache_service.dart';

/// Service responsável por cálculos estatísticos das medições
class StatisticsService with CacheableMixin {
  final CacheService _cache = CacheService();

  /// Calcula estatísticas para um mês específico com cache
  MonthStatistics calculateMonthStatistics(
      DateTime date, List<Medicoes> medicoesDoMes) {
    // Verifica cache primeiro
    final cached = _cache.getCachedMonthStatistics(date, medicoesDoMes);
    if (cached != null) {
      return cached;
    }

    if (medicoesDoMes.isEmpty) {
      const result = MonthStatistics(
        total: 0,
        media: 0,
        maximo: 0,
        diasComChuva: 0,
      );
      _cache.cacheMonthStatistics(date, medicoesDoMes, result);
      return result;
    }

    final total = _calculateTotal(medicoesDoMes);
    final media = _calculateAverage(total, date);
    final maximo = _calculateMaximum(medicoesDoMes);
    final diasComChuva = _calculateRainyDays(medicoesDoMes);

    final result = MonthStatistics(
      total: total,
      media: media,
      maximo: maximo,
      diasComChuva: diasComChuva,
    );

    // Armazena no cache
    _cache.cacheMonthStatistics(date, medicoesDoMes, result);
    return result;
  }

  /// Calcula total de precipitação
  double _calculateTotal(List<Medicoes> medicoes) {
    return medicoes.fold(0.0, (sum, item) => sum + item.quantidade);
  }

  /// Calcula média diária de precipitação
  double _calculateAverage(double total, DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return total / daysInMonth;
  }

  /// Calcula valor máximo de precipitação
  double _calculateMaximum(List<Medicoes> medicoes) {
    if (medicoes.isEmpty) return 0.0;

    return medicoes
        .map((e) => e.quantidade.toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  /// Calcula número de dias com chuva
  int _calculateRainyDays(List<Medicoes> medicoes) {
    return medicoes.where((m) => m.quantidade > 0).length;
  }

  /// Calcula estatísticas anuais com cache
  MonthStatistics calculateYearlyStatistics(List<Medicoes> medicoes, int year) {
    return memoize('yearly_stats_$year', () {
      final yearMedicoes = medicoes.where((m) {
        final date = DateTime.fromMillisecondsSinceEpoch(m.dtMedicao);
        return date.year == year;
      }).toList();

      final total = _calculateTotal(yearMedicoes);
      final media = total / 12; // Média mensal
      final maximo = _calculateMaximum(yearMedicoes);
      final diasComChuva = _calculateRainyDays(yearMedicoes);

      return MonthStatistics(
        total: total,
        media: media,
        maximo: maximo,
        diasComChuva: diasComChuva,
      );
    }, ttl: const Duration(hours: 1));
  }

  /// Calcula tendência de precipitação (comparando com período anterior)
  double calculateTrend(
      List<Medicoes> currentPeriod, List<Medicoes> previousPeriod) {
    final currentTotal = _calculateTotal(currentPeriod);
    final previousTotal = _calculateTotal(previousPeriod);

    if (previousTotal == 0) return 0.0;

    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  /// Identifica anomalias nos dados (valores muito acima da média) com cache
  List<Medicoes> findAnomalies(List<Medicoes> medicoes,
      {double threshold = 2.0}) {
    if (medicoes.length < 2) return [];

    final cacheKey = 'anomalies_${medicoes.length}_$threshold';
    return memoize(cacheKey, () {
      final values = medicoes.map((m) => m.quantidade).toList();
      final average = values.reduce((a, b) => a + b) / values.length;
      final variance = values
              .map((x) => (x - average) * (x - average))
              .reduce((a, b) => a + b) /
          values.length;
      final standardDeviation = variance > 0 ? (variance).abs() : 0.0;

      return medicoes
          .where((m) =>
              (m.quantidade - average).abs() > threshold * standardDeviation)
          .toList();
    }, ttl: const Duration(minutes: 10));
  }

  /// Invalida cache para um pluviômetro específico
  void invalidatePluviometroCache(String pluviometroId) {
    _cache.invalidatePluviometro(pluviometroId);
  }

  /// Invalida cache para uma data específica
  void invalidateDateCache(DateTime date) {
    _cache.invalidateDate(date);
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStatistics() {
    return _cache.getCacheStats();
  }
}
