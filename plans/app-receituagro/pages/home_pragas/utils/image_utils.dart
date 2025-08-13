class ImageUtils {
  static const String _imageBasePath = 'assets/imagens/bigsize/';
  static const String _imageExtension = '.jpg';

  /// Builds the complete image path for a praga
  static String buildImagePath(String? imageName) {
    if (imageName == null || imageName.isEmpty) return '';
    return '$_imageBasePath$imageName$_imageExtension';
  }

  /// Checks if the image path is valid
  static bool isValidImagePath(String? imageName) {
    return imageName != null && imageName.isNotEmpty;
  }
}