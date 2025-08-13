// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/planta_model.dart';
import 'plantas_state_service.dart';

/// Serviço especializado para lógica de busca e filtros de plantas
/// Separado do controller para melhor organização de responsabilidades
class PlantasSearchService extends GetxService {
  static PlantasSearchService get instance => Get.find<PlantasSearchService>();

  PlantasStateService get _stateService => PlantasStateService.instance;

  final searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxList<String> _searchHistory = <String>[].obs;
  final RxList<String> _searchSuggestions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    _loadSearchHistory();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ========== GETTERS ==========

  /// Query de busca atual
  String get searchQuery => _searchQuery.value;

  /// Histórico de buscas
  List<String> get searchHistory => _searchHistory.toList();

  /// Sugestões de busca
  List<String> get searchSuggestions => _searchSuggestions.toList();

  // ========== MÉTODOS DE BUSCA ==========

  /// Define o filtro de busca
  void setSearchFilter(String query) {
    _searchQuery.value = query.trim();
    searchController.text = query;
    _stateService.setSearchFilter(query);

    // Adicionar ao histórico se não estiver vazio
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      _addToSearchHistory(query);
    }

    // Atualizar sugestões
    _updateSearchSuggestions(query);
  }

  /// Limpa o filtro de busca
  void clearSearch() {
    _searchQuery.value = '';
    searchController.clear();
    _stateService.clearSearchFilter();
    _searchSuggestions.clear();
  }

  /// Busca plantas por texto
  List<PlantaModel> searchPlantas(String query) {
    if (query.isEmpty) {
      return _stateService.plantas.value;
    }

    final lowerQuery = query.toLowerCase();
    return _stateService.plantas.value.where((planta) {
      final nome = planta.nome?.toLowerCase() ?? '';
      final especie = planta.especie?.toLowerCase() ?? '';
      final observacoes = planta.observacoes?.toLowerCase() ?? '';

      return nome.contains(lowerQuery) ||
          especie.contains(lowerQuery) ||
          observacoes.contains(lowerQuery);
    }).toList();
  }

  /// Busca plantas por espaço
  List<PlantaModel> searchPlantasByEspaco(String espacoId) {
    return _stateService.plantas.value
        .where((planta) => planta.espacoId == espacoId)
        .toList();
  }

  /// Busca plantas por espécie
  List<PlantaModel> searchPlantasByEspecie(String especie) {
    final lowerEspecie = especie.toLowerCase();
    return _stateService.plantas.value
        .where((planta) =>
            planta.especie?.toLowerCase().contains(lowerEspecie) == true)
        .toList();
  }

  // ========== SUGESTÕES E HISTÓRICO ==========

  /// Gera sugestões de busca baseadas no query atual
  void _updateSearchSuggestions(String query) {
    if (query.isEmpty) {
      _searchSuggestions.clear();
      return;
    }

    final lowerQuery = query.toLowerCase();
    final suggestions = <String>{};

    // Sugestões baseadas em nomes de plantas
    for (final planta in _stateService.plantas.value) {
      final nome = planta.nome?.toLowerCase() ?? '';
      final especie = planta.especie?.toLowerCase() ?? '';

      if (nome.contains(lowerQuery) && nome != lowerQuery) {
        suggestions.add(planta.nome!);
      }

      if (especie.contains(lowerQuery) && especie != lowerQuery) {
        suggestions.add(planta.especie!);
      }
    }

    // Sugestões do histórico
    for (final historical in _searchHistory) {
      if (historical.toLowerCase().contains(lowerQuery) &&
          historical.toLowerCase() != lowerQuery) {
        suggestions.add(historical);
      }
    }

    _searchSuggestions.assignAll(suggestions.take(5).toList());
  }

  /// Adiciona query ao histórico de buscas
  void _addToSearchHistory(String query) {
    _searchHistory.remove(query); // Remove se já existe
    _searchHistory.insert(0, query); // Adiciona no início

    // Limita histórico a 10 itens
    if (_searchHistory.length > 10) {
      _searchHistory.removeRange(10, _searchHistory.length);
    }

    _saveSearchHistory();
  }

  /// Remove item do histórico
  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    _saveSearchHistory();
  }

  /// Limpa todo o histórico
  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
  }

  // ========== FILTROS AVANÇADOS ==========

  /// Filtra plantas com tarefas pendentes
  Future<List<PlantaModel>> getPlantasComTarefasPendentes() async {
    final plantasComTarefas = <PlantaModel>[];

    for (final planta in _stateService.plantas.value) {
      final tarefas = await _stateService.getTarefasPendentes(planta.id);
      if (tarefas.isNotEmpty) {
        plantasComTarefas.add(planta);
      }
    }

    return plantasComTarefas;
  }

  /// Filtra plantas por período de criação
  List<PlantaModel> getPlantasByPeriodo(DateTime inicio, DateTime fim) {
    return _stateService.plantas.value.where((planta) {
      final dataCadastro = planta.dataCadastro ??
          DateTime.fromMillisecondsSinceEpoch(planta.createdAt);
      return dataCadastro.isAfter(inicio) && dataCadastro.isBefore(fim);
    }).toList();
  }

  // ========== PERSISTÊNCIA ==========

  /// Configura listener para o campo de busca
  void _setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text;
      if (query != _searchQuery.value) {
        setSearchFilter(query);
      }
    });
  }

  /// Carrega histórico de buscas do storage local
  void _loadSearchHistory() {
    // TODO: Implementar carregamento do SharedPreferences
    // Por enquanto, lista vazia
    debugPrint('📚 PlantasSearchService: Histórico carregado');
  }

  /// Salva histórico de buscas no storage local
  void _saveSearchHistory() {
    // TODO: Implementar salvamento no SharedPreferences
    debugPrint('💾 PlantasSearchService: Histórico salvo');
  }
}
