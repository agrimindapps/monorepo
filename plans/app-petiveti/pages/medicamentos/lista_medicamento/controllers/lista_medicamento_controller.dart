// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../lista_medicamento_detalhes/views/lista_medicamento_detalhes_page.dart';
import '../models/medicamento_model.dart';

class ListaMedicamentoController extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _filterType = 'Todos';
  final Set<String> _favoritos = {};
  bool _isGridView = false;

  final List<String> _tiposFiltro = [
    'Todos',
    'Antibiótico',
    'Analgésico',
    'Anti-inflamatório',
    'Antiparasitário',
    'Vermífugo',
    'Suplemento',
    'Corticoide'
  ];

  TextEditingController get searchController => _searchController;
  String get searchText => _searchText;
  String get filterType => _filterType;
  Set<String> get favoritos => Set.unmodifiable(_favoritos);
  bool get isGridView => _isGridView;
  List<String> get tiposFiltro => List.unmodifiable(_tiposFiltro);

  List<Medicamento> get filteredMedicamentos {
    return MedicamentoRepository.filter(
      searchText: _searchText,
      filterType: _filterType,
    );
  }

  Map<String, List<Medicamento>> get groupedMedicamentos {
    return MedicamentoRepository.groupByType(filteredMedicamentos);
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

  void updateFilterType(String tipo) {
    _filterType = tipo;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  bool isFavorito(String nomeMedicamento) {
    return _favoritos.contains(nomeMedicamento);
  }

  void toggleFavorito(String nomeMedicamento) {
    if (_favoritos.contains(nomeMedicamento)) {
      _favoritos.remove(nomeMedicamento);
    } else {
      _favoritos.add(nomeMedicamento);
    }
    notifyListeners();
  }

  void navigateToDetalhes(BuildContext context, Medicamento medicamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListaMedicamentoDetalhesPage(),
        settings: RouteSettings(arguments: medicamento.toMap()),
      ),
    );
  }

  void navigateToFavoritos(BuildContext context) {
    // Implementar navegação para favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de favoritos em desenvolvimento')),
    );
  }

  void navigateToRecentes(BuildContext context) {
    // Implementar navegação para recentes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de recentes em desenvolvimento')),
    );
  }

  void navigateToAdicionar(BuildContext context) {
    // Implementar navegação para adicionar medicamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de adicionar medicamento em desenvolvimento')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
