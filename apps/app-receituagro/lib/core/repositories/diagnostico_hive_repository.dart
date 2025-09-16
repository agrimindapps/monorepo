import '../models/diagnostico_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para DiagnosticoHive
/// Implementa os métodos abstratos do BaseHiveRepository
class DiagnosticoHiveRepository extends BaseHiveRepository<DiagnosticoHive> {
  DiagnosticoHiveRepository() : super('receituagro_diagnosticos_static');

  @override
  DiagnosticoHive createFromJson(Map<String, dynamic> json) {
    return DiagnosticoHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(DiagnosticoHive entity) {
    return entity.idReg;
  }

  /// Busca por objectId (ID do Firebase) se idReg não funcionar
  @override
  DiagnosticoHive? getById(String id) {
    try {
      // Primeiro tenta buscar pela chave normal (idReg)
      final result = super.getById(id);
      if (result != null) {
        return result;
      }
      
      // Se não encontrou, tenta buscar por objectId
      final matches = findBy((item) => item.objectId == id);
      return matches.isNotEmpty ? matches.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Busca diagnósticos por defensivo
  List<DiagnosticoHive> findByDefensivo(String fkIdDefensivo) {
    return findBy((item) => item.fkIdDefensivo == fkIdDefensivo);
  }

  /// Busca diagnósticos por cultura
  List<DiagnosticoHive> findByCultura(String fkIdCultura) {
    return findBy((item) => item.fkIdCultura == fkIdCultura);
  }

  /// Busca diagnósticos por praga
  List<DiagnosticoHive> findByPraga(String fkIdPraga) {
    return findBy((item) => item.fkIdPraga == fkIdPraga);
  }

  /// Busca diagnósticos por cultura e defensivo
  List<DiagnosticoHive> findByCulturaAndDefensivo(String fkIdCultura, String fkIdDefensivo) {
    return findBy((item) => 
        item.fkIdCultura == fkIdCultura && item.fkIdDefensivo == fkIdDefensivo);
  }

  /// Busca diagnósticos por múltiplos critérios
  List<DiagnosticoHive> findByMultipleCriteria({
    String? defensivoId,
    String? culturaId, 
    String? pragaId,
  }) {
    return findBy((item) {
      if (defensivoId != null && item.fkIdDefensivo != defensivoId) return false;
      if (culturaId != null && item.fkIdCultura != culturaId) return false;
      if (pragaId != null && item.fkIdPraga != pragaId) return false;
      return true;
    });
  }
}