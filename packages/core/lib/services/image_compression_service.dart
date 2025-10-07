import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A service for compressing and optimizing images.
///
/// This service provides methods to resize images, compress them to JPEG format,
/// and manage the compressed files.
class ImageCompressionService {
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1920;
  static const int _quality = 80;
  static const int _maxFileSizeBytes = 2 * 1024 * 1024; // 2MB
  static const String _compressedImageDir = 'receipts';

  /// Compresses an image from a file path.
  ///
  /// Returns the path to the compressed JPEG image.
  /// Throws an [Exception] if the file is not found or cannot be processed.
  Future<String> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found: $imagePath');
      }
      final bytes = await file.readAsBytes();
      final compressedBytes = await _compress(bytes);
      return await _saveCompressedImage(compressedBytes, imagePath);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Compresses image data from a [Uint8List].
  ///
  /// Returns the compressed image as a [Uint8List].
  /// Throws an [Exception] if the image data cannot be processed.
  Future<Uint8List> compressImageBytes(Uint8List imageBytes) async {
    try {
      return await _compress(imageBytes);
    } catch (e) {
      throw Exception('Failed to compress image bytes: $e');
    }
  }

  /// The core compression logic.
  Future<Uint8List> _compress(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image bytes.');
    }
    final resizedImage = _resizeImage(image);
    final compressedBytes = img.encodeJpg(resizedImage, quality: _quality);
    return Uint8List.fromList(compressedBytes);
  }

  /// Resizes an image while maintaining its aspect ratio.
  img.Image _resizeImage(img.Image image) {
    if (image.width <= _maxWidth && image.height <= _maxHeight) {
      return image;
    }

    return img.copyResize(
      image,
      width: _maxWidth,
      height: _maxHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Saves the compressed image to the application's documents directory.
  Future<String> _saveCompressedImage(List<int> bytes, String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(appDir.path, _compressedImageDir));

      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = p.basenameWithoutExtension(originalPath);
      final compressedFileName = '${originalName}_compressed_$timestamp.jpg';
      final compressedFile = File(p.join(receiptsDir.path, compressedFileName));

      await compressedFile.writeAsBytes(bytes);
      return compressedFile.path;
    } catch (e) {
      throw Exception('Failed to save compressed image: $e');
    }
  }

  /// Returns the size of an image file in bytes.
  Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // Ignore errors and return 0
    }
    return 0;
  }

  /// Checks if an image needs compression based on its file size.
  Future<bool> needsCompression(String imagePath) async {
    final size = await getImageSize(imagePath);
    return size > _maxFileSizeBytes;
  }

  /// Deletes a compressed image file.
  Future<void> deleteCompressedImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Deletion is best-effort; failure is not critical.
    }
  }

  /// Returns the dimensions (width and height) of an image.
  Future<Map<String, int>?> getImageDimensions(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        return {'width': image.width, 'height': image.height};
      }
    } catch (e) {
      // Return null if dimensions cannot be determined.
    }
    return null;
  }

  /// Validates if a file at a given path is a valid image.
  Future<bool> isValidImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      return img.decodeImage(bytes) != null;
    } catch (e) {
      return false;
    }
  }

  /// Cleans up compressed images older than 30 days.
  Future<void> cleanupOldImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(appDir.path, _compressedImageDir));

      if (!await receiptsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final files = receiptsDir.list();

      await for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await deleteCompressedImage(entity.path);
          }
        }
      }
    } catch (e) {
      // Cleanup is best-effort; failure is not critical.
    }
  }

  /// Gathers statistics about the compression of an image.
  Future<Map<String, dynamic>> getCompressionStats(
    String originalPath,
    String compressedPath,
  ) async {
    try {
      final originalSize = await getImageSize(originalPath);
      final compressedSize = await getImageSize(compressedPath);
      final spaceSaved = originalSize > 0 ? originalSize - compressedSize : 0;

      return {
        'originalSize': originalSize,
        'compressedSize': compressedSize,
        'spaceSaved': spaceSaved,
        'spaceSavedPercent': originalSize > 0 ? (spaceSaved / originalSize * 100).round() : 0,
        'compressionRatio': originalSize > 0 ? compressedSize / originalSize : 0.0,
        'originalDimensions': await getImageDimensions(originalPath),
        'compressedDimensions': await getImageDimensions(compressedPath),
      };
    } catch (e) {
      return {};
    }
  }
}