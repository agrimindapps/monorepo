import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/medication_database.dart';
import '../../data/repositories/versioned_medication_database.dart';
import '../../domain/entities/medication_data.dart';
import '../../domain/entities/medication_dosage_input.dart';
import '../../domain/entities/medication_dosage_output.dart';
import '../../domain/strategies/medication_dosage_strategy.dart';

/// Provider Riverpod para MedicationDosageProvider
///
/// Gerencia estado da calculadora de dosagem de medicamentos
final medicationDosageProviderProvider = ChangeNotifierProvider<MedicationDosageProvider>((ref) {
  return MedicationDosageProvider();
});

/// Provider para gerenciamento de state da calculadora de dosagem de medicamentos
class MedicationDosageProvider with ChangeNotifier {
  late final MedicationDosageStrategy _strategy;
  MedicationDosageInput _input = const MedicationDosageInput(
    species: Species.dog,
    weight: 10.0,
    ageGroup: AgeGroup.adult,
    medicationId: '',
    frequency: AdministrationFrequency.twice,
    specialConditions: [],
    isEmergency: false,
  );

  MedicationDosageOutput? _output;
  bool _isCalculating = false;
  String? _error;
  List<MedicationData>? _allMedications;
  List<MedicationData> _filteredMedications = [];
  String _searchQuery = '';
  final List<MedicationDosageOutput> _calculationHistory = [];
  final List<String> _favoriteMedications = [];

  MedicationDosageProvider() {
    _initializeStrategy();
    _loadInitialData();
  }
  MedicationDosageInput get input => _input;
  MedicationDosageOutput? get output => _output;
  bool get isCalculating => _isCalculating;
  String? get error => _error;
  List<MedicationData> get filteredMedications => _filteredMedications;
  List<MedicationData> get allMedications => _allMedications ?? [];
  List<MedicationDosageOutput> get calculationHistory => List.unmodifiable(_calculationHistory);
  List<String> get favoriteMedications => List.unmodifiable(_favoriteMedications);
  String get searchQuery => _searchQuery;
  bool get hasValidInput => _validateCurrentInput();
  bool get hasCriticalAlerts => _output?.hasCriticalAlerts ?? false;
  bool get isSafeToAdminister => _output?.isSafeToAdminister ?? false;
  MedicationData? get selectedMedication => _getMedicationById(_input.medicationId);
  List<MedicationData> get topMedications => MedicationDatabase.getTopMedications();
  
  /// Inicializa strategy com base de dados
  void _initializeStrategy() {
    final medications = MedicationDatabase.getAllMedications();
    _strategy = MedicationDosageStrategy(medications);
  }

  /// Carrega dados iniciais
  void _loadInitialData() {
    _allMedications = MedicationDatabase.getAllMedications();
    _filteredMedications = _allMedications!;
    notifyListeners();
  }

  /// Atualiza espécie do animal
  void updateSpecies(Species species) {
    _input = _input.copyWith(species: species);
    _clearResults();
    _filterMedicationsBySpecies();
    notifyListeners();
  }

  /// Atualiza peso do animal
  void updateWeight(double weight) {
    if (weight > 0 && weight <= 100) {
      _input = _input.copyWith(weight: weight);
      _clearResults();
      if (hasValidInput) {
        _performCalculationDebounced();
      }
      notifyListeners();
    }
  }

  /// Atualiza grupo de idade
  void updateAgeGroup(AgeGroup ageGroup) {
    _input = _input.copyWith(ageGroup: ageGroup);
    _clearResults();
    _filterMedicationsByAge();
    if (hasValidInput) {
      _performCalculationDebounced();
    }
    notifyListeners();
  }

  /// Atualiza medicamento selecionado
  void updateMedicationId(String medicationId) {
    _input = _input.copyWith(medicationId: medicationId);
    _clearResults();
    final medication = _getMedicationById(medicationId);
    if (medication != null && medication.concentrations.isNotEmpty) {
      _input = _input.copyWith(concentration: medication.concentrations.first.value);
    }
    
    if (hasValidInput) {
      _performCalculationDebounced();
    }
    notifyListeners();
  }

  /// Atualiza concentração do medicamento
  void updateConcentration(double? concentration) {
    _input = _input.copyWith(concentration: concentration);
    if (hasValidInput) {
      _performCalculationDebounced();
    }
    notifyListeners();
  }

  /// Atualiza forma farmacêutica
  void updatePharmaceuticalForm(String? form) {
    _input = _input.copyWith(pharmaceuticalForm: form);
    notifyListeners();
  }

  /// Atualiza frequência de administração
  void updateFrequency(AdministrationFrequency frequency) {
    _input = _input.copyWith(frequency: frequency);
    if (hasValidInput) {
      _performCalculationDebounced();
    }
    notifyListeners();
  }

  /// Atualiza condições especiais
  void updateSpecialConditions(List<SpecialCondition> conditions) {
    _input = _input.copyWith(specialConditions: conditions);
    if (hasValidInput) {
      _performCalculationDebounced();
    }
    notifyListeners();
  }

  /// Adiciona condição especial
  void addSpecialCondition(SpecialCondition condition) {
    if (!_input.specialConditions.contains(condition)) {
      final newConditions = [..._input.specialConditions, condition];
      updateSpecialConditions(newConditions);
    }
  }

  /// Remove condição especial
  void removeSpecialCondition(SpecialCondition condition) {
    final newConditions = _input.specialConditions.where((c) => c != condition).toList();
    updateSpecialConditions(newConditions);
  }

  /// Atualiza flag de emergência
  void updateEmergencyFlag(bool isEmergency) {
    _input = _input.copyWith(isEmergency: isEmergency);
    if (hasValidInput) {
      _performCalculationDebounced();
    }
    notifyListeners();
  }

  /// Atualiza notas do veterinário
  void updateVeterinarianNotes(String? notes) {
    _input = _input.copyWith(veterinarianNotes: notes);
    notifyListeners();
  }

  /// Pesquisa medicamentos
  void searchMedications(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMedications = _allMedications ?? [];
    } else {
      _filteredMedications = (_allMedications ?? []).where((med) =>
        med.name.toLowerCase().contains(query.toLowerCase()) ||
        med.activeIngredient.toLowerCase().contains(query.toLowerCase()) ||
        med.category.toLowerCase().contains(query.toLowerCase()) ||
        med.indications.any((ind) => ind.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
    notifyListeners();
  }

  /// Filtra medicamentos por espécie
  void _filterMedicationsBySpecies() {
    if (_searchQuery.isEmpty) {
      _filteredMedications = MedicationDatabase.getMedicationsForSpecies(_input.species);
    } else {
      searchMedications(_searchQuery); // Re-aplica filtro de busca
    }
  }

  /// Filtra medicamentos por idade (remove contraindicados)
  void _filterMedicationsByAge() {
    _filteredMedications = _filteredMedications.where((med) =>
      med.isAppropriateForAge(_input.ageGroup, _input.species)
    ).toList();
  }

  /// Filtra medicamentos por categoria
  void filterByCategory(String category) {
    if (category.isEmpty || category == 'Todos') {
      _filteredMedications = _allMedications ?? [];
    } else {
      _filteredMedications = MedicationDatabase.getMedicationsByCategory(category);
    }
    notifyListeners();
  }

  /// Adiciona/remove medicamento dos favoritos
  void toggleFavoriteMedication(String medicationId) {
    if (_favoriteMedications.contains(medicationId)) {
      _favoriteMedications.remove(medicationId);
    } else {
      _favoriteMedications.add(medicationId);
    }
    notifyListeners();
  }

  /// Retorna medicamentos favoritos
  List<MedicationData> getFavoriteMedications() {
    return _favoriteMedications
        .map((id) => _getMedicationById(id))
        .where((med) => med != null)
        .cast<MedicationData>()
        .toList();
  }

  /// Executa cálculo de dosagem
  Future<void> calculateDosage() async {
    if (!hasValidInput) {
      _error = 'Dados insuficientes para o cálculo';
      notifyListeners();
      return;
    }

    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300)); // Simular processamento
      
      final result = _strategy.calculate(_input);
      _output = result;
      VersionedMedicationDatabase.instance.logDosageCalculation(
        medicationId: _input.medicationId,
        calculatedDose: result.dosagePerKg,
        species: _input.species,
        additionalData: {
          'weight': _input.weight,
          'ageGroup': _input.ageGroup.name,
          'frequency': _input.frequency.name,
          'specialConditions': _input.specialConditions.map((c) => c.name).toList(),
          'isEmergency': _input.isEmergency,
          'totalDailyDose': result.totalDailyDose,
          'dosePerAdministration': result.dosePerAdministration,
          'alertsCount': result.alerts.length,
          'criticalAlerts': result.alerts.where((a) => a.level == AlertLevel.danger).length,
        },
      );
      _addToHistory(result);
      
      _error = null;
    } catch (e) {
      _error = 'Erro no cálculo: ${e.toString()}';
      _output = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// Cálculo com debounce para updates automáticos
  void _performCalculationDebounced() {
    calculateDosage();
  }

  /// Limpa resultados atuais
  void _clearResults() {
    _output = null;
    _error = null;
  }

  /// Limpa todos os dados
  void clearAll() {
    _input = const MedicationDosageInput(
      species: Species.dog,
      weight: 10.0,
      ageGroup: AgeGroup.adult,
      medicationId: '',
      frequency: AdministrationFrequency.twice,
      specialConditions: [],
      isEmergency: false,
    );
    _clearResults();
    _searchQuery = '';
    _filteredMedications = _allMedications ?? [];
    notifyListeners();
  }

  /// Valida entrada atual
  bool _validateCurrentInput() {
    return _input.weight > 0 &&
           _input.weight <= 100 &&
           _input.medicationId.isNotEmpty &&
           _getMedicationById(_input.medicationId) != null;
  }

  /// Busca medicamento por ID
  MedicationData? _getMedicationById(String id) {
    return MedicationDatabase.getMedicationById(id);
  }

  /// Adiciona cálculo ao histórico
  void _addToHistory(MedicationDosageOutput result) {
    _calculationHistory.insert(0, result);
    if (_calculationHistory.length > 20) {
      _calculationHistory.removeRange(20, _calculationHistory.length);
    }
  }

  /// Limpa histórico
  void clearHistory() {
    _calculationHistory.clear();
    notifyListeners();
  }

  /// Remove item do histórico
  void removeFromHistory(int index) {
    if (index >= 0 && index < _calculationHistory.length) {
      _calculationHistory.removeAt(index);
      notifyListeners();
    }
  }

  /// Carrega cálculo do histórico
  void loadFromHistory(int index) {
    if (index >= 0 && index < _calculationHistory.length) {
      final historicalResult = _calculationHistory[index];
      final medication = _getMedicationById(historicalResult.medicationName.toLowerCase().replaceAll(' ', '_'));
      if (medication != null) {
        _input = MedicationDosageInput(
          species: Species.dog, // Derivar do histórico se possível
          weight: historicalResult.totalDailyDose / historicalResult.dosagePerKg,
          ageGroup: AgeGroup.adult, // Derivar do histórico se possível
          medicationId: medication.id,
          frequency: AdministrationFrequency.values.firstWhere(
            (f) => f.timesPerDay == historicalResult.administrationsPerDay,
            orElse: () => AdministrationFrequency.twice,
          ),
        );
        
        _output = historicalResult;
        notifyListeners();
      }
    }
  }

  /// Exporta prescrição como texto
  String exportPrescription() {
    if (_output == null) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('=== PRESCRIÇÃO VETERINÁRIA ===');
    buffer.writeln('Data: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln();
    buffer.writeln('DADOS DO ANIMAL:');
    buffer.writeln('Espécie: ${_input.species.displayName}');
    buffer.writeln('Peso: ${_input.weight.toStringAsFixed(1)} kg');
    buffer.writeln('Idade: ${_input.ageGroup.displayName}');
    
    if (_input.specialConditions.isNotEmpty) {
      buffer.writeln('Condições especiais: ${_input.specialConditions.map((c) => c.displayName).join(', ')}');
    }
    buffer.writeln();
    buffer.writeln('PRESCRIÇÃO:');
    buffer.writeln('Medicamento: ${_output!.medicationName}');
    buffer.writeln('Dosagem: ${_output!.dosePerAdministration.toStringAsFixed(2)} ${_output!.unit}');
    
    if (_output!.volumeToAdminister != null) {
      buffer.writeln('Volume: ${_output!.volumeToAdminister!.toStringAsFixed(2)} ml');
    }
    
    buffer.writeln('Frequência: ${_output!.administrationsPerDay}x ao dia');
    buffer.writeln('Intervalo: ${_output!.intervalBetweenDoses}');
    buffer.writeln();
    buffer.writeln('INSTRUÇÕES DE ADMINISTRAÇÃO:');
    buffer.writeln('Via: ${_output!.instructions.route}');
    buffer.writeln('Timing: ${_output!.instructions.timing}');
    
    if (_output!.instructions.dilution != null) {
      buffer.writeln('Preparo: ${_output!.instructions.dilution}');
    }
    buffer.writeln();
    if (_output!.alerts.isNotEmpty) {
      buffer.writeln('ALERTAS E PRECAUÇÕES:');
      for (final alert in _output!.alerts) {
        buffer.writeln('• [${alert.level.displayName.toUpperCase()}] ${alert.message}');
        if (alert.recommendation != null) {
          buffer.writeln('  Recomendação: ${alert.recommendation}');
        }
      }
      buffer.writeln();
    }
    if (_output!.monitoringInfo != null) {
      buffer.writeln('MONITORAMENTO:');
      buffer.writeln('Parâmetros: ${_output!.monitoringInfo!.parametersToMonitor.join(', ')}');
      buffer.writeln('Frequência: ${_output!.monitoringInfo!.frequency}');
      buffer.writeln('Sinais de alerta: ${_output!.monitoringInfo!.warningSignsToWatch.join(', ')}');
      buffer.writeln();
    }
    buffer.writeln('=== CALCULADO POR PETIVETI APP ===');
    
    return buffer.toString();
  }

  /// Retorna estatísticas de uso
  Map<String, int> getUsageStatistics() {
    final stats = <String, int>{};
    
    for (final result in _calculationHistory) {
      final key = result.medicationName;
      stats[key] = (stats[key] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Retorna medicamentos mais utilizados
  List<String> getMostUsedMedications({int limit = 5}) {
    final stats = getUsageStatistics();
    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return entries.take(limit).map((e) => e.key).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}