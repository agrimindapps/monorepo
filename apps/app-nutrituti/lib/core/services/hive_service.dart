// STUB - FASE 0.7
// TODO FASE 1: Implementar HiveService completo com integração ao core package

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._();
  factory HiveService() => _instance;
  HiveService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Inicializar Hive
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  // Registrar adapter com segurança (evita duplicação)
  static void safeRegisterAdapter<T>(TypeAdapter<T> adapter) {
    try {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    } catch (e) {
      // Adapter já registrado, ignorar
    }
  }

  // Abrir box
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_isInitialized) {
      await init();
    }
    return await Hive.openBox<T>(boxName);
  }

  // Fechar box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  // Fechar todos os boxes
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  // Deletar box
  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }
}
