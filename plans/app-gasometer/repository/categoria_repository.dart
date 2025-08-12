// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_flutter/hive_flutter.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../database/26_categorias_model.dart';
import '../pages/cadastros/veiculos_page/services/box_manager.dart';

class CategoriaRepository {
  // MARK: - Constants
  static const String _boxName = 'box_car_categorias';
  static const String collectionName = 'box_car_categorias';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Future<Box<CategoriaCar>> get _box => BoxManager.instance.getBox<CategoriaCar>(_boxName);

  // MARK: - Singleton Implementation
  static final CategoriaRepository _instance = CategoriaRepository._internal();
  factory CategoriaRepository() => _instance;
  CategoriaRepository._internal();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<CategoriaCar>> getCategorias() => _getAll();
  Future<CategoriaCar?> getCategoriaById(String id) => _getById(id);
  Future<bool> addCategoria(CategoriaCar categoria) => _add(categoria);
  Future<bool> updateCategoria(CategoriaCar categoria) => _update(categoria);
  Future<bool> deleteCategoria(CategoriaCar categoria) => _delete(categoria);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(26)) {
        // Hive.registerAdapter(CategoriaAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing CategoriaRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  // Box management now handled by BoxManager - no need for manual open/close

  // MARK: - CRUD Operations
  Future<List<CategoriaCar>> _getAll() async {
    try {
      final box = await _box;
      return box.values.where((categoria) => !categoria.isDeleted).toList();
    } catch (e) {
      debugPrint('Error getting categorias: $e');
      return [];
    }
  }

  Future<CategoriaCar?> _getById(String id) async {
    try {
      final box = await _box;
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting Categoria by ID: $e');
      return null;
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(CategoriaCar categoria) async {
    try {
      final box = await _box;
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await box.add(categoria);

      // Cria o registro no Firebase
      await _firestore.createRecord(
        collection: collectionName,
        data: categoria.toMap(),
      );

      // Marca como sincronizado
      categoria.markAsSynced();
      await box.put(key, categoria);

      return true;
    } catch (e) {
      debugPrint('Error adding Categoria: $e');
      return false;
    }
  }

  Future<bool> _update(CategoriaCar categoria) async {
    try {
      final box = await _box;
      final index = box.values.toList().indexWhere(
            (item) => item.id == categoria.id,
          );

      if (index != -1) {
        // Atualiza o campo updatedAt com a data/hora atual (em microsegundos)
        categoria.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await box.putAt(index, categoria);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: categoria.id,
          data: categoria.toMap(),
        );

        // Marca como sincronizado
        categoria.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Categoria: $e');
      return false;
    }
  }

  Future<bool> _delete(CategoriaCar categoria) async {
    try {
      final box = await _box;
      final index = box.values.toList().indexWhere(
            (item) => item.id == categoria.id,
          );

      if (index != -1) {
        // Marca o registro como deletado
        categoria.markAsDeleted();

        await box.putAt(index, categoria);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: categoria.id,
          data: categoria.toMap(),
        );

        // Marca como sincronizado
        categoria.markAsSynced();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Categoria: $e');
      return false;
    }
  }
}
