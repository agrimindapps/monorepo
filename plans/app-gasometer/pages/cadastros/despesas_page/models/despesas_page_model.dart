// Project imports:
import '../../../../database/22_despesas_model.dart';

class DespesasPageModel {
  final Map<DateTime, List<DespesaCar>> despesasPorMes;
  final bool isLoading;
  final bool showHeader;
  final int currentCarouselIndex;
  final String selectedVeiculoId;

  const DespesasPageModel({
    required this.despesasPorMes,
    required this.isLoading,
    required this.showHeader,
    required this.currentCarouselIndex,
    required this.selectedVeiculoId,
  });

  factory DespesasPageModel.initial() {
    return const DespesasPageModel(
      despesasPorMes: {},
      isLoading: false,
      showHeader: true,
      currentCarouselIndex: 0,
      selectedVeiculoId: '',
    );
  }

  DespesasPageModel copyWith({
    Map<DateTime, List<DespesaCar>>? despesasPorMes,
    bool? isLoading,
    bool? showHeader,
    int? currentCarouselIndex,
    String? selectedVeiculoId,
  }) {
    return DespesasPageModel(
      despesasPorMes: despesasPorMes ?? this.despesasPorMes,
      isLoading: isLoading ?? this.isLoading,
      showHeader: showHeader ?? this.showHeader,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      selectedVeiculoId: selectedVeiculoId ?? this.selectedVeiculoId,
    );
  }

  // Getters de conveniência
  bool get hasSelectedVehicle => selectedVeiculoId.isNotEmpty;
  bool get hasDespesas => despesasPorMes.isNotEmpty;
  bool get isEmpty => despesasPorMes.isEmpty;

  // Métodos para acessar dados
  List<DespesaCar> getDespesasForMonth(DateTime month) {
    return despesasPorMes[month] ?? [];
  }

  bool hasDataForMonth(DateTime month) {
    return getDespesasForMonth(month).isNotEmpty;
  }

  // Geração de lista de meses
  List<DateTime> get monthsList {
    if (despesasPorMes.isEmpty) return [];

    final dates = despesasPorMes.keys.toList();
    dates.sort();

    if (dates.isEmpty) return [];

    final oldestDate = dates.first;
    final newestDate = dates.last;

    List<DateTime> allMonths = [];
    DateTime currentDate = DateTime(oldestDate.year, oldestDate.month);
    final lastDate = DateTime(newestDate.year, newestDate.month);

    while (!currentDate.isAfter(lastDate)) {
      allMonths.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return allMonths.reversed.toList();
  }

  // Estatísticas gerais
  Map<String, dynamic> get overallStatistics {
    if (despesasPorMes.isEmpty) {
      return {
        'totalGeral': 0.0,
        'quantidadeTotal': 0,
        'mediaGeral': 0.0,
        'mesesComDados': 0,
      };
    }

    double totalGeral = 0.0;
    int quantidadeTotal = 0;

    for (final despesas in despesasPorMes.values) {
      for (final despesa in despesas) {
        totalGeral += despesa.valor;
        quantidadeTotal++;
      }
    }

    return {
      'totalGeral': totalGeral,
      'quantidadeTotal': quantidadeTotal,
      'mediaGeral': quantidadeTotal > 0 ? totalGeral / quantidadeTotal : 0.0,
      'mesesComDados': despesasPorMes.length,
    };
  }

  // Verifica se um mês específico está no carousel atual
  bool isCurrentMonth(DateTime month, int carouselIndex) {
    final months = monthsList;
    if (carouselIndex >= 0 && carouselIndex < months.length) {
      final currentMonth = months[carouselIndex];
      return currentMonth.year == month.year &&
          currentMonth.month == month.month;
    }
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DespesasPageModel &&
        other.isLoading == isLoading &&
        other.showHeader == showHeader &&
        other.currentCarouselIndex == currentCarouselIndex &&
        other.selectedVeiculoId == selectedVeiculoId &&
        _mapEquals(other.despesasPorMes, despesasPorMes);
  }

  bool _mapEquals(Map<DateTime, List<DespesaCar>> map1,
      Map<DateTime, List<DespesaCar>> map2) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final list1 = map1[key]!;
      final list2 = map2[key]!;
      if (list1.length != list2.length) return false;

      for (int i = 0; i < list1.length; i++) {
        if (list1[i].id != list2[i].id) return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    return despesasPorMes.hashCode ^
        isLoading.hashCode ^
        showHeader.hashCode ^
        currentCarouselIndex.hashCode ^
        selectedVeiculoId.hashCode;
  }

  @override
  String toString() {
    return 'DespesasPageModel('
        'hasDespesas: $hasDespesas, '
        'isLoading: $isLoading, '
        'hasSelectedVehicle: $hasSelectedVehicle, '
        'monthsCount: ${monthsList.length}'
        ')';
  }
}
