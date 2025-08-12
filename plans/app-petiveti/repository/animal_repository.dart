// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../models/11_animal_model.dart';

class AnimalRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_animais';
  static const String collectionName = 'box_vet_animais';
  static const String _selectedAnimalKey = 'selected_animal_id';

  // MARK: - Dependencies
  final _firestore = FirestoreService();
  final _prefs = SharedPreferences.getInstance();

  // MARK: - Properties
  String selectedAnimalId = '';
  Box<Animal> get _box => Hive.box<Animal>(_boxName);

  // MARK: - Constructor
  AnimalRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<String> getSelectedAnimalId() => _getSelectedId();
  Future<void> setSelectedAnimalId(String id) => _setSelectedId(id);
  Future<List<Animal>> getAnimais() => _getAll();
  Future<Animal?> getAnimalById(String id) => _getById(id);
  Future<bool> addAnimal(Animal animal) => _add(animal);
  Future<bool> updateAnimal(Animal animal) => _update(animal);
  Future<bool> deleteAnimal(Animal animal) => _delete(animal);
  Future<String> exportToCsv() => _exportToCsv();

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(AnimalAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing AnimalRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Animal>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - Selected Animal Management
  Future<String> _getSelectedId() async {
    try {
      final prefs = await _prefs;
      selectedAnimalId = prefs.getString(_selectedAnimalKey) ?? '';
    } catch (e) {
      debugPrint('Error getting selected animal: $e');
    }
    return selectedAnimalId;
  }

  Future<void> _setSelectedId(String id) async {
    try {
      final prefs = await _prefs;
      selectedAnimalId = id;
      await prefs.setString(_selectedAnimalKey, id);
    } catch (e) {
      debugPrint('Error saving selected animal: $e');
    }
  }

  // MARK: - CRUD Operations
  Future<List<Animal>> _getAll() async {
    List<Animal> animals = [];
    try {
      await _openBox();
      animals = _box.values.where((animal) => !animal.isDeleted).toList();
    } catch (e) {
      debugPrint('Error getting animals: $e');
    } finally {
      await _closeBox();
    }
    return animals;
  }

  Future<Animal?> _getById(String id) async {
    Animal? animal;
    try {
      await _openBox();
      animal = _box.get(id);
    } catch (e) {
      debugPrint('Error getting Animal by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
    return animal;
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(Animal animal) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(animal);

      // Cria o registro no Firebase e captura o objectId retornado
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: animal.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, animal);

      return true;
    } catch (e) {
      debugPrint('Error adding Animal: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(Animal animal) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == animal.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data/hora atual (em microsegundos)
        animal.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, animal);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: animal.id,
          data: animal.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Animal: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(Animal animal) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == animal.id);

      if (index != -1) {
        // Define o registro como deletado e atualiza o campo updatedAt
        animal.isDeleted = true;
        animal.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, animal);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: animal.id,
          data: animal.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Animal: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv() async {
    try {
      await _openBox();
      final animais = _box.values.where((animal) => !animal.isDeleted).toList();

      // Define CSV header with relevant fields
      const csvHeader =
          'Nome,Espécie,Raça,Data de Nascimento,Sexo,Cor,Peso Atual,Observações\n';

      // Convert each animal to a CSV row
      final csvRows = animais.map((animal) {
        final nome = _escapeField(animal.nome);
        final especie = _escapeField(animal.especie);
        final raca = _escapeField(animal.raca);
        // Format date from timestamp to readable format
        final dataNascimento = _escapeField(DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(animal.dataNascimento)));
        final sexo = _escapeField(animal.sexo);
        final cor = _escapeField(animal.cor);
        final pesoAtual = animal.pesoAtual.toString();
        final observacoes = _escapeField(animal.observacoes ?? '');

        return '$nome,$especie,$raca,$dataNascimento,$sexo,$cor,$pesoAtual,$observacoes';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting animals to CSV: $e');
      return '';
    } finally {
      await _closeBox();
    }
  }

  // Helper to escape fields that may contain commas, quotes, or newlines
  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Replace double quotes with two double quotes and wrap in quotes
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
