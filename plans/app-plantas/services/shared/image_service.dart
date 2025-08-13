// Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Mostra um diálogo para escolher entre câmera ou galeria
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar foto'),
          content: const Text('Escolha a origem da foto para sua planta:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 20),
                  SizedBox(width: 8),
                  Text('Câmera'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, size: 20),
                  SizedBox(width: 8),
                  Text('Galeria'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (source != null) {
      return await _pickAndProcessImage(source);
    }
    return null;
  }

  /// Captura ou seleciona uma imagem e a processa
  static Future<String?> _pickAndProcessImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Lê os bytes da imagem
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      // Processa e redimensiona a imagem
      final String base64Image = await _processAndResizeImage(imageBytes);

      return base64Image;
    } catch (e) {
      debugPrint('Erro ao capturar imagem: $e');
      return null;
    }
  }

  /// Processa e redimensiona a imagem para o tamanho desejado
  static Future<String> _processAndResizeImage(Uint8List imageBytes) async {
    try {
      // Decodifica a imagem
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Não foi possível decodificar a imagem');
    }

      // Redimensiona mantendo proporção
      const int maxSize = 1024;
      if (image.width > maxSize || image.height > maxSize) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: maxSize);
        } else {
          image = img.copyResize(image, height: maxSize);
        }
      }

      // Converte para JPEG com qualidade reduzida
      final List<int> compressedBytes = img.encodeJpg(image, quality: 85);

      // Converte para base64
      final String base64String = base64Encode(compressedBytes);

      return base64String;
    } catch (e) {
      debugPrint('Erro ao processar imagem: $e');
      // Em caso de erro, retorna a imagem original em base64
      return base64Encode(imageBytes);
    }
  }

  /// Converte base64 para Image widget
  static Widget? base64ToImage(
    String? base64String, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (base64String == null || base64String.isEmpty) return null;

    try {
      final Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Erro ao exibir imagem: $error');
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Erro ao decodificar base64: $e');
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      );
    }
  }

  /// Calcula o tamanho aproximado da string base64 em KB
  static double getBase64SizeKB(String base64String) {
    // Cada caractere base64 representa aproximadamente 0.75 bytes
    final double sizeBytes = base64String.length * 0.75;
    return sizeBytes / 1024; // Converte para KB
  }

  /// Verifica se a string base64 é válida
  static bool isValidBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return false;

    try {
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }
}
