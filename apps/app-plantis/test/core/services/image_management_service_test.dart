import 'package:app_plantis/core/services/image_management_service.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockIImageService extends Mock implements IImageService {}

void main() {
  late ImageManagementService service;
  late MockIImageService mockImageService;

  setUp(() {
    mockImageService = MockIImageService();
    service = ImageManagementService(imageService: mockImageService);
  });

  group('ImageManagementService', () {
    group('captureFromCamera', () {
      test('should return base64 image on success', () async {
        // Arrange
        const expectedBase64 = 'data:image/jpeg;base64,/9j/4AAQSkZJRg...';
        when(() => mockImageService.pickFromCamera())
            .thenAnswer((_) async => const Right(expectedBase64));

        // Act
        final result = await service.captureFromCamera();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (base64) => expect(base64, expectedBase64),
        );
        verify(() => mockImageService.pickFromCamera()).called(1);
      });

      test('should return failure when camera capture fails', () async {
        // Arrange
        when(() => mockImageService.pickFromCamera())
            .thenAnswer((_) async => const Left(
                  CacheFailure('Erro ao acessar câmera'),
                ));

        // Act
        final result = await service.captureFromCamera();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
            failure.message,
            contains('Erro ao capturar imagem da câmera'),
          ),
          (base64) => fail('Should not return success'),
        );
      });

      test('should return validation failure for invalid base64', () async {
        // Arrange
        const invalidBase64 = 'invalid-base64'; // Sem prefixo data:image/
        when(() => mockImageService.pickFromCamera())
            .thenAnswer((_) async => const Right(invalidBase64));

        // Act
        final result = await service.captureFromCamera();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (base64) => fail('Should not return success'),
        );
      });
    });

    group('selectFromGallery', () {
      test('should return base64 image on success', () async {
        // Arrange
        const expectedBase64 = 'data:image/png;base64,iVBORw0KGg...';
        when(() => mockImageService.pickFromGallery())
            .thenAnswer((_) async => const Right(expectedBase64));

        // Act
        final result = await service.selectFromGallery();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (base64) => expect(base64, expectedBase64),
        );
        verify(() => mockImageService.pickFromGallery()).called(1);
      });

      test('should return failure when gallery selection fails', () async {
        // Arrange
        when(() => mockImageService.pickFromGallery())
            .thenAnswer((_) async => const Left(
                  CacheFailure('Nenhuma imagem selecionada'),
                ));

        // Act
        final result = await service.selectFromGallery();

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('addImageToList', () {
      test('should add image to empty list successfully', () {
        // Arrange
        const currentImages = <String>[];
        const newImage = 'data:image/jpeg;base64,/9j/4AAQ...';

        // Act
        final result = service.addImageToList(currentImages, newImage);

        // Assert
        expect(result.isSuccess, true);
        expect(result.updatedImages.length, 1);
        expect(result.updatedImages.first, newImage);
        expect(result.message, 'Imagem adicionada com sucesso');
      });

      test('should add image to existing list', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg'];
        const newImage = 'image3.jpg';

        // Act
        final result = service.addImageToList(currentImages, newImage);

        // Assert
        expect(result.isSuccess, true);
        expect(result.updatedImages.length, 3);
        expect(result.updatedImages, ['image1.jpg', 'image2.jpg', 'image3.jpg']);
      });

      test('should reject when limit of 5 images is exceeded', () {
        // Arrange
        const currentImages = [
          'image1.jpg',
          'image2.jpg',
          'image3.jpg',
          'image4.jpg',
          'image5.jpg',
        ];
        const newImage = 'image6.jpg';

        // Act
        final result = service.addImageToList(currentImages, newImage);

        // Assert
        expect(result.isError, true);
        expect(result.message, contains('Máximo de 5 imagens'));
        expect(result.updatedImages.length, 5); // Lista não modificada
      });

      test('should reject duplicate image', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg'];
        const duplicateImage = 'image1.jpg';

        // Act
        final result = service.addImageToList(currentImages, duplicateImage);

        // Assert
        expect(result.isError, true);
        expect(result.message, contains('já foi adicionada'));
        expect(result.updatedImages.length, 2); // Lista não modificada
      });
    });

    group('removeImageFromList', () {
      test('should remove image at valid index', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg', 'image3.jpg'];
        const indexToRemove = 1;

        // Act
        final result = service.removeImageFromList(currentImages, indexToRemove);

        // Assert
        expect(result.isSuccess, true);
        expect(result.updatedImages.length, 2);
        expect(result.updatedImages, ['image1.jpg', 'image3.jpg']);
        expect(result.message, 'Imagem removida com sucesso');
      });

      test('should reject invalid index (negative)', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg'];
        const invalidIndex = -1;

        // Act
        final result = service.removeImageFromList(currentImages, invalidIndex);

        // Assert
        expect(result.isError, true);
        expect(result.message, contains('Índice da imagem inválido'));
      });

      test('should reject invalid index (out of bounds)', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg'];
        const invalidIndex = 5;

        // Act
        final result = service.removeImageFromList(currentImages, invalidIndex);

        // Assert
        expect(result.isError, true);
        expect(result.message, contains('Índice da imagem inválido'));
      });
    });

    group('removeSpecificImage', () {
      test('should remove specific image from list', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg', 'image3.jpg'];
        const imageToRemove = 'image2.jpg';

        // Act
        final result = service.removeSpecificImage(currentImages, imageToRemove);

        // Assert
        expect(result.isSuccess, true);
        expect(result.updatedImages.length, 2);
        expect(result.updatedImages, ['image1.jpg', 'image3.jpg']);
      });

      test('should reject if image not found in list', () {
        // Arrange
        const currentImages = ['image1.jpg', 'image2.jpg'];
        const nonExistentImage = 'image99.jpg';

        // Act
        final result = service.removeSpecificImage(currentImages, nonExistentImage);

        // Assert
        expect(result.isError, true);
        expect(result.message, contains('não encontrada na lista'));
      });
    });

    group('getImageListInfo', () {
      test('should return info for empty list', () {
        // Arrange
        const emptyList = <String>[];

        // Act
        final info = service.getImageListInfo(emptyList);

        // Assert
        expect(info.currentCount, 0);
        expect(info.maxCount, 5);
        expect(info.canAddMore, true);
        expect(info.remainingSlots, 5);
        expect(info.isEmpty, true);
        expect(info.isFull, false);
      });

      test('should return info for partial list', () {
        // Arrange
        const partialList = ['image1.jpg', 'image2.jpg'];

        // Act
        final info = service.getImageListInfo(partialList);

        // Assert
        expect(info.currentCount, 2);
        expect(info.maxCount, 5);
        expect(info.canAddMore, true);
        expect(info.remainingSlots, 3);
        expect(info.isEmpty, false);
        expect(info.isFull, false);
      });

      test('should return info for full list', () {
        // Arrange
        const fullList = [
          'image1.jpg',
          'image2.jpg',
          'image3.jpg',
          'image4.jpg',
          'image5.jpg',
        ];

        // Act
        final info = service.getImageListInfo(fullList);

        // Assert
        expect(info.currentCount, 5);
        expect(info.maxCount, 5);
        expect(info.canAddMore, false);
        expect(info.remainingSlots, 0);
        expect(info.isEmpty, false);
        expect(info.isFull, true);
      });
    });

    group('validateImageList', () {
      test('should validate empty list as valid', () {
        // Arrange
        const emptyList = <String>[];

        // Act
        final validation = service.validateImageList(emptyList);

        // Assert
        expect(validation.isValid, true);
        expect(validation.errors, isEmpty);
      });

      test('should validate list with valid images', () {
        // Arrange
        // Base64 válido precisa ter pelo menos 100 caracteres
        final validImage1 = 'data:image/jpeg;base64,${'a' * 100}';
        final validImage2 = 'data:image/png;base64,${'b' * 100}';
        final validList = [validImage1, validImage2];

        // Act
        final validation = service.validateImageList(validList);

        // Assert
        expect(validation.isValid, true);
        expect(validation.errors, isEmpty);
      });

      test('should reject list exceeding maximum', () {
        // Arrange
        final validBase64 = 'data:image/jpeg;base64,${'x' * 100}';
        final oversizedList = List.filled(6, validBase64);

        // Act
        final validation = service.validateImageList(oversizedList);

        // Assert
        expect(validation.isValid, false);
        expect(validation.hasErrors, true);
        expect(
          validation.errors.any((e) => e.contains('Máximo de 5 imagens')),
          true,
        );
      });

      test('should reject list with invalid base64 images', () {
        // Arrange
        const invalidList = [
          'data:image/jpeg;base64,valid...',
          'invalid-image', // Sem prefixo correto
        ];

        // Act
        final validation = service.validateImageList(invalidList);

        // Assert
        expect(validation.isValid, false);
        expect(validation.hasErrors, true);
        expect(
          validation.errors.any((e) => e.contains('inválida')),
          true,
        );
      });

      test('should reject list with duplicate images', () {
        // Arrange
        final duplicateImage = 'data:image/jpeg;base64,${'z' * 100}';
        final duplicateList = [duplicateImage, duplicateImage];

        // Act
        final validation = service.validateImageList(duplicateList);

        // Assert
        expect(validation.isValid, false);
        expect(validation.hasErrors, true);
        expect(
          validation.errors.any((e) => e.contains('duplicadas')),
          true,
        );
      });
    });

    group('uploadImages', () {
      test('should return empty list for empty input', () async {
        // Arrange
        const emptyList = <String>[];

        // Act
        final result = await service.uploadImages(emptyList);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (urls) => expect(urls, isEmpty),
        );
        verifyNever(() => mockImageService.uploadImages(any()));
      });

      test('should reject if any image is invalid', () async {
        // Arrange
        const invalidImages = [
          'data:image/jpeg;base64,valid...',
          'invalid-image', // Inválido
        ];

        // Act
        final result = await service.uploadImages(invalidImages);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (urls) => fail('Should not return success'),
        );
      });
    });

    group('deleteImage', () {
      test('should reject empty URL', () async {
        // Arrange
        const emptyUrl = '';

        // Act
        final result = await service.deleteImage(emptyUrl);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (success) => fail('Should not return success'),
        );
      });

      test('should call image service to delete valid URL', () async {
        // Arrange
        const validUrl = 'https://firebasestorage.googleapis.com/.../image.jpg';
        when(() => mockImageService.deleteImage(validUrl))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await service.deleteImage(validUrl);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockImageService.deleteImage(validUrl)).called(1);
      });
    });
  });
}
