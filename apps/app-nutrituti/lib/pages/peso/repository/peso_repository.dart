// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import '../../../../core/services/firebase_firestore_service.dart';
import '../models/peso_model.dart';

@injectable
class PesoRepository {
  static const String _boxName = 'box_peso';
  static const String collectionName = 'box_peso';
  final FirestoreService _firestore;

  // Observable state
  final ValueNotifier<List<PesoModel>> pesos = ValueNotifier([]);

  PesoRepository(this._firestore);

  // Initialization
  static Future<void> initializeAdapter() async {
    try {
      if (!Hive.isAdapterRegistered(23)) {
        // Use appropriate adapter ID
        Hive.registerAdapter(PesoModelAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing PesoRepository adapter: $e');
      rethrow;
    }
  }

  Box<PesoModel> get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError('Box $_boxName is not open. Call openBox() first.');
    }
    return Hive.box<PesoModel>(_boxName);
  }

  Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<PesoModel>(_boxName);
    }
  }

  Future<List<PesoModel>> getAll() async {
    try {
      await openBox();
      final List<PesoModel> registros =
          _box.values.where((registro) => !registro.isDeleted).toList();
      // ..sort((a, b) => b.data.compareTo(a.data));

      pesos.value = registros;
      return registros;
    } catch (e) {
      debugPrint('Error getting registros: $e');
      return [];
    }
  }

  Future<PesoModel?> get(String id) async {
    try {
      await openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Peso by ID: $e');
      return null;
    }
  }

  Future<void> add(PesoModel registro) async {
    try {
      await openBox();
      await _box.put(registro.id, registro);
      await _firestore.createRecord(
        collection: collectionName,
        data: registro.toMap(),
      );
      await getAll(); // Update observable list
    } catch (e) {
      debugPrint('Error adding Peso: $e');
    }
  }

  Future<void> updated(PesoModel registro) async {
    try {
      await openBox();
      await _box.put(registro.id, registro);
      await _firestore.updateRecord(
        collection: collectionName,
        recordId: registro.id,
        data: registro.toMap(),
      );
      await getAll(); // Update observable list
    } catch (e) {
      debugPrint('Error updating Peso: $e');
    }
  }

  Future<void> delete(PesoModel registro) async {
    try {
      await openBox();
      registro.markAsDeleted();
      await _box.put(registro.id, registro);
      await _firestore.updateRecord(
        collection: collectionName,
        recordId: registro.id,
        data: registro.toMap(),
      );
      await getAll(); // Update observable list
    } catch (e) {
      debugPrint('Error deleting Peso: $e');
    }
  }

  Future<void> initialize() async {
    await getAll(); // Load initial data
  }

  void dispose() {
    pesos.dispose();
  }
}
