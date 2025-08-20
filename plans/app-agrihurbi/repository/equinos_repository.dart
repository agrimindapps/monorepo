// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// Project imports:
import '../models/equino_class.dart';

/// Repository for managing equine data in Firestore
class EquinoRepository extends GetxController {
  // Singleton pattern implementation
  static final EquinoRepository _instance = EquinoRepository._internal();

  factory EquinoRepository() {
    return _instance;
  }

  EquinoRepository._internal();

  // Firebase and collection configuration
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'equinos';

  // Observable state variables
  final RxList<EquinosClass> listaEquinos = <EquinosClass>[].obs;
  final Rx<EquinosClass> mapEquinos = EquinosClass().obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingOne = false.obs;

  /// Fetches all equines from Firestore
  Future<void> getAll() async {
    isLoading.value = true;

    try {
      final QuerySnapshot reg = await _firestore.collection(_collection).get();

      final equines = reg.docs
          .map((doc) => EquinosClass().documentToClass(doc))
          .toList()
        ..sort((a, b) => a.nomeComum.compareTo(b.nomeComum));

      listaEquinos.assignAll(equines);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar equinos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches a single equine by ID
  Future<void> get(String idReg) async {
    if (idReg.isEmpty) {
      Get.snackbar('Erro', 'ID do equino não informado');
      return;
    }

    isLoadingOne.value = true;

    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(idReg).get();

      if (!doc.exists) {
        throw Exception('Equino não encontrado');
      }

      mapEquinos.value = EquinosClass().documentToClass(doc);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar equino: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOne.value = false;
    }
  }

  /// Prepares for a new equine insertion
  void newInsert() {
    mapEquinos.value = EquinosClass();
  }

  /// Saves or updates an equine
  Future<bool> saveUpdate() async {
    try {
      final equine = mapEquinos.value;

      if (equine.idReg.isEmpty) {
        // New equine
        await _firestore.collection(_collection).add(equine.toMap(equine));
      } else {
        // Update existing equine
        await _firestore
            .collection(_collection)
            .doc(equine.idReg)
            .update(equine.toMap(equine));
      }

      await getAll();

      Get.snackbar(
        'Sucesso',
        'Equino ${equine.idReg.isEmpty ? 'adicionado' : 'atualizado'} com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao salvar equino: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Soft deletes an equine by setting its status to inactive
  Future<bool> remove(String idReg) async {
    if (idReg.isEmpty) {
      Get.snackbar('Erro', 'ID do equino não informado');
      return false;
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(idReg)
          .update({'status': true});

      await getAll();

      Get.snackbar(
        'Sucesso',
        'Equino removido com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao remover equino: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
