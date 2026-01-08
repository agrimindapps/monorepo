import '../receituagro_database.dart';
import 'diagnostico_repository.dart';

/// Wrapper do DiagnosticoRepository (Drift) com nomenclatura compatível
///
/// NOTA: Diagnosticos são dados ESTÁTICOS (lookup table)
/// Métodos de userId removidos - tabela não possui campos de usuário
class DiagnosticosRepository {
  DiagnosticosRepository(this._baseRepo);

  final DiagnosticoRepository _baseRepo;

  Future<List<Diagnostico>> findAll() async {
    return await _baseRepo.findAll();
  }

  /// Busca por ID (idReg)
  Future<Diagnostico?> findByIdOrObjectId(String id) async {
    return await _baseRepo.findByIdReg(id);
  }

  /// Busca diagnósticos por defensivo (string FK)
  Future<List<Diagnostico>> findByDefensivo(String fkIdDefensivo) async {
    return await _baseRepo.findByDefensivoId(fkIdDefensivo);
  }

  /// Busca diagnósticos por cultura (string FK)
  Future<List<Diagnostico>> findByCultura(String fkIdCultura) async {
    return await _baseRepo.findByCulturaId(fkIdCultura);
  }

  /// Busca diagnósticos por praga (string FK)
  Future<List<Diagnostico>> findByPraga(String fkIdPraga) async {
    return await _baseRepo.findByPragaId(fkIdPraga);
  }

  /// Busca diagnósticos pela combinação tripla
  Future<List<Diagnostico>> findByTriplaCombinacao({
    String? fkIdDefensivo,
    String? fkIdCultura,
    String? fkIdPraga,
  }) async {
    // Faz busca manual com filtros
    final all = await _baseRepo.findAll();
    return all.where((d) {
      if (fkIdDefensivo != null && d.fkIdDefensivo != fkIdDefensivo) {
        return false;
      }
      if (fkIdCultura != null && d.fkIdCultura != fkIdCultura) {
        return false;
      }
      if (fkIdPraga != null && d.fkIdPraga != fkIdPraga) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Conta total de diagnósticos
  Future<int> count() async {
    return await _baseRepo.count();
  }

  /// Busca diagnósticos enriquecidos (com relações)
  Future<List<DiagnosticoEnriched>> findAllWithRelations() async {
    return await _baseRepo.findAllWithRelations();
  }

  /// Busca diagnósticos enriquecidos por defensivo
  Future<List<DiagnosticoEnriched>> findByDefensivoWithRelations(
    String fkIdDefensivo,
  ) async {
    return await _baseRepo.findByDefensivoWithRelations(fkIdDefensivo);
  }
}
