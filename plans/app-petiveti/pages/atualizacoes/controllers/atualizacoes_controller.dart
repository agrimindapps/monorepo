// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/atualizacao_model.dart';
import '../services/atualizacoes_service.dart';
import '../utils/atualizacoes_constants.dart';

class AtualizacoesController extends ChangeNotifier {
  final AtualizacoesService _service = AtualizacoesService();

  // State
  List<Atualizacao> _atualizacoes = [];
  List<Atualizacao> _filteredAtualizacoes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchTerm = '';
  String? _selectedCategory;
  bool _showOnlyImportant = false;
  bool _sortAscending = false;

  // Getters
  List<Atualizacao> get atualizacoes => List.unmodifiable(_filteredAtualizacoes);
  List<Atualizacao> get allAtualizacoes => List.unmodifiable(_atualizacoes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get searchTerm => _searchTerm;
  String? get selectedCategory => _selectedCategory;
  bool get showOnlyImportant => _showOnlyImportant;
  bool get sortAscending => _sortAscending;

  bool get hasAtualizacoes => _atualizacoes.isNotEmpty;
  bool get isEmpty => _atualizacoes.isEmpty;
  bool get isFiltered => _searchTerm.isNotEmpty || 
                          _selectedCategory != null || 
                          _showOnlyImportant;
  int get totalAtualizacoes => _atualizacoes.length;
  int get filteredCount => _filteredAtualizacoes.length;

  Atualizacao? get latestVersion {
    if (_atualizacoes.isEmpty) return null;
    return AtualizacaoRepository.getLatestVersion(_atualizacoes);
  }

  Map<String, int> get statistics {
    return AtualizacaoRepository.getStatistics(_atualizacoes);
  }

  List<String> get availableCategories {
    return AtualizacaoRepository.getAllCategories(_atualizacoes);
  }

  // Initialization
  Future<void> initialize() async {
    await loadAtualizacoes();
  }

  Future<void> loadAtualizacoes() async {
    try {
      _setLoading(true);
      _atualizacoes = await _service.loadAtualizacoes();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar atualizações: ${e.toString()}');
    }
  }

  // Search and filtering
  void updateSearchTerm(String term) {
    _searchTerm = term;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    updateSearchTerm('');
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void toggleImportantOnly() {
    _showOnlyImportant = !_showOnlyImportant;
    _applyFilters();
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _applySorting();
    notifyListeners();
  }

  void clearAllFilters() {
    _searchTerm = '';
    _selectedCategory = null;
    _showOnlyImportant = false;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredAtualizacoes = _service.filterAtualizacoes(
      atualizacoes: _atualizacoes,
      searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
      categoria: _selectedCategory,
      onlyImportant: _showOnlyImportant ? true : null,
    );
    
    _applySorting();
  }

  void _applySorting() {
    if (_sortAscending) {
      _filteredAtualizacoes = AtualizacaoRepository.sortByVersion(_filteredAtualizacoes).reversed.toList();
    } else {
      _filteredAtualizacoes = AtualizacaoRepository.sortByVersion(_filteredAtualizacoes);
    }
  }

  // Actions
  Future<void> refresh() async {
    await loadAtualizacoes();
  }

  void showVersionDetails(BuildContext context, Atualizacao atualizacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              atualizacao.isImportante 
                  ? AtualizacoesConstants.importantIcon 
                  : AtualizacoesConstants.versionIcon,
              color: atualizacao.isImportante 
                  ? AtualizacoesConstants.importantColor 
                  : null,
            ),
            const SizedBox(width: 8),
            Text(atualizacao.versaoFormatada),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (atualizacao.categoria != null) ...[
                Chip(
                  label: Text(atualizacao.categoria!),
                  backgroundColor: Colors.blue[100],
                ),
                const SizedBox(height: 16),
              ],
              if (atualizacao.dataLancamento != null) ...[
                Text(
                  'Lançado em: ${atualizacao.dataLancamento!.day}/${atualizacao.dataLancamento!.month}/${atualizacao.dataLancamento!.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Notas da versão:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...atualizacao.notas.map((nota) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $nota'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Apenas importantes'),
              value: _showOnlyImportant,
              onChanged: (value) {
                toggleImportantOnly();
                Navigator.pop(context);
              },
            ),
            if (availableCategories.isNotEmpty) ...[
              const Divider(),
              const Text('Categoria:'),
              ...availableCategories.map((category) => RadioListTile<String>(
                    title: Text(category),
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setCategory(value);
                      Navigator.pop(context);
                    },
                  )),
              RadioListTile<String?>(
                title: const Text('Todas'),
                value: null,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setCategory(null);
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearAllFilters();
              Navigator.pop(context);
            },
            child: const Text('Limpar tudo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String getFilterSummary() {
    final List<String> filters = [];
    
    if (_searchTerm.isNotEmpty) {
      filters.add('Pesquisa: "$_searchTerm"');
    }
    
    if (_selectedCategory != null) {
      filters.add('Categoria: $_selectedCategory');
    }
    
    if (_showOnlyImportant) {
      filters.add('Apenas importantes');
    }
    
    if (filters.isEmpty) {
      return 'Nenhum filtro aplicado';
    }
    
    return filters.join(' • ');
  }

  String getResultsSummary() {
    if (isEmpty) {
      return 'Nenhuma atualização disponível';
    }
    
    if (isFiltered) {
      return '$filteredCount de $totalAtualizacoes atualizações';
    }
    
    return '$totalAtualizacoes ${totalAtualizacoes == 1 ? 'atualização' : 'atualizações'}';
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool isLatestVersion(String version) {
    final latest = latestVersion;
    return latest != null && latest.versao == version;
  }

}
