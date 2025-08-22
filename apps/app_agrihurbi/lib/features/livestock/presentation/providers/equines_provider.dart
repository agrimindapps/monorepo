import 'package:flutter/foundation.dart';

import '../../domain/entities/equine_entity.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../../domain/usecases/get_equines.dart';

/// Provider especializado para operações de equinos
/// 
/// Separado do provider principal para otimização e modularização
/// Integrado completamente com use cases de equinos
class EquinesProvider extends ChangeNotifier {
  final GetAllEquinesUseCase _getAllEquines;
  final GetEquinesUseCase _getEquines;
  final GetEquineByIdUseCase _getEquineById;

  EquinesProvider({
    required GetAllEquinesUseCase getAllEquines,
    required GetEquinesUseCase getEquines,
    required GetEquineByIdUseCase getEquineById,
  })  : _getAllEquines = getAllEquines,
        _getEquines = getEquines,
        _getEquineById = getEquineById;

  // === STATE MANAGEMENT ===

  List<EquineEntity> _equines = [];
  EquineEntity? _selectedEquine;
  
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  
  String? _errorMessage;
  String _searchQuery = '';

  // === GETTERS ===

  List<EquineEntity> get equines => _equines;
  EquineEntity? get selectedEquine => _selectedEquine;
  
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  
  /// Equinos ativos (não deletados)
  List<EquineEntity> get activeEquines => 
    _equines.where((equine) => equine.isActive).toList();
  
  /// Equinos filtrados por busca
  List<EquineEntity> get filteredEquines {
    var filtered = activeEquines;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((equine) =>
        equine.commonName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        equine.registrationId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        equine.originCountry.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  /// Estatísticas dos equinos
  int get totalEquines => _equines.length;
  int get activeEquinesCount => activeEquines.length;
  int get filteredEquinesCount => filteredEquines.length;
  
  /// Países de origem únicos para filtros
  List<String> get uniqueOriginCountries {
    final countries = activeEquines.map((equine) => equine.originCountry).toSet();
    return countries.toList()..sort();
  }

  // === OPERAÇÕES PRINCIPAIS ===

  /// Carrega todos os equinos
  Future<void> loadEquines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllEquines();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('EquinesProvider: Erro ao carregar equinos - ${failure.message}');
      },
      (equines) {
        _equines = equines;
        debugPrint('EquinesProvider: Equinos carregados - ${equines.length} itens');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega equinos com filtros
  Future<void> loadEquinesWithFilters(EquineSearchParams? searchParams) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final params = GetEquinesParams(searchParams: searchParams);
    final result = await _getEquines(params);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('EquinesProvider: Erro ao carregar equinos filtrados - ${failure.message}');
      },
      (equines) {
        _equines = equines;
        debugPrint('EquinesProvider: Equinos filtrados carregados - ${equines.length} itens');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega equino por ID
  Future<bool> loadEquineById(String equineId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getEquineById(equineId);
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('EquinesProvider: Erro ao carregar equino por ID - ${failure.message}');
      },
      (equine) {
        _selectedEquine = equine;
        
        // Atualiza na lista se já existe
        final index = _equines.indexWhere((e) => e.id == equine.id);
        if (index != -1) {
          _equines[index] = equine;
        } else {
          _equines.add(equine);
        }
        
        success = true;
        debugPrint('EquinesProvider: Equino carregado por ID - ${equine.id}');
      },
    );

    _isLoadingDetail = false;
    notifyListeners();
    return success;
  }

  /// Seleciona um equino específico
  void selectEquine(EquineEntity? equine) {
    _selectedEquine = equine;
    notifyListeners();
    debugPrint('EquinesProvider: Equino selecionado - ${equine?.id ?? 'nenhum'}');
  }

  // === OPERAÇÕES DE BUSCA E FILTROS ===

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    debugPrint('EquinesProvider: Query de busca atualizada - "$query"');
  }

  /// Limpa busca
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
    debugPrint('EquinesProvider: Busca limpa');
  }

  /// Busca equino por ID na lista local
  EquineEntity? getEquineById(String id) {
    try {
      return _equines.firstWhere((equine) => equine.id == id);
    } catch (e) {
      debugPrint('EquinesProvider: Equino não encontrado na lista local - $id');
      return null;
    }
  }

  /// Busca equinos por país de origem
  List<EquineEntity> getEquinesByOriginCountry(String originCountry) {
    return activeEquines
        .where((equine) => equine.originCountry.toLowerCase() == originCountry.toLowerCase())
        .toList();
  }

  // === OPERAÇÕES AUXILIARES ===

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await loadEquines();
  }

  /// Limpa seleção
  void clearSelection() {
    _selectedEquine = null;
    notifyListeners();
  }

  /// Verifica se equino está selecionado
  bool isEquineSelected(String equineId) {
    return _selectedEquine?.id == equineId;
  }

  /// Adiciona ou atualiza equino na lista
  void upsertEquine(EquineEntity equine) {
    final index = _equines.indexWhere((e) => e.id == equine.id);
    if (index != -1) {
      _equines[index] = equine;
    } else {
      _equines.add(equine);
    }
    notifyListeners();
    debugPrint('EquinesProvider: Equino upsert - ${equine.id}');
  }

  /// Remove equino da lista local
  void removeEquine(String equineId) {
    _equines.removeWhere((equine) => equine.id == equineId);
    
    if (_selectedEquine?.id == equineId) {
      _selectedEquine = null;
    }
    
    notifyListeners();
    debugPrint('EquinesProvider: Equino removido da lista local - $equineId');
  }

  @override
  void dispose() {
    debugPrint('EquinesProvider: Disposed');
    super.dispose();
  }
}