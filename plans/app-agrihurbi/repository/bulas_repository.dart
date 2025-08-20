// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// Project imports:
import '../models/bulas_class.dart';

/// Repository for managing pharmaceutical instructions (bulas) in Firestore
class BulasRepository extends GetxController {
  // Singleton pattern implementation
  static final BulasRepository _instance = BulasRepository._internal();

  factory BulasRepository() {
    return _instance;
  }

  BulasRepository._internal();

  // Firebase and collection configuration
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'bulas';

  // Observable state variables
  final RxList<BulasClass> listaBulas = <BulasClass>[].obs;
  final Rx<BulasClass> mapBula = BulasClass().obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingOne = false.obs;

  /// Fetches all pharmaceutical instructions from Firestore
  Future<void> getAll() async {
    isLoading.value = true;

    try {
      final QuerySnapshot reg = await _firestore.collection(_collection).get();

      final bulas = reg.docs
          .map((doc) => BulasClass().documentToClass(doc))
          .toList()
        ..sort((a, b) => a.descricao.compareTo(b.descricao));

      listaBulas.assignAll(bulas);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar bulas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches a single pharmaceutical instruction by ID
  Future<void> get(String idReg) async {
    if (idReg.isEmpty) {
      Get.snackbar('Erro', 'ID da bula não informado');
      return;
    }

    isLoadingOne.value = true;

    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(idReg).get();

      if (!doc.exists) {
        throw Exception('Bula não encontrada');
      }

      mapBula.value = BulasClass().documentToClass(doc);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar bula: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOne.value = false;
    }
  }

  /// Prepares for a new pharmaceutical instruction insertion
  void newInsert() {
    mapBula.value = BulasClass();
  }

  /// Saves or updates a pharmaceutical instruction
  Future<bool> saveUpdate() async {
    try {
      final bula = mapBula.value;

      if (bula.idReg.isEmpty) {
        // New instruction
        await _firestore.collection(_collection).add(bula.toMap(bula));
      } else {
        // Update existing instruction
        await _firestore
            .collection(_collection)
            .doc(bula.idReg)
            .update(bula.toMap(bula));
      }

      await getAll();

      Get.snackbar(
        'Sucesso',
        'Bula ${bula.idReg.isEmpty ? 'adicionada' : 'atualizada'} com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao salvar bula: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Soft deletes a pharmaceutical instruction by setting its status to inactive
  Future<bool> remove(String idReg) async {
    if (idReg.isEmpty) {
      Get.snackbar('Erro', 'ID da bula não informado');
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
        'Bula removida com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao remover bula: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
