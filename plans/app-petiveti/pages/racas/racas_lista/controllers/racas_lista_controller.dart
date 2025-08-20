// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../racas_detalhes/views/racas_detalhes_page.dart';
import '../models/especie_model.dart';
import '../models/raca_model.dart';

class RacasListaController extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isGridView = false;
  final Set<String> _selectedRacas = {};
  final Set<String> _quickFilters = {};
  Especie? _especieAtual;

  // Filtros avançados
  final Set<String> _tamanhoFiltros = {};
  final Set<String> _temperamentoFiltros = {};
  final Set<String> _cuidadosFiltros = {};

  TextEditingController get searchController => _searchController;
  String get searchText => _searchText;
  bool get isGridView => _isGridView;
  Set<String> get selectedRacas => Set.unmodifiable(_selectedRacas);
  Set<String> get quickFilters => Set.unmodifiable(_quickFilters);
  Especie? get especieAtual => _especieAtual;
  Set<String> get tamanhoFiltros => Set.unmodifiable(_tamanhoFiltros);
  Set<String> get temperamentoFiltros => Set.unmodifiable(_temperamentoFiltros);
  Set<String> get cuidadosFiltros => Set.unmodifiable(_cuidadosFiltros);

  List<Raca> get racasFiltradas {
    final racas = RacaRepository.filter(
      searchText: _searchText,
      quickFilters: _quickFilters.toList(),
      tamanhoFiltros: _tamanhoFiltros.toList(),
      temperamentoFiltros: _temperamentoFiltros.toList(),
      cuidadosFiltros: _cuidadosFiltros.toList(),
    );

    // Atualizar total de raças na espécie
    if (_especieAtual != null) {
      EspecieRepository.atualizarTotalRacas(_especieAtual!.nome, racas.length);
    }

    return racas;
  }

  bool get hasActiveFilters {
    return _quickFilters.isNotEmpty ||
           _tamanhoFiltros.isNotEmpty ||
           _temperamentoFiltros.isNotEmpty ||
           _cuidadosFiltros.isNotEmpty ||
           _searchText.isNotEmpty;
  }

  void inicializarEspecie(Object? arguments) {
    if (arguments != null && arguments is Map<String, dynamic>) {
      _especieAtual = EspecieRepository.getEspecieOrDefault(
        arguments['especie'] ?? 'Cachorros'
      );
      notifyListeners();
    } else {
      _especieAtual = EspecieRepository.getEspecieOrDefault('Cachorros');
      notifyListeners();
    }
  }

  void updateSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  void clearSearch() {
    _searchController.clear();
    _searchText = '';
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void toggleQuickFilter(String filter) {
    if (_quickFilters.contains(filter)) {
      _quickFilters.remove(filter);
    } else {
      _quickFilters.add(filter);
    }
    notifyListeners();
  }

  void clearAllFilters() {
    _searchController.clear();
    _searchText = '';
    _quickFilters.clear();
    _tamanhoFiltros.clear();
    _temperamentoFiltros.clear();
    _cuidadosFiltros.clear();
    notifyListeners();
  }

  void toggleTamanhoFilter(String tamanho) {
    if (_tamanhoFiltros.contains(tamanho)) {
      _tamanhoFiltros.remove(tamanho);
    } else {
      _tamanhoFiltros.add(tamanho);
    }
    notifyListeners();
  }

  void toggleTemperamentoFilter(String temperamento) {
    if (_temperamentoFiltros.contains(temperamento)) {
      _temperamentoFiltros.remove(temperamento);
    } else {
      _temperamentoFiltros.add(temperamento);
    }
    notifyListeners();
  }

  void toggleCuidadosFilter(String cuidado) {
    if (_cuidadosFiltros.contains(cuidado)) {
      _cuidadosFiltros.remove(cuidado);
    } else {
      _cuidadosFiltros.add(cuidado);
    }
    notifyListeners();
  }

  bool isRacaSelected(String nomeRaca) {
    return _selectedRacas.contains(nomeRaca);
  }

  void toggleRacaSelection(String nomeRaca) {
    if (_selectedRacas.contains(nomeRaca)) {
      _selectedRacas.remove(nomeRaca);
    } else {
      if (_selectedRacas.length < 3) {
        _selectedRacas.add(nomeRaca);
      }
    }
    notifyListeners();
  }

  bool canSelectMoreRacas() {
    return _selectedRacas.length < 3;
  }

  void clearSelection() {
    _selectedRacas.clear();
    notifyListeners();
  }

  void navigateToRacaDetalhes(BuildContext context, Raca raca) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RacasDetalhesPage(),
        settings: RouteSettings(arguments: raca.nome),
      ),
    );
  }

  void showCompareOptions(BuildContext context) {
    if (_selectedRacas.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comparar Raças'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raças selecionadas: ${_selectedRacas.length}'),
            const SizedBox(height: 8),
            ..._selectedRacas.map((nome) => Text('• $nome')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar navegação para comparação
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de comparação em desenvolvimento'),
                ),
              );
            },
            child: const Text('Comparar'),
          ),
        ],
      ),
    );
  }

  void showMaxSelectionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você só pode comparar até 3 raças.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
