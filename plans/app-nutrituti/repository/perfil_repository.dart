// Package imports:
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../database/perfil_model.dart';

class PerfilRepository extends GetxController {
  static const String _boxName = 'box_perfil';
  late Box<PerfilModel> _pesoBox;

  var perfils = <PerfilModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    _pesoBox = await Hive.openBox<PerfilModel>(_boxName);
    perfils.value = _pesoBox.values.toList();
  }

  Future<void> getAll(PerfilModel perfil) async {
    await _pesoBox.put(perfil.id, perfil);
    perfils.value = _pesoBox.values.toList();
  }

  Future<PerfilModel?> get(String idReg) async {
    return _pesoBox.get(idReg);
  }

  Future<void> post(PerfilModel perfil) async {
    await _pesoBox.put(perfil.id, perfil);
    perfils.value = _pesoBox.values.toList();
  }

  Future<void> put(PerfilModel perfil) async {
    await _pesoBox.put(perfil.id, perfil);
    perfils.value = _pesoBox.values.toList();
  }

  Future<void> delete(String idReg) async {
    await _pesoBox.delete(idReg);
    perfils.value = _pesoBox.values.toList();
  }
}
