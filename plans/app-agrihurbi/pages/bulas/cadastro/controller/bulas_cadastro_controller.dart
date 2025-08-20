// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../../services/storage_service.dart';
import '../model/bula_model.dart';
import '../repository/bulas_repository.dart';

class BulasCadastroController extends GetxController {
  final _repository = BulasRepository();
  final _imagePicker = ImagePicker();
  final _storageService = StorageService();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxList<File> images = <File>[].obs;
  final Rx<File?> imageMiniatura = Rx<File?>(null);
  final RxString errorMessage = ''.obs;

  Future<void> initializeData(String idReg) async {
    isLoading.value = true;

    try {
      if (idReg.isNotEmpty) {
        await _repository.get(idReg);
      } else {
        _repository.newInsert();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selecionarImagens() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (pickedFiles.isNotEmpty) {
        images.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      }
    } catch (e) {
      errorMessage.value = 'Erro ao selecionar imagens';
    }
  }

  Future<void> selecionarMiniatura() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageMiniatura.value = File(pickedFile.path);
      }
    } catch (e) {
      errorMessage.value = 'Erro ao selecionar miniatura';
    }
  }

  Future<bool> _uploadImages() async {
    try {
      if (images.isNotEmpty) {
        final urls = await _storageService.uploadMultipleFiles(
          bucket: StorageBuckets.bulas,
          files: images,
          folder: StorageFolders.bulas,
        );

        _repository.mapBula.value.imagens ??= [];
        _repository.mapBula.value.imagens!.addAll(urls);
      }

      if (imageMiniatura.value != null) {
        final url = await _storageService.uploadFile(
          bucket: StorageBuckets.bulas,
          file: imageMiniatura.value!,
          folder: StorageFolders.miniaturas,
        );

        if (url != null) {
          _repository.mapBula.value.miniatura = url;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao fazer upload das imagens: $e');
      errorMessage.value = 'Erro ao fazer upload das imagens';
      return false;
    }
  }

  Future<bool> salvarRegistro() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading.value = true;

    try {
      await _uploadImages();
      final acao = await _repository.saveUpdate();
      errorMessage.value = '';
      return acao;
    } catch (e) {
      errorMessage.value = 'Erro ao salvar registro';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void updateBulaDescricao(String value) {
    _repository.mapBula.value.descricao = value;
  }

  BulaModel get bula => _repository.mapBula.value;
}