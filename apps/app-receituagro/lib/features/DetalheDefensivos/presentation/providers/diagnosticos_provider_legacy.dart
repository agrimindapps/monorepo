import 'package:flutter/foundation.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_by_defensivo_usecase.dart';
import '../../data/repositories/diagnostico_repository_impl.dart';

/// Provider legado para compatibilidade com Provider pattern
/// Mantém compatibilidade com código existente que usa ChangeNotifier
class DiagnosticosProvider extends ChangeNotifier {
  final GetDiagnosticosByDefensivoUseCase _getDiagnosticosUseCase;

  DiagnosticosProvider()
      : _getDiagnosticosUseCase = GetDiagnosticosByDefensivoUseCase(
          DiagnosticoRepositoryImpl(sl()),
        );

  List<DiagnosticoEntity> _diagnosticos = [];
  List<DiagnosticoEntity> _originalDiagnosticos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCultura;
  Map<String, List<DiagnosticoEntity>> _diagnosticosGrouped = {};

  // Getters
  List<DiagnosticoEntity> get diagnosticos => _diagnosticos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _diagnosticos.isNotEmpty;
  bool get isEmpty => _diagnosticos.isEmpty && !_isLoading && !hasError;
  String get searchQuery => _searchQuery;
  String? get selectedCultura => _selectedCultura;
  Map<String, List<DiagnosticoEntity>> get diagnosticosGrouped => _diagnosticosGrouped;

  /// Carrega diagnósticos para um defensivo
  Future<void> loadDiagnosticos(String idDefensivo) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = GetDiagnosticosByDefensivoParams(
      idDefensivo: idDefensivo,
      cultura: _selectedCultura,
      searchQuery: _searchQuery,
    );

    final result = await _getDiagnosticosUseCase(params);

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (diagnosticos) {
        _originalDiagnosticos = diagnosticos;
        _diagnosticos = diagnosticos;
        _diagnosticosGrouped = _groupDiagnosticosByCultura(diagnosticos);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  /// Aplica filtro de pesquisa
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Seleciona uma cultura específica
  void setSelectedCultura(String? cultura) {
    if (_selectedCultura == cultura) return;
    
    _selectedCultura = cultura;
    _applyFilters();
    notifyListeners();
  }

  /// Aplica filtros aos dados já carregados
  void _applyFilters() {
    var filteredDiagnosticos = List<DiagnosticoEntity>.from(_originalDiagnosticos);

    // Filtro por cultura
    if (_selectedCultura != null && 
        _selectedCultura!.isNotEmpty && 
        _selectedCultura != 'Todas') {
      filteredDiagnosticos = filteredDiagnosticos
          .where((d) => d.cultura.toLowerCase() == _selectedCultura!.toLowerCase())
          .toList();
    }

    // Filtro por query de busca
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredDiagnosticos = filteredDiagnosticos
          .where((d) =>
              d.nome.toLowerCase().contains(query) ||
              d.cultura.toLowerCase().contains(query) ||
              d.grupo.toLowerCase().contains(query) ||
              d.ingredienteAtivo.toLowerCase().contains(query))
          .toList();
    }

    _diagnosticos = filteredDiagnosticos;
    _diagnosticosGrouped = _groupDiagnosticosByCultura(filteredDiagnosticos);
  }

  /// Agrupa diagnósticos por cultura
  Map<String, List<DiagnosticoEntity>> _groupDiagnosticosByCultura(
    List<DiagnosticoEntity> diagnosticos,
  ) {
    final Map<String, List<DiagnosticoEntity>> grouped = {};

    for (final diagnostico in diagnosticos) {
      if (!grouped.containsKey(diagnostico.cultura)) {
        grouped[diagnostico.cultura] = [];
      }
      grouped[diagnostico.cultura]!.add(diagnostico);
    }

    // Ordenar as culturas alfabeticamente
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<DiagnosticoEntity>> sortedGrouped = {};

    for (final key in sortedKeys) {
      // Ordenar diagnósticos dentro de cada cultura
      grouped[key]!.sort((a, b) => a.nome.compareTo(b.nome));
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  /// Lista de culturas disponíveis
  List<String> get availableCulturas {
    final culturas = {'Todas'};
    for (final diagnostico in _originalDiagnosticos) {
      culturas.add(diagnostico.cultura);
    }
    return culturas.toList()..sort();
  }

  /// Limpa os dados
  void clearData() {
    _diagnosticos = [];
    _originalDiagnosticos = [];
    _diagnosticosGrouped = {};
    _isLoading = false;
    _errorMessage = null;
    _searchQuery = '';
    _selectedCultura = null;
    notifyListeners();
  }
}