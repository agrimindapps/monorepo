import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/update_bovine.dart';

/// Provider especializado para operações de bovinos
/// 
/// Separado do provider principal para otimização e modularização
/// Integrado completamente com todos os use cases bovinos
@singleton
class BovinesProvider extends ChangeNotifier {
  final GetAllBovinesUseCase _getAllBovines;
  final CreateBovineUseCase _createBovine;
  final UpdateBovineUseCase _updateBovine;
  final DeleteBovineUseCase _deleteBovine;

  BovinesProvider({
    required GetAllBovinesUseCase getAllBovines,
    required CreateBovineUseCase createBovine,
    required UpdateBovineUseCase updateBovine,
    required DeleteBovineUseCase deleteBovine,
  })  : _getAllBovines = getAllBovines,
        _createBovine = createBovine,
        _updateBovine = updateBovine,
        _deleteBovine = deleteBovine;

  // === STATE MANAGEMENT ===

  List<BovineEntity> _bovines = [];
  BovineEntity? _selectedBovine;
  
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  
  String? _errorMessage;
  String _searchQuery = '';

  // === GETTERS ===

  List<BovineEntity> get bovines => _bovines;
  BovineEntity? get selectedBovine => _selectedBovine;
  
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  
  /// Bovinos ativos (não deletados)
  List<BovineEntity> get activeBovines => 
    _bovines.where((bovine) => bovine.isActive).toList();
  
  /// Bovinos filtrados por busca
  List<BovineEntity> get filteredBovines {
    var filtered = activeBovines;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bovine) =>
        bovine.commonName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        bovine.breed.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        bovine.registrationId.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  /// Estatísticas dos bovinos
  int get totalBovines => _bovines.length;
  int get activeBovinesCount => activeBovines.length;
  int get filteredBovinesCount => filteredBovines.length;
  
  /// Raças únicas para filtros
  List<String> get uniqueBreeds {
    final breeds = activeBovines.map((bovine) => bovine.breed).toSet();
    return breeds.toList()..sort();
  }

  // === OPERAÇÕES PRINCIPAIS ===

  /// Carrega todos os bovinos
  Future<void> loadBovines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllBovines();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('BovinesProvider: Erro ao carregar bovinos - ${failure.message}');
      },
      (bovines) {
        _bovines = bovines;
        debugPrint('BovinesProvider: Bovinos carregados - ${bovines.length} itens');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Seleciona um bovino específico
  void selectBovine(BovineEntity? bovine) {
    _selectedBovine = bovine;
    notifyListeners();
    debugPrint('BovinesProvider: Bovino selecionado - ${bovine?.id ?? 'nenhum'}');
  }

  /// Cria um novo bovino
  Future<bool> createBovine(BovineEntity bovine) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _createBovine(CreateBovineParams(bovine: bovine));
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('BovinesProvider: Erro ao criar bovino - ${failure.message}');
      },
      (createdBovine) {
        _bovines.add(createdBovine);
        _selectedBovine = createdBovine; // Seleciona o bovino criado
        success = true;
        debugPrint('BovinesProvider: Bovino criado com sucesso - ${createdBovine.id}');
      },
    );

    _isCreating = false;
    notifyListeners();
    return success;
  }

  /// Atualiza um bovino existente
  Future<bool> updateBovine(BovineEntity bovine) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateBovine(UpdateBovineParams(bovine: bovine));
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('BovinesProvider: Erro ao atualizar bovino - ${failure.message}');
      },
      (updatedBovine) {
        final index = _bovines.indexWhere((b) => b.id == updatedBovine.id);
        if (index != -1) {
          _bovines[index] = updatedBovine;
          
          // Atualiza o selecionado se for o mesmo
          if (_selectedBovine?.id == updatedBovine.id) {
            _selectedBovine = updatedBovine;
          }
          
          success = true;
          debugPrint('BovinesProvider: Bovino atualizado com sucesso - ${updatedBovine.id}');
        }
      },
    );

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  /// Remove um bovino (soft delete)
  Future<bool> deleteBovine(String bovineId, {bool confirmed = false}) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteBovine(
      DeleteBovineParams(
        bovineId: bovineId,
        confirmed: confirmed,
        requireConfirmation: !confirmed,
      ),
    );
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('BovinesProvider: Erro ao deletar bovino - ${failure.message}');
      },
      (_) {
        final index = _bovines.indexWhere((b) => b.id == bovineId);
        if (index != -1) {
          // Soft delete - marca como inativo
          _bovines[index] = _bovines[index].copyWith(isActive: false);
          
          // Limpa seleção se foi o selecionado
          if (_selectedBovine?.id == bovineId) {
            _selectedBovine = null;
          }
          
          success = true;
          debugPrint('BovinesProvider: Bovino deletado com sucesso - $bovineId');
        }
      },
    );

    _isDeleting = false;
    notifyListeners();
    return success;
  }

  // === OPERAÇÕES DE BUSCA E FILTROS ===

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    debugPrint('BovinesProvider: Query de busca atualizada - "$query"');
  }

  /// Limpa busca
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
    debugPrint('BovinesProvider: Busca limpa');
  }

  /// Busca bovino por ID
  BovineEntity? getBovineById(String id) {
    try {
      return _bovines.firstWhere((bovine) => bovine.id == id);
    } catch (e) {
      debugPrint('BovinesProvider: Bovino não encontrado - $id');
      return null;
    }
  }

  /// Carrega um bovino específico por ID e o define como selecionado
  Future<bool> loadBovineById(String id) async {
    // Primeiro tenta buscar localmente
    final localBovine = getBovineById(id);
    if (localBovine != null) {
      _selectedBovine = localBovine;
      notifyListeners();
      return true;
    }
    
    // Se não encontrou localmente, recarrega todos os bovinos
    await loadBovines();
    final bovine = getBovineById(id);
    
    if (bovine != null) {
      _selectedBovine = bovine;
      notifyListeners();
      return true;
    }
    
    return false;
  }

  /// Busca bovinos por raça
  List<BovineEntity> getBovinesByBreed(String breed) {
    return activeBovines
        .where((bovine) => bovine.breed.toLowerCase() == breed.toLowerCase())
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
    await loadBovines();
  }

  /// Limpa seleção
  void clearSelection() {
    _selectedBovine = null;
    notifyListeners();
  }

  /// Verifica se bovino está selecionado
  bool isBovineSelected(String bovineId) {
    return _selectedBovine?.id == bovineId;
  }

  @override
  void dispose() {
    debugPrint('BovinesProvider: Disposed');
    super.dispose();
  }
}