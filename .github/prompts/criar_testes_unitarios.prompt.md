---
mode: agent
---
# Criar Testes Unitários (TDD Approach)

Você será guiado na criação de testes unitários completos seguindo TDD e os padrões do monorepo.

## 🎯 FILOSOFIA DE TESTES DO MONOREPO

### Padrões Estabelecidos
- **Mocking**: Mocktail (não Mockito)
- **Structure**: Arrange-Act-Assert
- **Naming**: `should_[expected]_when_[condition]`
- **Coverage**: Mínimo 80% para use cases críticos
- **Pattern**: Test BEFORE implementation (TDD)

### O que Testar?
- ✅ **Use Cases**: 100% coverage (business logic crítico)
- ✅ **Repositories**: Sucesso e falhas
- ✅ **Models**: JSON serialization/deserialization
- ✅ **Providers**: State transitions
- ⚠️ **Widgets**: Apenas comportamentos complexos
- ❌ **UI simples**: Não testar cada Text/Button

## 📋 ESTRUTURA DE TESTES

### Espelhar lib/ em test/
```
lib/                          test/
├── domain/                   ├── domain/
│   ├── entities/             │   ├── entities/
│   ├── repositories/         │   ├── repositories/
│   └── usecases/             │   └── usecases/
│       └── get_user.dart     │       └── get_user_test.dart
├── data/                     ├── data/
│   ├── models/               │   ├── models/
│   └── repositories/         │   └── repositories/
└── presentation/             └── presentation/
    └── providers/                └── providers/
```

## 📝 TEMPLATES DE TESTES

### Teste de Use Case (Domain)

```dart
// test/domain/usecases/get_vehicle_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/failures/failure.dart';
import 'package:app/domain/entities/vehicle.dart';
import 'package:app/domain/repositories/vehicle_repository.dart';
import 'package:app/domain/usecases/get_vehicle.dart';

// Mock do repository
class MockVehicleRepository extends Mock implements VehicleRepository {}

void main() {
  late GetVehicle usecase;
  late MockVehicleRepository mockRepository;

  setUp(() {
    mockRepository = MockVehicleRepository();
    usecase = GetVehicle(mockRepository);
  });

  const tVehicleId = 'vehicle-123';
  const tVehicle = Vehicle(
    id: tVehicleId,
    name: 'Honda Civic',
    plate: 'ABC-1234',
  );

  group('GetVehicle', () {
    test(
      'should return Vehicle when repository succeeds',
      () async {
        // Arrange
        when(() => mockRepository.getVehicle(any()))
            .thenAnswer((_) async => const Right(tVehicle));

        // Act
        final result = await usecase(tVehicleId);

        // Assert
        expect(result, const Right(tVehicle));
        verify(() => mockRepository.getVehicle(tVehicleId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return NotFoundFailure when vehicle does not exist',
      () async {
        // Arrange
        final tFailure = NotFoundFailure('Vehicle not found');
        when(() => mockRepository.getVehicle(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase(tVehicleId);

        // Assert
        expect(result, Left(tFailure));
        verify(() => mockRepository.getVehicle(tVehicleId)).called(1);
      },
    );

    test(
      'should return CacheFailure when local storage fails',
      () async {
        // Arrange
        final tFailure = CacheFailure('Storage error');
        when(() => mockRepository.getVehicle(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase(tVehicleId);

        // Assert
        expect(result, Left(tFailure));
      },
    );
  });
}
```

### Teste de Repository (Data)

```dart
// test/data/repositories/vehicle_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/failures/failure.dart';
import 'package:app/data/datasources/vehicle_local_datasource.dart';
import 'package:app/data/datasources/vehicle_remote_datasource.dart';
import 'package:app/data/models/vehicle_model.dart';
import 'package:app/data/repositories/vehicle_repository_impl.dart';

class MockLocalDataSource extends Mock implements VehicleLocalDataSource {}
class MockRemoteDataSource extends Mock implements VehicleRemoteDataSource {}

void main() {
  late VehicleRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repository = VehicleRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  const tVehicleId = 'vehicle-123';
  const tVehicleModel = VehicleModel(
    id: tVehicleId,
    name: 'Honda Civic',
    plate: 'ABC-1234',
  );

  group('getVehicle', () {
    test(
      'should return remote data when remote call is successful',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getVehicle(any()))
            .thenAnswer((_) async => tVehicleModel);
        when(() => mockLocalDataSource.cacheVehicle(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getVehicle(tVehicleId);

        // Assert
        verify(() => mockRemoteDataSource.getVehicle(tVehicleId));
        verify(() => mockLocalDataSource.cacheVehicle(tVehicleModel));
        expect(result, const Right(tVehicleModel));
      },
    );

    test(
      'should return cached data when remote call fails',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getVehicle(any()))
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedVehicle(any()))
            .thenAnswer((_) async => tVehicleModel);

        // Act
        final result = await repository.getVehicle(tVehicleId);

        // Assert
        verify(() => mockRemoteDataSource.getVehicle(tVehicleId));
        verify(() => mockLocalDataSource.getCachedVehicle(tVehicleId));
        expect(result, const Right(tVehicleModel));
      },
    );

    test(
      'should return CacheFailure when both remote and cache fail',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getVehicle(any()))
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedVehicle(any()))
            .thenThrow(Exception('Cache error'));

        // Act
        final result = await repository.getVehicle(tVehicleId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );
  });
}
```

### Teste de Model (Data)

```dart
// test/data/models/vehicle_model_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/data/models/vehicle_model.dart';
import 'package:app/domain/entities/vehicle.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  const tVehicleModel = VehicleModel(
    id: '1',
    name: 'Honda Civic',
    plate: 'ABC-1234',
    year: 2020,
  );

  group('VehicleModel', () {
    test('should be a subclass of Vehicle entity', () {
      expect(tVehicleModel, isA<Vehicle>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Arrange
        final Map<String, dynamic> jsonMap = json.decode(
          fixture('vehicle.json'),
        );

        // Act
        final result = VehicleModel.fromJson(jsonMap);

        // Assert
        expect(result, tVehicleModel);
      });

      test('should handle missing optional fields', () {
        // Arrange
        final jsonMap = {
          'id': '1',
          'name': 'Honda Civic',
          'plate': 'ABC-1234',
          // year is optional
        };

        // Act
        final result = VehicleModel.fromJson(jsonMap);

        // Assert
        expect(result.year, null);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tVehicleModel.toJson();

        // Assert
        final expectedMap = {
          'id': '1',
          'name': 'Honda Civic',
          'plate': 'ABC-1234',
          'year': 2020,
        };
        expect(result, expectedMap);
      });
    });
  });
}
```

### Teste de Provider (Presentation)

```dart
// test/presentation/providers/vehicle_provider_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/failures/failure.dart';
import 'package:app/domain/entities/vehicle.dart';
import 'package:app/domain/usecases/get_vehicles.dart';
import 'package:app/presentation/providers/vehicle_provider.dart';

class MockGetVehicles extends Mock implements GetVehicles {}

void main() {
  late MockGetVehicles mockGetVehicles;
  late ProviderContainer container;

  setUp(() {
    mockGetVehicles = MockGetVehicles();
    container = ProviderContainer(
      overrides: [
        getVehiclesProvider.overrideWithValue(mockGetVehicles),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tVehicles = [
    Vehicle(id: '1', name: 'Car 1', plate: 'ABC-1234'),
    Vehicle(id: '2', name: 'Car 2', plate: 'DEF-5678'),
  ];

  group('VehicleNotifier', () {
    test('should emit loading then data when successful', () async {
      // Arrange
      when(() => mockGetVehicles())
          .thenAnswer((_) async => const Right(tVehicles));

      // Act
      final notifier = container.read(vehicleNotifierProvider.notifier);
      
      // Assert - initial loading state
      expect(
        container.read(vehicleNotifierProvider),
        const AsyncValue<List<Vehicle>>.loading(),
      );

      // Wait for async operation
      await container.read(vehicleNotifierProvider.future);

      // Assert - data state
      expect(
        container.read(vehicleNotifierProvider),
        AsyncValue.data(tVehicles),
      );
    });

    test('should emit error when usecase fails', () async {
      // Arrange
      final tFailure = ServerFailure('Server error');
      when(() => mockGetVehicles())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final notifier = container.read(vehicleNotifierProvider.notifier);

      // Wait and expect error
      await expectLater(
        container.read(vehicleNotifierProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### Teste de Widget

```dart
// test/presentation/widgets/vehicle_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/vehicle.dart';
import 'package:app/presentation/widgets/vehicle_card.dart';

void main() {
  const tVehicle = Vehicle(
    id: '1',
    name: 'Honda Civic',
    plate: 'ABC-1234',
  );

  Widget makeTestableWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('VehicleCard', () {
    testWidgets('should display vehicle name and plate', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          child: VehicleCard(vehicle: tVehicle),
        ),
      );

      // Assert
      expect(find.text('Honda Civic'), findsOneWidget);
      expect(find.text('ABC-1234'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      var wasTapped = false;
      await tester.pumpWidget(
        makeTestableWidget(
          child: VehicleCard(
            vehicle: tVehicle,
            onTap: () => wasTapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(VehicleCard));
      await tester.pump();

      // Assert
      expect(wasTapped, true);
    });
  });
}
```

## 🛠️ SETUP DE FIXTURES

### Criar Fixture Reader
```dart
// test/fixtures/fixture_reader.dart
import 'dart:io';

String fixture(String name) {
  final file = File('test/fixtures/$name');
  return file.readAsStringSync();
}
```

### Criar JSON Fixtures
```json
// test/fixtures/vehicle.json
{
  "id": "1",
  "name": "Honda Civic",
  "plate": "ABC-1234",
  "year": 2020
}
```

## 📊 COVERAGE

### Rodar Testes com Coverage
```bash
# Rodar todos os testes com coverage
flutter test --coverage

# Gerar relatório HTML (opcional)
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
open coverage/html/index.html
```

### Analisar Coverage
```bash
# Ver coverage summary
lcov --summary coverage/lcov.info

# Target: >80% para código crítico (use cases, repositories)
```

## ✅ CHECKLIST DE TESTES

### Para cada Use Case
- [ ] Teste de sucesso (happy path)
- [ ] Teste de cada tipo de failure
- [ ] Verificar chamada ao repository
- [ ] Verificar nenhuma interação extra

### Para cada Repository
- [ ] Teste com remote success
- [ ] Teste com remote failure + cache success
- [ ] Teste com ambos failure
- [ ] Verificar cache strategy

### Para cada Model
- [ ] Teste fromJson com dados completos
- [ ] Teste fromJson com campos opcionais
- [ ] Teste toJson
- [ ] Verificar é subclass da entity

### Para cada Provider
- [ ] Teste estado inicial (loading)
- [ ] Teste sucesso (data)
- [ ] Teste erro (error)
- [ ] Teste métodos de mutação

## 🎯 BEST PRACTICES

1. **Nomenclatura Clara**: Use `should_[expected]_when_[condition]`
2. **AAA Pattern**: Sempre Arrange-Act-Assert
3. **One Assertion**: Foque em um comportamento por teste
4. **Mock Apenas Dependências**: Não mock o que está sendo testado
5. **Fixtures para JSON**: Use arquivos fixture ao invés de strings inline
6. **Teardown**: Sempre dispose de containers/mocks
7. **Group Related**: Use `group()` para organizar testes relacionados

## 🚨 ERROS COMUNS

### ❌ Não fazer:
```dart
// Mock incorreto (sem when)
test('test', () {
  final result = await usecase(); // Vai falhar sem mock!
});

// Múltiplas assertions sem contexto
expect(result.name, 'Honda');
expect(result.plate, 'ABC-1234');
expect(result.year, 2020);
```

### ✅ Fazer:
```dart
// Setup correto do mock
test('test', () {
  when(() => mockRepo.get()).thenAnswer((_) async => Right(data));
  final result = await usecase();
  expect(result, Right(data));
});

// Assertion clara e focada
expect(result, const Right(tVehicle));
expect(result.getOrElse(() => Vehicle.empty), tVehicle);
```

Boa testagem! 🧪
