// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';

class MedicoesPageState {
  final List<dynamic> daysOfMonth;
  final bool isLoading;
  final int currentCarouselIndex;
  final List<Pluviometro> pluviometros;
  final List<Medicoes> medicoes;
  final bool hasError;
  final String? errorMessage;
  final String? selectedPluviometroId;

  const MedicoesPageState({
    this.daysOfMonth = const [],
    this.isLoading = false,
    this.currentCarouselIndex = 0,
    this.pluviometros = const [],
    this.medicoes = const [],
    this.hasError = false,
    this.errorMessage,
    this.selectedPluviometroId,
  });

  MedicoesPageState copyWith({
    List<dynamic>? daysOfMonth,
    bool? isLoading,
    int? currentCarouselIndex,
    List<Pluviometro>? pluviometros,
    List<Medicoes>? medicoes,
    bool? hasError,
    String? errorMessage,
    String? selectedPluviometroId,
  }) {
    return MedicoesPageState(
      daysOfMonth: daysOfMonth ?? this.daysOfMonth,
      isLoading: isLoading ?? this.isLoading,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      pluviometros: pluviometros ?? this.pluviometros,
      medicoes: medicoes ?? this.medicoes,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPluviometroId:
          selectedPluviometroId ?? this.selectedPluviometroId,
    );
  }
}

class EstatisticaItem {
  final String label;
  final String valor;
  final IconData icon;
  final Color cor;

  const EstatisticaItem({
    required this.label,
    required this.valor,
    required this.icon,
    required this.cor,
  });
}

class MonthStatistics {
  final double total;
  final double media;
  final double maximo;
  final int diasComChuva;

  const MonthStatistics({
    required this.total,
    required this.media,
    required this.maximo,
    required this.diasComChuva,
  });
}
