import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../diagnosticos/data/repositories/diagnosticos_repository_impl.dart';

/// Model para diagnóstico usado na UI
class DiagnosticoModel {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String dosagem;
  final String cultura;
  final String grupo;

  DiagnosticoModel({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    required this.dosagem,
    required this.cultura,
    required this.grupo,
  });
}

/// Provider para gerenciar diagnósticos relacionados à praga
/// Responsabilidade única: filtros e busca de diagnósticos
class DiagnosticosPragaProvider extends ChangeNotifier {
  final DiagnosticosRepositoryImpl _diagnosticosRepository = sl<DiagnosticosRepositoryImpl>();

  // Estado dos diagnósticos
  List<DiagnosticoModel> _diagnosticos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Estado dos filtros
  String _searchQuery = '';
  String _selectedCultura = 'Todas';

  // Lista de culturas disponíveis
  final List<String> _culturas = [
    'Todas',
    'Soja',
    'Milho',
    'Algodão',
    'Café',
    'Citros',
    'Cana-de-açúcar'
  ];

  // Getters
  List<DiagnosticoModel> get diagnosticos => _diagnosticos;
  List<DiagnosticoModel> get filteredDiagnosticos => _filterDiagnosticos();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCultura => _selectedCultura;
  List<String> get culturas => _culturas;

  /// Carrega diagnósticos para uma praga específica
  Future<void> loadDiagnosticos(String pragaId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _diagnosticosRepository.getByPraga(pragaId);

      result.fold(
        (failure) {
          _errorMessage = 'Erro ao carregar diagnósticos: ${failure.toString()}';
          _diagnosticos = [];
          debugPrint(_errorMessage);
        },
        (diagnosticosEntities) {
          // Converte entidades para o modelo usado na UI
          _diagnosticos = diagnosticosEntities.map((entity) {
            return DiagnosticoModel(
              id: entity.id,
              nome: entity.nomeDefensivo ?? 'Defensivo não especificado',
              ingredienteAtivo: entity.idDefensivo,
              dosagem: entity.dosagem.toString(),
              cultura: entity.nomeCultura ?? 'Não especificado',
              grupo: entity.nomePraga ?? '',
            );
          }).toList();
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao carregar diagnósticos: $e';
      _diagnosticos = [];
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Filtra diagnósticos baseado na busca e cultura selecionada
  List<DiagnosticoModel> _filterDiagnosticos() {
    return _diagnosticos.where((diagnostic) {
      bool matchesSearch = _searchQuery.isEmpty ||
          diagnostic.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          diagnostic.ingredienteAtivo.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCulture = _selectedCultura == 'Todas' ||
          diagnostic.cultura == _selectedCultura;

      return matchesSearch && matchesCulture;
    }).toList();
  }

  /// Agrupa diagnósticos filtrados por cultura
  Map<String, List<DiagnosticoModel>> get groupedDiagnosticos {
    final filtered = filteredDiagnosticos;
    final grouped = <String, List<DiagnosticoModel>>{};
    
    for (final diagnostic in filtered) {
      grouped.putIfAbsent(diagnostic.cultura, () => []).add(diagnostic);
    }
    
    return grouped;
  }

  /// Obtém dados do defensivo por nome
  Map<String, dynamic>? getDefensivoData(String nome) {
    // Implementação futura para dados do defensivo
    // Por enquanto retorna dados mock
    return {
      'fabricante': 'Fabricante Desconhecido',
      'registro': 'Registro não disponível'
    };
  }

  /// Limpa filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCultura = 'Todas';
    notifyListeners();
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}