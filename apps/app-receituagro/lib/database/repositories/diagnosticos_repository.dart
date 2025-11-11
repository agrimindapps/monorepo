import 'package:core/core.dart';
import 'diagnostico_repository.dart';

/// Wrapper do DiagnosticoRepository (Drift) com nomenclatura compatível
@lazySingleton
class DiagnosticosRepository {
  DiagnosticosRepository(this._baseRepo);

  final DiagnosticoRepository _baseRepo;

  /// Busca todos os diagnósticos
  Future<List<DiagnosticoData>> findAll() async {
    return await _baseRepo.findAll();
  }

  /// Busca por ID (Firebase ou local)
  Future<DiagnosticoData?> findByIdOrObjectId(String id) async {
    // Tenta primeiro como Firebase ID
    final all = await _baseRepo.findAll();
    for (final diag in all) {
      if (diag.firebaseId == id || diag.id.toString() == id) {
        return diag;
      }
    }
    return null;
  }

  /// Busca diagnósticos por defensivo
  Future<List<DiagnosticoData>> findByDefensivo(
    String userId,
    String defenisivoId,
  ) async {
    return await _baseRepo.findByDefensivo(
      userId,
      int.tryParse(defenisivoId) ?? 0,
    );
  }

  /// Busca diagnósticos por cultura
  Future<List<DiagnosticoData>> findByCultura(
    String userId,
    String culturaId,
  ) async {
    return await _baseRepo.findByCultura(userId, int.tryParse(culturaId) ?? 0);
  }

  /// Busca diagnósticos por praga
  Future<List<DiagnosticoData>> findByPraga(
    String userId,
    String pragaId,
  ) async {
    return await _baseRepo.findByPraga(userId, int.tryParse(pragaId) ?? 0);
  }

  /// Busca diagnósticos pela combinação tripla
  Future<List<DiagnosticoData>> findByTriplaCombinacao({
    required String userId,
    String? defenisivoId,
    String? culturaId,
    String? pragaId,
  }) async {
    // Faz busca manual com filtros
    final all = await _baseRepo.findByUserId(userId);
    return all.where((d) {
      if (defenisivoId != null && d.defenisivoId.toString() != defenisivoId) {
        return false;
      }
      if (culturaId != null && d.culturaId.toString() != culturaId) {
        return false;
      }
      if (pragaId != null && d.pragaId.toString() != pragaId) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Insere diagnóstico
  Future<int> insert(DiagnosticoData diagnostico) async {
    return await _baseRepo.insert(diagnostico);
  }

  /// Atualiza diagnóstico
  Future<bool> update(DiagnosticoData diagnostico) async {
    return await _baseRepo.update(diagnostico);
  }

  /// Remove diagnóstico (soft delete)
  Future<bool> delete(int id) async {
    return await _baseRepo.softDelete(id);
  }

  /// Conta total de diagnósticos
  Future<int> count() async {
    final all = await _baseRepo.findAll();
    return all.length;
  }
}
