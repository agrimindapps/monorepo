// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/bula_model.dart';

class BulasRepository {
  static final BulasRepository _instance = BulasRepository._internal();
  factory BulasRepository() => _instance;
  BulasRepository._internal();

  final ValueNotifier<BulaModel> mapBula = ValueNotifier(BulaModel.empty());

  Future<void> get(String id) async {
    // TODO: Implement get from Firebase
    mapBula.value = BulaModel.empty();
    mapBula.value.id = id;
  }

  void newInsert() {
    mapBula.value = BulaModel.empty();
  }

  Future<bool> saveUpdate() async {
    // TODO: Implement save/update to Firebase
    final isNewRecord = mapBula.value.id == null;
    // Save logic here
    return isNewRecord;
  }
}
