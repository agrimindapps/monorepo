// Project imports:
import '../models/medicoes_models.dart';
import '../repository/medicoes_repository.dart';

class MedicoesController {
  // Singleton Pattern
  static final MedicoesController _instance = MedicoesController._internal();
  factory MedicoesController() => _instance;
  MedicoesController._internal();

  // Repository reference
  final _repository = MedicoesRepository();

  // Initialization
  static Future<void> initialize() => MedicoesRepository.initialize();

  // Delegate methods
  Future<List<Medicoes>> getMedicoes(String pluviometroId) =>
      _repository.getMedicoes(pluviometroId);

  Future<bool> addMedicao(Medicoes medicao) => _repository.addMedicao(medicao);

  Future<bool> updateMedicao(Medicoes medicao) =>
      _repository.updateMedicao(medicao);

  Future<bool> deleteMedicao(Medicoes medicao) =>
      _repository.deleteMedicao(medicao);

  // Data Analysis Methods
  List<DateTime> getMonthsList(List<Medicoes> medicoes) =>
      _repository.getMonthsList(medicoes);

  List<Medicoes> getMedicoesDoMes(List<Medicoes> medicoes, DateTime date) =>
      _repository.getMedicoesDoMes(medicoes, date);

  double getTotalMedicoesDoMes(List<Medicoes> medicoesDoMes) =>
      _repository.getTotalMedicoesDoMes(medicoesDoMes);

  double getMediaDiaria(List<Medicoes> medicoesDoMes) =>
      _repository.getMediaDiaria(medicoesDoMes);

  String formatDate(int milliseconds) => _repository.formatDate(milliseconds);
}
