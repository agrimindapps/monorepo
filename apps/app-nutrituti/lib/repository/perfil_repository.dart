// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import '../database/perfil_model.dart';

@injectable
class PerfilRepository {
  static const String _boxName = 'box_perfil';
  late Box<PerfilModel> _pesoBox;

  final ValueNotifier<List<PerfilModel>> perfils = ValueNotifier([]);

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _pesoBox = await Hive.openBox<PerfilModel>(_boxName);
      perfils.value = _pesoBox.values.toList();
    }
  }

  Box<PerfilModel> get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError('Box $_boxName is not open. Call initialize() first.');
    }
    return Hive.box<PerfilModel>(_boxName);
  }

  Future<void> getAll(PerfilModel perfil) async {
    await _box.put(perfil.id, perfil);
    perfils.value = _box.values.toList();
  }

  Future<PerfilModel?> get(String idReg) async {
    return _box.get(idReg);
  }

  Future<void> post(PerfilModel perfil) async {
    await _box.put(perfil.id, perfil);
    perfils.value = _box.values.toList();
  }

  Future<void> put(PerfilModel perfil) async {
    await _box.put(perfil.id, perfil);
    perfils.value = _box.values.toList();
  }

  Future<void> delete(String idReg) async {
    await _box.delete(idReg);
    perfils.value = _box.values.toList();
  }

  void dispose() {
    perfils.dispose();
  }
}
