// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../../repository/equinos_repository.dart';
import '../../../../services/image_validation_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/upload_service.dart';

class EquinosCadastroController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final imagePicker = ImagePicker();
  final storageService = StorageService();
  final uploadService = UploadService();

  // Observable state
  final isLoading = false.obs;
  final images = <File>[].obs;
  final imageMiniatura = Rxn<File>();
  final errorMessage = ''.obs;
  final uploadProgress = 0.0.obs;

  // Parameters
  String idReg = '';

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments['idReg'] != null) {
      idReg = arguments['idReg'];
    }
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (idReg.isNotEmpty) {
        await EquinoRepository().get(idReg);
      } else {
        EquinoRepository().newInsert();
      }
    } catch (e) {
      errorMessage.value = 'Erro ao carregar dados: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selecionarImagens() async {
    try {
      errorMessage.value = '';
      final pickedFiles = await imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFiles.isNotEmpty) {
        final newImages = pickedFiles.map((xFile) => File(xFile.path)).toList();

        // Validar arquivos usando o novo serviço
        final validationResults =
            await ImageValidationService.validateMultipleImages(newImages);

        for (int i = 0; i < newImages.length; i++) {
          final result = validationResults[i];
          if (!result.isValid) {
            errorMessage.value = 'Imagem ${i + 1}: ${result.message}';
            return;
          }
        }

        images.addAll(newImages);

        // Mostrar warning se houver
        final warnings = validationResults
            .where((r) => r.type == ImageValidationType.warning);
        if (warnings.isNotEmpty) {
          Get.snackbar(
            'Aviso',
            warnings.first.message!,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Erro ao selecionar imagens: $e';
    }
  }

  Future<void> selecionarMiniatura() async {
    try {
      errorMessage.value = '';
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validar arquivo usando o novo serviço
        final validationResult = await ImageValidationService.validateImage(
          file,
          isMiniatura: true,
        );

        if (!validationResult.isValid) {
          errorMessage.value = validationResult.message;
          return;
        }

        imageMiniatura.value = file;

        // Mostrar warning se houver
        if (validationResult.type == ImageValidationType.warning) {
          Get.snackbar(
            'Aviso',
            validationResult.message!,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Erro ao selecionar miniatura: $e';
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  void removeMiniatura() {
    imageMiniatura.value = null;
  }

  Future<bool> uploadImages() async {
    try {
      uploadProgress.value = 0.0;

      // Upload das imagens principais
      if (images.isNotEmpty) {
        final multipleUploadResult = await uploadService.uploadMultipleFiles(
          files: images.toList(),
          bucket: StorageBuckets.equinos,
          folder: StorageFolders.equinos,
          onProgress: (progress) {
            uploadProgress.value = progress.overallProgress *
                0.8; // 80% do progresso para imagens principais
          },
        );

        if (!multipleUploadResult.isSuccess) {
          // Se falhou completamente
          errorMessage.value =
              'Erro no upload: ${multipleUploadResult.errorMessage}';
          return false;
        } else {
          // Upload foi bem-sucedido
          if (multipleUploadResult.urls != null &&
              multipleUploadResult.urls!.isNotEmpty) {
            EquinoRepository()
                .mapEquinos
                .value
                .imagens!
                .addAll(multipleUploadResult.urls!);
          }

          // Se houve falhas parciais, avisar
          if (multipleUploadResult.failedFiles != null &&
              multipleUploadResult.failedFiles!.isNotEmpty) {
            final failedCount = multipleUploadResult.failedFiles!.length;
            errorMessage.value =
                'Aviso: $failedCount arquivo(s) falharam no upload';
          }
        }
      }

      // Upload da miniatura
      if (imageMiniatura.value != null) {
        uploadProgress.value = 0.8; // 80% concluído

        final miniaturaUrl = await uploadService.uploadSingleFile(
          file: imageMiniatura.value!,
          bucket: StorageBuckets.equinos,
          folder: StorageFolders.miniaturas,
          onProgress: (progress) {
            uploadProgress.value = 0.8 +
                (progress.overallProgress * 0.2); // 20% restante para miniatura
          },
        );

        if (miniaturaUrl != null) {
          EquinoRepository().mapEquinos.value.miniatura = miniaturaUrl;
        } else {
          errorMessage.value = 'Erro no upload da miniatura';
          return false;
        }
      }

      uploadProgress.value = 1.0;
      return true;
    } catch (e) {
      errorMessage.value = 'Erro inesperado no upload: $e';
      uploadProgress.value = 0.0;
      return false;
    }
  }

  Future<bool> salvarRegistro() async {
    if (!formKey.currentState!.validate()) {
      errorMessage.value = 'Por favor, preencha todos os campos obrigatórios';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uploadSuccess = await uploadImages();
      if (!uploadSuccess) {
        return false;
      }

      final saveSuccess = await EquinoRepository().saveUpdate();
      if (saveSuccess) {
        Get.snackbar(
          'Sucesso',
          'Registro salvo com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navegar de volta e atualizar lista
        Get.back(result: true);
        return true;
      } else {
        errorMessage.value = 'Erro ao salvar registro';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erro inesperado: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
