// Project imports:
import '../models/dashboard_data_model.dart';
import '../models/dashboard_statistics_model.dart';

class DashboardDataService {
  Future<List<Pet>> loadPets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DashboardRepository.getPets();
  }

  Future<List<ConsultaData>> loadConsultas(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DashboardRepository.getConsultas();
  }

  Future<List<VacinaData>> loadVacinas(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DashboardRepository.getVacinas();
  }

  Future<List<DespesaData>> loadDespesas(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DashboardRepository.getDespesas();
  }

  Future<List<MedicamentoData>> loadMedicamentos(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DashboardRepository.getMedicamentos();
  }

  Future<List<PesoData>> loadHistoricoPeso(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DashboardRepository.getHistoricoPeso();
  }

  DashboardStatistics calculateStatistics({
    required List<ConsultaData> consultas,
    required List<VacinaData> vacinas,
    required List<MedicamentoData> medicamentos,
  }) {
    return DashboardStatistics.fromData(
      consultas: consultas,
      vacinas: vacinas,
      medicamentos: medicamentos,
    );
  }

  ExpensesByCategory calculateExpensesByCategory(List<DespesaData> despesas) {
    return ExpensesByCategory.fromDespesas(despesas);
  }
}
