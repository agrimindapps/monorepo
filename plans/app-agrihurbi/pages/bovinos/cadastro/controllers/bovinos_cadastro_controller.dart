import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BovinosCadastroController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> bovinoData = RxMap<String, dynamic>();
  
  // Propriedades adicionais
  final Rx<Map<String, dynamic>> bovino = Rx<Map<String, dynamic>>({});
  final RxString error = RxString('');
  final RxList<String> images = RxList<String>();
  final RxString imageMiniatura = RxString('');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Getters para acessar valores do bovino com segurança
  String get id => bovino.value['id'] ?? '';
  String get nomeComum => bovino.value['nomeComum'] ?? '';
  String get paisOrigem => bovino.value['paisOrigem'] ?? '';
  String get status => bovino.value['status'] ?? '';
  String get tipoAnimal => bovino.value['tipoAnimal'] ?? '';
  String get origem => bovino.value['origem'] ?? '';
  String get caracteristicas => bovino.value['caracteristicas'] ?? '';
  String get raca => bovino.value['raca'] ?? '';
  String get aptidao => bovino.value['aptidao'] ?? '';
  List<String> get tags => List<String>.from(bovino.value['tags'] ?? []);
  String get sistemaCriacao => bovino.value['sistemaCriacao'] ?? '';
  String get finalidade => bovino.value['finalidade'] ?? '';

  // Getter para File da imagem miniatura
  File? get miniaturaFile => 
    imageMiniatura.value.isNotEmpty ? File(imageMiniatura.value) : null;

  // Lista de arquivos de imagens
  List<File> get imagensFiles => 
    images.map((path) => File(path)).toList();

  // Métodos de atualização para cada campo
  void updateNomeComum(String value) {
    bovino.value['nomeComum'] = value;
    bovino.refresh();
  }

  void updatePaisOrigem(String value) {
    bovino.value['paisOrigem'] = value;
    bovino.refresh();
  }

  void updateStatus(String value) {
    bovino.value['status'] = value;
    bovino.refresh();
  }

  void updateTipoAnimal(String value) {
    bovino.value['tipoAnimal'] = value;
    bovino.refresh();
  }

  void updateOrigem(String value) {
    bovino.value['origem'] = value;
    bovino.refresh();
  }

  void updateCaracteristicas(String value) {
    bovino.value['caracteristicas'] = value;
    bovino.refresh();
  }

  void updateRaca(String value) {
    bovino.value['raca'] = value;
    bovino.refresh();
  }

  void updateAptidao(String value) {
    bovino.value['aptidao'] = value;
    bovino.refresh();
  }

  void updateTags(List<String> value) {
    bovino.value['tags'] = value;
    bovino.refresh();
  }

  void updateSistemaCriacao(String value) {
    bovino.value['sistemaCriacao'] = value;
    bovino.refresh();
  }

  void updateFinalidade(String value) {
    bovino.value['finalidade'] = value;
    bovino.refresh();
  }

  void _logError(String message) {
    debugPrint('BovinosCadastroController - $message');
  }

  void setBovinoData(String field, dynamic value) {
    bovinoData[field] = value;
    bovino.value[field] = value;
    bovino.refresh();
  }

  Future<void> salvarRegistro() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (formKey.currentState != null && formKey.currentState!.validate()) {
        bool resultado = await _salvarBovino();
        
        if (resultado) {
          Get.snackbar(
            'Sucesso', 
            'Registro salvo com sucesso', 
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white
          );
        } else {
          error.value = 'Falha ao salvar o registro';
        }
      } else {
        error.value = 'Por favor, preencha todos os campos obrigatórios';
      }
    } catch (e) {
      _logError('Erro ao salvar registro: $e');
      error.value = 'Erro inesperado durante o salvamento';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _salvarBovino() async {
    try {
      if (bovinoData.isEmpty) {
        error.value = 'Dados do bovino não preenchidos';
        return false;
      }
      
      // Simula salvamento, substituir por lógica real
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      _logError('Erro ao salvar bovino: $e');
      error.value = 'Falha ao salvar bovino';
      return false;
    }
  }

  Future<void> selecionarImagens() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      
      images.value = pickedFiles.map((file) => file.path).toList();
      images.refresh();
    } catch (e) {
      _logError('Erro ao selecionar imagens: $e');
      error.value = 'Falha ao selecionar imagens';
    }
  }

  Future<void> selecionarMiniatura() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        imageMiniatura.value = pickedFile.path;
      }
    } catch (e) {
      _logError('Erro ao selecionar miniatura: $e');
      error.value = 'Falha ao selecionar miniatura';
    }
  }

  void clearError() {
    error.value = '';
  }

  void limparFormulario() {
    bovinoData.clear();
    bovino.value.clear();
    images.clear();
    imageMiniatura.value = '';
    formKey.currentState?.reset();
    error.value = '';
  }

  Future<bool> removerBovino() async {
    try {
      if (bovino.value.isEmpty || bovino.value['id'] == null) {
        error.value = 'Nenhum bovino selecionado para remoção';
        return false;
      }

      // Simula remoção, substituir por lógica real de remoção
      await Future.delayed(const Duration(milliseconds: 500));
      
      limparFormulario();
      
      Get.snackbar(
        'Sucesso', 
        'Bovino removido com sucesso', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white
      );

      return true;
    } catch (e) {
      _logError('Erro ao remover bovino: $e');
      error.value = 'Falha ao remover bovino';
      return false;
    }
  }
}