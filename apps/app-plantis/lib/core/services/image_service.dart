import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Selecionar imagem da galeria
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao selecionar imagem da galeria: $e');
      return null;
    }
  }

  /// Capturar imagem da câmera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao capturar imagem da câmera: $e');
      return null;
    }
  }

  /// Selecionar múltiplas imagens
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      // Limitar número de imagens
      final limitedImages = images.take(maxImages).toList();
      
      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Erro ao selecionar múltiplas imagens: $e');
      return [];
    }
  }

  /// Mostrar dialog de seleção de fonte
  Future<File?> showImageSourceDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Imagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  /// Upload de imagem para Firebase Storage
  Future<String?> uploadImage(
    File imageFile, {
    required String folder,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Gerar nome único se não fornecido
      final String finalFileName = fileName ?? 
          '${_uuid.v4()}${_getFileExtension(imageFile.path)}';
      
      // Referência no Firebase Storage
      final Reference storageRef = _storage.ref().child('$folder/$finalFileName');
      
      // Configurar metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Upload com progresso
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Monitorar progresso se callback fornecido
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Aguardar conclusão
      final TaskSnapshot snapshot = await uploadTask;
      
      // Retornar URL de download
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  /// Upload de múltiplas imagens
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    required String folder,
    Function(int, double)? onProgress,
  }) async {
    final List<String> downloadUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final File imageFile = imageFiles[i];
      
      final String? downloadUrl = await uploadImage(
        imageFile,
        folder: folder,
        onProgress: onProgress != null 
            ? (progress) => onProgress(i, progress) 
            : null,
      );
      
      if (downloadUrl != null) {
        downloadUrls.add(downloadUrl);
      }
    }
    
    return downloadUrls;
  }

  /// Deletar imagem do Firebase Storage
  Future<bool> deleteImage(String downloadUrl) async {
    try {
      // Extrair referência da URL
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar imagem: $e');
      return false;
    }
  }

  /// Deletar múltiplas imagens
  Future<void> deleteMultipleImages(List<String> downloadUrls) async {
    for (final String url in downloadUrls) {
      await deleteImage(url);
    }
  }

  /// Comprimir imagem (utilitário)
  Future<File?> compressImage(
    File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      // Para uma implementação mais robusta, você pode usar o package 'flutter_image_compress'
      // Por enquanto, retornamos o arquivo original
      return imageFile;
    } catch (e) {
      debugPrint('Erro ao comprimir imagem: $e');
      return null;
    }
  }

  /// Validar formato de imagem
  bool isValidImageFormat(String filePath) {
    final String extension = _getFileExtension(filePath).toLowerCase();
    const List<String> validFormats = ['.jpg', '.jpeg', '.png', '.webp'];
    return validFormats.contains(extension);
  }

  /// Extrair extensão do arquivo
  String _getFileExtension(String filePath) {
    final int lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return filePath.substring(lastDotIndex);
  }

  /// Validar tamanho do arquivo (em bytes)
  bool isValidFileSize(File file, {int maxSizeInMB = 10}) {
    final int fileSizeInBytes = file.lengthSync();
    final int maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Widget para preview de imagem com loading
  Widget buildImagePreview(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    Widget child;

    if (imageUrl == null || imageUrl.isEmpty) {
      child = placeholder ?? 
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade400,
              size: 40,
            ),
          );
    } else {
      child = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade400,
                  size: 40,
                ),
              );
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: child,
      );
    }

    return child;
  }
}

/// Enum para tipos de upload
enum ImageUploadType {
  plant('plants'),
  space('spaces'),
  task('tasks'),
  profile('profiles');

  const ImageUploadType(this.folder);
  final String folder;
}

/// Classe para resultado de upload
class ImageUploadResult {
  final String? downloadUrl;
  final String? error;
  final bool success;

  ImageUploadResult({
    this.downloadUrl,
    this.error,
    required this.success,
  });

  factory ImageUploadResult.success(String downloadUrl) {
    return ImageUploadResult(
      downloadUrl: downloadUrl,
      success: true,
    );
  }

  factory ImageUploadResult.error(String error) {
    return ImageUploadResult(
      error: error,
      success: false,
    );
  }
}