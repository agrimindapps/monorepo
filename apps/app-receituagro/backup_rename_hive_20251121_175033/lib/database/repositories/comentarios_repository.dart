import 'package:core/core.dart';
import 'comentario_repository.dart';

/// Repositório de Comentários usando Drift
///
/// Wrapper que fornece acesso aos métodos do ComentarioRepository
/// com nomenclatura compatível com o legacy repository
@lazySingleton
class ComentariosRepository {
  ComentariosRepository(this._baseRepo);

  final ComentarioRepository _baseRepo;

  Future<List<ComentarioData>> findAll() async {
    return await _baseRepo.findAll();
  }

  /// Busca comentário por ID
  Future<ComentarioData?> findById(int id) async {
    return await _baseRepo.findById(id);
  }

  /// Busca comentários por contexto/item
  Future<List<ComentarioData>> findByContext(String pkIdentificador) async {
    return await _baseRepo.findByItem(pkIdentificador);
  }

  /// Busca comentários por ferramenta (module)
  Future<List<ComentarioData>> findByTool(String moduleName) async {
    final all = await _baseRepo.findAll();
    return all.where((c) => c.moduleName == moduleName).toList();
  }

  /// Insere novo comentário
  Future<int> insert(ComentarioData comentario) async {
    return await _baseRepo.insert(comentario);
  }

  /// Atualiza comentário
  Future<bool> update(ComentarioData comentario) async {
    return await _baseRepo.update(comentario);
  }

  /// Remove comentário (soft delete)
  Future<bool> delete(int id) async {
    return await _baseRepo.softDelete(id);
  }

  /// Conta comentários por item
  Future<int> countByItem(String itemId) async {
    return await _baseRepo.countByItem(itemId);
  }

  /// Conta comentários por usuário
  Future<int> countByUserId(String userId) async {
    return await _baseRepo.countByUserId(userId);
  }

  /// Remove comentários antigos (cleanup)
  Future<void> cleanupOld({int olderThanDays = 365}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
    final all = await _baseRepo.findAll();

    for (final comentario in all) {
      if (comentario.createdAt.isBefore(cutoffDate)) {
        await _baseRepo.softDelete(comentario.id);
      }
    }
  }

  /// Estatísticas do usuário
  Future<Map<String, int>> getUserStats(String userId) async {
    final userComentarios = await _baseRepo.findByUserId(userId);
    final total = userComentarios.length;

    // Agrupa por módulo
    final byModule = <String, int>{};
    for (final c in userComentarios) {
      byModule[c.moduleName] = (byModule[c.moduleName] ?? 0) + 1;
    }

    return {'total': total, ...byModule};
  }
}
