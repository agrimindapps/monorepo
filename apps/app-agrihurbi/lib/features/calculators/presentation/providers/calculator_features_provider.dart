import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/calculation_template.dart';
import '../../domain/services/calculator_favorites_service.dart';
import '../../domain/services/calculator_template_service.dart';

/// Provider Riverpod para CalculatorFeaturesProvider
final calculatorFeaturesProvider =
    ChangeNotifierProvider<CalculatorFeaturesProvider>((ref) {
      return CalculatorFeaturesProvider();
    });

/// Provider para funcionalidades avançadas das calculadoras
///
/// Gerencia templates, favoritos, compartilhamento e histórico
/// Complementa o CalculatorProvider com features específicas
@singleton
class CalculatorFeaturesProvider extends ChangeNotifier {
  late final CalculatorFavoritesService _favoritesService;
  late final CalculatorTemplateService _templateService;
  List<String> _favoriteIds = [];
  bool _isLoadingFavorites = false;
  List<CalculationTemplate> _templates = [];
  List<CalculationTemplate> _filteredTemplates = [];
  bool _isLoadingTemplates = false;
  String _templateSearchQuery = '';
  String? _errorMessage;

  CalculatorFeaturesProvider();

  /// Inicializa os serviços
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritesService = CalculatorFavoritesService(prefs);
    _templateService = CalculatorTemplateService(prefs);

    await Future.wait([loadFavorites(), loadTemplates()]);
  }

  List<String> get favoriteIds => _favoriteIds;
  bool get isLoadingFavorites => _isLoadingFavorites;

  List<CalculationTemplate> get templates => _templates;
  List<CalculationTemplate> get filteredTemplates => _filteredTemplates;
  bool get isLoadingTemplates => _isLoadingTemplates;
  String get templateSearchQuery => _templateSearchQuery;

  String? get errorMessage => _errorMessage;

  /// Carrega lista de favoritos
  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favoriteIds = await _favoritesService.getFavoriteIds();
      debugPrint(
        'CalculatorFeaturesProvider: Favoritos carregados - ${_favoriteIds.length} itens',
      );
    } catch (e) {
      _errorMessage = 'Erro ao carregar favoritos: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao carregar favoritos - $e');
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  /// Verifica se calculadora é favorita
  bool isFavorite(String calculatorId) {
    return _favoriteIds.contains(calculatorId);
  }

  /// Alterna status de favorito
  Future<bool> toggleFavorite(String calculatorId) async {
    try {
      final success = await _favoritesService.toggleFavorite(calculatorId);
      if (success) {
        await loadFavorites(); // Recarrega lista
        debugPrint(
          'CalculatorFeaturesProvider: Favorito alternado - $calculatorId',
        );
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao alterar favorito: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao alterar favorito - $e');
      notifyListeners();
      return false;
    }
  }

  /// Adiciona calculadora aos favoritos
  Future<bool> addToFavorites(String calculatorId) async {
    try {
      final success = await _favoritesService.addToFavorites(calculatorId);
      if (success) {
        await loadFavorites();
        debugPrint(
          'CalculatorFeaturesProvider: Adicionado aos favoritos - $calculatorId',
        );
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar favorito: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao adicionar favorito - $e');
      notifyListeners();
      return false;
    }
  }

  /// Remove calculadora dos favoritos
  Future<bool> removeFromFavorites(String calculatorId) async {
    try {
      final success = await _favoritesService.removeFromFavorites(calculatorId);
      if (success) {
        await loadFavorites();
        debugPrint(
          'CalculatorFeaturesProvider: Removido dos favoritos - $calculatorId',
        );
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao remover favorito: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao remover favorito - $e');
      notifyListeners();
      return false;
    }
  }

  /// Obtém estatísticas dos favoritos
  Future<FavoritesStats> getFavoritesStats() async {
    return await _favoritesService.getStats();
  }

  /// Carrega todos os templates
  Future<void> loadTemplates() async {
    _isLoadingTemplates = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _templateService.getAllTemplates();
      _applyTemplateFilters();
      debugPrint(
        'CalculatorFeaturesProvider: Templates carregados - ${_templates.length} itens',
      );
    } catch (e) {
      _errorMessage = 'Erro ao carregar templates: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao carregar templates - $e');
    } finally {
      _isLoadingTemplates = false;
      notifyListeners();
    }
  }

  /// Carrega templates de uma calculadora específica
  Future<List<CalculationTemplate>> getTemplatesForCalculator(
    String calculatorId,
  ) async {
    try {
      return await _templateService.getTemplatesForCalculator(calculatorId);
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesProvider: Erro ao carregar templates da calculadora - $e',
      );
      return [];
    }
  }

  /// Salva novo template
  Future<bool> saveTemplate(CalculationTemplate template) async {
    try {
      final success = await _templateService.saveTemplate(template);
      if (success) {
        await loadTemplates(); // Recarrega lista
        debugPrint(
          'CalculatorFeaturesProvider: Template salvo - ${template.name}',
        );
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao salvar template: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao salvar template - $e');
      notifyListeners();
      return false;
    }
  }

  /// Remove template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      final success = await _templateService.deleteTemplate(templateId);
      if (success) {
        await loadTemplates(); // Recarrega lista
        debugPrint(
          'CalculatorFeaturesProvider: Template removido - $templateId',
        );
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao remover template: ${e.toString()}';
      debugPrint('CalculatorFeaturesProvider: Erro ao remover template - $e');
      notifyListeners();
      return false;
    }
  }

  /// Marca template como usado
  Future<bool> markTemplateAsUsed(String templateId) async {
    try {
      final success = await _templateService.markTemplateAsUsed(templateId);
      if (success) {
        final templateIndex = _templates.indexWhere((t) => t.id == templateId);
        if (templateIndex != -1) {
          _templates[templateIndex] = _templates[templateIndex].markAsUsed();
          _applyTemplateFilters();
          notifyListeners();
        }
        debugPrint(
          'CalculatorFeaturesProvider: Template marcado como usado - $templateId',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesProvider: Erro ao marcar template como usado - $e',
      );
      return false;
    }
  }

  /// Busca templates
  void searchTemplates(String query) {
    _templateSearchQuery = query;
    _applyTemplateFilters();
    notifyListeners();
    debugPrint('CalculatorFeaturesProvider: Busca de templates - "$query"');
  }

  /// Aplica filtros aos templates
  void _applyTemplateFilters() {
    var filtered = List<CalculationTemplate>.from(_templates);
    if (_templateSearchQuery.isNotEmpty) {
      final query = _templateSearchQuery.toLowerCase();
      filtered =
          filtered
              .where(
                (template) =>
                    template.name.toLowerCase().contains(query) ||
                    (template.description?.toLowerCase() ?? '').contains(
                      query,
                    ) ||
                    template.tags.any(
                      (tag) => tag.toLowerCase().contains(query),
                    ),
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

    _filteredTemplates = filtered;
  }

  /// Obtém templates recentes
  Future<List<CalculationTemplate>> getRecentTemplates({int limit = 5}) async {
    try {
      return await _templateService.getRecentTemplates(limit: limit);
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesProvider: Erro ao obter templates recentes - $e',
      );
      return [];
    }
  }

  /// Obtém templates populares
  Future<List<CalculationTemplate>> getPopularTemplates({int limit = 5}) async {
    try {
      return await _templateService.getPopularTemplates(limit: limit);
    } catch (e) {
      debugPrint(
        'CalculatorFeaturesProvider: Erro ao obter templates populares - $e',
      );
      return [];
    }
  }

  /// Obtém estatísticas dos templates
  Future<TemplateStats> getTemplateStats() async {
    return await _templateService.getStats();
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
    try {
      final template = await _templateService.getTemplateById(templateId);
      if (template == null) return null;
      return template.toString();
    } catch (e) {
      debugPrint('CalculatorFeaturesProvider: Erro ao exportar template - $e');
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
      debugPrint('CalculatorFeaturesProvider: Erro ao exportar resultado - $e');
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
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa filtros de templates
  void clearTemplateFilters() {
    _templateSearchQuery = '';
    _applyTemplateFilters();
    notifyListeners();
  }

  /// Refresh completo dos dados
  Future<void> refreshAllData() async {
    await Future.wait([loadFavorites(), loadTemplates()]);
  }

  @override
  void dispose() {
    debugPrint('CalculatorFeaturesProvider: Disposed');
    super.dispose();
  }
}
