// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../models/development_model.dart';
import '../services/data_generation_service.dart';

class DevelopmentController extends ChangeNotifier {
  // Services
  late final DataGenerationService _dataService;

  // State
  SimulationConfig _config = SimulationConfig.defaultConfig();
  SimulationResult? _lastSimulation;
  DevelopmentStats _stats = const DevelopmentStats();
  bool _isSimulating = false;
  bool _isRemoving = false;
  String? _errorMessage;

  // Getters
  SimulationConfig get config => _config;
  SimulationResult? get lastSimulation => _lastSimulation;
  DevelopmentStats get stats => _stats;
  bool get isSimulating => _isSimulating;
  bool get isRemoving => _isRemoving;
  bool get isOperating => _isSimulating || _isRemoving;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  // Config getters
  SimulationScope get selectedScope => _config.scope;
  int get animalCount => _config.animalCount;
  int get monthsOfData => _config.monthsOfData;
  int get estimatedRecords => _config.estimatedRecords;
  Duration get estimatedDuration => _config.estimatedDuration;

  DevelopmentController() {
    _initializeServices();
  }

  void _initializeServices() {
    _dataService = DataGenerationService();
  }

  Future<void> initialize() async {
    try {
      await _loadStats();
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar desenvolvimento: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      _stats = await _dataService.getDevelopmentStats();
    } catch (e) {
      debugPrint('Error loading development stats: $e');
      _stats = const DevelopmentStats();
    }
  }

  // Configuration management
  void updateScope(SimulationScope scope) {
    if (_config.scope == scope) return;
    
    _config = SimulationConfig.fromScope(scope);
    notifyListeners();
  }

  void updateAnimalCount(int count) {
    if (_config.animalCount == count || count < 1 || count > 50) return;
    
    _config = _config.copyWith(animalCount: count);
    notifyListeners();
  }

  void updateMonthsOfData(int months) {
    if (_config.monthsOfData == months || months < 1 || months > 60) return;
    
    _config = _config.copyWith(monthsOfData: months);
    notifyListeners();
  }

  void updateIncludeWeights(bool include) {
    if (_config.includeWeights == include) return;
    
    _config = _config.copyWith(includeWeights: include);
    notifyListeners();
  }

  void updateIncludeVaccines(bool include) {
    if (_config.includeVaccines == include) return;
    
    _config = _config.copyWith(includeVaccines: include);
    notifyListeners();
  }

  void updateIncludeReminders(bool include) {
    if (_config.includeReminders == include) return;
    
    _config = _config.copyWith(includeReminders: include);
    notifyListeners();
  }

  void updateIncludeMedications(bool include) {
    if (_config.includeMedications == include) return;
    
    _config = _config.copyWith(includeMedications: include);
    notifyListeners();
  }

  void updateIncludeExpenses(bool include) {
    if (_config.includeExpenses == include) return;
    
    _config = _config.copyWith(includeExpenses: include);
    notifyListeners();
  }

  void resetToDefaultConfig() {
    _config = SimulationConfig.defaultConfig();
    notifyListeners();
  }

  // Operations
  Future<void> simulateTestData() async {
    if (isOperating) return;

    _setSimulating(true);
    _clearError();

    try {
      final result = await _dataService.generateTestData(_config);
      _lastSimulation = result;
      
      if (result.success) {
        await _updateStats(isSimulation: true);
      }
    } catch (e) {
      _setError('Erro na simulação: $e');
      _lastSimulation = SimulationResult.createFailure(
        error: e.toString(),
        duration: Duration.zero,
      );
    } finally {
      _setSimulating(false);
    }
  }

  Future<void> removeAllData() async {
    if (isOperating) return;

    _setRemoving(true);
    _clearError();

    try {
      await _dataService.clearAllData();
      await _updateStats(isDataReset: true);
    } catch (e) {
      _setError('Erro ao remover dados: $e');
    } finally {
      _setRemoving(false);
    }
  }

  Future<void> _updateStats({bool isSimulation = false, bool isDataReset = false}) async {
    try {
      final now = DateTime.now();
      
      if (isSimulation) {
        _stats = _stats.copyWith(
          totalSimulations: _stats.totalSimulations + 1,
          lastSimulation: now,
          simulationsByScope: {
            ..._stats.simulationsByScope,
            _config.scope.id: (_stats.simulationsByScope[_config.scope.id] ?? 0) + 1,
          },
        );
      }
      
      if (isDataReset) {
        _stats = _stats.copyWith(
          totalDataResets: _stats.totalDataResets + 1,
          lastDataReset: now,
        );
      }
    } catch (e) {
      debugPrint('Error updating stats: $e');
    }
  }

  // Utility methods
  List<SimulationScope> getAvailableScopes() {
    return DevelopmentRepository.getAvailableScopes();
  }

  List<DevelopmentAction> getAvailableActions() {
    return DevelopmentRepository.getAvailableActions();
  }

  String getScopeDescription(SimulationScope scope) {
    return scope.description;
  }

  String getConfigDescription() {
    return _config.scopeDescription;
  }

  Map<String, String> getConfigWarnings() {
    return DevelopmentRepository.getWarnings(_config);
  }

  bool hasConfigWarnings() {
    return getConfigWarnings().isNotEmpty;
  }

  String formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String formatRecordCount(int count) {
    if (count > 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  bool canSimulate() {
    return !isOperating && _config.animalCount > 0 && _config.monthsOfData > 0;
  }

  bool canRemoveData() {
    return !isOperating;
  }

  String getLastSimulationSummary() {
    if (_lastSimulation == null) return 'Nenhuma simulação realizada';
    return _lastSimulation!.summary;
  }

  // Validation
  bool isValidAnimalCount(int count) {
    return count >= 1 && count <= 50;
  }

  bool isValidMonthsCount(int months) {
    return months >= 1 && months <= 60;
  }

  String? validateConfig() {
    if (!isValidAnimalCount(_config.animalCount)) {
      return 'Número de animais deve estar entre 1 e 50';
    }
    
    if (!isValidMonthsCount(_config.monthsOfData)) {
      return 'Período deve estar entre 1 e 60 meses';
    }
    
    if (_config.estimatedRecords > 50000) {
      return 'Configuração gerará muitos registros (${formatRecordCount(_config.estimatedRecords)})';
    }
    
    return null;
  }

  Future<void> refresh() async {
    _clearError();
    await initialize();
  }

  void _setSimulating(bool simulating) {
    _isSimulating = simulating;
    notifyListeners();
  }

  void _setRemoving(bool removing) {
    _isRemoving = removing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('DevelopmentController Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

}
