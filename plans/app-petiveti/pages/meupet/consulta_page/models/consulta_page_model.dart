// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/12_consulta_model.dart';
import '../utils/consulta_utils.dart';

class ConsultaPageModel {
  List<Consulta> consultas;
  List<Consulta> filteredConsultas;
  String? selectedAnimalId;
  Animal? selectedAnimal;
  String searchText;
  DateTime? selectedDate;
  String selectedSortBy;
  bool isAscending;

  ConsultaPageModel({
    this.consultas = const [],
    List<Consulta>? filteredConsultas,
    this.selectedAnimalId,
    this.selectedAnimal,
    this.searchText = '',
    this.selectedDate,
    this.selectedSortBy = 'data',
    this.isAscending = false,
  }) : filteredConsultas = filteredConsultas ?? const [];

  ConsultaPageModel copyWith({
    List<Consulta>? consultas,
    List<Consulta>? filteredConsultas,
    String? selectedAnimalId,
    Animal? selectedAnimal,
    String? searchText,
    DateTime? selectedDate,
    String? selectedSortBy,
    bool? isAscending,
  }) {
    return ConsultaPageModel(
      consultas: consultas ?? this.consultas,
      filteredConsultas: filteredConsultas ?? this.filteredConsultas,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      searchText: searchText ?? this.searchText,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSortBy: selectedSortBy ?? this.selectedSortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  void addConsulta(Consulta consulta) {
    consultas = [...consultas, consulta];
    updateFilteredConsultas();
  }

  void updateConsulta(Consulta updatedConsulta) {
    consultas = consultas.map((consulta) {
      return consulta.id == updatedConsulta.id ? updatedConsulta : consulta;
    }).toList();
    updateFilteredConsultas();
  }

  void removeConsulta(Consulta consultaToRemove) {
    consultas = consultas.where((consulta) => consulta.id != consultaToRemove.id).toList();
    updateFilteredConsultas();
  }

  void setConsultas(List<Consulta> newConsultas) {
    consultas = List.from(newConsultas);
    updateFilteredConsultas();
  }

  void clearConsultas() {
    consultas = [];
    filteredConsultas = [];
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    selectedAnimalId = animalId;
    selectedAnimal = animal;
  }

  void setSearchText(String text) {
    searchText = text;
  }

  void setSelectedDate(DateTime? date) {
    selectedDate = date;
  }

  void setSortBy(String sortBy) {
    selectedSortBy = sortBy;
  }

  void setSortOrder(bool ascending) {
    isAscending = ascending;
  }

  void clearSelectedAnimal() {
    selectedAnimalId = null;
    selectedAnimal = null;
  }

  void clearFilters() {
    searchText = '';
    selectedDate = null;
    selectedSortBy = 'data';
    isAscending = false;
  }

  void updateFilteredConsultas() {
    List<Consulta> result = List.from(consultas);

    // Apply search filter
    if (searchText.isNotEmpty) {
      result = _applySearchFilter(result, searchText);
    }

    // Apply date filter
    if (selectedDate != null) {
      result = _applyDateFilter(result, selectedDate!);
    }

    // Apply sorting
    result = _applySorting(result, selectedSortBy, isAscending);

    filteredConsultas = result;
  }

  List<Consulta> _applySearchFilter(List<Consulta> consultas, String query) {
    final lowercaseQuery = query.toLowerCase();
    return consultas.where((consulta) {
      return consulta.veterinario.toLowerCase().contains(lowercaseQuery) ||
             consulta.motivo.toLowerCase().contains(lowercaseQuery) ||
             consulta.diagnostico.toLowerCase().contains(lowercaseQuery) ||
             (consulta.observacoes?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Consulta> _applyDateFilter(List<Consulta> consultas, DateTime filterDate) {
    return consultas.where((consulta) {
      final consultaDate = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      return ConsultaUtils.isSameDay(consultaDate, filterDate);
    }).toList();
  }

  List<Consulta> _applySorting(List<Consulta> consultas, String sortBy, bool ascending) {
    final sorted = List<Consulta>.from(consultas);
    
    switch (sortBy) {
      case 'data':
        sorted.sort((a, b) {
          final comparison = a.dataConsulta.compareTo(b.dataConsulta);
          return ascending ? comparison : -comparison;
        });
        break;
      case 'veterinario':
        sorted.sort((a, b) {
          final comparison = a.veterinario.compareTo(b.veterinario);
          return ascending ? comparison : -comparison;
        });
        break;
      case 'motivo':
        sorted.sort((a, b) {
          final comparison = a.motivo.compareTo(b.motivo);
          return ascending ? comparison : -comparison;
        });
        break;
      case 'valor':
        sorted.sort((a, b) {
          final comparison = a.valor.compareTo(b.valor);
          return ascending ? comparison : -comparison;
        });
        break;
      default:
        // Default to date sorting
        sorted.sort((a, b) {
          final comparison = a.dataConsulta.compareTo(b.dataConsulta);
          return ascending ? comparison : -comparison;
        });
    }
    
    return sorted;
  }

  // Getters
  bool get hasConsultas => consultas.isNotEmpty;
  bool get isEmpty => consultas.isEmpty;
  int get consultaCount => consultas.length;
  int get filteredCount => filteredConsultas.length;
  bool get hasSelectedAnimal => selectedAnimalId != null && selectedAnimalId!.isNotEmpty;
  bool get hasActiveFilters => searchText.isNotEmpty || selectedDate != null;

  String getFormattedMonth() {
    return ConsultaUtils.getFormattedMonth();
  }

  String getFilterSummary() {
    final filters = <String>[];
    
    if (searchText.isNotEmpty) {
      filters.add('Busca: "$searchText"');
    }
    
    if (selectedDate != null) {
      filters.add('Data: ${ConsultaUtils.formatDate(selectedDate!)}');
    }
    
    if (filters.isEmpty) {
      return 'Sem filtros aplicados';
    }
    
    return filters.join(' • ');
  }

  Map<String, dynamic> getStatistics() {
    if (consultas.isEmpty) {
      return {
        'total': 0,
        'thisMonth': 0,
        'thisYear': 0,
        'averageValor': 0.0,
        'lastConsulta': null,
        'nextConsulta': null,
        'veterinarios': <String>[],
        'motivos': <String>[],
      };
    }

    final now = DateTime.now();
    final thisMonth = consultas.where((c) {
      final date = DateTime.fromMillisecondsSinceEpoch(c.dataConsulta);
      return date.year == now.year && date.month == now.month;
    }).length;

    final thisYear = consultas.where((c) {
      final date = DateTime.fromMillisecondsSinceEpoch(c.dataConsulta);
      return date.year == now.year;
    }).length;

    final valores = consultas.where((c) => c.valor > 0).map((c) => c.valor).toList();
    final averageValor = valores.isNotEmpty 
        ? valores.reduce((a, b) => a + b) / valores.length 
        : 0.0;

    final sortedByDate = List<Consulta>.from(consultas)
      ..sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));

    final veterinarios = consultas.map((c) => c.veterinario).toSet().toList();
    final motivos = consultas.map((c) => c.motivo).toSet().toList();

    return {
      'total': consultas.length,
      'thisMonth': thisMonth,
      'thisYear': thisYear,
      'averageValor': averageValor,
      'lastConsulta': sortedByDate.isNotEmpty ? sortedByDate.first : null,
      'nextConsulta': null, // Could be implemented with scheduling
      'veterinarios': veterinarios,
      'motivos': motivos,
    };
  }

  List<Map<String, dynamic>> getMonthlyStats() {
    final monthlyData = <String, List<Consulta>>{};
    
    for (final consulta in consultas) {
      final date = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      monthlyData[monthKey] = monthlyData[monthKey] ?? [];
      monthlyData[monthKey]!.add(consulta);
    }

    return monthlyData.entries.map((entry) {
      final monthConsultas = entry.value;
      final totalValor = monthConsultas.where((c) => c.valor > 0).fold(0.0, (sum, c) => sum + c.valor);
      final averageValor = monthConsultas.where((c) => c.valor > 0).isNotEmpty
          ? totalValor / monthConsultas.where((c) => c.valor > 0).length
          : 0.0;

      return {
        'month': entry.key,
        'count': monthConsultas.length,
        'averageValor': averageValor,
        'veterinarios': monthConsultas.map((c) => c.veterinario).toSet().length,
      };
    }).toList()..sort((a, b) => (b['month'] as String).compareTo(a['month'] as String));
  }

  Map<String, int> getVeterinarioStats() {
    final stats = <String, int>{};
    for (final consulta in consultas) {
      stats[consulta.veterinario] = (stats[consulta.veterinario] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getMotivoStats() {
    final stats = <String, int>{};
    for (final consulta in consultas) {
      stats[consulta.motivo] = (stats[consulta.motivo] ?? 0) + 1;
    }
    return stats;
  }

  @override
  String toString() {
    return 'ConsultaPageModel(consultas: ${consultas.length}, filtered: ${filteredConsultas.length}, selectedAnimal: $selectedAnimalId)';
  }

  Map<String, dynamic> toJson() {
    return {
      'consultaCount': consultas.length,
      'filteredCount': filteredConsultas.length,
      'selectedAnimalId': selectedAnimalId,
      'searchText': searchText,
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedSortBy': selectedSortBy,
      'isAscending': isAscending,
      'hasActiveFilters': hasActiveFilters,
    };
  }

  factory ConsultaPageModel.fromJson(Map<String, dynamic> json) {
    return ConsultaPageModel(
      selectedAnimalId: json['selectedAnimalId'],
      searchText: json['searchText'] ?? '',
      selectedDate: json['selectedDate'] != null 
          ? DateTime.parse(json['selectedDate'])
          : null,
      selectedSortBy: json['selectedSortBy'] ?? 'data',
      isAscending: json['isAscending'] ?? false,
    );
  }
}
