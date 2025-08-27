import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';

/// Provider para gerenciar estado dos diagnósticos
/// Responsabilidade única: busca, filtro e pesquisa de diagnósticos
class DiagnosticosProvider extends ChangeNotifier {
  final GetDiagnosticosUsecase _getDiagnosticosUsecase;

  DiagnosticosProvider({
    GetDiagnosticosUsecase? getDiagnosticosUsecase,
  }) : _getDiagnosticosUsecase = getDiagnosticosUsecase ?? sl<GetDiagnosticosUsecase>();

  List<DiagnosticoEntity> _diagnosticos = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCultura = 'Todas';

  // Lista de culturas disponíveis
  final List<String> _culturas = [
    'Todas',
    'Arroz',
    'Braquiária',
    'Cana-de-açúcar',
    'Café',
    'Milho',
    'Soja'
  ];

  // Getters
  List<DiagnosticoEntity> get diagnosticos => _getFilteredDiagnosticos();
  List<DiagnosticoEntity> get allDiagnosticos => _diagnosticos;
  List<String> get culturas => _culturas;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCultura => _selectedCultura;

  /// Carrega diagnósticos relacionados ao defensivo
  Future<void> loadDiagnosticos(String defensivoId) async {
    _setLoading(true);
    _clearError();

    final result = await _getDiagnosticosUsecase(
      GetDiagnosticosParams(defensivoId: defensivoId),
    );

    result.fold(
      (failure) {
        _setError('Erro ao carregar diagnósticos: ${failure.message}');
        _setLoading(false);
      },
      (diagnosticos) {
        _diagnosticos = diagnosticos;
        _setLoading(false);
      },
    );
  }

  /// Atualiza query de pesquisa
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Atualiza cultura selecionada
  void updateSelectedCultura(String cultura) {
    _selectedCultura = cultura;
    notifyListeners();
  }

  /// Limpa filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCultura = 'Todas';
    notifyListeners();
  }

  /// Retorna diagnósticos filtrados
  List<DiagnosticoEntity> _getFilteredDiagnosticos() {
    List<DiagnosticoEntity> filtered = _diagnosticos;

    // Filtrar por cultura
    if (_selectedCultura != 'Todas') {
      filtered = filtered.where((d) => d.cultura == _selectedCultura).toList();
    }

    // Filtrar por pesquisa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((d) =>
          d.nome.toLowerCase().contains(query) ||
          d.ingredienteAtivo.toLowerCase().contains(query) ||
          d.cultura.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  /// Agrupa diagnósticos por cultura
  Map<String, List<DiagnosticoEntity>> get diagnosticosGroupedByCultura {
    final Map<String, List<DiagnosticoEntity>> grouped = {};

    for (final diagnostico in _getFilteredDiagnosticos()) {
      if (!grouped.containsKey(diagnostico.cultura)) {
        grouped[diagnostico.cultura] = [];
      }
      grouped[diagnostico.cultura]!.add(diagnostico);
    }

    // Ordenar as culturas alfabeticamente
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<DiagnosticoEntity>> sortedGrouped = {};

    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  /// Reset do provider
  void reset() {
    _diagnosticos = [];
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    _searchQuery = '';
    _selectedCultura = 'Todas';
    notifyListeners();
  }
}