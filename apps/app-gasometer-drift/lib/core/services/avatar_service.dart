import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service responsible for avatar image processing, compression and management
class AvatarService {
  static const int _maxSizeBytes = 50 * 1024; // 50KB max
  static const int _targetDimension = 200; // 200x200px target
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB max input
  
  final ImagePicker _imagePicker = ImagePicker();

  /// Select image from camera with proper permissions and validation
  Future<AvatarResult> selectFromCamera() async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        return AvatarResult.error('Permissão de câmera necessária');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return AvatarResult.cancelled();
      }

      return await _processImage(pickedFile);
    } catch (e) {
      return AvatarResult.error('Erro ao acessar câmera: ${e.toString()}');
    }
  }

  /// Select image from gallery with proper validation
  Future<AvatarResult> selectFromGallery() async {
    try {
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        if (Platform.isAndroid) {
          status = await Permission.photos.request();
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        } else {
          status = await Permission.storage.request();
        }
      }

      if (!status.isGranted) {
        return AvatarResult.error('Permissão de galeria necessária');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return AvatarResult.cancelled();
      }

      return await _processImage(pickedFile);
    } catch (e) {
      return AvatarResult.error('Erro ao acessar galeria: ${e.toString()}');
    }
  }

  /// Process, validate and compress the selected image
  Future<AvatarResult> _processImage(XFile imageFile) async {
    try {
      final File file = File(imageFile.path);
      final fileSize = await file.length();
      if (fileSize > _maxFileSizeBytes) {
        return AvatarResult.error('Arquivo muito grande (max 5MB)');
      }
      final extension = imageFile.path.toLowerCase();
      if (!extension.endsWith('.jpg') && 
          !extension.endsWith('.jpeg') && 
          !extension.endsWith('.png')) {
        return AvatarResult.error('Tipo de arquivo não suportado (apenas JPG/PNG)');
      }
      final Uint8List originalBytes = await file.readAsBytes();
      final img.Image? originalImage = img.decodeImage(originalBytes);
      
      if (originalImage == null) {
        return AvatarResult.error('Imagem corrompida ou formato inválido');
      }
      final img.Image processedImage = _resizeAndCropToSquare(originalImage);
      final String base64String = await _compressToBase64(processedImage);
      try {
        await file.delete();
      } catch (e) {
        print('Warning: Could not delete temporary file: $e');
      }

      return AvatarResult.success(
        base64String,
        _calculateSizeKB(base64String),
      );
      
    } catch (e) {
      return AvatarResult.error('Erro ao processar imagem: ${e.toString()}');
    }
  }

  /// Resize image to square format with smart cropping
  img.Image _resizeAndCropToSquare(img.Image image) {
    final int smallerSide = image.width < image.height ? image.width : image.height;
    final int cropX = (image.width - smallerSide) ~/ 2;
    final int cropY = (image.height - smallerSide) ~/ 2;
    final img.Image croppedImage = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: smallerSide,
      height: smallerSide,
    );
    return img.copyResize(
      croppedImage,
      width: _targetDimension,
      height: _targetDimension,
      interpolation: img.Interpolation.cubic,
    );
  }

  /// Compress image to base64 with size optimization
  Future<String> _compressToBase64(img.Image image) async {
    int quality = 95;
    String base64String = '';
    
    do {
      final List<int> jpegBytes = img.encodeJpg(image, quality: quality);
      base64String = base64Encode(jpegBytes);
      if (_calculateSizeBytes(base64String) <= _maxSizeBytes || quality <= 10) {
        break;
      }
      quality -= 10;
    } while (quality > 0);
    
    return base64String;
  }

  /// Calculate size in bytes from base64 string
  int _calculateSizeBytes(String base64String) {
    return base64String.length * 3 ~/ 4;
  }

  /// Calculate size in KB from base64 string
  double _calculateSizeKB(String base64String) {
    return _calculateSizeBytes(base64String) / 1024;
  }

  /// Validate if a base64 string represents a valid avatar
  bool isValidAvatar(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return false;
    }

    try {
      final bytes = base64Decode(base64String);
      return bytes.isNotEmpty && _calculateSizeBytes(base64String) <= _maxSizeBytes;
    } catch (e) {
      return false;
    }
  }

  /// Convert base64 string to image bytes for display
  Uint8List? decodeAvatarBytes(String? base64String) {
    if (!isValidAvatar(base64String)) {
      return null;
    }

    try {
      return base64Decode(base64String!);
    } catch (e) {
      return null;
    }
  }

  /// Check if device supports camera
  Future<bool> get isCameraAvailable async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      return false;
    }
  }
}

/// Result wrapper for avatar operations
class AvatarResult {

  const AvatarResult._({
    required this.success,
    this.base64Data,
    this.sizeKB,
    this.errorMessage,
    this.cancelled = false,
  });

  factory AvatarResult.success(String base64Data, double sizeKB) {
    return AvatarResult._(
      success: true,
      base64Data: base64Data,
      sizeKB: sizeKB,
    );
  }

  factory AvatarResult.error(String message) {
    return AvatarResult._(
      success: false,
      errorMessage: message,
    );
  }

  factory AvatarResult.cancelled() {
    return const AvatarResult._(
      success: false,
      cancelled: true,
    );
  }
  final bool success;
  final String? base64Data;
  final double? sizeKB;
  final String? errorMessage;
  final bool cancelled;
}
