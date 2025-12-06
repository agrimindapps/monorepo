import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Informações de Fitossanitários usando Drift
///
/// Gerencia todas as operações de leitura dos dados complementares de fitossanitários
/// 

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
      ..where((tbl) => tbl.modoAcao.like('%$modoAcao%'));
    return await query.get();
  }

  /// Busca informações por formulação
  Future<List<FitossanitariosInfoData>> findByFormulacao(
    String formulacao,
  ) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.formulacao.like('%$formulacao%'));
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
    final countColumn = _db.fitossanitariosInfo.id.count();
    final query = _db.selectOnly(_db.fitossanitariosInfo)
      ..addColumns([countColumn]);
    final result = await query.getSingle();
    return result.read(countColumn)!;
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

  /// Conta todos os modos de ação únicos (separando por vírgula)
  Future<int> countDistinctModosAcao() async {
    final infos = await findAll();
    final modosSet = <String>{};
    
    for (final info in infos) {
      if (info.modoAcao != null && info.modoAcao!.isNotEmpty) {
        // Split by comma and trim each value
        final modos = info.modoAcao!.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty);
        modosSet.addAll(modos);
      }
    }
    
    return modosSet.length;
  }

  /// Retorna lista de todos os modos de ação únicos (separando por vírgula)
  Future<List<String>> getDistinctModosAcao() async {
    final infos = await findAll();
    final modosSet = <String>{};
    
    for (final info in infos) {
      if (info.modoAcao != null && info.modoAcao!.isNotEmpty) {
        // Split by comma and trim each value
        final modos = info.modoAcao!.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty);
        modosSet.addAll(modos);
      }
    }
    
    final modosList = modosSet.toList();
    modosList.sort();
    return modosList;
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
