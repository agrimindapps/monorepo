/// Módulo de gerenciamento de imagens do Core
///
/// Fornece:
/// - [ImageProcessingService] - Processamento e compressão de imagens
/// - [EntityImage] - Entidade para representar imagens
/// - [EntityImages] - Schema Drift para tabela de imagens
/// - [ImageProcessingConfig] - Configurações de processamento
/// - [IEntityImageRepository] - Interface para repository de imagens
/// - [EntityImageHelper] - Helper para operações em entidades específicas
/// - [EntityImageSyncAdapter] - Sincronização com Firestore
///
/// Exemplo de uso:
/// ```dart
/// // Processar uma imagem
/// final service = ImageProcessingService.instance;
/// final processed = await service.processImage(
///   imageBytes,
///   config: ImageProcessingConfig.standard,
/// );
///
/// // Criar entidade
/// final entity = EntityImage(
///   moduleName: 'plantis',
///   entityType: 'plant',
///   entityId: 'abc123',
///   imageBase64: processed.base64DataUri,
///   sizeBytes: processed.sizeBytes,
///   width: processed.width,
///   height: processed.height,
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// ```
library;

export 'entity_image.dart';
export 'entity_image_repository.dart';
export 'entity_image_sync_adapter.dart';
export 'entity_images_table.dart';
export 'image_processing_service.dart';
