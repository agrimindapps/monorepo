import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/favoritos_data.dart';
import '../models/favorito_defensivo_model.dart';
import '../models/favorito_praga_model.dart';
import '../models/favorito_diagnostico_model.dart';

abstract class IFavoritosRepository {
  Future<List<FavoritoDefensivoModel>> getFavoritosDefensivos();
  Future<List<FavoritoPragaModel>> getFavoritosPragas();
  Future<List<FavoritoDiagnosticoModel>> getFavoritosDiagnosticos();
  Future<void> removeFavoritoDefensivo(int id);
  Future<void> removeFavoritoPraga(int id);
  Future<void> removeFavoritoDiagnostico(int id);
}

abstract class IPremiumService {
  bool get isPremium;
}

class FavoritosDataService extends ChangeNotifier {
  final IFavoritosRepository? _repository;
  
  FavoritosData _favoritosData = const FavoritosData();
  bool _isLoading = false;
  String _errorMessage = '';

  FavoritosDataService({
    IFavoritosRepository? repository,
  }) : _repository = repository;

  FavoritosData get favoritosData => _favoritosData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  Future<void> loadAllFavorites() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await Future.wait([
        _carregarFavoritosDefensivos(),
        _carregarFavoritosPragas(),
        _carregarFavoritosDiagnosticos(),
      ]);

    } catch (e) {
      _errorMessage = 'Erro ao carregar favoritos: $e';
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _carregarFavoritosDefensivos() async {
    try {
      final dados = await _repository?.getFavoritosDefensivos() ?? <FavoritoDefensivoModel>[];
      _favoritosData = _favoritosData.copyWith(defensivos: dados);
    } catch (e) {
      debugPrint('Error loading defensivos favorites: $e');
    }
  }

  Future<void> _carregarFavoritosPragas() async {
    try {
      final dados = await _repository?.getFavoritosPragas() ?? <FavoritoPragaModel>[];
      _favoritosData = _favoritosData.copyWith(pragas: dados);
    } catch (e) {
      debugPrint('Error loading pragas favorites: $e');
    }
  }

  Future<void> _carregarFavoritosDiagnosticos() async {
    // Premium check removido - usando dados reais via Hive
    try {
      final dados = await _repository?.getFavoritosDiagnosticos() ?? <FavoritoDiagnosticoModel>[];
      _favoritosData = _favoritosData.copyWith(diagnosticos: dados);
    } catch (e) {
      debugPrint('Error loading diagnosticos favorites: $e');
    }
  }

  Future<void> removeFavoritoDefensivo(int id) async {
    try {
      await _repository?.removeFavoritoDefensivo(id);
      final updated = _favoritosData.defensivos.where((item) => item.id != id).toList();
      _favoritosData = _favoritosData.copyWith(defensivos: updated);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing defensivo favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavoritoPraga(int id) async {
    try {
      await _repository?.removeFavoritoPraga(id);
      final updated = _favoritosData.pragas.where((item) => item.id != id).toList();
      _favoritosData = _favoritosData.copyWith(pragas: updated);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing praga favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavoritoDiagnostico(int id) async {
    try {
      await _repository?.removeFavoritoDiagnostico(id);
      final updated = _favoritosData.diagnosticos.where((item) => item.id != id).toList();
      _favoritosData = _favoritosData.copyWith(diagnosticos: updated);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing diagnostico favorite: $e');
      rethrow;
    }
  }

  void updateDefensivosFilter(String filter) {
    _favoritosData = _favoritosData.copyWith(defensivosFilter: filter);
    notifyListeners();
  }

  void updatePragasFilter(String filter) {
    _favoritosData = _favoritosData.copyWith(pragasFilter: filter);
    notifyListeners();
  }

  void updateDiagnosticosFilter(String filter) {
    _favoritosData = _favoritosData.copyWith(diagnosticosFilter: filter);
    notifyListeners();
  }

  void clearAllFilters() {
    _favoritosData = _favoritosData.copyWith(
      defensivosFilter: '',
      pragasFilter: '',
      diagnosticosFilter: '',
    );
    notifyListeners();
  }

}