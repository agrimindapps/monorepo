import 'package:flutter/foundation.dart';

import '../../domain/entities/equine_entity.dart';
import '../../domain/usecases/get_equines.dart';

/// Provider especializado para gerenciamento de equinos
///
/// Responsabilidade única: CRUD e gerenciamento de estado de equinos
/// Seguindo Single Responsibility Principle
class EquinesManagementProvider extends ChangeNotifier {
  final GetEquinesUseCase _getEquines;

  EquinesManagementProvider({
    required GetEquinesUseCase getEquines,
  }) : _getEquines = getEquines;

  List<EquineEntity> _equines = [];
  EquineEntity? _selectedEquine;

  /// Estados de loading específicos para cada operação
  bool _isLoadingEquines = false;
  final bool _isCreating = false;
  final bool _isUpdating = false;
  final bool _isDeleting = false;

  String? _errorMessage;

  List<EquineEntity> get equines => _equines;
  EquineEntity? get selectedEquine => _selectedEquine;

  bool get isLoadingEquines => _isLoadingEquines;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isAnyOperationInProgress =>
      _isLoadingEquines || _isCreating || _isUpdating || _isDeleting;

  String? get errorMessage => _errorMessage;

  /// Equinos ativos (não deletados)
  List<EquineEntity> get activeEquines =>
      _equines.where((equine) => equine.isActive).toList();

  int get totalEquines => _equines.length;
  int get totalActiveEquines => activeEquines.length;

  /// Verifica se tem equino selecionado
  bool get hasSelectedEquine => _selectedEquine != null;

  /// Carrega todos os equinos
  Future<void> loadEquines() async {
    _isLoadingEquines = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getEquines(const GetEquinesParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint(
            'EquinesManagementProvider: Erro ao carregar equinos - ${failure.message}');
      },
      (equines) {
        _equines = equines;
        debugPrint(
            'EquinesManagementProvider: Equinos carregados - ${equines.length}');
      },
    );

    _isLoadingEquines = false;
    notifyListeners();
  }

  /// Seleciona um equino específico
  void selectEquine(EquineEntity? equine) {
    _selectedEquine = equine;
    notifyListeners();
    debugPrint(
        'EquinesManagementProvider: Equino selecionado - ${equine?.id ?? "nenhum"}');
  }

  /// Encontra equino por ID
  EquineEntity? findEquineById(String id) {
    try {
      return _equines.firstWhere((equine) => equine.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se equino existe
  bool equineExists(String id) {
    return findEquineById(id) != null;
  }

  /// Obtém lista de países de origem únicos
  List<String> get uniqueOriginCountries {
    final countries = <String>{};

    for (final equine in _equines) {
      countries.add(equine.originCountry);
    }

    return countries.toList()..sort();
  }

  /// Refresh completo dos equinos
  Future<void> refreshEquines() async {
    await loadEquines();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa seleção atual
  void clearSelection() {
    _selectedEquine = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _equines.clear();
    _selectedEquine = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> createEquine(EquineEntity equine) async {
    debugPrint(
        'EquinesManagementProvider: createEquine não implementado ainda');
    return false;
  }

  Future<bool> updateEquine(EquineEntity equine) async {
    debugPrint(
        'EquinesManagementProvider: updateEquine não implementado ainda');
    return false;
  }

  Future<bool> deleteEquine(String equineId) async {
    debugPrint(
        'EquinesManagementProvider: deleteEquine não implementado ainda');
    return false;
  }

  @override
  void dispose() {
    debugPrint('EquinesManagementProvider: Disposed');
    super.dispose();
  }
}
