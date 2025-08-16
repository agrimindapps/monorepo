import '../models/diagnostico_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para DiagnosticoHive
/// Implementa os métodos abstratos do BaseHiveRepository
class DiagnosticoHiveRepository extends BaseHiveRepository<DiagnosticoHive> {
  DiagnosticoHiveRepository() : super('receituagro_diagnosticos');

  @override
  DiagnosticoHive createFromJson(Map<String, dynamic> json) {
    return DiagnosticoHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(DiagnosticoHive entity) {
    return entity.idReg;
  }

  /// Busca diagnósticos por defensivo
  List<DiagnosticoHive> findByDefensivo(String fkIdDefensivo) {
    return findBy((item) => item.fkIdDefensivo == fkIdDefensivo);
  }

  /// Busca diagnósticos por cultura
  List<DiagnosticoHive> findByCultura(String fkIdCultura) {
    return findBy((item) => item.fkIdCultura == fkIdCultura);
  }

  /// Busca diagnósticos por cultura e defensivo
  List<DiagnosticoHive> findByCulturaAndDefensivo(String fkIdCultura, String fkIdDefensivo) {
    return findBy((item) => 
        item.fkIdCultura == fkIdCultura && item.fkIdDefensivo == fkIdDefensivo);
  }
}