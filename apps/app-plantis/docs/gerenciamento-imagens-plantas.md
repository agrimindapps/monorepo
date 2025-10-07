# Gerenciamento de Imagens de Plantas - Plantis

**Documento de Análise e Implementação**
**Versão:** 1.0
**Data:** 07 de Outubro de 2025
**Status:** Produção (Parcial)

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Modelo de Dados](#modelo-de-dados)
4. [Seleção de Imagens](#seleção-de-imagens)
5. [Suporte Multiplataforma](#suporte-multiplataforma)
6. [Processamento de Imagens](#processamento-de-imagens)
7. [Upload para Firebase Storage](#upload-para-firebase-storage)
8. [Armazenamento](#armazenamento)
9. [Gerenciamento de Lista](#gerenciamento-de-lista)
10. [Otimização e Performance](#otimização-e-performance)
11. [Validações e Segurança](#validações-e-segurança)
12. [UI/UX](#uiux)
13. [Integração com Plant Entity](#integração-com-plant-entity)
14. [Estado da Implementação](#estado-da-implementação)
15. [Fluxos Críticos](#fluxos-críticos)
16. [Gaps e Pendências](#gaps-e-pendências)
17. [Problemas Conhecidos](#problemas-conhecidos)
18. [Recomendações](#recomendações)
19. [Roadmap](#roadmap)
20. [Atualizações e Tarefas](#atualizações-e-tarefas)

---

## 🎯 Visão Geral

O sistema de gerenciamento de imagens do Plantis permite aos usuários **capturar, selecionar, processar e armazenar fotos de suas plantas** com otimização automática e suporte multiplataforma.

### Objetivos

- ✅ Permitir seleção de imagens da galeria (iOS/Android/Web)
- ✅ Permitir captura de fotos da câmera (iOS/Android)
- ✅ Comprimir e otimizar imagens automaticamente
- ✅ Upload para Firebase Storage com URLs permanentes
- ✅ Suportar até 5 imagens por planta
- ✅ Funcionar offline com sincronização posterior
- ⚠️ Suporte web (parcial - limitações conhecidas)

### Stack Tecnológica

```yaml
Seleção: image_picker ^1.0.0 (iOS/Android/Web)
Compressão: image package ^4.0.0
Storage: Firebase Storage
MIME Detection: mime ^2.0.0
Local Cache: path_provider + Hive
Formato: Base64 (temporário) → JPG (permanente)
```

### Limites e Configurações

```dart
const imageConfig = {
  'maxImagesPerPlant': 5,
  'maxOriginalSize': 10 * 1024 * 1024,  // 10MB
  'maxCompressedSize': 2 * 1024 * 1024,  // 2MB
  'maxWidth': 1920,
  'maxHeight': 1920,
  'quality': 85,  // JPEG quality
  'thumbnailSize': 200,
  'allowedFormats': ['.jpg', '.jpeg', '.png', '.webp'],
};
```

---

## 🏗️ Arquitetura

### Camadas e Responsabilidades

```
┌─────────────────────────────────────────────────┐
│           PRESENTATION LAYER                    │
│  ┌───────────────────────────────────────────┐  │
│  │  PlantFormBasicInfo (Widget)              │  │
│  │  - UI de seleção de imagem                │  │
│  │  - Preview e remoção                      │  │
│  │  - Loading states                         │  │
│  └───────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────┘
                 │ Uses
                 ↓
┌─────────────────────────────────────────────────┐
│          APPLICATION SERVICE LAYER              │
│  ┌───────────────────────────────────────────┐  │
│  │  ImageManagementService (app-plantis)     │  │
│  │  - captureFromCamera()                    │  │
│  │  - selectFromGallery()                    │  │
│  │  - addImageToList()                       │  │
│  │  - removeImageFromList()                  │  │
│  │  - uploadImages()                         │  │
│  │  - deleteImage()                          │  │
│  │  - validateImageList()                    │  │
│  └───────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────┘
                 │ Adapter Pattern
                 ↓
┌─────────────────────────────────────────────────┐
│       CORE INFRASTRUCTURE LAYER                 │
│  ┌───────────────────────────────────────────┐  │
│  │  ImageService (packages/core)             │  │
│  │  - pickImageFromGallery()                 │  │
│  │  - pickImageFromCamera()                  │  │
│  │  - pickMultipleImages()                   │  │
│  │  - uploadImage()                          │  │
│  │  - validateImage()                        │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  EnhancedImageService                     │  │
│  │  - Cache management                       │  │
│  │  - Compression                            │  │
│  │  - Thumbnails                             │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  ImageCompressionService                  │  │
│  │  - compressImage()                        │  │
│  │  - resizeImage()                          │  │
│  │  - encodeJpg()                            │  │
│  └───────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────┘
                 │ Uses
                 ↓
┌─────────────────────────────────────────────────┐
│          EXTERNAL DEPENDENCIES                  │
│  - image_picker (Flutter plugin)                │
│  - image (compression library)                  │
│  - Firebase Storage SDK                         │
│  - mime (MIME type detection)                   │
└─────────────────────────────────────────────────┘
```

### Adapter Pattern

```dart
// Resolve violação DIP (Dependency Inversion Principle)
// App depende de interface, não de implementação concreta

abstract class IImageService {
  Future<Either<Failure, String>> pickFromCamera();
  Future<Either<Failure, String>> pickFromGallery();
  Future<Either<Failure, List<String>>> uploadImages(List<String> base64Images);
  Future<Either<Failure, void>> deleteImage(String imageUrl);
}

class ImageServiceAdapter implements IImageService {
  final ImageService _imageService;  // Core service

  @override
  Future<Either<Failure, String>> pickFromGallery() async {
    final result = await _imageService.pickImageFromGallery();
    return result.fold(
      (error) => Left(CacheFailure(error.message)),
      (file) async {
        // Converte File → Base64 data URI
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        return Right('data:$mimeType;base64,$base64String');
      },
    );
  }
}
```

### Estrutura de Diretórios

```
apps/app-plantis/
└── lib/
    ├── core/
    │   ├── services/
    │   │   ├── image_management_service.dart        # ⭐ Service principal (396 linhas)
    │   │   ├── enhanced_image_cache_manager.dart    # Cache otimizado
    │   │   └── image_preloader_service.dart         # Pre-carregamento
    │   ├── data/
    │   │   └── adapters/
    │   │       └── plantis_image_service_adapter.dart
    │   └── widgets/
    │       └── unified_image_widget.dart             # Widget reutilizável
    └── features/
        └── plants/
            └── presentation/
                └── widgets/
                    ├── plant_form_basic_info.dart   # ⭐ UI de seleção (200 linhas)
                    ├── plant_image_section.dart      # Seção de imagem detalhes
                    ├── optimized_plant_image_widget.dart
                    └── optimized_image_widget.dart

packages/core/
└── lib/
    ├── services/
    │   └── image_compression_service.dart            # ⭐ Compressão (150 linhas)
    └── src/
        ├── domain/
        │   └── entities/
        │       └── profile_image_result.dart
        └── infrastructure/
            └── services/
                ├── image_service.dart                # ⭐ Service genérico (200 linhas)
                ├── enhanced_image_service.dart       # ⭐ Service avançado (150 linhas)
                ├── enhanced_image_service_unified.dart
                ├── profile_image_service.dart
                └── optimized_image_service.dart
```

---

## 📊 Modelo de Dados

### ImageListResult

**Uso:** Resultado de operações em lista de imagens

```dart
class ImageListResult {
  final bool isSuccess;
  final String message;
  final List<String> updatedImages;

  factory ImageListResult.success(String message, List<String> images) {
    return ImageListResult._(
      isSuccess: true,
      message: message,
      updatedImages: images,
    );
  }

  factory ImageListResult.error(String message, List<String> currentImages) {
    return ImageListResult._(
      isSuccess: false,
      message: message,
      updatedImages: currentImages,
    );
  }
}

// Uso:
final result = imageManagementService.addImageToList(
  currentImages: ['image1.jpg', 'image2.jpg'],
  newImage: 'image3.jpg',
);

if (result.isSuccess) {
  print(result.message);  // "Imagem adicionada com sucesso"
  updatePlantImages(result.updatedImages);  // ['image1.jpg', 'image2.jpg', 'image3.jpg']
} else {
  showError(result.message);  // "Máximo de 5 imagens permitidas"
}
```

### ImageUploadResult

**Uso:** Resultado de upload para Firebase Storage

```dart
class ImageUploadResult {
  final String downloadUrl;      // URL pública permanente
  final String fileName;          // Nome do arquivo no Storage
  final String folder;            // Pasta no Storage
  final DateTime uploadedAt;      // Timestamp do upload

  Map<String, dynamic> toMap();
}

// Exemplo de resultado:
ImageUploadResult(
  downloadUrl: 'https://firebasestorage.googleapis.com/.../plant_abc123_1.jpg',
  fileName: 'plant_abc123_1.jpg',
  folder: 'plants/abc123/images',
  uploadedAt: DateTime(2025, 10, 7, 15, 30),
);
```

### ImageListInfo

**Uso:** Informações sobre estado da lista de imagens

```dart
class ImageListInfo {
  final int currentCount;      // Quantidade atual
  final int maxCount;           // Máximo permitido (5)
  final bool canAddMore;        // Pode adicionar mais?
  final int remainingSlots;     // Slots restantes
  final bool isEmpty;           // Lista vazia?
  final bool isFull;            // Lista cheia?
}

// Uso:
final info = imageManagementService.getImageListInfo(plant.imageUrls);

if (info.isFull) {
  showSnackbar('Limite de ${info.maxCount} imagens atingido');
} else {
  showSnackbar('${info.remainingSlots} imagens restantes');
}
```

### ImageListValidation

**Uso:** Validação completa de lista de imagens

```dart
class ImageListValidation {
  final bool isValid;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
}

// Uso:
final validation = imageManagementService.validateImageList(images);

if (!validation.isValid) {
  for (final error in validation.errors) {
    print('Erro: $error');
    // "Imagem 3 é inválida"
    // "Existem imagens duplicadas"
  }
}
```

### Plant Entity (imageUrls)

```dart
class Plant extends BaseSyncEntity {
  final String id;
  final String name;
  final List<String> imageUrls;  // ⭐ Lista de URLs do Firebase Storage

  // Propriedades computadas
  bool get hasImages => imageUrls.isNotEmpty;
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;
  int get imageCount => imageUrls.length;
}
```

---

## 📸 Seleção de Imagens

### pickFromGallery()

**Plataformas:** iOS ✅ | Android ✅ | Web ✅

```dart
// ImageManagementService
Future<Either<Failure, String>> selectFromGallery() async {
  try {
    final result = await _imageService.pickFromGallery();

    return result.fold(
      (failure) => Left(_mapImageFailure(failure, 'Erro ao selecionar imagem da galeria')),
      (base64Image) {
        if (_isValidBase64Image(base64Image)) {
          return Right(base64Image);
        } else {
          return const Left(ValidationFailure('Imagem selecionada inválida'));
        }
      },
    );
  } catch (e) {
    return Left(CacheFailure('Erro inesperado ao selecionar imagem: $e'));
  }
}
```

**Fluxo:**

```
User taps "Selecionar da Galeria"
  ↓
ImageManagementService.selectFromGallery()
  ↓
ImageServiceAdapter.pickFromGallery()
  ↓
ImageService.pickImageFromGallery() (core)
  ↓
image_picker.pickImage(source: ImageSource.gallery)
  ↓ [OS abre galeria nativa]
User seleciona imagem
  ↓
XFile retornado
  ↓
Validações (formato, tamanho)
  ↓
File → Bytes → Base64
  ↓
Base64 data URI: "data:image/jpeg;base64,/9j/4AAQ..."
  ↓
Retorna Either<Failure, String>
```

### pickFromCamera()

**Plataformas:** iOS ✅ | Android ✅ | Web ⚠️ (limitado)

```dart
Future<Either<Failure, String>> captureFromCamera() async {
  try {
    final result = await _imageService.pickFromCamera();

    return result.fold(
      (failure) => Left(_mapImageFailure(failure, 'Erro ao capturar imagem da câmera')),
      (base64Image) {
        if (_isValidBase64Image(base64Image)) {
          return Right(base64Image);
        } else {
          return const Left(ValidationFailure('Imagem capturada inválida'));
        }
      },
    );
  } catch (e) {
    return Left(CacheFailure('Erro inesperado ao capturar imagem: $e'));
  }
}
```

**Configurações do image_picker:**

```dart
final XFile? image = await _picker.pickImage(
  source: ImageSource.camera,
  maxWidth: 1920,            // Largura máxima
  maxHeight: 1920,           // Altura máxima
  imageQuality: 85,          // Qualidade JPEG (0-100)
  preferredCameraDevice: CameraDevice.rear,  // Câmera traseira por padrão
);
```

### pickMultipleImages()

**Status:** ⚠️ Implementado no core, mas não usado no app atualmente

```dart
// packages/core/lib/src/infrastructure/services/image_service.dart
Future<Result<List<File>>> pickMultipleImages({int? maxImages}) async {
  final List<XFile> images = await _picker.pickMultiImage(
    maxWidth: config.maxWidth.toDouble(),
    maxHeight: config.maxHeight.toDouble(),
    imageQuality: config.imageQuality,
  );

  final maxCount = maxImages ?? config.maxImagesCount;
  final limitedImages = images.take(maxCount).toList();

  final List<File> files = [];
  for (final xFile in limitedImages) {
    final file = File(xFile.path);
    final validationResult = validateImage(file);
    if (validationResult.isError) {
      return Future.error(validationResult.error!);
    }
    files.add(file);
  }

  return files;
}
```

---

## 🌐 Suporte Multiplataforma

### Comparativo de Recursos

| Recurso | iOS | Android | Web | Observações |
|---------|-----|---------|-----|-------------|
| Galeria | ✅ 100% | ✅ 100% | ✅ 100% | Funciona perfeitamente |
| Câmera | ✅ 100% | ✅ 100% | ⚠️ Limitado | Web usa getUserMedia (HTTPS obrigatório) |
| Múltiplas imagens | ✅ | ✅ | ✅ | Todos suportam |
| Compressão | ✅ | ✅ | ✅ | Funciona em todos |
| Upload | ✅ | ✅ | ⚠️ CORS | Web precisa configuração Firebase |
| Cache local | ✅ | ✅ | ⚠️ Limitado | Web usa IndexedDB |

### iOS - Configuração

**Info.plist** (obrigatório):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>O Plantis precisa acessar suas fotos para você adicionar imagens das suas plantas</string>

<key>NSCameraUsageDescription</key>
<string>O Plantis precisa acessar a câmera para você fotografar suas plantas</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>O Plantis precisa salvar fotos das suas plantas na galeria</string>
```

**Comportamento:**
- Solicita permissão na primeira vez
- Se negado, mostra alerta direcionando para Settings
- Suporta Live Photos (convertido automaticamente)

### Android - Configuração

**AndroidManifest.xml**:

```xml
<!-- Permissões (Android 12 e anterior) -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                 android:maxSdkVersion="32" />

<!-- Android 13+ (Photo Picker) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**Comportamento:**
- Android 13+: Photo Picker nativo (sem permissão necessária)
- Android 12 e anterior: Solicita permissão runtime
- Scoped Storage automático

### Web - Configuração e Limitações

**CORS Configuration** (Firebase Storage):

```javascript
// cors.json
[
  {
    "origin": ["https://plantis.app", "http://localhost:5000"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600
  }
]

// Aplicar:
// gsutil cors set cors.json gs://your-bucket-name
```

**Limitações Web:**

```dart
// 1. Câmera requer HTTPS (exceto localhost)
// 2. Tamanho de arquivo limitado pelo browser
// 3. Sem acesso direto a File System
// 4. getUserMedia pode não funcionar em iframes

// Detecção de plataforma:
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Comportamento específico web
  showSnackbar('Câmera pode não funcionar em todos os navegadores');
} else {
  // Comportamento mobile
}
```

**Fallback para Web:**

```dart
Future<Either<Failure, String>> selectImageWeb() async {
  if (kIsWeb) {
    // Web: Sempre usar galeria (mais confiável)
    return selectFromGallery();
  } else {
    // Mobile: Oferecer opção câmera/galeria
    return showImageSourceDialog();
  }
}
```

---

## 🔧 Processamento de Imagens

### Conversão para Base64

**Por que Base64?**
- Temporário durante criação/edição de planta
- Permite preview sem upload
- Independente de plataforma
- Fácil transmissão JSON

```dart
// File → Base64 data URI
Future<String> fileToBase64DataUri(File file) async {
  final bytes = await file.readAsBytes();
  final base64String = base64Encode(bytes);
  final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

  return 'data:$mimeType;base64,$base64String';
}

// Exemplo de resultado:
// "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD..."
```

### Compressão Automática

**ImageCompressionService** (packages/core):

```dart
class ImageCompressionService {
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1920;
  static const int _quality = 80;
  static const int _maxFileSizeBytes = 2 * 1024 * 1024; // 2MB

  Future<Uint8List> compressImageBytes(Uint8List imageBytes) async {
    // 1. Decode
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // 2. Resize (mantendo aspect ratio)
    final resizedImage = _resizeImage(image);

    // 3. Encode to JPEG
    final compressedBytes = img.encodeJpg(resizedImage, quality: _quality);

    return Uint8List.fromList(compressedBytes);
  }

  img.Image _resizeImage(img.Image image) {
    int newWidth = image.width;
    int newHeight = image.height;

    if (newWidth > _maxWidth || newHeight > _maxHeight) {
      final aspectRatio = newWidth / newHeight;

      if (aspectRatio > 1) {
        // Landscape
        newWidth = _maxWidth;
        newHeight = (_maxWidth / aspectRatio).round();
      } else {
        // Portrait
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
}
```

**Tabela de Compressão:**

| Original | Dimensões | Tamanho | Comprimido | Redução |
|----------|-----------|---------|------------|---------|
| 4032x3024 | 12MP | 8.5 MB | 1920x1440 | 1.2 MB | 86% |
| 3264x2448 | 8MP | 6.2 MB | 1920x1440 | 1.1 MB | 82% |
| 2048x1536 | 3MP | 3.1 MB | 1920x1440 | 950 KB | 69% |
| 1920x1080 | 2MP | 1.8 MB | 1920x1080 | 800 KB | 56% |

### Validação de Formato

```dart
bool _isValidBase64Image(String base64Image) {
  if (base64Image.trim().isEmpty) return false;

  try {
    // 1. Verifica header data URI
    if (!base64Image.startsWith('data:image/')) {
      return false;
    }

    // 2. Verifica tamanho mínimo (100 bytes)
    if (base64Image.length < 100) {
      return false;
    }

    // 3. Verifica tamanho máximo (14MB para margem)
    const maxSizeBytes = 14 * 1024 * 1024;
    if (base64Image.length > maxSizeBytes) {
      return false;
    }

    return true;
  } catch (e) {
    return false;
  }
}
```

### Geração de Thumbnails

**EnhancedImageService:**

```dart
Future<Uint8List> generateThumbnail(Uint8List imageBytes) async {
  final image = img.decodeImage(imageBytes);
  if (image == null) throw Exception('Failed to decode image');

  final thumbnail = img.copyResize(
    image,
    width: 200,
    height: 200,
    interpolation: img.Interpolation.average,
  );

  return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 70));
}
```

---

## ☁️ Upload para Firebase Storage

### Estrutura de Pastas

```
Firebase Storage Root
└── plants/
    ├── {plantId_1}/
    │   └── images/
    │       ├── image_uuid_1.jpg
    │       ├── image_uuid_2.jpg
    │       └── image_uuid_3.jpg
    ├── {plantId_2}/
    │   └── images/
    │       └── image_uuid_4.jpg
    └── {plantId_3}/
        └── images/
            ├── image_uuid_5.jpg
            └── image_uuid_6.jpg
```

### Processo de Upload

```dart
// ImageService (packages/core)
Future<Result<ImageUploadResult>> uploadImage(
  File imageFile, {
  String? folder,
  String? fileName,
  UploadProgressCallback? onProgress,
}) async {
  try {
    // 1. Gera nome único se não fornecido
    final uploadFileName = fileName ?? '${_uuid.v4()}.jpg';

    // 2. Define folder (padrão: 'images')
    final uploadFolder = folder ?? config.defaultFolder;

    // 3. Cria referência no Storage
    final storageRef = _storage.ref().child('$uploadFolder/$uploadFileName');

    // 4. Prepara metadados
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
        'compressed': 'true',
      },
    );

    // 5. Upload com progress tracking
    final uploadTask = storageRef.putFile(imageFile, metadata);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    // 6. Aguarda conclusão
    await uploadTask;

    // 7. Obtém download URL
    final downloadUrl = await storageRef.getDownloadURL();

    // 8. Retorna resultado
    return Result.success(
      ImageUploadResult(
        downloadUrl: downloadUrl,
        fileName: uploadFileName,
        folder: uploadFolder,
        uploadedAt: DateTime.now(),
      ),
    );
  } catch (e, stackTrace) {
    return Result.error(
      StorageError(
        message: 'Erro ao fazer upload: ${e.toString()}',
        code: 'UPLOAD_ERROR',
        details: e.toString(),
        stackTrace: stackTrace,
      ),
    );
  }
}
```

### Upload Múltiplo

```dart
// ImageManagementService
Future<Either<Failure, List<String>>> uploadImages(List<String> base64Images) async {
  if (base64Images.isEmpty) {
    return const Right([]);
  }

  try {
    // 1. Valida todas as imagens
    for (final image in base64Images) {
      if (!_isValidBase64Image(image)) {
        return const Left(ValidationFailure('Uma ou mais imagens são inválidas'));
      }
    }

    // 2. Converte Base64 → File temporário
    final tempFiles = <File>[];
    for (int i = 0; i < base64Images.length; i++) {
      final base64 = base64Images[i].split(',').last;
      final bytes = base64Decode(base64);
      final tempFile = File('${Directory.systemTemp.path}/temp_$i.jpg');
      await tempFile.writeAsBytes(bytes);
      tempFiles.add(tempFile);
    }

    // 3. Upload de todos os arquivos
    final result = await _imageService.uploadImages(tempFiles.map((f) => f.path).toList());

    // 4. Limpa arquivos temporários
    for (final file in tempFiles) {
      try {
        await file.delete();
      } catch (_) {}
    }

    return result.fold(
      (failure) => Left(_mapImageFailure(failure, 'Erro ao enviar imagens')),
      (imageUrls) => Right(imageUrls),
    );
  } catch (e) {
    return Left(NetworkFailure('Erro inesperado no upload: $e'));
  }
}
```

### Retry Logic

```dart
Future<Either<Failure, String>> uploadWithRetry(
  File imageFile, {
  int maxRetries = 3,
}) async {
  int attempt = 0;

  while (attempt < maxRetries) {
    final result = await uploadImage(imageFile);

    if (result.isRight()) {
      return result;
    }

    attempt++;
    if (attempt < maxRetries) {
      // Exponential backoff
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
  }

  return Left(NetworkFailure('Falha após $maxRetries tentativas'));
}
```

---

## 💾 Armazenamento

### Fluxo de Dados

```
┌──────────────────────────────────────────────────────┐
│  FASE 1: Criação/Edição (Offline-first)             │
├──────────────────────────────────────────────────────┤
│  User seleciona imagem                               │
│    ↓                                                 │
│  File → Base64 data URI                              │
│    ↓                                                 │
│  Armazenado em memória (PlantFormState.imageUrls)   │
│    ↓                                                 │
│  Preview na UI                                       │
└──────────────────────────────────────────────────────┘
                        ↓ User salva planta
┌──────────────────────────────────────────────────────┐
│  FASE 2: Upload (se online)                          │
├──────────────────────────────────────────────────────┤
│  Base64 → Bytes → File temporário                    │
│    ↓                                                 │
│  Compressão (se necessário)                          │
│    ↓                                                 │
│  Upload para Firebase Storage                        │
│    ↓                                                 │
│  Obtém download URL                                  │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  FASE 3: Persistência                                │
├──────────────────────────────────────────────────────┤
│  Plant.imageUrls = [downloadUrl1, downloadUrl2]      │
│    ↓                                                 │
│  Salva no Hive (local)                               │
│    ↓                                                 │
│  Sincroniza com Firestore (remote)                   │
└──────────────────────────────────────────────────────┘
```

### Local Storage (Hive)

```dart
// Plant model em Hive
{
  "id": "plant_abc123",
  "name": "Samambaia",
  "imageUrls": [
    "https://firebasestorage.googleapis.com/.../image_1.jpg",
    "https://firebasestorage.googleapis.com/.../image_2.jpg"
  ],
  // ... outros campos
}
```

### Remote Storage (Firestore + Firebase Storage)

**Firestore** (metadados):

```javascript
// users/{userId}/plants/{plantId}
{
  "id": "plant_abc123",
  "name": "Samambaia",
  "imageUrls": [
    "https://firebasestorage.googleapis.com/.../image_1.jpg",
    "https://firebasestorage.googleapis.com/.../image_2.jpg"
  ],
  "createdAt": 1704672000000,
  "updatedAt": 1704672000000
}
```

**Firebase Storage** (arquivos):

```
plants/plant_abc123/images/image_uuid_1.jpg  (1.2 MB)
plants/plant_abc123/images/image_uuid_2.jpg  (950 KB)
```

### Cache Strategy

**Enhanced Cache Manager:**

```dart
class EnhancedImageCacheManager {
  final Map<String, Uint8List> _memoryCache = {};
  final Directory _diskCacheDir;

  // 1. Memory cache (rápido, limitado)
  Uint8List? getFromMemory(String key) {
    return _memoryCache[key];
  }

  void saveToMemory(String key, Uint8List bytes) {
    _memoryCache[key] = bytes;
  }

  // 2. Disk cache (persistente)
  Future<Uint8List?> getFromDisk(String key) async {
    final file = File('${_diskCacheDir.path}/$key');
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  Future<void> saveToDisk(String key, Uint8List bytes) async {
    final file = File('${_diskCacheDir.path}/$key');
    await file.writeAsBytes(bytes);
  }

  // 3. Estratégia de busca em cascata
  Future<Uint8List?> get(String url) async {
    final key = _generateCacheKey(url);

    // 1. Tenta memory cache (0-1ms)
    var bytes = getFromMemory(key);
    if (bytes != null) return bytes;

    // 2. Tenta disk cache (10-50ms)
    bytes = await getFromDisk(key);
    if (bytes != null) {
      saveToMemory(key, bytes);  // Promove para memory
      return bytes;
    }

    // 3. Faz download e cacheia (500-2000ms)
    bytes = await _downloadImage(url);
    if (bytes != null) {
      saveToMemory(key, bytes);
      await saveToDisk(key, bytes);
    }

    return bytes;
  }
}
```

---

## 📋 Gerenciamento de Lista

### addImageToList()

```dart
ImageListResult addImageToList(List<String> currentImages, String newImage) {
  const maxImages = 5;

  // 1. Verifica limite
  if (currentImages.length >= maxImages) {
    return ImageListResult.error(
      'Máximo de $maxImages imagens permitidas por planta',
      currentImages,
    );
  }

  // 2. Verifica duplicata
  if (currentImages.contains(newImage)) {
    return ImageListResult.error(
      'Esta imagem já foi adicionada',
      currentImages,
    );
  }

  // 3. Adiciona
  final updatedList = List<String>.from(currentImages)..add(newImage);

  return ImageListResult.success(
    'Imagem adicionada com sucesso',
    updatedList,
  );
}
```

**Uso na UI:**

```dart
Future<void> _addImage(String base64Image) async {
  final formState = ref.read(plantFormStateProvider);

  final result = imageManagementService.addImageToList(
    formState.imageUrls,
    base64Image,
  );

  if (result.isSuccess) {
    ref.read(plantFormStateProvider.notifier).updateImages(result.updatedImages);
    showSnackbar(result.message);
  } else {
    showErrorSnackbar(result.message);
  }
}
```

### removeImageFromList()

```dart
ImageListResult removeImageFromList(List<String> currentImages, int index) {
  // 1. Valida índice
  if (index < 0 || index >= currentImages.length) {
    return ImageListResult.error(
      'Índice da imagem inválido',
      currentImages,
    );
  }

  // 2. Remove
  final updatedList = List<String>.from(currentImages)..removeAt(index);

  return ImageListResult.success(
    'Imagem removida com sucesso',
    updatedList,
  );
}
```

### deleteImage() - Firebase Storage

```dart
Future<Either<Failure, void>> deleteImage(String imageUrl) async {
  if (imageUrl.trim().isEmpty) {
    return const Left(ValidationFailure('URL da imagem é obrigatória'));
  }

  try {
    // 1. Extrai caminho do Storage da URL
    // URL: https://firebasestorage.googleapis.com/.../plants%2Fabc%2Fimage.jpg?...
    // Path: plants/abc/image.jpg
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final encodedPath = pathSegments.last;
    final decodedPath = Uri.decodeComponent(encodedPath);

    // 2. Deleta do Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child(decodedPath);
    await storageRef.delete();

    return const Right(null);
  } catch (e) {
    return Left(NetworkFailure('Erro ao deletar imagem: $e'));
  }
}
```

---

## ⚡ Otimização e Performance

### Lazy Loading

```dart
class OptimizedPlantImageWidget extends StatelessWidget {
  final String imageUrl;

  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _cacheManager.get(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget();
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          cacheWidth: 400,  // Decode apenas no tamanho necessário
        );
      },
    );
  }
}
```

### Progressive Loading

```dart
Widget _buildProgressiveImage(String imageUrl) {
  return Stack(
    children: [
      // 1. Blur placeholder (carrega primeiro)
      Image.memory(
        thumbnailBytes,
        fit: BoxFit.cover,
        colorBlendMode: BlendMode.dstATop,
        color: Colors.grey.withOpacity(0.5),
      ),

      // 2. Imagem full (carrega depois)
      FadeInImage.memoryNetwork(
        placeholder: thumbnailBytes,
        image: imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration(milliseconds: 300),
      ),
    ],
  );
}
```

### Preloading

```dart
class ImagePreloaderService {
  Future<void> preloadPlantImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      // Baixa e cacheia em background
      unawaited(_cacheManager.get(url));
    }
  }
}

// Uso ao abrir lista de plantas:
@override
void initState() {
  super.initState();
  final plants = ref.read(plantsProvider);
  final allImageUrls = plants.expand((p) => p.imageUrls).toList();
  imagePreloaderService.preloadPlantImages(allImageUrls);
}
```

### Memory Management

```dart
class ImageMemoryManager {
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  int _currentCacheSize = 0;

  void addToCache(String key, Uint8List bytes) {
    final bytesSize = bytes.lengthInBytes;

    // Evict LRU se necessário
    while (_currentCacheSize + bytesSize > _maxCacheSize) {
      _evictLeastRecentlyUsed();
    }

    _memoryCache[key] = CacheEntry(
      bytes: bytes,
      lastAccessed: DateTime.now(),
    );
    _currentCacheSize += bytesSize;
  }

  void _evictLeastRecentlyUsed() {
    if (_memoryCache.isEmpty) return;

    final oldest = _memoryCache.entries
        .reduce((a, b) => a.value.lastAccessed.isBefore(b.value.lastAccessed) ? a : b);

    _currentCacheSize -= oldest.value.bytes.lengthInBytes;
    _memoryCache.remove(oldest.key);
  }
}
```

---

## 🔒 Validações e Segurança

### Validação de MIME Type

```dart
Result<File> validateImage(File file) {
  // 1. Verifica se arquivo existe
  if (!file.existsSync()) {
    return Result.error(ValidationError(message: 'Arquivo não encontrado'));
  }

  // 2. Detecta MIME type
  final mimeType = lookupMimeType(file.path);
  if (mimeType == null) {
    return Result.error(ValidationError(message: 'Tipo de arquivo desconhecido'));
  }

  // 3. Verifica se é imagem
  if (!mimeType.startsWith('image/')) {
    return Result.error(ValidationError(message: 'Arquivo não é uma imagem'));
  }

  // 4. Verifica formato permitido
  final allowedFormats = ['image/jpeg', 'image/png', 'image/webp', 'image/heic'];
  if (!allowedFormats.contains(mimeType)) {
    return Result.error(ValidationError(
      message: 'Formato não suportado. Use JPG, PNG, WEBP ou HEIC',
    ));
  }

  return Result.success(file);
}
```

### Validação de Tamanho

```dart
Result<File> validateFileSize(File file) {
  final fileStat = file.statSync();
  final sizeInBytes = fileStat.size;
  final sizeInMB = sizeInBytes / (1024 * 1024);

  const maxSizeMB = 10;

  if (sizeInMB > maxSizeMB) {
    return Result.error(ValidationError(
      message: 'Imagem muito grande (${sizeInMB.toStringAsFixed(1)}MB). Máximo: ${maxSizeMB}MB',
    ));
  }

  return Result.success(file);
}
```

### Sanitização de Nome de Arquivo

```dart
String sanitizeFileName(String fileName) {
  // Remove caracteres perigosos
  var sanitized = fileName
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')  // Caracteres inválidos
      .replaceAll(RegExp(r'\.\.'), '_')          // Path traversal
      .replaceAll(RegExp(r'\s+'), '_');          // Espaços

  // Limita tamanho
  if (sanitized.length > 100) {
    final ext = path.extension(sanitized);
    sanitized = sanitized.substring(0, 100 - ext.length) + ext;
  }

  return sanitized;
}
```

### Rate Limiting

```dart
class UploadRateLimiter {
  final Map<String, List<DateTime>> _uploadAttempts = {};
  static const maxUploadsPerMinute = 10;

  bool canUpload(String userId) {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));

    // Remove tentativas antigas
    _uploadAttempts[userId]?.removeWhere((time) => time.isBefore(oneMinuteAgo));

    final recentAttempts = _uploadAttempts[userId]?.length ?? 0;

    if (recentAttempts >= maxUploadsPerMinute) {
      return false;
    }

    // Registra tentativa
    _uploadAttempts[userId] = (_uploadAttempts[userId] ?? [])..add(now);

    return true;
  }
}
```

---

## 🎨 UI/UX

### PlantFormBasicInfo - Seleção de Imagem

**Layout:**

```
┌────────────────────────────────────────────────┐
│  Foto da Planta                           [X]  │  ← Se tem imagem
├────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────┐ │
│  │                                          │ │
│  │         [Imagem da planta]               │ │
│  │           120px height                   │ │
│  │                                          │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘

                    OU

┌────────────────────────────────────────────────┐
│  [📷] Adicionar Foto                          │  ← Se NÃO tem imagem
│                                                │
│  Toque para escolher uma imagem da sua planta  │
└────────────────────────────────────────────────┘
```

**Código (plant_form_basic_info.dart:93-165):**

```dart
Widget _buildImageSection(BuildContext context) {
  final formState = ref.watch(solidPlantFormStateProvider);
  final formManager = ref.read(solidPlantFormStateManagerProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (formState.isUploadingImages)
        _buildUploadProgress(context)
      else if (formState.imageUrls.isNotEmpty)
        _buildSingleImage(context, formState, formManager)
      else
        _buildEmptyImageArea(context, formManager),
    ],
  );
}

Widget _buildEmptyImageArea(
  BuildContext context,
  PlantFormStateManager formManager,
) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: InkWell(
      onTap: () => _showImageOptions(context, formManager),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_photo_alternate,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicionar Foto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque para escolher uma imagem da sua planta',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Dialog de Opções (Câmera/Galeria)

```dart
void _showImageOptions(BuildContext context, PlantFormStateManager formManager) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Escolher da Galeria'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromGallery(formManager);
              },
            ),
            if (!kIsWeb)  // Câmera apenas mobile
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tirar Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromCamera(formManager);
                },
              ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}
```

### Loading States

```dart
Widget _buildUploadProgress(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text('Enviando imagem...'),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: _uploadProgress,  // 0.0 - 1.0
        ),
      ],
    ),
  );
}
```

---

## ✅ Estado da Implementação

### 100% Implementado

#### 1. ImageManagementService ✅

**Arquivo:** `apps/app-plantis/lib/core/services/image_management_service.dart` (396 linhas)

- [x] captureFromCamera()
- [x] selectFromGallery()
- [x] addImageToList()
- [x] removeImageFromList()
- [x] removeSpecificImage()
- [x] uploadImages()
- [x] deleteImage()
- [x] getImageListInfo()
- [x] validateImageList()
- [x] Validação de Base64
- [x] Limite de 5 imagens

#### 2. ImageService (Core) ✅

**Arquivo:** `packages/core/lib/src/infrastructure/services/image_service.dart`

- [x] pickImageFromGallery()
- [x] pickImageFromCamera()
- [x] pickMultipleImages()
- [x] uploadImage()
- [x] validateImage()
- [x] Configuração flexível

#### 3. ImageCompressionService ✅

**Arquivo:** `packages/core/lib/services/image_compression_service.dart`

- [x] compressImage()
- [x] compressImageBytes()
- [x] Resize mantendo aspect ratio
- [x] Encode to JPEG
- [x] Validação de tamanho

#### 4. UI de Seleção ✅

**Arquivo:** `apps/app-plantis/lib/features/plants/presentation/widgets/plant_form_basic_info.dart`

- [x] Empty state (área clicável)
- [x] Preview de imagem
- [x] Botão de remover
- [x] Dialog de opções

### 80% Implementado (Funcional, mas incompleto)

#### 5. EnhancedImageService ⚠️

**Status:** Implementado mas não utilizado

**Arquivo:** `packages/core/lib/src/infrastructure/services/enhanced_image_service.dart`

**Implementado:**
- [x] Cache management (memory + disk)
- [x] Thumbnail generation
- [x] Compression

**Pendente:**
- [ ] Integração com ImageManagementService
- [ ] Uso efetivo do cache em produção

#### 6. Upload para Firebase Storage ⚠️

**Status:** Implementado mas sem retry logic robusto

**Implementado:**
- [x] Upload simples funcional
- [x] Obtenção de download URL
- [x] Metadados customizados

**Pendente:**
- [ ] Retry logic com exponential backoff
- [ ] Progress tracking na UI
- [ ] Cancelamento de upload
- [ ] Queue de uploads offline

#### 7. Suporte Web ⚠️

**Status:** Parcialmente funcional

**Implementado:**
- [x] Galeria funciona
- [x] Upload funciona (com CORS configurado)

**Pendente:**
- [ ] Câmera web (getUserMedia)
- [ ] CORS configuration automática
- [ ] Fallbacks para navegadores antigos

### 50% Implementado (Parcial)

#### 8. Múltiplas Imagens ⚠️

**Status:** Backend pronto, UI não implementada

**Implementado:**
- [x] pickMultipleImages() no core
- [x] Upload de múltiplas imagens

**Pendente:**
- [ ] UI para seleção múltipla
- [ ] Grid de preview de múltiplas imagens
- [ ] Reordenação de imagens (drag & drop)

#### 9. Cache Avançado 🟡

**Status:** Implementado mas não otimizado

**Implementado:**
- [x] Memory cache básico
- [x] Disk cache

**Pendente:**
- [ ] LRU eviction policy
- [ ] Cache size limits
- [ ] Cache warming (preload)
- [ ] Cache metrics

### Não Implementado (0%)

#### 10. Crop de Imagens ❌

**Objetivo:** Permitir usuário recortar imagem antes de salvar

**Biblioteca Sugerida:** `image_cropper ^5.0.0`

```dart
Future<File?> cropImage(File imageFile) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),  // Quadrado
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Recortar Imagem',
        toolbarColor: Colors.green,
      ),
      IOSUiSettings(
        title: 'Recortar Imagem',
      ),
    ],
  );

  return croppedFile != null ? File(croppedFile.path) : null;
}
```

**Estimativa:** 6-8 horas

#### 11. Filtros e Edição ❌

**Objetivo:** Aplicar filtros (brightness, contrast, saturation)

**Implementação:**

```dart
Future<Uint8List> applyFilter(Uint8List imageBytes, ImageFilter filter) async {
  final image = img.decodeImage(imageBytes);

  switch (filter) {
    case ImageFilter.brightness:
      return img.adjustColor(image, brightness: 1.2);
    case ImageFilter.contrast:
      return img.adjustColor(image, contrast: 1.3);
    case ImageFilter.saturation:
      return img.adjustColor(image, saturation: 1.5);
  }
}
```

**Estimativa:** 8-12 horas

#### 12. Múltiplos Uploads Simultâneos ❌

**Objetivo:** Upload paralelo de várias imagens com progress tracking

```dart
Future<List<ImageUploadResult>> uploadMultipleConcurrent(
  List<File> files,
  Function(int completed, int total) onProgress,
) async {
  final results = <ImageUploadResult>[];
  int completed = 0;

  await Future.wait(
    files.map((file) async {
      final result = await uploadImage(file);
      completed++;
      onProgress(completed, files.length);
      results.add(result);
    }),
  );

  return results;
}
```

**Estimativa:** 4-6 horas

#### 13. Image Gallery Viewer ❌

**Objetivo:** Visualizar imagens em fullscreen com zoom

**Biblioteca:** `photo_view ^0.14.0`

```dart
class ImageGalleryPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(initialPage: initialIndex),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return PhotoView(
          imageProvider: NetworkImage(imageUrls[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
    );
  }
}
```

**Estimativa:** 4-6 horas

---

## 🔄 Fluxos Críticos

### Fluxo 1: Selecionar da Galeria → Upload → Salvar

```
User está criando nova planta
  ↓
Toca em "Adicionar Foto"
  ↓
Dialog aparece: [Galeria] [Câmera] [Cancelar]
  ↓
User seleciona "Galeria"
  ↓
OS abre Photo Picker nativo
  ↓
User seleciona imagem
  ↓
image_picker retorna XFile
  ↓
ImageService.pickImageFromGallery()
  ├─ Valida formato (JPEG/PNG/WEBP)
  ├─ Valida tamanho (<10MB)
  └─ File → Bytes → Base64
  ↓
ImageServiceAdapter converte
  └─ Base64 data URI: "data:image/jpeg;base64,..."
  ↓
ImageManagementService.selectFromGallery()
  ├─ Valida Base64
  └─ Retorna Either<Failure, String>
  ↓
PlantFormStateManager atualiza estado
  └─ PlantFormState.imageUrls = [base64DataUri]
  ↓
UI atualiza (preview da imagem aparece)
  ↓
[User preenche outros campos e salva]
  ↓
PlantFormStateManager.savePlant()
  ├─ 1. Base64 → Bytes → File temporário
  ├─ 2. Compressão (1920x1920, quality 85)
  ├─ 3. Upload para Firebase Storage
  │    └─ plants/{plantId}/images/{uuid}.jpg
  ├─ 4. Obtém download URL
  │    └─ https://firebasestorage.googleapis.com/.../image.jpg
  ├─ 5. Plant.imageUrls = [downloadUrl]
  ├─ 6. Salva em Hive (local)
  └─ 7. Sincroniza com Firestore
  ↓
✅ Planta salva com imagem
```

### Fluxo 2: Capturar da Câmera

```
User toca "Tirar Foto"
  ↓
image_picker.pickImage(source: ImageSource.camera)
  ↓
OS solicita permissão de câmera (se primeira vez)
  ├─ iOS: NSCameraUsageDescription
  └─ Android: CAMERA permission
  ↓
User concede permissão
  ↓
Câmera nativa abre
  ↓
User captura foto
  ↓
Foto é processada (resize automático pelo plugin)
  ↓
XFile retornado com foto
  ↓
[Mesmo fluxo de processamento da galeria]
  ├─ Validação
  ├─ Base64 conversion
  ├─ Preview
  └─ Upload ao salvar
```

### Fluxo 3: Remover Imagem

```
User visualiza planta com imagem
  ↓
Toca no [X] para remover
  ↓
Dialog de confirmação (opcional)
  ↓
User confirma remoção
  ↓
ImageManagementService.removeImageFromList(index: 0)
  ├─ Valida índice
  └─ Remove da lista
  ↓
PlantFormStateManager atualiza
  └─ PlantFormState.imageUrls = []
  ↓
UI atualiza (volta para empty state)
  ↓
[Se for imagem já salva no Firebase]
  ↓
ImageManagementService.deleteImage(imageUrl)
  ├─ Extrai path do Storage da URL
  ├─ FirebaseStorage.ref(path).delete()
  └─ Arquivo deletado do Storage
  ↓
PlantRepository.updatePlant()
  ├─ Atualiza Hive
  └─ Sincroniza Firestore
  ↓
✅ Imagem removida
```

---

## ❗ Gaps e Pendências

### 🔴 Críticos

#### GAP-001: Sem retry logic robusto no upload

**Problema:** Upload falha se conexão cair durante processo

**Impacto:** Alto - Usuário perde imagem se conexão instável

**Solução:**

```dart
Future<Either<Failure, String>> uploadWithRetry(
  File imageFile, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 2),
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (attempt < maxRetries) {
    final result = await uploadImage(imageFile);

    if (result.isRight()) {
      return result;
    }

    attempt++;
    if (attempt < maxRetries) {
      await Future.delayed(delay);
      delay *= 2;  // Exponential backoff
    }
  }

  return Left(NetworkFailure('Upload falhou após $maxRetries tentativas'));
}
```

**Estimativa:** 4 horas
**Prioridade:** Alta

#### GAP-002: CORS não configurado automaticamente para web

**Problema:** Web apps precisam configuração manual do Firebase Storage CORS

**Impacto:** Alto - Upload não funciona no web sem configuração manual

**Solução:**

```bash
# cors.json
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600
  }
]

# Aplicar:
gsutil cors set cors.json gs://your-bucket-name
```

**Documentação:** Adicionar no README do projeto

**Estimativa:** 2 horas (documentação + script)
**Prioridade:** Alta

#### GAP-003: Sem tratamento de imagens órfãs no Storage

**Problema:** Se upload falha após salvar no Storage, imagem fica órfã

**Impacto:** Médio - Desperdício de storage, custos desnecessários

**Solução:**

```dart
// Cloud Function para limpar imagens órfãs
exports.cleanOrphanImages = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const storage = admin.storage().bucket();
    const firestore = admin.firestore();

    // 1. Lista todas as imagens no Storage
    const [files] = await storage.getFiles({ prefix: 'plants/' });

    // 2. Para cada imagem, verifica se está em alguma planta
    for (const file of files) {
      const imageUrl = file.publicUrl();
      const plantsSnapshot = await firestore
        .collectionGroup('plants')
        .where('imageUrls', 'array-contains', imageUrl)
        .get();

      // 3. Se não está em nenhuma planta, deleta
      if (plantsSnapshot.empty) {
        await file.delete();
        console.log(`Deleted orphan image: ${file.name}`);
      }
    }
  });
```

**Estimativa:** 6 horas
**Prioridade:** Média

### 🟡 Importantes

#### GAP-004: Sem progress tracking na UI

**Problema:** Usuário não vê progresso do upload

**Impacto:** Médio - UX ruim, usuário não sabe se está travado

**Solução:**

```dart
class PlantFormState {
  final double uploadProgress;  // 0.0 - 1.0
  final bool isUploadingImages;
}

// No upload:
final uploadTask = storageRef.putFile(imageFile);

uploadTask.snapshotEvents.listen((snapshot) {
  final progress = snapshot.bytesTransferred / snapshot.totalBytes;
  ref.read(plantFormStateProvider.notifier).updateUploadProgress(progress);
});
```

**Estimativa:** 3 horas
**Prioridade:** Média

#### GAP-005: Cache não está sendo usado efetivamente

**Problema:** EnhancedImageService implementado mas não integrado

**Impacto:** Médio - Performance pior do que poderia ser

**Solução:**

```dart
// Integrar cache no ImageManagementService
class ImageManagementService {
  final EnhancedImageService _cacheService;

  Future<Uint8List?> getCachedImage(String url) async {
    return await _cacheService.get(url);
  }
}

// Uso no widget:
FutureBuilder<Uint8List?>(
  future: imageManagementService.getCachedImage(imageUrl),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Image.memory(snapshot.data!);
    }
    return CircularProgressIndicator();
  },
)
```

**Estimativa:** 4 horas
**Prioridade:** Média

#### GAP-006: Sem validação server-side

**Problema:** Validações apenas client-side, podem ser bypassadas

**Impacto:** Médio - Risco de segurança

**Solução:**

```javascript
// Cloud Function
exports.validateImageUpload = functions.storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;

    // Valida content type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(contentType)) {
      await admin.storage().bucket().file(filePath).delete();
      throw new Error('Invalid file type');
    }

    // Valida tamanho
    const sizeInMB = parseInt(object.size) / (1024 * 1024);
    if (sizeInMB > 10) {
      await admin.storage().bucket().file(filePath).delete();
      throw new Error('File too large');
    }
  });
```

**Estimativa:** 5 horas
**Prioridade:** Média

### 🟢 Desejáveis

#### GAP-007: Sem crop de imagens

**Estimativa:** 6-8 horas
**Biblioteca:** image_cropper

#### GAP-008: Sem múltipla seleção na UI

**Estimativa:** 8-10 horas

#### GAP-009: Sem image viewer fullscreen

**Estimativa:** 4-6 horas
**Biblioteca:** photo_view

---

## ⚠️ Problemas Conhecidos

### 1. Câmera no Web

**Problema:** `pickImage(source: ImageSource.camera)` não funciona bem no web

**Causa:** Depende de getUserMedia API, suporte varia por navegador

**Workaround:**

```dart
if (kIsWeb) {
  // Força uso de galeria
  return pickFromGallery();
} else {
  return pickFromCamera();
}
```

### 2. CORS no Firebase Storage (Web)

**Problema:** Cross-Origin Resource Sharing precisa configuração manual

**Solução:** Documentado em GAP-002

### 3. Permissões iOS

**Problema:** App crasha se não tiver Info.plist configurado

**Solução:**

Adicionar ao `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos</string>

<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera</string>
```

### 4. Tamanho de imagem no Web

**Problema:** Browsers limitam tamanho de imagens que podem ser processadas

**Causa:** Memory constraints

**Solução:**

```dart
if (kIsWeb) {
  // Reduz qualidade para web
  return pickImage(
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 75,
  );
}
```

### 5. Base64 é ineficiente para grandes imagens

**Problema:** Base64 aumenta tamanho em ~33%

**Causa:** Encoding overhead

**Solução:**

```dart
// Usar File path em vez de Base64 quando possível
class PlantFormState {
  final List<String> imageUrls;      // URLs permanentes
  final List<String> pendingPaths;   // Caminhos temporários
}
```

---

## 💡 Recomendações

### Performance

1. **Implementar cache warming**

```dart
// Preload ao abrir lista de plantas
Future<void> warmCache(List<Plant> plants) async {
  final allUrls = plants.expand((p) => p.imageUrls).toList();

  for (final url in allUrls) {
    unawaited(cacheManager.get(url));
  }
}
```

2. **Lazy load em listas**

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return OptimizedPlantImageWidget(
      imageUrl: plants[index].primaryImage,
      cacheWidth: 400,  // Decode apenas tamanho necessário
    );
  },
)
```

3. **Usar thumbnails em listas**

```dart
// Gerar thumbnail 200x200 no upload
final thumbnail = await generateThumbnail(imageBytes);
await uploadImage(thumbnail, fileName: 'thumb_$uuid.jpg');

plant.thumbnailUrl = thumbnailDownloadUrl;
```

### UX

1. **Adicionar crop antes de salvar**

```dart
Future<File?> cropBeforeUpload(File imageFile) async {
  final cropped = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
  );
  return cropped != null ? File(cropped.path) : imageFile;
}
```

2. **Feedback visual durante upload**

```dart
Stack(
  children: [
    Image.memory(imageBytes),
    if (isUploading)
      Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: uploadProgress),
            Text('${(uploadProgress * 100).toInt()}%'),
          ],
        ),
      ),
  ],
)
```

3. **Undo após remoção**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Imagem removida'),
    action: SnackBarAction(
      label: 'Desfazer',
      onPressed: () => restoreImage(),
    ),
    duration: Duration(seconds: 3),
  ),
);
```

### Segurança

1. **Rate limiting server-side**

```javascript
// Cloud Function
const rateLimit = new Map();

exports.checkUploadRate = functions.https.onCall((data, context) => {
  const uid = context.auth.uid;
  const now = Date.now();
  const userUploads = rateLimit.get(uid) || [];

  // Remove uploads antigos (>1 minuto)
  const recentUploads = userUploads.filter(time => now - time < 60000);

  if (recentUploads.length >= 10) {
    throw new Error('Too many uploads. Please wait.');
  }

  rateLimit.set(uid, [...recentUploads, now]);
});
```

2. **Validar imagem server-side**

```javascript
// Usar Sharp para validar que é realmente uma imagem
const sharp = require('sharp');

try {
  const metadata = await sharp(buffer).metadata();
  // É uma imagem válida
} catch (error) {
  // Não é uma imagem ou está corrompida
  throw new Error('Invalid image file');
}
```

### Testes

```dart
// test/features/plants/services/image_management_service_test.dart
void main() {
  group('ImageManagementService', () {
    test('should add image to list successfully', () {
      final service = ImageManagementService.create();
      final result = service.addImageToList(
        ['image1.jpg'],
        'image2.jpg',
      );

      expect(result.isSuccess, true);
      expect(result.updatedImages.length, 2);
    });

    test('should reject when limit exceeded', () {
      final service = ImageManagementService.create();
      final result = service.addImageToList(
        ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.jpg'],
        '6.jpg',
      );

      expect(result.isError, true);
      expect(result.message, contains('Máximo de 5 imagens'));
    });

    test('should validate Base64 images', () async {
      final service = ImageManagementService.create();
      final validation = service.validateImageList([
        'data:image/jpeg;base64,/9j/4AAQ...',
        'invalid-data',
      ]);

      expect(validation.isValid, false);
      expect(validation.errors.length, 1);
    });
  });
}
```

---

## 🗺️ Roadmap

### Fase 1: Completar Funcionalidades Críticas (1-2 semanas)

**Prioridade:** Alta

- [ ] **[GAP-001]** Retry logic robusto (4h)
- [ ] **[GAP-002]** Documentar CORS setup (2h)
- [ ] **[GAP-004]** Progress tracking UI (3h)
- [ ] **[GAP-005]** Integrar cache (4h)
- [ ] Testes unitários (8h)

**Total:** 21 horas (~3 dias úteis)

### Fase 2: Suporte Web Completo (1 semana)

**Prioridade:** Média

- [ ] Testar e corrigir câmera web
- [ ] CORS configuration script
- [ ] Fallbacks para browsers antigos
- [ ] Web-specific optimizations

**Total:** 16 horas (~2 dias úteis)

### Fase 3: Edição de Imagens (1 semana)

**Prioridade:** Baixa/Média

- [ ] **[GAP-007]** Crop de imagens (8h)
- [ ] **[GAP-011]** Filtros básicos (12h)
- [ ] UI de edição (6h)

**Total:** 26 horas (~3 dias úteis)

### Fase 4: Features Avançadas (1-2 semanas)

**Prioridade:** Baixa

- [ ] **[GAP-008]** Múltipla seleção (10h)
- [ ] **[GAP-009]** Image viewer fullscreen (6h)
- [ ] **[GAP-012]** Uploads simultâneos (6h)
- [ ] Reordenação drag & drop (8h)

**Total:** 30 horas (~4 dias úteis)

---

## 📝 Atualizações e Tarefas

### Log de Atualizações

#### v1.0 - 07/10/2025
- ✅ Documento inicial criado
- ✅ Análise completa da implementação
- ✅ 9 gaps identificados
- ✅ 5 problemas conhecidos documentados
- ✅ Roadmap de 4 fases definido

---

### Tarefas Prioritárias

#### 🔴 Imediato (Esta Semana)

1. **[IMAG-001] Implementar retry logic no upload**
   - **Estimativa:** 4 horas
   - **Responsável:** TBD
   - **Arquivo:** `image_service.dart`
   - **Critério:** Upload com 3 tentativas + exponential backoff

2. **[IMAG-002] Documentar setup CORS**
   - **Estimativa:** 2 horas
   - **Responsável:** TBD
   - **Deliverable:** Script + README
   - **Critério:** Web upload funcionando após seguir doc

3. **[IMAG-003] Progress tracking na UI**
   - **Estimativa:** 3 horas
   - **Responsável:** TBD
   - **Arquivo:** `plant_form_basic_info.dart`
   - **Critério:** Progress bar visível durante upload

#### 🟡 Próximas 2 Semanas

4. **[IMAG-004] Integrar EnhancedImageService**
   - **Estimativa:** 4 horas
   - **Objetivo:** Cache efetivo em produção

5. **[IMAG-005] Testes unitários**
   - **Estimativa:** 8 horas
   - **Cobertura:** ≥80% ImageManagementService

6. **[IMAG-006] Validação server-side**
   - **Estimativa:** 5 horas
   - **Cloud Function** para validar uploads

#### 🟢 Backlog

7. **[IMAG-007]** Crop de imagens
8. **[IMAG-008]** Múltipla seleção
9. **[IMAG-009]** Image viewer fullscreen
10. **[IMAG-010]** Filtros e edição

---

### KPIs

#### Técnicos

| Métrica | Atual | Meta |
|---------|-------|------|
| Cobertura de testes | ~0% | ≥80% |
| Taxa de sucesso upload | ~85% | ≥98% |
| Tempo médio upload | ~3s | <2s |
| Taxa de erro | ~15% | <2% |
| Cache hit rate | ~0% | ≥60% |

#### UX

| Métrica | Atual | Meta |
|---------|-------|------|
| Usuários com imagem | ~40% | ≥70% |
| Imagens por planta | ~0.8 | ≥2.0 |
| Taxa de abandono durante upload | ~20% | <5% |
| Satisfação (NPS) | - | ≥8 |

---

## 📚 Referências

### Documentação Oficial

- [image_picker](https://pub.dev/packages/image_picker)
- [Firebase Storage Flutter](https://firebase.google.com/docs/storage/flutter/start)
- [image package](https://pub.dev/packages/image)
- [mime](https://pub.dev/packages/mime)

### Arquivos do Projeto

- `apps/app-plantis/lib/core/services/image_management_service.dart` - Service principal (396 linhas)
- `packages/core/lib/src/infrastructure/services/image_service.dart` - Core service
- `packages/core/lib/services/image_compression_service.dart` - Compressão
- `apps/app-plantis/lib/features/plants/presentation/widgets/plant_form_basic_info.dart` - UI

### Documentos Relacionados

- `sincronia-hive-firebase.md` - Sistema de sincronização
- `gerenciamento-tarefas-plantas.md` - Integração com tarefas
- `implementacao-in-app-purchase.md` - Premium features

---

**Documento Vivo:** Este documento será atualizado conforme o sistema evolui.
**Última Atualização:** 07/10/2025
**Próxima Revisão:** 14/10/2025
