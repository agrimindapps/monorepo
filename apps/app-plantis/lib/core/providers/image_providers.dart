import 'package:core/core.dart' hide Column;

import '../services/image_management_service.dart';

part 'image_providers.g.dart';

/// Provider for ImageService (from core package)
@riverpod
ImageService imageService(Ref ref) {
  return ImageService();
}

/// Provider for ImageServiceAdapter (adapts core ImageService to IImageService)
@riverpod
IImageService imageServiceAdapter(Ref ref) {
  final imageService = ref.watch(imageServiceProvider);
  return ImageServiceAdapter(imageService);
}

/// Provider for ImageManagementService (specialized SOLID service)
@riverpod
ImageManagementService imageManagementService(
  Ref ref,
) {
  final imageService = ref.watch(imageServiceAdapterProvider);
  return ImageManagementService(imageService: imageService);
}

/// Provider for EnhancedImageService (cache + optimization)
@riverpod
EnhancedImageService enhancedImageService(Ref ref) {
  final service = EnhancedImageService();
  service.initialize();
  return service;
}
