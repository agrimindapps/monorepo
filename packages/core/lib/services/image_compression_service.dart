import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Service for compressing and optimizing images
/// Converts images to JPEG format for optimal storage and performance
class ImageCompressionService {
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1920;
  static const int _quality = 80;
  static const int _maxFileSizeBytes = 2 * 1024 * 1024; // 2MB

  /// Compress image from file path
  /// Returns the path to the compressed image
  Future<String> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found: $imagePath');
      }
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      final resizedImage = _resizeImage(image);
      final compressedBytes = img.encodeJpg(resizedImage, quality: _quality);
      final compressedPath = await _saveCompressedImage(compressedBytes, imagePath);
      
      return compressedPath;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Compress image from bytes
  /// Returns the compressed image bytes
  Future<Uint8List> compressImageBytes(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image bytes');
      }
      final resizedImage = _resizeImage(image);
      final compressedBytes = img.encodeJpg(resizedImage, quality: _quality);
      
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to compress image bytes: $e');
    }
  }

  /// Resize image maintaining aspect ratio
  img.Image _resizeImage(img.Image image) {
    int newWidth = image.width;
    int newHeight = image.height;
    
    if (newWidth > _maxWidth || newHeight > _maxHeight) {
      final aspectRatio = newWidth / newHeight;
      
      if (aspectRatio > 1) {
        newWidth = _maxWidth;
        newHeight = (_maxWidth / aspectRatio).round();
      } else {
        newHeight = _maxHeight;
        newWidth = (_maxHeight * aspectRatio).round();
      }
      
      return img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );
    }
    
    return image;
  }

  /// Save compressed image to app directory
  Future<String> _saveCompressedImage(List<int> bytes, String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');
      
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = originalPath.split('/').last.split('.').first;
      final compressedFileName = '${originalName}_compressed_$timestamp.jpg';
      
      final compressedFile = File('${receiptsDir.path}/$compressedFileName');
      await compressedFile.writeAsBytes(bytes);
      
      return compressedFile.path;
    } catch (e) {
      throw Exception('Failed to save compressed image: $e');
    }
  }

  /// Get compressed image size in bytes
  Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return 0;
      }
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Check if image needs compression based on file size
  Future<bool> needsCompression(String imagePath) async {
    final size = await getImageSize(imagePath);
    return size > _maxFileSizeBytes;
  }

  /// Delete compressed image file
  Future<void> deleteCompressedImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
    }
  }

  /// Get image dimensions
  Future<Map<String, int>?> getImageDimensions(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return null;
      }

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return null;
    }
  }

  /// Validate image file
  Future<bool> isValidImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return false;
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      return image != null;
    } catch (e) {
      return false;
    }
  }

  /// Clean up old compressed images (older than 30 days)
  Future<void> cleanupOldImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');
      
      if (!await receiptsDir.exists()) {
        return;
      }

      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: 30));
      
      await for (final entity in receiptsDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            try {
              await entity.delete();
            } catch (e) {
            }
          }
        }
      }
    } catch (e) {
    }
  }

  /// Get compression statistics
  Future<Map<String, dynamic>> getCompressionStats(
    String originalPath,
    String compressedPath,
  ) async {
    try {
      final originalSize = await getImageSize(originalPath);
      final compressedSize = await getImageSize(compressedPath);
      
      final originalDimensions = await getImageDimensions(originalPath);
      final compressedDimensions = await getImageDimensions(compressedPath);
      
      final compressionRatio = originalSize > 0 ? compressedSize / originalSize : 0.0;
      final spaceSaved = originalSize - compressedSize;
      final spaceSavedPercent = originalSize > 0 ? (spaceSaved / originalSize) * 100 : 0.0;
      
      return {
        'originalSize': originalSize,
        'compressedSize': compressedSize,
        'spaceSaved': spaceSaved,
        'spaceSavedPercent': spaceSavedPercent.round(),
        'compressionRatio': compressionRatio,
        'originalDimensions': originalDimensions,
        'compressedDimensions': compressedDimensions,
      };
    } catch (e) {
      return {};
    }
  }
}
