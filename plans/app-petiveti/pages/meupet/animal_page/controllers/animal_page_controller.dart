// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../controllers/sync/sync_controllers.dart';
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';
import '../../../../services/peso_calculator_service.dart';
import '../../../../services/security_service.dart';
import '../../../../utils/debounce.dart';
import '../../../../utils/error_handler.dart';

class AnimalPageController extends GetxController {
  late final AnimalsSyncController _animalsController;
  late final PesosSyncController _pesosController;
  final PesoCalculatorService _pesoCalculator = PesoCalculatorService();

  // Usando observáveis para state management reativo
  final RxList<Animal> _animals = <Animal>[].obs;
  final RxList<PesoAnimal> _pesos = <PesoAnimal>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPesosLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'todos'.obs;
  final RxString _selectedAnimalId = ''.obs;
  final Rxn<int> _dataInicial = Rxn<int>();
  final Rxn<int> _dataFinal = Rxn<int>();

  // Performance optimizations
  final Debounce _loadDebounce = Debounce(milliseconds: 300);
  final Debounce _searchDebounce = Debounce(milliseconds: 500);
  final ErrorHandler _errorHandler = ErrorHandler();
  final SecurityService _securityService = SecurityService();

  // Getters públicos para observáveis
  List<Animal> get animals => _animals;
  List<Animal> get filteredAnimals => _getFilteredAnimals();
  List<PesoAnimal> get pesos => _pesos;
  List<PesoAnimal> get filteredPesos => _getFilteredPesos();
  bool get isLoading => _isLoading.value;
  bool get isPesosLoading => _isPesosLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;
  String get selectedAnimalId => _selectedAnimalId.value;
  int? get dataInicial => _dataInicial.value;
  int? get dataFinal => _dataFinal.value;

  Animal? get selectedAnimal {
    if (_selectedAnimalId.value.isEmpty || _animals.isEmpty) return null;
    try {
      return _animals.firstWhere((animal) => animal.id == _selectedAnimalId.value);
    } catch (e) {
      return null;
    }
  }

  AnimalPageController();

  @override
  void onInit() {
    super.onInit();
    // Inicializar controllers sync
    _animalsController = Get.find<AnimalsSyncController>();
    _pesosController = Get.find<PesosSyncController>();
    
    // Inicialização simples e segura
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      await _errorHandler.withTimeout(
        () async {
          // Controllers sync já são inicializados automaticamente
          await loadAnimals();
          await getSelectedAnimalId();
          if (_selectedAnimalId.value.isNotEmpty) {
            await loadPesos();
          }
        },
        timeout: const Duration(seconds: 30),
        operationName: 'AnimalPageController initialization',
      );
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Falha ao inicializar página de animais',
        type: ErrorType.unknown,
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loadAnimals() async {
    // Debounce para evitar múltiplas chamadas
    _loadDebounce.run(() => _performLoadAnimals());
  }

  Future<void> _performLoadAnimals() async {
    _isLoading.value = true;

    try {
      final result = await _errorHandler.withRetry(
        () => _animalsController.refreshAnimals().then((_) => _animalsController.animals),
        maxRetries: 3,
        operationName: 'loadAnimals',
      );
      _animals.value = result;
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Erro ao carregar lista de animais',
        type: ErrorType.database,
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshAnimals() async {
    await loadAnimals();
  }

  Future<void> getSelectedAnimalId() async {
    // TODO: Implementar lógica de animal selecionado no sync controller
    // Por enquanto, manter vazio
    _selectedAnimalId.value = '';
  }

  Future<void> setSelectedAnimalId(String id) async {
    // TODO: Implementar lógica de animal selecionado no sync controller
    _selectedAnimalId.value = id;
    if (id.isNotEmpty) {
      await loadPesos();
    } else {
      _pesos.clear();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void updateFilter(String filter) {
    _selectedFilter.value = filter;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  List<Animal> _getFilteredAnimals() {
    var result = List<Animal>.from(_animals);
    if (_selectedFilter.value != 'todos') {
      result = result
          .where((animal) =>
              animal.especie.toLowerCase() == _selectedFilter.value.toLowerCase())
          .toList();
    }
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      result = result.where((animal) {
        return animal.nome.toLowerCase().contains(query) ||
            animal.raca.toLowerCase().contains(query) ||
            animal.cor.toLowerCase().contains(query);
      }).toList();
    }
    return result;
  }

  Future<bool> deleteAnimal(Animal animal) async {
    try {
      // Execute with security validation and audit logging
      return await _securityService.executeCriticalOperation<bool>(
        operation: CriticalOperation.delete,
        resourceType: 'animal',
        resourceId: animal.id,
        userId: 'current_user', // In real app, get from auth service
        context: {
          'animalName': animal.nome,
          'animalSpecies': animal.especie,
        },
        action: () async {
          _isLoading.value = true;

          try {
            final result = await _errorHandler.withRetry(
              () => _animalsController.deleteAnimal(animal.id),
              maxRetries: 2,
              operationName: 'deleteAnimal',
            );

            if (result) {
              await loadAnimals();
            }

            return result;
          } finally {
            _isLoading.value = false;
          }
        },
      );
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Erro ao excluir animal',
        type: ErrorType.database,
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<Animal?> getAnimalById(String id) async {
    return await _animalsController.getAnimalById(id);
  }

  int get totalAnimals => _animals.length;
  Map<String, int> get animalsBySpecies {
    final Map<String, int> species = {};
    for (final animal in _animals) {
      species[animal.especie] = (species[animal.especie] ?? 0) + 1;
    }
    return species;
  }

  List<String> get availableSpecies {
    final Set<String> species = _animals.map((a) => a.especie).toSet();
    return ['todos', ...species.toList()..sort()];
  }

  String getAnimalAge(Animal animal) {
    final birthDate =
        DateTime.fromMillisecondsSinceEpoch(animal.dataNascimento);
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    if (years > 0) {
      final yearText = years == 1 ? 'ano' : 'anos';
      if (months > 0) {
        final monthText = months == 1 ? 'mês' : 'meses';
        return '$years $yearText e $months $monthText';
      }
      return '$years $yearText';
    } else if (months > 0) {
      final monthText = months == 1 ? 'mês' : 'meses';
      return '$months $monthText';
    } else {
      return '${difference.inDays} dias';
    }
  }

  String getAnimalInitials(String nome) {
    if (nome.isEmpty) return '?';
    final words = nome.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  String get selectedAnimalName {
    final animal = selectedAnimal;
    return animal?.nome ?? 'Nenhum animal selecionado';
  }

  String get selectedAnimalRace {
    final animal = selectedAnimal;
    return animal?.raca ?? '';
  }

  // Peso-related getters
  bool get hasPesos => _pesos.isNotEmpty;
  bool get hasDateRange => _dataInicial.value != null && _dataFinal.value != null;
  int get pesoCount => _pesos.length;

  double get pesoAtual => _pesoCalculator.calcularPesoAtual(_pesos);
  double get mediaPesos => _pesoCalculator.calcularMediaPesos(_pesos);
  double get pesoMinimo => _pesoCalculator.calcularPesoMinimo(_pesos);
  double get pesoMaximo => _pesoCalculator.calcularPesoMaximo(_pesos);

  int get totalRegistros => _pesos.length;

  // Peso-related methods
  Future<void> loadPesos([String? animalId]) async {
    try {
      _isPesosLoading.value = true;

      final targetAnimalId = animalId ?? _selectedAnimalId.value;

      if (targetAnimalId.isNotEmpty) {
        var result = _pesosController.getPesosByAnimal(targetAnimalId);
        // Filtrar por data se necessário
        if (_dataInicial.value != null || _dataFinal.value != null) {
          final inicio = _dataInicial.value ?? DateTime.now().subtract(const Duration(days: 180)).millisecondsSinceEpoch;
          final fim = _dataFinal.value ?? DateTime.now().millisecondsSinceEpoch;
          result = result.where((peso) => peso.dataPesagem >= inicio && peso.dataPesagem <= fim).toList();
        }
        _pesos.value = result;
      } else {
        _pesos.clear();
      }
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Falha ao carregar registros de peso',
        type: ErrorType.database,
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
    } finally {
      _isPesosLoading.value = false;
    }
  }

  Future<bool> addPeso(PesoAnimal peso) async {
    try {
      final result = await _pesosController.createPeso(peso);
      if (result != null) {
        await loadPesos(peso.animalId);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Erro ao adicionar registro de peso',
        type: ErrorType.database,
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> updatePeso(PesoAnimal peso) async {
    try {
      final result = await _pesosController.updatePeso(peso.id, peso);
      if (result) {
        await loadPesos(peso.animalId);
      }
      return result;
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Erro ao atualizar registro de peso',
        type: ErrorType.database,
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> deletePeso(PesoAnimal peso) async {
    try {
      final result = await _pesosController.deletePeso(peso.id);
      if (result) {
        _pesos.removeWhere((p) => p.id == peso.id);
      }
      return result;
    } catch (e, stackTrace) {
      _errorHandler.handleError(
        e,
        userMessage: 'Erro ao excluir registro de peso',
        type: ErrorType.database,
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<PesoAnimal?> getPesoById(String id) async {
    return await _pesosController.getPesoById(id);
  }

  void setDateRange(int? inicial, int? dataFinal) {
    _dataInicial.value = inicial;
    _dataFinal.value = dataFinal;
    if (_selectedAnimalId.value.isNotEmpty) {
      loadPesos();
    }
  }

  void clearDateRange() {
    _dataInicial.value = null;
    _dataFinal.value = null;
    if (_selectedAnimalId.value.isNotEmpty) {
      loadPesos();
    }
  }

  List<PesoAnimal> _getFilteredPesos() {
    return _pesoCalculator.filtrarPorData(_pesos, _dataInicial.value, _dataFinal.value);
  }

  // Delegated calculator methods
  double calcularVariacaoPeso() => _pesoCalculator.calcularVariacaoPeso(_pesos);
  double calcularPercentualVariacao() =>
      _pesoCalculator.calcularPercentualVariacao(_pesos);
  bool isWeightIncreasing() => _pesoCalculator.isPesoAumentando(_pesos);
  bool isWeightDecreasing() => _pesoCalculator.isPesoDiminuindo(_pesos);
  bool isWeightStable() => _pesoCalculator.isPesoEstavel(_pesos);
  List<Map<String, dynamic>> getGraphData() =>
      _pesoCalculator.gerarDadosGrafico(_pesos);
  String formatDateToString(int timestamp) =>
      _pesoCalculator.formatarDataParaString(timestamp);
  String getFormattedCurrentMonth() => _pesoCalculator.formatarMesAtual();
  List<String> getAvailableMonths() => _pesoCalculator.gerarListaMesesDisponiveis(_pesos);
  String getFormattedPeriod() => _pesoCalculator.formatarPeriodoRegistros(_pesos);
  String getSubtitle() => _pesoCalculator.gerarSubtitulo(_pesos);
  String generateCSVData() => _pesoCalculator.gerarDadosCSV(_pesos);
  TendenciaPeso getTendenciaPeso() => _pesoCalculator.calcularTendencia(_pesos);
  List<PesoAnimal> getOutliers() => _pesoCalculator.detectarOutliers(_pesos);
  double getTaxaVariacaoSemanal() =>
      _pesoCalculator.calcularTaxaVariacaoSemanal(_pesos);

  // View state helper methods
  bool shouldShowNoAnimalSelected() => _selectedAnimalId.value.isEmpty;
  bool shouldShowLoading() => _isPesosLoading.value;
  bool shouldShowError() => false; // Using ErrorHandler instead
  bool shouldShowNoData() =>
      !shouldShowNoAnimalSelected() && _pesos.isEmpty && !_isPesosLoading.value;
  bool shouldShowPesos() =>
      !shouldShowNoAnimalSelected() && _pesos.isNotEmpty && !_isPesosLoading.value;
  bool canAddPeso() => !shouldShowNoAnimalSelected();

  // Monthly navigation methods
  final RxInt _currentMonthIndex = 0.obs;

  List<DateTime> getMonthsList() {
    if (_pesos.isEmpty) {
      return [DateTime.now()];
    }

    final dates = _pesos.map((peso) => DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem)).toList();
    final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    return _generateMonthsBetween(oldestDate, newestDate);
  }

  List<DateTime> _generateMonthsBetween(DateTime start, DateTime end) {
    List<DateTime> months = [];
    DateTime currentDate = DateTime(start.year, start.month);
    final lastDate = DateTime(end.year, end.month);

    while (!currentDate.isAfter(lastDate)) {
      months.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return months.reversed.toList();
  }

  int getCurrentMonthIndex() => _currentMonthIndex.value;

  void setCurrentMonthIndex(int index) {
    _currentMonthIndex.value = index;
    update();
  }

  @override
  void onClose() {
    // Clean up resources
    _loadDebounce.dispose();
    _searchDebounce.dispose();

    // Dispose ErrorHandler resources
    _errorHandler.clearErrorLog();

    super.onClose();
  }
}
