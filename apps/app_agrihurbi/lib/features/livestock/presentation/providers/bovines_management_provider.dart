import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/update_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';

/// Provider especializado para gerenciamento de bovinos
/// 
/// Responsabilidade única: CRUD e gerenciamento de estado de bovinos
/// Seguindo Single Responsibility Principle
@singleton
class BovinesManagementProvider extends ChangeNotifier {
  final GetAllBovinesUseCase _getAllBovines;
  final CreateBovineUseCase _createBovine;
  final UpdateBovineUseCase _updateBovine;
  final DeleteBovineUseCase _deleteBovine;

  BovinesManagementProvider({
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
  
  /// Estados de loading específicos para cada operação
  bool _isLoadingBovines = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  
  String? _errorMessage;

  // === GETTERS ===

  List<BovineEntity> get bovines => _bovines;
  BovineEntity? get selectedBovine => _selectedBovine;
  
  bool get isLoadingBovines => _isLoadingBovines;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isAnyOperationInProgress => 
    _isLoadingBovines || _isCreating || _isUpdating || _isDeleting;
  
  String? get errorMessage => _errorMessage;
  
  /// Bovinos ativos (não deletados)
  List<BovineEntity> get activeBovines => 
    _bovines.where((bovine) => bovine.isActive).toList();
  
  int get totalBovines => _bovines.length;
  int get totalActiveBovines => activeBovines.length;
  
  /// Verifica se tem bovino selecionado
  bool get hasSelectedBovine => _selectedBovine != null;

  // === BOVINES CRUD OPERATIONS ===

  /// Carrega todos os bovinos
  Future<void> loadBovines() async {
    _isLoadingBovines = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllBovines();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('BovinesManagementProvider: Erro ao carregar bovinos - ${failure.message}');
      },
      (bovines) {
        _bovines = bovines;
        debugPrint('BovinesManagementProvider: Bovinos carregados - ${bovines.length}');
      },
    );

    _isLoadingBovines = false;
    notifyListeners();
  }

  /// Seleciona um bovino específico
  void selectBovine(BovineEntity? bovine) {
    _selectedBovine = bovine;
    notifyListeners();
    debugPrint('BovinesManagementProvider: Bovino selecionado - ${bovine?.id ?? "nenhum"}');
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
        debugPrint('BovinesManagementProvider: Erro ao criar bovino - ${failure.message}');
      },
      (createdBovine) {
        _bovines.add(createdBovine);
        _selectedBovine = createdBovine; // Seleciona o bovino recém-criado
        success = true;
        debugPrint('BovinesManagementProvider: Bovino criado com sucesso - ${createdBovine.id}');
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
        debugPrint('BovinesManagementProvider: Erro ao atualizar bovino - ${failure.message}');
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
          debugPrint('BovinesManagementProvider: Bovino atualizado com sucesso - ${updatedBovine.id}');
        }
      },
    );

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  /// Remove um bovino (soft delete)
  Future<bool> deleteBovine(String bovineId) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteBovine(DeleteBovineParams(bovineId: bovineId));
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('BovinesManagementProvider: Erro ao deletar bovino - ${failure.message}');
      },
      (_) {
        // Marca como inativo (soft delete)
        final index = _bovines.indexWhere((b) => b.id == bovineId);
        if (index != -1) {
          _bovines[index] = _bovines[index].copyWith(isActive: false);
          
          // Limpa seleção se foi o selecionado
          if (_selectedBovine?.id == bovineId) {
            _selectedBovine = null;
          }
          
          success = true;
          debugPrint('BovinesManagementProvider: Bovino deletado com sucesso - $bovineId');
        }
      },
    );

    _isDeleting = false;
    notifyListeners();
    return success;
  }

  /// Remove permanentemente um bovino da lista local
  void removeBovineFromList(String bovineId) {
    _bovines.removeWhere((bovine) => bovine.id == bovineId);
    
    // Limpa seleção se foi o removido
    if (_selectedBovine?.id == bovineId) {
      _selectedBovine = null;
    }
    
    notifyListeners();
    debugPrint('BovinesManagementProvider: Bovino removido da lista local - $bovineId');
  }

  /// Encontra bovino por ID
  BovineEntity? findBovineById(String id) {
    try {
      return _bovines.firstWhere((bovine) => bovine.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se bovino existe
  bool bovineExists(String id) {
    return findBovineById(id) != null;
  }

  /// Obtém lista de raças únicas
  List<String> get uniqueBreeds {
    final breeds = <String>{};
    
    for (final bovine in _bovines) {
      breeds.add(bovine.breed);
    }
    
    return breeds.toList()..sort();
  }

  /// Obtém lista de países de origem únicos
  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    
    for (final bovine in _bovines) {
      countries.add(bovine.originCountry);
    }
    
    return countries.toList()..sort();
  }

  /// Refresh completo dos bovinos
  Future<void> refreshBovines() async {
    await loadBovines();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa seleção atual
  void clearSelection() {
    _selectedBovine = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _bovines.clear();
    _selectedBovine = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('BovinesManagementProvider: Disposed');
    super.dispose();
  }
}