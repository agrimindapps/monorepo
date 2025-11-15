// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart' as drift;

// Project imports:
import '../database/perfil_model.dart';
import '../drift_database/nutrituti_database.dart';
import '../drift_database/daos/perfil_dao.dart';

@injectable
class PerfilRepository {
  final NutritutiDatabase _database;

  PerfilRepository(this._database);

  final ValueNotifier<List<PerfilModel>> perfils = ValueNotifier([]);

  PerfilDao get _dao => _database.perfilDao;

  Future<void> initialize() async {
    final perfisData = await _dao.getPerfil();
    if (perfisData != null) {
      perfils.value = [_fromDrift(perfisData)];
    } else {
      perfils.value = [];
    }
  }

  Future<void> getAll(PerfilModel perfil) async {
    await _dao.savePerfil(_toCompanion(perfil));
    final updatedPerfil = await _dao.getPerfil();
    perfils.value = updatedPerfil != null ? [_fromDrift(updatedPerfil)] : [];
  }

  Future<PerfilModel?> get(String idReg) async {
    final perfil = await _dao.getPerfilById(idReg);
    return perfil != null ? _fromDrift(perfil) : null;
  }

  Future<void> post(PerfilModel perfil) async {
    await _dao.savePerfil(_toCompanion(perfil));
    final updatedPerfil = await _dao.getPerfil();
    perfils.value = updatedPerfil != null ? [_fromDrift(updatedPerfil)] : [];
  }

  Future<void> put(PerfilModel perfil) async {
    await _dao.savePerfil(_toCompanion(perfil));
    final updatedPerfil = await _dao.getPerfil();
    perfils.value = updatedPerfil != null ? [_fromDrift(updatedPerfil)] : [];
  }

  Future<void> delete(String idReg) async {
    await _dao.deletePerfil(idReg);
    perfils.value = [];
  }

  void dispose() {
    perfils.dispose();
  }

  // Conversion methods
  PerfilModel _fromDrift(Perfil perfil) {
    return PerfilModel(
      id: perfil.id,
      createdAt: perfil.createdAt,
      updatedAt: perfil.updatedAt,
      nome: perfil.nome,
      datanascimento: perfil.dataNascimento,
      altura: perfil.altura,
      peso: perfil.peso,
      genero: perfil.genero,
      imagePath: perfil.imagePath,
    );
  }

  PerfisCompanion _toCompanion(PerfilModel model) {
    return PerfisCompanion(
      id: drift.Value(model.id ?? ''),
      nome: drift.Value(model.nome),
      dataNascimento: drift.Value(model.datanascimento),
      altura: drift.Value(model.altura),
      peso: drift.Value(model.peso),
      genero: drift.Value(model.genero),
      imagePath: drift.Value(model.imagePath),
      createdAt: model.createdAt != null
          ? drift.Value(model.createdAt!)
          : const drift.Value.absent(),
      updatedAt: model.updatedAt != null
          ? drift.Value(model.updatedAt!)
          : drift.Value(DateTime.now()),
    );
  }
}
