// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../interfaces/i_diagnostic_filter_service.dart';

/// Serviço para filtro de diagnósticos
class DiagnosticFilterService implements IDiagnosticFilterService {
  final RxList<String> _searchHistory = <String>[].obs;
  static const int _maxHistoryItems = 10;

  @override
  List<dynamic> filterDiagnosticos({
    required List<dynamic> diagnosticos,
    required String searchText,
    String? selectedCultura,
  }) {
    if (searchText.isEmpty &&
        (selectedCultura == null || selectedCultura.isEmpty)) {
      final result = List<dynamic>.from(diagnosticos);
      // Ordena as indicações (defensivos) alfabeticamente por nomePraga
      for (var diagnostico in result) {
        final indicacoes = diagnostico['indicacoes'] as List<dynamic>? ?? [];
        indicacoes.sort((a, b) {
          final nomeA = (a['nomePraga'] ?? '').toString().toLowerCase();
          final nomeB = (b['nomePraga'] ?? '').toString().toLowerCase();
          return nomeA.compareTo(nomeB);
        });
      }
      // Ordena os diagnósticos por nomePraga dentro de cada cultura
      return _sortDiagnosticosByCultura(result);
    }

    final searchTerms = searchText
        .toLowerCase()
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();

    final filteredResult = diagnosticos.where((diagnostico) {
      // Filtro por cultura selecionada
      if (selectedCultura != null &&
          selectedCultura.isNotEmpty &&
          diagnostico['cultura'] != selectedCultura) {
        return false;
      }

      // Se não há termos de busca, mas há filtro de cultura, retorna true
      if (searchTerms.isEmpty) {
        return true;
      }

      final cultura = diagnostico['cultura']?.toString().toLowerCase() ?? '';
      final indicacoes = diagnostico['indicacoes'] as List<dynamic>? ?? [];

      // Verifica se todos os termos de busca são encontrados
      return searchTerms.every((searchTerm) {
        // Busca na cultura
        if (cultura.contains(searchTerm)) return true;

        // Busca nas indicações
        return indicacoes.any((indicacao) {
          final nomePraga =
              indicacao['nomePraga']?.toString().toLowerCase() ?? '';
          final nomeCientifico =
              indicacao['nomeCientifico']?.toString().toLowerCase() ?? '';
          return nomePraga.contains(searchTerm) ||
              nomeCientifico.contains(searchTerm);
        });
      });
    }).toList();
    
    // Ordena as indicações (defensivos) alfabeticamente por nomePraga
    for (var diagnostico in filteredResult) {
      final indicacoes = diagnostico['indicacoes'] as List<dynamic>? ?? [];
      indicacoes.sort((a, b) {
        final nomeA = (a['nomePraga'] ?? '').toString().toLowerCase();
        final nomeB = (b['nomePraga'] ?? '').toString().toLowerCase();
        return nomeA.compareTo(nomeB);
      });
    }
    
    // Ordena os diagnósticos por nomePraga dentro de cada cultura
    return _sortDiagnosticosByCultura(filteredResult);
  }

  @override
  void addToSearchHistory(String searchTerm) {
    final trimmedTerm = searchTerm.trim();
    if (trimmedTerm.isEmpty) return;

    // Remove se já existir
    _searchHistory.remove(trimmedTerm);

    // Adiciona no início
    _searchHistory.insert(0, trimmedTerm);

    // Mantém apenas os últimos itens
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory.removeRange(_maxHistoryItems, _searchHistory.length);
    }
  }

  @override
  List<String> getSearchSuggestions(String currentTerm) {
    if (currentTerm.isEmpty) {
      return _searchHistory.take(5).toList();
    }

    final lowerTerm = currentTerm.toLowerCase();
    return _searchHistory
        .where((item) => item.toLowerCase().contains(lowerTerm))
        .take(5)
        .toList();
  }

  @override
  void clearSearchHistory() {
    _searchHistory.clear();
  }

  @override
  List<String> get searchHistory => _searchHistory.toList();

  /// Remove um item específico do histórico
  void removeFromHistory(String item) {
    _searchHistory.remove(item);
  }

  /// Verifica se um termo está no histórico
  bool isInHistory(String term) {
    return _searchHistory.contains(term);
  }

  /// Obtém estatísticas do histórico
  Map<String, dynamic> getHistoryStats() {
    return {
      'totalItems': _searchHistory.length,
      'maxItems': _maxHistoryItems,
      'mostRecent': _searchHistory.isNotEmpty ? _searchHistory.first : null,
    };
  }

  /// Ordena os diagnósticos por nomePraga dentro de cada cultura
  List<dynamic> _sortDiagnosticosByCultura(List<dynamic> diagnosticos) {
    // Agrupa os diagnósticos por cultura
    final Map<String, List<dynamic>> diagnosticosPorCultura = {};
    
    for (var diagnostico in diagnosticos) {
      final cultura = diagnostico['cultura']?.toString() ?? 'Sem cultura';
      if (!diagnosticosPorCultura.containsKey(cultura)) {
        diagnosticosPorCultura[cultura] = [];
      }
      diagnosticosPorCultura[cultura]!.add(diagnostico);
    }
    
    // Ordena os diagnósticos dentro de cada cultura por nomePraga
    final List<dynamic> resultado = [];
    final culturasOrdenadas = diagnosticosPorCultura.keys.toList()..sort();
    
    for (final cultura in culturasOrdenadas) {
      final diagnosticosDaCultura = diagnosticosPorCultura[cultura]!;
      
      // Ordena os diagnósticos desta cultura por nomePraga
      diagnosticosDaCultura.sort((a, b) {
        final nomeA = (a['nomePraga'] ?? '').toString().toLowerCase();
        final nomeB = (b['nomePraga'] ?? '').toString().toLowerCase();
        return nomeA.compareTo(nomeB);
      });
      
      resultado.addAll(diagnosticosDaCultura);
    }
    
    return resultado;
  }
}
