import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculator.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../datasources/calculator_local_datasource.dart';
import '../models/calculation_history_model.dart';
import '../../domain/calculators/medication_dosage_calculator.dart';
import '../../domain/calculators/caloric_needs_calculator.dart';
import '../../domain/calculators/fluid_therapy_calculator.dart';
import '../../domain/calculators/anesthesia_calculator.dart';
import '../../domain/calculators/pregnancy_calculator.dart';
import '../../domain/calculators/body_condition_calculator.dart';
import '../../domain/calculators/diabetes_insulin_calculator.dart';
import '../../domain/calculators/hydration_calculator.dart';
import '../../domain/calculators/unit_conversion_calculator.dart';
import '../../domain/calculators/advanced_diet_calculator.dart';
import '../../domain/calculators/animal_age_calculator.dart';
import '../../domain/calculators/ideal_weight_calculator.dart';
import '../../domain/calculators/pregnancy_birth_calculator.dart';

/// Implementação do repositório de calculadoras
class CalculatorRepositoryImpl implements CalculatorRepository {
  const CalculatorRepositoryImpl(this._localDataSource);
  
  final CalculatorLocalDatasource _localDataSource;

  // Cache estático das calculadoras para melhor performance
  static final List<Calculator> _calculators = [
    MedicationDosageCalculator(),
    CaloricNeedsCalculator(),
    FluidTherapyCalculator(),
    AnesthesiaCalculator(),
    PregnancyCalculator(),
    BodyConditionCalculator(),
    DiabetesInsulinCalculator(),
    HydrationCalculator(),
    UnitConversionCalculator(),
    AdvancedDietCalculator(),
    AnimalAgeCalculator(),
    IdealWeightCalculator(),
    PregnancyBirthCalculator(),
  ];

  @override
  Future<List<Calculator>> getCalculators() async {
    return List.from(_calculators);
  }

  @override
  Future<Calculator?> getCalculatorById(String id) async {
    try {
      return _calculators.firstWhere((calc) => calc.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Calculator>> getCalculatorsByCategory(CalculatorCategory category) async {
    return _calculators.where((calc) => calc.category == category).toList();
  }

  @override
  Future<void> saveCalculationHistory(CalculationHistory history) async {
    final model = CalculationHistoryModel.fromEntity(history);
    await _localDataSource.saveCalculationHistory(model);
    
    // Incrementar estatísticas de uso
    await _localDataSource.incrementCalculatorUsage(history.calculatorId);
  }

  @override
  Future<List<CalculationHistory>> getCalculationHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final models = await _localDataSource.getCalculationHistory(
      calculatorId: calculatorId,
      animalId: animalId,
      limit: limit,
      fromDate: fromDate,
      toDate: toDate,
    );

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CalculationHistory?> getCalculationHistoryById(String id) async {
    final model = await _localDataSource.getCalculationHistoryById(id);
    return model?.toEntity();
  }

  @override
  Future<void> deleteCalculationHistory(String id) async {
    await _localDataSource.deleteCalculationHistory(id);
  }

  @override
  Future<void> clearCalculationHistory() async {
    await _localDataSource.clearCalculationHistory();
  }

  @override
  Future<List<String>> getFavoriteCalculatorIds() async {
    return await _localDataSource.getFavoriteCalculatorIds();
  }

  @override
  Future<void> addFavoriteCalculator(String calculatorId) async {
    // Verificar se a calculadora existe
    final calculator = await getCalculatorById(calculatorId);
    if (calculator == null) {
      throw ArgumentError('Calculadora não encontrada: $calculatorId');
    }

    await _localDataSource.addFavoriteCalculator(calculatorId);
  }

  @override
  Future<void> removeFavoriteCalculator(String calculatorId) async {
    await _localDataSource.removeFavoriteCalculator(calculatorId);
  }

  @override
  Future<bool> isFavoriteCalculator(String calculatorId) async {
    return await _localDataSource.isFavoriteCalculator(calculatorId);
  }

  @override
  Future<Map<String, int>> getCalculatorUsageStats() async {
    return await _localDataSource.getCalculatorUsageStats();
  }
}