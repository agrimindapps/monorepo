// Project imports:
import '../../../../models/15_medicamento_model.dart';
import '../../../../repository/medicamento_repository.dart';

class MedicamentosService {
  final MedicamentoRepository _repository;

  MedicamentosService({MedicamentoRepository? repository})
      : _repository = repository ?? MedicamentoRepository();

  static Future<MedicamentosService> initialize() async {
    await MedicamentoRepository.initialize();
    return MedicamentosService();
  }

  Future<List<MedicamentoVet>> getMedicamentos(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      return await _repository.getMedicamentos(
        animalId,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos: ${e.toString()}');
    }
  }

  Future<bool> deleteMedicamento(MedicamentoVet medicamento) async {
    try {
      return await _repository.deleteMedicamento(medicamento);
    } catch (e) {
      throw Exception('Erro ao deletar medicamento: ${e.toString()}');
    }
  }

  Future<List<MedicamentoVet>> getMedicamentosAtivos(String animalId) async {
    try {
      final medicamentos = await _repository.getMedicamentos(animalId);
      final hoje = DateTime.now().millisecondsSinceEpoch;
      
      return medicamentos.where((medicamento) {
        return medicamento.inicioTratamento <= hoje && 
               medicamento.fimTratamento >= hoje;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos ativos: ${e.toString()}');
    }
  }

  Future<List<MedicamentoVet>> getMedicamentosFinalizados(String animalId) async {
    try {
      final medicamentos = await _repository.getMedicamentos(animalId);
      final hoje = DateTime.now().millisecondsSinceEpoch;
      
      return medicamentos.where((medicamento) {
        return medicamento.fimTratamento < hoje;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos finalizados: ${e.toString()}');
    }
  }

  Future<List<MedicamentoVet>> getMedicamentosParaHoje(String animalId) async {
    try {
      final hoje = DateTime.now();
      final hojeMilisegundos = DateTime(hoje.year, hoje.month, hoje.day).millisecondsSinceEpoch;
      
      final medicamentos = await _repository.getMedicamentos(animalId);
      
      return medicamentos.where((medicamento) {
        return medicamento.inicioTratamento <= hojeMilisegundos &&
               medicamento.fimTratamento >= hojeMilisegundos;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos para hoje: ${e.toString()}');
    }
  }

  Future<List<MedicamentoVet>> searchMedicamentos(
    String animalId, 
    String query,
  ) async {
    try {
      final medicamentos = await _repository.getMedicamentos(animalId);
      
      if (query.isEmpty) return medicamentos;
      
      final lowercaseQuery = query.toLowerCase();
      return medicamentos.where((medicamento) {
        return medicamento.nomeMedicamento.toLowerCase().contains(lowercaseQuery) ||
               medicamento.dosagem.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos: ${e.toString()}');
    }
  }
}
