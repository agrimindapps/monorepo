// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/defensivos_repository.dart';
import '../models/defensivo_item.dart';
import '../models/defensivos_home_data.dart';

/// Service responsável pela lógica de negócio do módulo Home Defensivos
/// Extrai a lógica de business logic do controller seguindo SRP
class DefensivosBusinessService {
  late final DefensivosRepository _repository;
  
  /// Inicializa o service com validação de pré-condições
  Future<void> initialize() async {
    await _initializeRepositoryInstance();
    await _initializeRepositoryInfo();
  }
  
  /// Carrega dados completos da home com fallback para dados vazios
  Future<DefensivosHomeData> loadHomeData() async {
    try {
      return await _loadData();
    } catch (e) {
      // Fallback para dados vazios em caso de erro
      return _createEmptyHomeData();
    }
  }
  
  /// Valida se o service está devidamente inicializado
  bool isInitialized() {
    try {
      return _repository != null;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _initializeRepositoryInstance() async {
    try {
      // Tentar usar repository singleton primeiro
      if (Get.isRegistered<DefensivosRepository>()) {
        _repository = Get.find<DefensivosRepository>();
      } else {
        _repository = DefensivosRepository();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeRepositoryInfo() async {
    try {
      _repository.initInfo();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<DefensivosHomeData> _loadData() async {
    // Load counts synchronously
    final counts = _loadCounts();
    
    // Load lists with error handling
    final recentlyAccessed = await _loadRecentlyAccessedDefensivos();
    final newProducts = await _loadNewProducts();
    
    return DefensivosHomeData(
      defensivos: counts.defensivos,
      fabricantes: counts.fabricantes,
      actionMode: counts.actionMode,
      activeIngredient: counts.activeIngredient,
      agronomicClass: counts.agronomicClass,
      recentlyAccessed: recentlyAccessed,
      newProducts: newProducts,
    );
  }
  
  ({
    int defensivos, 
    int fabricantes, 
    int actionMode, 
    int activeIngredient, 
    int agronomicClass
  }) _loadCounts() {
    return (
      defensivos: _repository.getDefensivosCount(),
      fabricantes: _repository.getFabricanteCount(),
      actionMode: _repository.getModoDeAcaoCount(),
      activeIngredient: _repository.getIngredienteAtivoCount(),
      agronomicClass: _repository.getClasseAgronomicaCount(),
    );
  }
  
  Future<List<DefensivoItem>> _loadRecentlyAccessedDefensivos() async {
    try {
      final items = await _repository.getDefensivosAcessados();
      return items.take(10).map((item) => DefensivoItem.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<DefensivoItem>> _loadNewProducts() async {
    try {
      final items = _repository.getDefensivosNovos();
      return items.take(5).map((item) => DefensivoItem.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }
  
  DefensivosHomeData _createEmptyHomeData() {
    return DefensivosHomeData(
      defensivos: 0,
      fabricantes: 0,
      actionMode: 0,
      activeIngredient: 0,
      agronomicClass: 0,
      recentlyAccessed: [],
      newProducts: [],
    );
  }
}