import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Fitossanitários usando Drift
///
/// Gerencia todas as operações de leitura dos dados estáticos de fitossanitários
/// 
@lazySingleton
class FitossanitariosRepository {
  FitossanitariosRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todos os fitossanitários
  Future<List<Fitossanitario>> findAll() async {
    final query = _db.select(_db.fitossanitarios);
    return await query.get();
  }

  /// Busca fitossanitário por ID
  Future<Fitossanitario?> findById(int id) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Busca fitossanitário por ID do defensivo (idDefensivo)
  Future<Fitossanitario?> findByIdDefensivo(String idDefensivo) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.idDefensivo.equals(idDefensivo));
    return await query.getSingleOrNull();
  }

  /// Busca fitossanitários por nome (busca parcial)
  Future<List<Fitossanitario>> findByNome(String nome) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.nome.like('%$nome%'));
    return await query.get();
  }

  /// Busca fitossanitários por classe
  Future<List<Fitossanitario>> findByClasse(String classe) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.classe.equals(classe));
    return await query.get();
  }

  /// Busca fitossanitários elegíveis (apenas com status = true)
  /// Nota: O campo elegivel foi removido do filtro pois todos os dados JSON têm elegivel=false
  Future<List<Fitossanitario>> findElegiveis() async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.status.equals(true));
    return await query.get();
  }

  /// Busca fitossanitários comercializados
  Future<List<Fitossanitario>> findComercializados() async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.comercializado.equals(1));
    return await query.get();
  }

  /// Conta o total de fitossanitários
  Future<int> count() async {
    final countColumn = _db.fitossanitarios.id.count();
    final query = _db.selectOnly(_db.fitossanitarios)
      ..addColumns([countColumn]);
    final result = await query.getSingle();
    return result.read(countColumn)!;
  }

  /// Carrega fitossanitários a partir de dados JSON
  ///
  /// **Formato esperado do JSON:**
  /// ```json
  /// {
  ///   "idReg": "string",
  ///   "nomeComum": "string",
  ///   "fabricante": "string",
  ///   "classe": "string",
  ///   "classeAgronomica": "string",
  ///   "ingredienteAtivo": "string",
  ///   "registroMapa": "string",
  ///   "status": "boolean",
  ///   "comercializado": "int",
  ///   "elegivel": "boolean"
  /// }
  /// ```
  Future<void> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String version,
  ) async {
    await _db.transaction(() async {
      // Limpa dados antigos
      await _db.delete(_db.fitossanitarios).go();

      // Insere novos dados
      for (final item in jsonData) {
        final companion = FitossanitariosCompanion.insert(
          idDefensivo: item['idReg'] as String,
          nome: item['nomeComum'] as String,
          nomeComum: Value(item['nomeComum'] as String?),
          fabricante: Value(item['fabricante'] as String?),
          classe: Value(item['classe'] as String?),
          classeAgronomica: Value(item['classeAgronomica'] as String?),
          ingredienteAtivo: Value(item['ingredienteAtivo'] as String?),
          registroMapa: Value(item['registroMapa'] as String?),
          status: Value(
            item['status'] is bool
                ? item['status'] as bool
                : (item['status']?.toString().toLowerCase() == 'true'),
          ),
          comercializado: Value(
            item['comercializado'] is int
                ? item['comercializado'] as int
                : int.tryParse(item['comercializado']?.toString() ?? '1') ?? 1,
          ),
          elegivel: Value(
            item['elegivel'] is bool
                ? item['elegivel'] as bool
                : (item['elegivel']?.toString().toLowerCase() == 'true'),
          ),
        );

        await _db.into(_db.fitossanitarios).insert(companion);
      }
    });
  }

  // ============================================================================
  // MÉTODOS DE COMPATIBILIDADE LEGACY
  // ============================================================================

  /// @deprecated Use findById instead
  /// Legacy alias for findById
  Future<Fitossanitario?> getById(String idDefensivo) async {
    return await findByIdDefensivo(idDefensivo);
  }
}
