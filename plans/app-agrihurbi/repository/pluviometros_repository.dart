// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../../../core/services/firebase_firestore_service.dart';
import '../models/pluviometros_models.dart';

class PluviometrosRepository {
  // MARK: - Constants
  static const String _boxName = 'box_agr_pluviometros';
  static const String collectionName = 'box_agr_pluviometros';
  static const String _selectedPluviometroKey = 'selected_pluviometro_id';

  // MARK: - Dependencies
  final _firestore = FirestoreService();
  final _prefs = SharedPreferences.getInstance();

  // MARK: - Properties
  String selectedPluviometroId = '';
  Box<Pluviometro> get _box => Hive.box<Pluviometro>(_boxName);

  // MARK: - Singleton Implementation
  static final PluviometrosRepository _instance =
      PluviometrosRepository._internal();
  factory PluviometrosRepository() => _instance;
  PluviometrosRepository._internal();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<void> getSelectedPluviometroId() => _getSelectedId();
  Future<void> setSelectedPluviometroId(String id) => _setSelectedId(id);
  Future<List<Pluviometro>> getPluviometros() => _getAll();
  Future<Pluviometro?> getPluviometroById(String id) => _getById(id);
  Future<bool> addPluviometro(Pluviometro pluviometro) => _add(pluviometro);
  Future<bool> updatePluviometro(Pluviometro pluviometro) =>
      _update(pluviometro);
  Future<bool> deletePluviometro(Pluviometro pluviometro) =>
      _delete(pluviometro);
  Future<String> exportToCsv() => _exportToCsv();

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(31)) {
        Hive.registerAdapter(PluviometroAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing PluviometrosRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Pluviometro>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - Selected Pluviometro Management
  Future<void> _getSelectedId() async {
    try {
      final prefs = await _prefs;
      selectedPluviometroId = prefs.getString(_selectedPluviometroKey) ?? '';
    } catch (e) {
      debugPrint('Error getting selected pluviometro: $e');
    }
  }

  Future<void> _setSelectedId(String id) async {
    try {
      final prefs = await _prefs;
      selectedPluviometroId = id;
      await prefs.setString(_selectedPluviometroKey, id);
    } catch (e) {
      debugPrint('Error saving selected pluviometro: $e');
    }
  }

  // MARK: - CRUD Operations
  Future<List<Pluviometro>> _getAll() async {
    try {
      await _openBox();
      final pluviometros =
          _box.values.where((pluviometro) => !pluviometro.isDeleted).toList();
      // Create a new list to avoid box closure issues
      return List<Pluviometro>.from(pluviometros);
    } catch (e) {
      debugPrint('Error getting pluviometros: $e');
      return [];
    }
    // Don't close the box here - let it stay open for other operations
  }

  Future<Pluviometro?> _getById(String id) async {
    try {
      await _openBox();
      return _box.values.firstWhere(
        (pluviometro) => pluviometro.id == id,
        orElse: () => throw Exception('Pluviometro not found'),
      );
    } catch (e) {
      debugPrint('Error getting Pluviometro by ID: $e');
      return null;
    }
    // Don't close the box here - let it stay open for other operations
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(Pluviometro pluviometro) async {
    try {
      await _openBox();
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      pluviometro.createdAt = currentTime;
      pluviometro.updatedAt = currentTime;

      final localKey = await _box.add(pluviometro);

      // Try to create record in Firebase with enhanced error handling
      try {
        await _firestore.createRecord(
          collection: collectionName,
          data: pluviometro.toMap(),
        );
      } catch (e) {
        debugPrint('Firebase error while adding pluviometro: $e');
        // Continue with local save even if Firebase fails
      }
      await _box.put(localKey, pluviometro);
      return true;
    } catch (e) {
      debugPrint('Error adding Pluviometro: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(Pluviometro pluviometro) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == pluviometro.id);

      if (index != -1) {
        // Atualiza updatedAt com o timestamp atual (em microsegundos)
        pluviometro.updatedAt = DateTime.now().millisecondsSinceEpoch;
        await _box.putAt(index, pluviometro);

        // Try to update record in Firebase with enhanced error handling
        try {
          await _firestore.updateRecord(
            collection: collectionName,
            recordId: pluviometro.id,
            data: pluviometro.toMap(),
          );
        } catch (e) {
          debugPrint('Firebase error while updating pluviometro: $e');
          // Continue with local update even if Firebase fails
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Pluviometro: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(Pluviometro pluviometro) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == pluviometro.id);

      if (index != -1) {
        // Marca o registro como deletado e atualiza updatedAt com o timestamp atual (em microsegundos)
        pluviometro.markAsDeleted();
        await _box.putAt(index, pluviometro);

        // Try to update record in Firebase with enhanced error handling
        try {
          await _firestore.updateRecord(
            collection: collectionName,
            recordId: pluviometro.id,
            data: pluviometro.toMap(),
          );
        } catch (e) {
          debugPrint('Firebase error while deleting pluviometro: $e');
          // Continue with local deletion even if Firebase fails
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Pluviometro: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // Add a dispose method to properly close the box when needed
  Future<void> dispose() async {
    if (_box.isOpen) {
      await _closeBox();
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv() async {
    try {
      await _openBox();
      final pluviometros =
          _box.values.where((pluviometro) => !pluviometro.isDeleted).toList();

      // Define o cabeçalho do CSV com os campos relevantes
      const csvHeader = 'Descrição,Quantidade,Longitude,Latitude,Grupo\n';

      // Converte cada pluviômetro em uma linha do CSV
      final csvRows = pluviometros.map((pluviometro) {
        // Escape commas in string fields
        final descricao = _escapeField(pluviometro.descricao);
        final quantidade = _escapeField(pluviometro.quantidade);
        final longitude = _escapeField(pluviometro.longitude ?? '');
        final latitude = _escapeField(pluviometro.latitude ?? '');
        final grupo = _escapeField(pluviometro.fkGrupo ?? '');

        return '$descricao,$quantidade,$longitude,$latitude,$grupo';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting pluviometros to CSV: $e');
      return '';
    } finally {
      await _closeBox();
    }
  }

  // Helper para escapar campos que podem conter vírgulas
  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Substitui aspas duplas por duas aspas duplas e envolve em aspas
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
