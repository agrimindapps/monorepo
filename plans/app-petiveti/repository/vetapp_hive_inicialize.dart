// Project imports:
import 'animal_repository.dart';
import 'consulta_repository.dart';
import 'despesa_repository.dart';
import 'lembrete_repository.dart';
import 'medicamento_repository.dart';
import 'peso_repository.dart';
import 'vacina_repository.dart';

class VetAppInicialize {
  // inicialize hive boxs
  void initialize() {
    // Inicializar repositórios individuais
    AnimalRepository.initialize();
    MedicamentoRepository.initialize();
    VacinaRepository.initialize();
    LembreteRepository.initialize();
    ConsultaRepository.initialize();
    DespesaRepository.initialize();
    PesoRepository.initialize();
  }
}
