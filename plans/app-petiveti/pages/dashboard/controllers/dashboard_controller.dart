// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/dashboard_data_model.dart';
import '../models/dashboard_statistics_model.dart';
import '../services/dashboard_data_service.dart';

class DashboardController extends ChangeNotifier {
  final DashboardDataService _dataService = DashboardDataService();

  // State
  List<Pet> _pets = [];
  Pet? _selectedPet;
  List<ConsultaData> _consultas = [];
  List<VacinaData> _vacinas = [];
  List<DespesaData> _despesas = [];
  List<MedicamentoData> _medicamentos = [];
  List<PesoData> _historicoPeso = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Pet> get pets => List.unmodifiable(_pets);
  Pet? get selectedPet => _selectedPet;
  List<ConsultaData> get consultas => List.unmodifiable(_consultas);
  List<VacinaData> get vacinas => List.unmodifiable(_vacinas);
  List<DespesaData> get despesas => List.unmodifiable(_despesas);
  List<MedicamentoData> get medicamentos => List.unmodifiable(_medicamentos);
  List<PesoData> get historicoPeso => List.unmodifiable(_historicoPeso);
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasPets => _pets.isNotEmpty;
  bool get hasSelectedPet => _selectedPet != null;

  DashboardStatistics get statistics {
    return _dataService.calculateStatistics(
      consultas: _consultas,
      vacinas: _vacinas,
      medicamentos: _medicamentos,
    );
  }

  ExpensesByCategory get expensesByCategory {
    return _dataService.calculateExpensesByCategory(_despesas);
  }

  // Initialization
  Future<void> initialize() async {
    await _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      _setLoading(true);
      _pets = await _dataService.loadPets();
      
      if (_pets.isNotEmpty) {
        await selectPet(_pets.first);
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar pets: ${e.toString()}');
    }
  }

  Future<void> selectPet(Pet pet) async {
    try {
      _selectedPet = pet;
      notifyListeners();

      // Load pet data in parallel
      final futures = await Future.wait([
        _dataService.loadConsultas(pet.id),
        _dataService.loadVacinas(pet.id),
        _dataService.loadDespesas(pet.id),
        _dataService.loadMedicamentos(pet.id),
        _dataService.loadHistoricoPeso(pet.id),
      ]);

      _consultas = futures[0] as List<ConsultaData>;
      _vacinas = futures[1] as List<VacinaData>;
      _despesas = futures[2] as List<DespesaData>;
      _medicamentos = futures[3] as List<MedicamentoData>;
      _historicoPeso = futures[4] as List<PesoData>;

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar dados do pet: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    if (_selectedPet != null) {
      await selectPet(_selectedPet!);
    } else {
      await _loadPets();
    }
  }

  // Navigation actions
  void navigateToWeightRegistration(BuildContext context) {
    // TODO: Implement navigation to weight registration
    _showComingSoonSnackBar(context, 'Registrar Peso');
  }

  void navigateToConsultationRegistration(BuildContext context) {
    // TODO: Implement navigation to consultation registration
    _showComingSoonSnackBar(context, 'Nova Consulta');
  }

  void navigateToVaccinationRegistration(BuildContext context) {
    // TODO: Implement navigation to vaccination registration
    _showComingSoonSnackBar(context, 'Registrar Vacina');
  }

  void navigateToMedicationRegistration(BuildContext context) {
    // TODO: Implement navigation to medication registration
    _showComingSoonSnackBar(context, 'Medicamento');
  }

  void navigateToExpenseRegistration(BuildContext context) {
    // TODO: Implement navigation to expense registration
    _showComingSoonSnackBar(context, 'Nova Despesa');
  }

  void navigateToConsultationHistory(BuildContext context) {
    // TODO: Implement navigation to consultation history
    _showComingSoonSnackBar(context, 'Histórico de Consultas');
  }

  void navigateToAddVaccination(BuildContext context) {
    // TODO: Implement navigation to add vaccination
    _showComingSoonSnackBar(context, 'Nova Vacina');
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em breve!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

}
