import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculation_template.dart';
import '../../domain/services/calculator_favorites_service.dart';
import '../../domain/services/calculator_template_service.dart';

part 'calculator_features_provider.g.dart';

/// State class for CalculatorFeatures
class CalculatorFeaturesState {
  final List<String> favoriteIds;
  final bool isLoadingFavorites;
  final List<CalculationTemplate> templates;
  final List<CalculationTemplate> filteredTemplates;
  final bool isLoadingTemplates;
  final String templateSearchQuery;
  final String? errorMessage;

  const CalculatorFeaturesState({
    this.favoriteIds = const [],
    this.isLoadingFavorites = false,
    this.templates = const [],
    this.filteredTemplates = const [],
    this.isLoadingTemplates = false,
    this.templateSearchQuery = '',
    this.errorMessage,
  });

  CalculatorFeaturesState copyWith({
    List<String>? favoriteIds,
    bool? isLoadingFavorites,
    List<CalculationTemplate>? templates,
    List<CalculationTemplate>? filteredTemplates,
    bool? isLoadingTemplates,
    String? templateSearchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalculatorFeaturesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      isLoadingTemplates: isLoadingTemplates ?? this.isLoadingTemplates,
      templateSearchQuery: templateSearchQuery ?? this.templateSearchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// CalculatorFeatures Notifier using Riverpod code generation
@riverpod
class CalculatorFeaturesNotifier extends _$CalculatorFeaturesNotifier {
  CalculatorFavoritesService? _favoritesService;
  CalculatorTemplateService? _templateService;

  @override
  CalculatorFeaturesState build() {
    return const CalculatorFeaturesState();
  }

  // Convenience getters for backward compatibility
  List<String> get favoriteIds => state.favoriteIds;
  bool get isLoadingFavorites => state.isLoadingFavorites;
  List<CalculationTemplate> get templates => state.templates;
  List<CalculationTemplate> get filteredTemplates => state.filteredTemplates;
  bool get isLoadingTemplates => state.isLoadingTemplates;
  String get templateSearchQuery => state.templateSearchQuery;
  String? get errorMessage => state.errorMessage;

  /// Inicializa os serviços
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritesService = CalculatorFavoritesService(prefs);
    _templateService = CalculatorTemplateService(prefs);

    await Future.wait([loadFavorites(), loadTemplates()]);
  }

  /// Carrega lista de favoritos
  Future<void> loadFavorites() async {
    if (_favoritesService == null) return;

    state = state.copyWith(isLoadingFavorites: true, clearError: true);

    try {
      final favorites = await _favoritesService!.getFavoriteIds();
      state = state.copyWith(favoriteIds: favorites, isLoadingFavorites: false);
      debugPrint(
        'CalculatorFeaturesNotifier: Favoritos carregados - ${favorites.length} itens',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar favoritos: ${e.toString()}',
        isLoadingFavorites: false,
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao carregar favoritos - $e');
    }
  }

  /// Verifica se calculadora é favorita
  bool isFavorite(String calculatorId) {
    return state.favoriteIds.contains(calculatorId);
  }

  /// Alterna status de favorito
  Future<bool> toggleFavorite(String calculatorId) async {
    if (_favoritesService == null) return false;

    try {
      final success = await _favoritesService!.toggleFavorite(calculatorId);
      if (success) {
        await loadFavorites();
        debugPrint(
          'CalculatorFeaturesNotifier: Favorito alternado - $calculatorId',
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao alterar favorito: ${e.toString()}',
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao alterar favorito - $e');
      return false;
    }
  }

  /// Adiciona calculadora aos favoritos
  Future<bool> addToFavorites(String calculatorId) async {
    if (_favoritesService == null) return false;

    try {
      final success = await _favoritesService!.addToFavorites(calculatorId);
      if (success) {
        await loadFavorites();
        debugPrint(
          'CalculatorFeaturesNotifier: Adicionado aos favoritos - $calculatorId',
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao adicionar favorito: ${e.toString()}',
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao adicionar favorito - $e');
      return false;
    }
  }

  /// Remove calculadora dos favoritos
  Future<bool> removeFromFavorites(String calculatorId) async {
    if (_favoritesService == null) return false;

    try {
      final success = await _favoritesService!.removeFromFavorites(
        calculatorId,
      );
      if (success) {
        await loadFavorites();
        debugPrint(
          'CalculatorFeaturesNotifier: Removido dos favoritos - $calculatorId',
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover favorito: ${e.toString()}',
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao remover favorito - $e');
      return false;
    }
  }

  /// Obtém estatísticas dos favoritos
  Future<FavoritesStats> getFavoritesStats() async {
    if (_favoritesService == null) {
      return const FavoritesStats(totalFavorites: 0, hasBackup: false);
    }
    return await _favoritesService!.getStats();
  }

  /// Carrega todos os templates
  Future<void> loadTemplates() async {
    if (_templateService == null) return;

    state = state.copyWith(isLoadingTemplates: true, clearError: true);

    try {
      final templates = await _templateService!.getAllTemplates();
      state = state.copyWith(templates: templates, isLoadingTemplates: false);
      _applyTemplateFilters();
      debugPrint(
        'CalculatorFeaturesNotifier: Templates carregados - ${templates.length} itens',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar templates: ${e.toString()}',
        isLoadingTemplates: false,
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao carregar templates - $e');
    }
  }

  /// Carrega templates de uma calculadora específica
  Future<List<CalculationTemplate>> getTemplatesForCalculator(
    String calculatorId,
  ) async {
    if (_templateService == null) return [];

    try {
      return await _templateService!.getTemplatesForCalculator(calculatorId);
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesNotifier: Erro ao carregar templates da calculadora - $e',
      );
      return [];
    }
  }

  /// Salva novo template
  Future<bool> saveTemplate(CalculationTemplate template) async {
    if (_templateService == null) return false;

    try {
      final success = await _templateService!.saveTemplate(template);
      if (success) {
        await loadTemplates();
        debugPrint(
          'CalculatorFeaturesNotifier: Template salvo - ${template.name}',
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao salvar template: ${e.toString()}',
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao salvar template - $e');
      return false;
    }
  }

  /// Remove template
  Future<bool> deleteTemplate(String templateId) async {
    if (_templateService == null) return false;

    try {
      final success = await _templateService!.deleteTemplate(templateId);
      if (success) {
        await loadTemplates();
        debugPrint(
          'CalculatorFeaturesNotifier: Template removido - $templateId',
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover template: ${e.toString()}',
      );
      debugPrint('CalculatorFeaturesNotifier: Erro ao remover template - $e');
      return false;
    }
  }

  /// Marca template como usado
  Future<bool> markTemplateAsUsed(String templateId) async {
    if (_templateService == null) return false;

    try {
      final success = await _templateService!.markTemplateAsUsed(templateId);
      if (success) {
        final templateIndex = state.templates.indexWhere(
          (t) => t.id == templateId,
        );
        if (templateIndex != -1) {
          final updatedTemplates = List<CalculationTemplate>.from(
            state.templates,
          );
          updatedTemplates[templateIndex] = updatedTemplates[templateIndex]
              .markAsUsed();
          state = state.copyWith(templates: updatedTemplates);
          _applyTemplateFilters();
        }
        debugPrint(
          'CalculatorFeaturesNotifier: Template marcado como usado - $templateId',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesNotifier: Erro ao marcar template como usado - $e',
      );
      return false;
    }
  }

  /// Busca templates
  void searchTemplates(String query) {
    state = state.copyWith(templateSearchQuery: query);
    _applyTemplateFilters();
    debugPrint('CalculatorFeaturesNotifier: Busca de templates - "$query"');
  }

  /// Aplica filtros aos templates
  void _applyTemplateFilters() {
    var filtered = List<CalculationTemplate>.from(state.templates);
    if (state.templateSearchQuery.isNotEmpty) {
      final query = state.templateSearchQuery.toLowerCase();
      filtered = filtered
          .where(
            (template) =>
                template.name.toLowerCase().contains(query) ||
                (template.description?.toLowerCase() ?? '').contains(query) ||
                template.tags.any((tag) => tag.toLowerCase().contains(query)),
          )
          .toList();
    }
    filtered.sort((a, b) {
      if (a.lastUsed != null && b.lastUsed == null) return -1;
      if (a.lastUsed == null && b.lastUsed != null) return 1;
      if (a.lastUsed != null && b.lastUsed != null) {
        return b.lastUsed!.compareTo(a.lastUsed!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    state = state.copyWith(filteredTemplates: filtered);
  }

  /// Obtém templates recentes
  Future<List<CalculationTemplate>> getRecentTemplates({int limit = 5}) async {
    if (_templateService == null) return [];

    try {
      return await _templateService!.getRecentTemplates(limit: limit);
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesNotifier: Erro ao obter templates recentes - $e',
      );
      return [];
    }
  }

  /// Obtém templates populares
  Future<List<CalculationTemplate>> getPopularTemplates({int limit = 5}) async {
    if (_templateService == null) return [];

    try {
      return await _templateService!.getPopularTemplates(limit: limit);
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesNotifier: Erro ao obter templates populares - $e',
      );
      return [];
    }
  }

  /// Obtém estatísticas dos templates
  Future<TemplateStats> getTemplateStats() async {
    if (_templateService == null) {
      return const TemplateStats(
        totalTemplates: 0,
        recentlyUsed: 0,
        publicTemplates: 0,
        hasBackup: false,
      );
    }
    return await _templateService!.getStats();
  }

  /// Gera link de compartilhamento para calculadora
  String generateCalculatorShareLink(
    String calculatorId,
    String calculatorName,
  ) {
    return 'agrihurbi://calculator/$calculatorId';
  }

  /// Gera texto para compartilhamento de calculadora
  String generateCalculatorShareText(
    String calculatorName,
    String description,
  ) {
    return 'Confira a calculadora "$calculatorName" no AgriHurbi!\n\n'
        '$description\n\n'
        'Baixe o app e melhore sua gestão agrícola.';
  }

  /// Gera texto para compartilhamento de resultado
  String generateResultShareText(
    String calculatorName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> outputs,
  ) {
    final inputsText = inputs.entries
        .map((e) => '• ${e.key}: ${e.value}')
        .join('\n');

    final outputsText = outputs.entries
        .map((e) => '• ${e.key}: ${e.value}')
        .join('\n');

    return 'Resultado da calculadora "$calculatorName" - AgriHurbi\n\n'
        'Parâmetros:\n$inputsText\n\n'
        'Resultados:\n$outputsText\n\n'
        'Calculado em ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
  }

  /// Exporta template como JSON
  Future<String?> exportTemplate(String templateId) async {
    if (_templateService == null) return null;

    try {
      final template = await _templateService!.getTemplateById(templateId);
      if (template == null) return null;
      return template.toString();
    } catch (e) {
      debugPrint('CalculatorFeaturesNotifier: Erro ao exportar template - $e');
      return null;
    }
  }

  /// Exporta resultado como CSV/JSON
  Future<String?> exportResult(
    String format,
    String calculatorName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> outputs,
  ) async {
    try {
      if (format.toLowerCase() == 'csv') {
        return _generateCSVResult(calculatorName, inputs, outputs);
      } else if (format.toLowerCase() == 'json') {
        return _generateJSONResult(calculatorName, inputs, outputs);
      }
      return null;
    } catch (e) {
      debugPrint('CalculatorFeaturesNotifier: Erro ao exportar resultado - $e');
      return null;
    }
  }

  String _generateCSVResult(
    String calculatorName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> outputs,
  ) {
    final timestamp = DateTime.now().toIso8601String();

    var csv = 'Calculadora,Tipo,Parâmetro,Valor,Timestamp\n';

    for (final entry in inputs.entries) {
      csv +=
          '"$calculatorName",Entrada,"${entry.key}","${entry.value}","$timestamp"\n';
    }

    for (final entry in outputs.entries) {
      csv +=
          '"$calculatorName",Resultado,"${entry.key}","${entry.value}","$timestamp"\n';
    }

    return csv;
  }

  String _generateJSONResult(
    String calculatorName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> outputs,
  ) {
    final data = {
      'calculator': calculatorName,
      'timestamp': DateTime.now().toIso8601String(),
      'inputs': inputs,
      'outputs': outputs,
    };
    return data.toString();
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpa filtros de templates
  void clearTemplateFilters() {
    state = state.copyWith(templateSearchQuery: '');
    _applyTemplateFilters();
  }

  /// Refresh completo dos dados
  Future<void> refreshAllData() async {
    await Future.wait([loadFavorites(), loadTemplates()]);
  }
}
