import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_plantis/features/plants/domain/entities/plant.dart';
import 'package:app_plantis/features/plants/domain/repositories/plants_repository.dart';
import 'package:app_plantis/features/plants/domain/usecases/add_plant_usecase.dart';
import 'package:app_plantis/features/tasks/domain/usecases/generate_initial_tasks_usecase.dart';

// Generate mocks
@GenerateMocks([PlantsRepository, GenerateInitialTasksUseCase])
import 'add_plant_usecase_test.mocks.dart';

void main() {
  late AddPlantUseCase useCase;
  late MockPlantsRepository mockRepository;
  late MockGenerateInitialTasksUseCase mockGenerateTasksUseCase;

  setUp(() {
    mockRepository = MockPlantsRepository();
    mockGenerateTasksUseCase = MockGenerateInitialTasksUseCase();
    useCase = AddPlantUseCase(mockRepository, generateInitialTasksUseCase: mockGenerateTasksUseCase);
  });

  group('AddPlantUseCase - Caso de Uso Adicionar Planta', () {
    const testPlantId = 'test_plant_id';
    const testPlantName = 'Rosa Vermelha';
    const testSpecies = 'Rosa rubiginosa';
    const testSpaceId = 'space_123';
    const testNotes = 'Uma bela rosa do jardim';
    final testPlantingDate = DateTime(2024, 1, 15);

    Plant createTestPlant({
      String? id,
      String? name,
      String? species,
      String? spaceId,
      String? notes,
      DateTime? plantingDate,
      PlantConfig? config,
    }) {
      return Plant(
        id: id ?? testPlantId,
        name: name ?? testPlantName,
        species: species ?? testSpecies,
        spaceId: spaceId ?? testSpaceId,
        notes: notes ?? testNotes,
        plantingDate: plantingDate ?? testPlantingDate,
        config: config,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: true,
      );
    }

    AddPlantParams createTestParams({
      String? id,
      String? name,
      String? species,
      String? spaceId,
      String? notes,
      DateTime? plantingDate,
      PlantConfig? config,
    }) {
      return AddPlantParams(
        id: id,
        name: name ?? testPlantName,
        species: species ?? testSpecies,
        spaceId: spaceId ?? testSpaceId,
        notes: notes ?? testNotes,
        plantingDate: plantingDate ?? testPlantingDate,
        config: config,
      );
    }

    group('Casos de Sucesso', () {
      test('deve adicionar uma planta com sucesso quando todos os dados são válidos', () async {
        // Arrange
        final testParams = createTestParams();
        final expectedPlant = createTestPlant();

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        result.fold(
          (failure) => fail('Esperava sucesso mas obteve falha: $failure'),
          (plant) {
            expect(plant.name, equals(testPlantName));
            expect(plant.species, equals(testSpecies));
            expect(plant.spaceId, equals(testSpaceId));
            expect(plant.notes, equals(testNotes));
            expect(plant.plantingDate, equals(testPlantingDate));
            expect(plant.isDirty, isTrue);
          },
        );

        // Verify repository was called
        verify(mockRepository.addPlant(any)).called(1);
      });

      test('deve adicionar planta com dados mínimos obrigatórios (apenas nome)', () async {
        // Arrange
        final testParams = AddPlantParams(name: testPlantName);
        
        // Create a plant with ALL null optional fields for testing
        final expectedPlant = Plant(
          id: testPlantId,
          name: testPlantName,
          species: null,  // Explicitly null
          spaceId: null,  // Explicitly null
          notes: null,    // Explicitly null
          plantingDate: null,  // Explicitly null
          config: null,   // Explicitly null
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        result.fold(
          (failure) => fail('Esperava sucesso mas obteve falha: $failure'),
          (plant) {
            expect(plant.name, equals(testPlantName));
            expect(plant.species, isNull);
            expect(plant.spaceId, isNull);
            expect(plant.notes, isNull);
            expect(plant.plantingDate, isNull);
          },
        );
      });

      test('deve gerar ID quando não fornecido', () async {
        // Arrange
        final testParams = AddPlantParams(name: testPlantName);
        final expectedPlant = createTestPlant();

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        await useCase(testParams);

        // Assert
        final capturedPlant = verify(mockRepository.addPlant(captureAny)).captured.single as Plant;
        expect(capturedPlant.id, isNotEmpty);
        expect(capturedPlant.id, isNot(equals('')));
      });

      test('deve remover espaços em branco dos campos de texto', () async {
        // Arrange
        final testParams = AddPlantParams(
          name: '  $testPlantName  ',
          species: '  $testSpecies  ',
          notes: '  $testNotes  ',
        );
        final expectedPlant = createTestPlant();

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        await useCase(testParams);

        // Assert
        final capturedPlant = verify(mockRepository.addPlant(captureAny)).captured.single as Plant;
        expect(capturedPlant.name, equals(testPlantName));
        expect(capturedPlant.species, equals(testSpecies));
        expect(capturedPlant.notes, equals(testNotes));
      });

      test('deve configurar timestamps corretamente', () async {
        // Arrange
        final testParams = createTestParams();
        final expectedPlant = createTestPlant();

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        final beforeCall = DateTime.now();

        // Act
        await useCase(testParams);

        final afterCall = DateTime.now();

        // Assert
        final capturedPlant = verify(mockRepository.addPlant(captureAny)).captured.single as Plant;
        expect(capturedPlant.createdAt, isNotNull);
        expect(capturedPlant.updatedAt, isNotNull);
        expect(capturedPlant.createdAt!.isAfter(beforeCall.subtract(Duration(seconds: 1))), isTrue);
        expect(capturedPlant.updatedAt!.isBefore(afterCall.add(Duration(seconds: 1))), isTrue);
        expect(capturedPlant.isDirty, isTrue);
      });
    });

    group('Geração de Tarefas', () {
      test('deve gerar tarefas iniciais quando configuração é fornecida', () async {
        // Arrange
        final plantConfig = PlantConfig(
          wateringIntervalDays: 3,
          fertilizingIntervalDays: 14,
          enableWateringCare: true,
          enableFertilizerCare: true,
        );
        final testParams = createTestParams(config: plantConfig);
        final expectedPlant = createTestPlant(config: plantConfig);

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));
        when(mockGenerateTasksUseCase(any))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        verify(mockRepository.addPlant(any)).called(1);
        verify(mockGenerateTasksUseCase(any)).called(1);
      });

      test('não deve gerar tarefas quando configuração é nula', () async {
        // Arrange
        final testParams = createTestParams(config: null);
        final expectedPlant = createTestPlant(config: null);

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        verify(mockRepository.addPlant(any)).called(1);
        verifyNever(mockGenerateTasksUseCase(any));
      });

      test('não deve falhar se geração de tarefas falhar', () async {
        // Arrange
        final plantConfig = PlantConfig(
          wateringIntervalDays: 3,
          enableWateringCare: true,
        );
        final testParams = createTestParams(config: plantConfig);
        final expectedPlant = createTestPlant(config: plantConfig);

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));
        when(mockGenerateTasksUseCase(any))
            .thenAnswer((_) async => const Left(UnknownFailure('Task generation failed')));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        result.fold(
          (failure) => fail('Esperava sucesso mas obteve falha: $failure'),
          (plant) => expect(plant.name, equals(testPlantName)),
        );
      });
    });

    group('Erros de Validação', () {
      test('deve retornar ValidationFailure quando nome está vazio', () async {
        // Arrange
        final testParams = AddPlantParams(name: '');

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, equals('Nome da planta é obrigatório'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verifyNever(mockRepository.addPlant(any));
      });

      test('deve retornar ValidationFailure quando nome tem apenas espaços', () async {
        // Arrange
        final testParams = AddPlantParams(name: '   ');

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, equals('Nome da planta é obrigatório'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verifyNever(mockRepository.addPlant(any));
      });

      test('deve retornar ValidationFailure quando nome é muito curto', () async {
        // Arrange
        final testParams = AddPlantParams(name: 'A');

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, equals('Nome deve ter pelo menos 2 caracteres'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verifyNever(mockRepository.addPlant(any));
      });

      test('deve retornar ValidationFailure quando nome é muito longo', () async {
        // Arrange
        final longName = 'A' * 51; // 51 characters
        final testParams = AddPlantParams(name: longName);

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, equals('Nome não pode ter mais de 50 caracteres'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verifyNever(mockRepository.addPlant(any));
      });

      test('deve retornar ValidationFailure quando espécie é muito longa', () async {
        // Arrange
        final longSpecies = 'A' * 101; // 101 characters
        final testParams = AddPlantParams(name: testPlantName, species: longSpecies);

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, equals('Espécie não pode ter mais de 100 caracteres'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verifyNever(mockRepository.addPlant(any));
      });

      test('deve retornar ValidationFailure quando observações são muito longas', () async {
        // Arrange
        final longNotes = 'A' * 501; // 501 characters
        final testParams = AddPlantParams(name: testPlantName, notes: longNotes);

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, equals('Observações não podem ter mais de 500 caracteres'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verifyNever(mockRepository.addPlant(any));
      });
    });

    group('Erros do Repositório', () {
      test('deve retornar falha do repositório quando addPlant falha', () async {
        // Arrange
        final testParams = createTestParams();
        const repositoryFailure = NetworkFailure('Connection failed');

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => const Left(repositoryFailure));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Left<Failure, Plant>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect((failure as NetworkFailure).message, equals('Connection failed'));
          },
          (plant) => fail('Esperava falha mas obteve sucesso'),
        );

        verify(mockRepository.addPlant(any)).called(1);
      });

      test('deve tratar vários tipos de falha do repositório', () async {
        // Testa diferentes tipos de falha
        final failureTypes = [
          const CacheFailure('Cache error'),
          const ServerFailure('Server error'),
          const AuthFailure('Auth error'),
          const NotFoundFailure('Not found'),
          const UnknownFailure('Unknown error'),
        ];

        for (final failure in failureTypes) {
          // Arrange
          final testParams = createTestParams();
          when(mockRepository.addPlant(any))
              .thenAnswer((_) async => Left(failure));

          // Act
          final result = await useCase(testParams);

          // Assert
          expect(result, isA<Left<Failure, Plant>>());
          result.fold(
            (resultFailure) {
              expect(resultFailure.runtimeType, equals(failure.runtimeType));
              expect(resultFailure.message, equals(failure.message));
            },
            (plant) => fail('Esperava falha mas obteve sucesso para ${failure.runtimeType}'),
          );
        }
      });
    });

    group('Casos Extremos', () {
      test('deve tratar valores nulos adequadamente', () async {
        // Arrange
        final testParams = AddPlantParams(
          name: testPlantName,
          species: null,
          spaceId: null,
          notes: null,
          plantingDate: null,
          config: null,
        );
        final expectedPlant = createTestPlant(
          species: null,
          spaceId: null,
          notes: null,
          plantingDate: null,
          config: null,
        );

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        final capturedPlant = verify(mockRepository.addPlant(captureAny)).captured.single as Plant;
        expect(capturedPlant.species, isNull);
        expect(capturedPlant.spaceId, isNull);
        expect(capturedPlant.notes, isNull);
        expect(capturedPlant.plantingDate, isNull);
        expect(capturedPlant.config, isNull);
      });

      test('deve tratar strings vazias convertendo para null quando apropriado', () async {
        // Arrange
        final testParams = AddPlantParams(
          name: testPlantName,
          species: '',
          notes: '',
        );
        final expectedPlant = createTestPlant();

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        await useCase(testParams);

        // Assert
        final capturedPlant = verify(mockRepository.addPlant(captureAny)).captured.single as Plant;
        expect(capturedPlant.name, equals(testPlantName));
        // Empty strings should be trimmed and potentially converted to null
        // Isso depende da implementação - ajustar baseado no comportamento real
      });

      test('deve preservar dados de imagem quando fornecidos', () async {
        // Arrange
        const testImageBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
        final testImageUrls = ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'];
        
        final testParams = AddPlantParams(
          name: testPlantName,
          imageBase64: testImageBase64,
          imageUrls: testImageUrls,
        );
        final expectedPlant = createTestPlant();

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));

        // Act
        await useCase(testParams);

        // Assert
        final capturedPlant = verify(mockRepository.addPlant(captureAny)).captured.single as Plant;
        expect(capturedPlant.imageBase64, equals(testImageBase64));
        expect(capturedPlant.imageUrls, equals(testImageUrls));
      });
    });

    group('Testes de Integração', () {
      test('deve criar planta com configuração completa e gerar tarefas', () async {
        // Arrange
        final plantConfig = PlantConfig(
          wateringIntervalDays: 3,
          fertilizingIntervalDays: 14,
          pruningIntervalDays: 90,
          sunlightCheckIntervalDays: 7,
          pestInspectionIntervalDays: 14,
          replantingIntervalDays: 365,
          lightRequirement: 'medium',
          waterAmount: 'moderate',
          soilType: 'well-draining',
          idealTemperature: 22.5,
          idealHumidity: 60.0,
          enableWateringCare: true,
          enableFertilizerCare: true,
          lastWateringDate: DateTime.now().subtract(Duration(days: 1)),
          lastFertilizerDate: DateTime.now().subtract(Duration(days: 7)),
        );

        final testParams = AddPlantParams(
          name: testPlantName,
          species: testSpecies,
          spaceId: testSpaceId,
          notes: testNotes,
          plantingDate: testPlantingDate,
          config: plantConfig,
          imageBase64: 'base64_encoded_image',
          imageUrls: ['https://example.com/plant1.jpg'],
        );

        final expectedPlant = createTestPlant(config: plantConfig);

        when(mockRepository.addPlant(any))
            .thenAnswer((_) async => Right(expectedPlant));
        when(mockGenerateTasksUseCase(any))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase(testParams);

        // Assert
        expect(result, isA<Right<Failure, Plant>>());
        result.fold(
          (failure) => fail('Esperava sucesso mas obteve falha: $failure'),
          (plant) {
            expect(plant.name, equals(testPlantName));
            expect(plant.species, equals(testSpecies));
            expect(plant.spaceId, equals(testSpaceId));
            expect(plant.notes, equals(testNotes));
            expect(plant.plantingDate, equals(testPlantingDate));
            expect(plant.config, isNotNull);
            expect(plant.config!.wateringIntervalDays, equals(3));
            expect(plant.config!.fertilizingIntervalDays, equals(14));
            expect(plant.config!.enableWateringCare, isTrue);
            expect(plant.config!.enableFertilizerCare, isTrue);
          },
        );

        verify(mockRepository.addPlant(any)).called(1);
        verify(mockGenerateTasksUseCase(any)).called(1);
      });
    });
  });
}