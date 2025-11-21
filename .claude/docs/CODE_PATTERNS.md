# 💎 Padrões de Código (Gold Standard)

Estes snippets foram extraídos do `app-plantis` e representam a forma CORRETA de implementar código neste monorepo.

## 1. Use Case Pattern

Use cases devem implementar a interface `UseCase<Type, Params>` e retornar `Either`.

```dart
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddPlantUseCase implements UseCase<Plant, AddPlantParams> {
  AddPlantUseCase(this.repository);

  final PlantsRepository repository;

  @override
  Future<Either<Failure, Plant>> call(AddPlantParams params) async {
    // 1. Validação
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Nome é obrigatório'));
    }

    // 2. Lógica de Negócio
    final plant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: params.name,
      createdAt: DateTime.now(),
    );

    // 3. Chamada ao Repository
    return repository.addPlant(plant);
  }
}

class AddPlantParams {
  final String name;
  const AddPlantParams({required this.name});
}
```

## 2. Repository Implementation Pattern

Repositories devem tratar erros e gerenciar cache/remoto.

```dart
@LazySingleton(as: PlantsRepository)
class PlantsRepositoryImpl implements PlantsRepository {
  PlantsRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, Plant>> addPlant(Plant plant) async {
    try {
      // 1. Salva localmente (Offline-first)
      final plantModel = PlantModel.fromEntity(plant);
      await localDatasource.addPlant(plantModel);

      // 2. Tenta sincronizar se online
      if (await networkInfo.isConnected) {
        try {
          final remotePlant = await remoteDatasource.addPlant(plantModel);
          // Atualiza local com dados do servidor (ex: ID gerado)
          await localDatasource.updatePlant(remotePlant);
          return Right(remotePlant);
        } catch (e) {
          // Falha silenciosa no remoto, retorna local (será sincronizado depois)
          return Right(plantModel);
        }
      }

      return Right(plantModel);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

## 3. Riverpod Notifier Pattern

Use `@riverpod` para gerar providers. Use `ref.read` para acessar UseCases (que vêm do GetIt).

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plants_notifier.g.dart';

@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  late final GetPlantsUseCase _getPlantsUseCase;
  late final AddPlantUseCase _addPlantUseCase;

  @override
  PlantsState build() {
    // Injeção via ponte GetIt -> Riverpod
    _getPlantsUseCase = ref.read(getPlantsUseCaseProvider);
    _addPlantUseCase = ref.read(addPlantUseCaseProvider);
    
    // Carregamento inicial
    loadPlants();
    
    return const PlantsState();
  }

  Future<void> loadPlants() async {
    state = state.copyWith(isLoading: true);
    
    final result = await _getPlantsUseCase(const NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false, 
        error: failure.message
      ),
      (plants) => state = state.copyWith(
        isLoading: false, 
        plants: plants
      ),
    );
  }

  Future<void> addPlant(String name) async {
    state = state.copyWith(isLoading: true);
    
    final result = await _addPlantUseCase(AddPlantParams(name: name));
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (plant) {
        // Atualização otimista ou recarregamento
        final newList = [...state.plants, plant];
        state = state.copyWith(isLoading: false, plants: newList);
      },
    );
  }
}

// Ponte para UseCases do GetIt
@riverpod
GetPlantsUseCase getPlantsUseCase(Ref ref) => GetIt.I<GetPlantsUseCase>();

@riverpod
AddPlantUseCase addPlantUseCase(Ref ref) => GetIt.I<AddPlantUseCase>();
```
