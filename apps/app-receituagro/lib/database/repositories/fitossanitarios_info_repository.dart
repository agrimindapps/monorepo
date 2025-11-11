import 'package:core/core.dart';
import '../receituagro_database.dart';

/// Repositório de Informações de Fitossanitários usando Drift
///
/// Gerencia todas as operações de leitura dos dados complementares de fitossanitários
/// usando o banco de dados Drift ao invés do Hive.
@lazySingleton
class FitossanitariosInfoRepository {
  FitossanitariosInfoRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as informações de fitossanitários
  Future<List<FitossanitariosInfoData>> findAll() async {
    final query = _db.select(_db.fitossanitariosInfo);
    return await query.get();
  }

  /// Busca informação de fitossanitário por ID
  Future<FitossanitariosInfoData?> findById(int id) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Busca informação de fitossanitário por ID de registro (idReg)
  Future<FitossanitariosInfoData?> findByIdReg(String idReg) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.idReg.equals(idReg));
    return await query.getSingleOrNull();
  }

  /// Busca informações por ID do defensivo
  Future<FitossanitariosInfoData?> findByDefensivoId(int defensivoId) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.defensivoId.equals(defensivoId));
    return await query.getSingleOrNull();
  }

  /// Busca informações com join do fitossanitário
  Future<List<FitossanitarioInfoWithDefensivo>> findAllWithDefensivo() async {
    final query = _db.select(_db.fitossanitariosInfo).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.id.equalsExp(_db.fitossanitariosInfo.defensivoId),
      ),
    ]);

    final results = await query.get();
    return results.map((row) {
      return FitossanitarioInfoWithDefensivo(
        fitossanitarioInfo: row.readTable(_db.fitossanitariosInfo),
        fitossanitario: row.readTableOrNull(_db.fitossanitarios),
      );
    }).toList();
  }

  /// Busca informações por modo de ação (busca parcial)
  Future<List<FitossanitariosInfoData>> findByModoAcao(String modoAcao) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.modoAcao.contains(modoAcao));
    return await query.get();
  }

  /// Busca informações por formulação
  Future<List<FitossanitariosInfoData>> findByFormulacao(
    String formulacao,
  ) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.formulacao.contains(formulacao));
    return await query.get();
  }

  /// Busca informações por classe toxicológica
  Future<List<FitossanitariosInfoData>> findByToxicidade(
    String toxicidade,
  ) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.toxicidade.equals(toxicidade));
    return await query.get();
  }

  /// Busca informações por carência
  Future<List<FitossanitariosInfoData>> findByCarencia(String carencia) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.carencia.equals(carencia));
    return await query.get();
  }

  /// Conta o total de informações de fitossanitários
  Future<int> count() async {
    final count = _db.fitossanitariosInfo.id.count();
    final query = _db.selectOnly(_db.fitossanitariosInfo)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }

  /// Observa mudanças em todas as informações de fitossanitários
  Stream<List<FitossanitariosInfoData>> watchAll() {
    return _db.select(_db.fitossanitariosInfo).watch();
  }

  /// Observa mudanças em uma informação específica
  Stream<FitossanitariosInfoData?> watchById(int id) {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Observa mudanças por defensivo
  Stream<FitossanitariosInfoData?> watchByDefensivoId(int defensivoId) {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.defensivoId.equals(defensivoId));
    return query.watchSingleOrNull();
  }
}

/// Classe auxiliar para join de FitossanitariosInfo com Fitossanitario
class FitossanitarioInfoWithDefensivo {
  final FitossanitariosInfoData fitossanitarioInfo;
  final Fitossanitario? fitossanitario;

  FitossanitarioInfoWithDefensivo({
    required this.fitossanitarioInfo,
    this.fitossanitario,
  });
}
