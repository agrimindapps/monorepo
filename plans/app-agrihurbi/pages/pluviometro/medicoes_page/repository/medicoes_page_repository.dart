// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../../../../repository/medicoes_repository.dart';
import '../../../../repository/pluviometros_repository.dart';

class MedicoesPageRepository {
  final _medicoesRepository = MedicoesRepository();
  final _pluviometrosRepository = PluviometrosRepository();

  Future<List<Medicoes>> getMedicoes(String pluviometroId) async {
    return await _medicoesRepository.getMedicoes(pluviometroId);
  }

  Future<List<Pluviometro>> getPluviometros() async {
    return await _pluviometrosRepository.getPluviometros();
  }

  Future<bool> saveMedicao(Medicoes medicao) async {
    if (medicao.id.isEmpty) {
      return await _medicoesRepository.addMedicao(medicao);
    } else {
      return await _medicoesRepository.updateMedicao(medicao);
    }
  }

  Future<bool> deleteMedicao(Medicoes medicao) async {
    return await _medicoesRepository.deleteMedicao(medicao);
  }
}
