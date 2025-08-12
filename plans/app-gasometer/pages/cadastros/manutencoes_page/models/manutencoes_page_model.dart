// Project imports:
import '../../../../database/25_manutencao_model.dart';

class ManutencoesPageModel {
  final List<ManutencaoCar> manutencoes;
  final List<DateTime> monthsList;
  final bool isLoading;
  final bool showHeader;
  final int currentCarouselIndex;
  final String selectedVeiculoId;
  final String searchQuery;

  const ManutencoesPageModel({
    required this.manutencoes,
    required this.monthsList,
    required this.isLoading,
    required this.showHeader,
    required this.currentCarouselIndex,
    required this.selectedVeiculoId,
    required this.searchQuery,
  });

  factory ManutencoesPageModel.initial() {
    return const ManutencoesPageModel(
      manutencoes: [],
      monthsList: [],
      isLoading: false,
      showHeader: true,
      currentCarouselIndex: 0,
      selectedVeiculoId: '',
      searchQuery: '',
    );
  }

  ManutencoesPageModel copyWith({
    List<ManutencaoCar>? manutencoes,
    List<DateTime>? monthsList,
    bool? isLoading,
    bool? showHeader,
    int? currentCarouselIndex,
    String? selectedVeiculoId,
    String? searchQuery,
  }) {
    return ManutencoesPageModel(
      manutencoes: manutencoes ?? this.manutencoes,
      monthsList: monthsList ?? this.monthsList,
      isLoading: isLoading ?? this.isLoading,
      showHeader: showHeader ?? this.showHeader,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      selectedVeiculoId: selectedVeiculoId ?? this.selectedVeiculoId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Getters de conveniência
  bool get hasSelectedVehicle => selectedVeiculoId.isNotEmpty;
  bool get hasManutencoes => manutencoes.isNotEmpty;
  bool get isEmpty => manutencoes.isEmpty;
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  // Métodos para acessar dados por mês
  List<ManutencaoCar> getManutencoesByMonth(DateTime month) {
    return manutencoes.where((manutencao) {
      final manutencaoDate =
          DateTime.fromMillisecondsSinceEpoch(manutencao.data);
      return manutencaoDate.year == month.year &&
          manutencaoDate.month == month.month;
    }).toList();
  }

  bool hasDataForMonth(DateTime month) {
    return getManutencoesByMonth(month).isNotEmpty;
  }

  // Estatísticas gerais
  Map<String, dynamic> get overallStatistics {
    if (manutencoes.isEmpty) {
      return {
        'totalGasto': 0.0,
        'totalPendentes': 0,
        'totalConcluidas': 0,
        'totalManutencoes': 0,
        'mediaGastos': 0.0,
      };
    }

    final totalGasto = manutencoes.fold(0.0, (sum, item) => sum + item.valor);
    final totalPendentes = manutencoes.where((m) => !m.concluida).length;
    final totalConcluidas = manutencoes.where((m) => m.concluida).length;
    final totalManutencoes = manutencoes.length;
    final mediaGastos = totalGasto / totalManutencoes;

    return {
      'totalGasto': totalGasto,
      'totalPendentes': totalPendentes,
      'totalConcluidas': totalConcluidas,
      'totalManutencoes': totalManutencoes,
      'mediaGastos': mediaGastos,
    };
  }

  // Estatísticas mensais
  Map<String, dynamic> getMonthlyStatistics(DateTime month) {
    final manutencoesMes = getManutencoesByMonth(month);

    if (manutencoesMes.isEmpty) {
      return {
        'totalGasto': 0.0,
        'pendentes': 0,
        'concluidas': 0,
        'total': 0,
      };
    }

    final totalGasto =
        manutencoesMes.fold(0.0, (sum, item) => sum + item.valor);
    final pendentes = manutencoesMes.where((m) => !m.concluida).length;
    final concluidas = manutencoesMes.where((m) => m.concluida).length;
    final total = manutencoesMes.length;

    return {
      'totalGasto': totalGasto,
      'pendentes': pendentes,
      'concluidas': concluidas,
      'total': total,
    };
  }

  // Filtros
  List<ManutencaoCar> get manutencoesPendentes {
    return manutencoes.where((m) => !m.concluida).toList();
  }

  List<ManutencaoCar> get manutencoesConcluidas {
    return manutencoes.where((m) => m.concluida).toList();
  }

  List<ManutencaoCar> getManutencoesByTipo(String tipo) {
    return manutencoes
        .where((m) => m.tipo.toLowerCase() == tipo.toLowerCase())
        .toList();
  }

  // Manutenção mais cara
  ManutencaoCar? get manutencaoMaisCara {
    if (manutencoes.isEmpty) return null;
    return manutencoes.reduce((a, b) => a.valor > b.valor ? a : b);
  }

  // Manutenção mais recente
  ManutencaoCar? get manutencaoMaisRecente {
    if (manutencoes.isEmpty) return null;
    return manutencoes.reduce((a, b) => a.data > b.data ? a : b);
  }

  // Próxima manutenção agendada
  ManutencaoCar? get proximaManutencao {
    final pendentes = manutencoesPendentes;
    if (pendentes.isEmpty) return null;

    // Ordena por data e retorna a mais próxima
    pendentes.sort((a, b) => a.data.compareTo(b.data));
    return pendentes.first;
  }

  // Análise de tipos
  Map<String, int> get distribuicaoPorTipo {
    final Map<String, int> distribuicao = {};

    for (final manutencao in manutencoes) {
      distribuicao[manutencao.tipo] = (distribuicao[manutencao.tipo] ?? 0) + 1;
    }

    return distribuicao;
  }

  // Verifica se um mês específico está no carousel atual
  bool isCurrentMonth(DateTime month, int carouselIndex) {
    if (carouselIndex >= 0 && carouselIndex < monthsList.length) {
      final currentMonth = monthsList[carouselIndex];
      return currentMonth.year == month.year &&
          currentMonth.month == month.month;
    }
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ManutencoesPageModel &&
        other.isLoading == isLoading &&
        other.showHeader == showHeader &&
        other.currentCarouselIndex == currentCarouselIndex &&
        other.selectedVeiculoId == selectedVeiculoId &&
        other.searchQuery == searchQuery &&
        _listEquals(other.manutencoes, manutencoes) &&
        _listEquals(other.monthsList, monthsList);
  }

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return manutencoes.hashCode ^
        monthsList.hashCode ^
        isLoading.hashCode ^
        showHeader.hashCode ^
        currentCarouselIndex.hashCode ^
        selectedVeiculoId.hashCode ^
        searchQuery.hashCode;
  }

  @override
  String toString() {
    return 'ManutencoesPageModel('
        'hasManutencoes: $hasManutencoes, '
        'isLoading: $isLoading, '
        'hasSelectedVehicle: $hasSelectedVehicle, '
        'monthsCount: ${monthsList.length}, '
        'totalManutencoes: ${manutencoes.length}'
        ')';
  }
}
