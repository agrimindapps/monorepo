import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';

part 'reports_state.freezed.dart';

/// View states for reports feature
enum ReportsViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Tipo de relatório
enum ReportType {
  summary('Resumo Geral'),
  fuel('Combustível'),
  maintenance('Manutenção'),
  expenses('Despesas'),
  comparison('Comparação');

  const ReportType(this.displayName);
  final String displayName;
}

/// Período do relatório
enum ReportPeriod {
  week('Última Semana'),
  month('Último Mês'),
  threeMonths('3 Meses'),
  sixMonths('6 Meses'),
  year('Último Ano'),
  custom('Personalizado');

  const ReportPeriod(this.displayName);
  final String displayName;
}

/// State imutável para gerenciamento de relatórios
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
sealed class ReportsState with _$ReportsState {

  const factory ReportsState({
    /// Tipo de relatório selecionado
    @Default(ReportType.summary) ReportType selectedType,

    /// Período do relatório
    @Default(ReportPeriod.month) ReportPeriod selectedPeriod,

    /// Data inicial (para período customizado)
    DateTime? customStartDate,

    /// Data final (para período customizado)
    DateTime? customEndDate,

    /// Filtro por veículo
    String? selectedVehicleId,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Resumo do relatório
    ReportSummaryEntity? summary,

    /// Comparações entre veículos
    @Default([]) List<ReportComparisonEntity> comparisons,

    /// Dados para gráficos - Consumo ao longo do tempo
    @Default([]) List<Map<String, dynamic>> consumptionChartData,

    /// Dados para gráficos - Gastos ao longo do tempo
    @Default([]) List<Map<String, dynamic>> expensesChartData,

    /// Dados para gráficos - Distribuição por tipo
    @Default([]) List<Map<String, dynamic>> distributionChartData,

    /// Exportação em progresso
    @Default(false) bool isExporting,

    /// Formato de exportação (pdf, csv, excel)
    @Default('pdf') String exportFormat,
  }) = _ReportsState;
  const ReportsState._();

  /// Factory para estado inicial
  factory ReportsState.initial() => const ReportsState();

  // ========== Computed Properties ==========

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se há resumo carregado
  bool get hasSummary => summary != null;

  /// Verifica se há comparações
  bool get hasComparisons => comparisons.isNotEmpty;

  /// Verifica se há dados de gráficos
  bool get hasChartData =>
      consumptionChartData.isNotEmpty ||
      expensesChartData.isNotEmpty ||
      distributionChartData.isNotEmpty;

  /// Verifica se está usando período customizado
  bool get isCustomPeriod => selectedPeriod == ReportPeriod.custom;

  /// Verifica se o período customizado é válido
  bool get isCustomPeriodValid =>
      customStartDate != null &&
      customEndDate != null &&
      customEndDate!.isAfter(customStartDate!);

  /// Estado da view baseado nos dados
  ReportsViewState get viewState {
    if (isLoading) return ReportsViewState.loading;
    if (hasError) return ReportsViewState.error;
    if (!hasSummary && !hasComparisons) return ReportsViewState.empty;
    if (hasSummary || hasComparisons) return ReportsViewState.loaded;
    return ReportsViewState.initial;
  }

  /// Datas calculadas do período selecionado
  DateRange get calculatedDateRange {
    if (isCustomPeriod && isCustomPeriodValid) {
      return DateRange(customStartDate!, customEndDate!);
    }

    final now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod) {
      case ReportPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case ReportPeriod.threeMonths:
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case ReportPeriod.sixMonths:
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case ReportPeriod.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case ReportPeriod.custom:
        startDate = now.subtract(const Duration(days: 30)); // Fallback
        break;
    }

    return DateRange(startDate, now);
  }

  /// Título do relatório atual
  String get reportTitle {
    final typeStr = selectedType.displayName;
    final periodStr = selectedPeriod.displayName;
    return '$typeStr - $periodStr';
  }
}

/// Extension para métodos de transformação do state
extension ReportsStateX on ReportsState {
  /// Limpa mensagem de erro
  ReportsState clearError() => copyWith(error: null);

  /// Limpa dados do relatório
  ReportsState clearReportData() => copyWith(
        summary: null,
        comparisons: [],
        consumptionChartData: [],
        expensesChartData: [],
        distributionChartData: [],
      );

  /// Reseta ao estado inicial
  ReportsState reset() => ReportsState.initial();
}

/// Helper class para range de datas
class DateRange {

  DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
  int get days => duration.inDays;

  @override
  String toString() => '${start.toLocal()} - ${end.toLocal()}';
}
