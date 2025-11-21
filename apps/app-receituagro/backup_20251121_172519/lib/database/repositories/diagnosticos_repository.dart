import 'package:core/core.dart';
import '../receituagro_database.dart';
import 'diagnostico_repository.dart';

/// Wrapper do DiagnosticoRepository (Drift) com nomenclatura compatível
/// 
/// NOTA: Diagnosticos são dados ESTÁTICOS (lookup table)
/// Métodos de userId removidos - tabela não possui campos de usuário
@lazySingleton
class DiagnosticosRepository {
  DiagnosticosRepository(this._baseRepo);

  final DiagnosticoRepository _baseRepo;

  /// Busca todos os diagnósticos (dados estáticos)
  Future<List<Diagnostico>> findAll() async {
    return await _baseRepo.findAll();
  }

  /// Busca por ID (Firebase ou local)
  Future<Diagnostico?> findByIdOrObjectId(String id) async {
    // Tenta primeiro como Firebase ID
    final byFirebase = await _baseRepo.findByFirebaseId(id);
    if (byFirebase != null) return byFirebase;
    
    // Tenta como ID local
    final localId = int.tryParse(id);
    if (localId != null) {
      return await _baseRepo.findById(localId);
    }
    
    // Tenta como idReg
    return await _baseRepo.findByIdReg(id);
  }

  /// Busca diagnósticos por defensivo
  Future<List<Diagnostico>> findByDefensivo(int defensivoId) async {
    return await _baseRepo.findByDefensivo(defensivoId);
  }

  /// Busca diagnósticos por cultura
  Future<List<Diagnostico>> findByCultura(int culturaId) async {
    return await _baseRepo.findByCultura(culturaId);
  }

  /// Busca diagnósticos por praga
  Future<List<Diagnostico>> findByPraga(int pragaId) async {
    return await _baseRepo.findByPraga(pragaId);
  }

  /// Busca diagnósticos pela combinação tripla
  Future<List<Diagnostico>> findByTriplaCombinacao({
    int? defensivoId,
    int? culturaId,
    int? pragaId,
  }) async {
    // Faz busca manual com filtros
    final all = await _baseRepo.findAll();
    return all.where((d) {
      if (defensivoId != null && d.defensivoId != defensivoId) {
        return false;
      }
      if (culturaId != null && d.culturaId != culturaId) {
        return false;
      }
      if (pragaId != null && d.pragaId != pragaId) {
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
    int defensivoId,
  ) async {
    return await _baseRepo.findByDefensivoWithRelations(defensivoId);
  }
}
