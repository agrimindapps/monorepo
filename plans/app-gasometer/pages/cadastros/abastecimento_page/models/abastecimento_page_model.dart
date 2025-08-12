// Project imports:
import '../../../../database/23_abastecimento_model.dart';

class AbastecimentoPageModel {
  final bool showHeader;
  final int currentCarouselIndex;
  final Map<DateTime, List<AbastecimentoCar>> abastecimentosAgrupados;
  final String selectedVeiculoId;

  const AbastecimentoPageModel({
    required this.showHeader,
    required this.currentCarouselIndex,
    required this.abastecimentosAgrupados,
    required this.selectedVeiculoId,
  });

  AbastecimentoPageModel copyWith({
    bool? showHeader,
    int? currentCarouselIndex,
    Map<DateTime, List<AbastecimentoCar>>? abastecimentosAgrupados,
    String? selectedVeiculoId,
  }) {
    return AbastecimentoPageModel(
      showHeader: showHeader ?? this.showHeader,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      abastecimentosAgrupados:
          abastecimentosAgrupados ?? this.abastecimentosAgrupados,
      selectedVeiculoId: selectedVeiculoId ?? this.selectedVeiculoId,
    );
  }

  bool get hasSelectedVehicle => selectedVeiculoId.isNotEmpty;
  bool get hasAbastecimentos => abastecimentosAgrupados.isNotEmpty;

  List<DateTime> get monthsList {
    if (abastecimentosAgrupados.isEmpty) return [];

    final allDates = abastecimentosAgrupados.keys.toList();
    allDates.sort();

    final uniqueMonths = <DateTime>{};
    for (final date in allDates) {
      final monthStart = DateTime(date.year, date.month);
      uniqueMonths.add(monthStart);
    }

    final sortedMonths = uniqueMonths.toList();
    sortedMonths.sort();

    return sortedMonths;
  }

  bool hasDataForMonth(DateTime month) {
    return abastecimentosAgrupados[month]?.isNotEmpty ?? false;
  }

  List<AbastecimentoCar> getAbastecimentosForMonth(DateTime month) {
    return abastecimentosAgrupados[month] ?? [];
  }
}
