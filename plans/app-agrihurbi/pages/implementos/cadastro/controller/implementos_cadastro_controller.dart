// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../../models/implementos_class.dart';
import '../../../../repository/implementos_repository.dart';
import '../../../../services/storage_service.dart';
import '../models/implemento_model.dart';

class ImplementosCadastroController extends ChangeNotifier {
  final _repository = ImplementosRepository();
  final _imagePicker = ImagePicker();
  final _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<File> _images = [];
  List<File> get images => _images;

  File? _imageMiniatura;
  File? get imageMiniatura => _imageMiniatura;

  late ImplementoModel implemento;
  final formKey = GlobalKey<FormState>();

  Future<void> initializeData(String idReg) async {
    _setLoading(true);
    try {
      if (idReg.isNotEmpty) {
        final data = await _repository.get(idReg);
        implemento = ImplementoModel.fromJson(data.toJson());
      } else {
        implemento = ImplementoModel();
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selecionarImagens() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);
      _images.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      notifyListeners();
        } catch (e) {
      rethrow;
    }
  }

  Future<void> selecionarMiniatura() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageMiniatura = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _uploadImages() async {
    try {
      if (_images.isNotEmpty) {
        final urls = await _storageService.uploadMultipleFiles(
          bucket: StorageBuckets.implementos,
          files: _images,
          folder: StorageFolders.implementos,
        );

        implemento.imagens.addAll(urls);
      }

      if (_imageMiniatura != null) {
        final url = await _storageService.uploadFile(
          bucket: StorageBuckets.implementos,
          file: _imageMiniatura!,
          folder: StorageFolders.miniaturas,
        );

        if (url != null) {
          implemento.miniatura = url;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao fazer upload das imagens: $e');
      rethrow;
    }
  }

  Future<bool> salvarRegistro() async {
    if (!formKey.currentState!.validate()) return false;

    _setLoading(true);
    try {
      await _uploadImages();
      final success =
          await _repository.saveUpdate(implemento as ImplementosClass);
      return success;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void updateImplemento({
    String? descricao,
    String? marca,
    bool? status,
  }) {
    if (descricao != null) implemento.descricao = descricao;
    if (marca != null) implemento.marca = marca;
    if (status != null) implemento.status = status;
    notifyListeners();
  }
}
