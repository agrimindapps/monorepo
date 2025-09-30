import 'package:core/core.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../entities/space.dart';
import '../repositories/spaces_repository.dart';

@injectable
class GetSpacesUseCase implements UseCase<List<Space>, NoParams> {
  final SpacesRepository repository;

  GetSpacesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Space>>> call(NoParams params) {
    return repository.getSpaces();
  }
}

@injectable
class GetSpaceByIdUseCase implements UseCase<Space, String> {
  final SpacesRepository repository;

  GetSpaceByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Space>> call(String id) {
    if (id.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('ID do espaço é obrigatório')),
      );
    }
    return repository.getSpaceById(id);
  }
}

@injectable
class AddSpaceUseCase implements UseCase<Space, AddSpaceParams> {
  final SpacesRepository repository;

  AddSpaceUseCase(this.repository);

  @override
  Future<Either<Failure, Space>> call(AddSpaceParams params) async {
    // Validate space data
    final validationResult = _validateSpace(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Get current user ID from auth state notifier
    final currentUser = AuthStateNotifier.instance.currentUser;
    if (currentUser == null) {
      return const Left(AuthFailure('Usuário não está autenticado'));
    }

    // Create space with timestamps
    final now = DateTime.now();
    final space = Space(
      id: params.id ?? _generateId(),
      name: params.name.trim(),
      description: params.description?.trim(),
      lightCondition: params.lightCondition,
      humidity: params.humidity,
      averageTemperature: params.averageTemperature,
      createdAt: now,
      updatedAt: now,
      isDirty: true,
      userId: currentUser.id,
      moduleName: 'plantis',
    );

    return repository.addSpace(space);
  }

  ValidationFailure? _validateSpace(AddSpaceParams params) {
    if (params.name.trim().isEmpty) {
      return const ValidationFailure('Nome do espaço é obrigatório');
    }

    if (params.name.trim().length < 2) {
      return const ValidationFailure('Nome deve ter pelo menos 2 caracteres');
    }

    if (params.name.trim().length > 50) {
      return const ValidationFailure('Nome não pode ter mais de 50 caracteres');
    }

    if (params.description != null && params.description!.trim().length > 200) {
      return const ValidationFailure(
        'Descrição não pode ter mais de 200 caracteres',
      );
    }

    if (params.humidity != null &&
        (params.humidity! < 0 || params.humidity! > 100)) {
      return const ValidationFailure('Umidade deve estar entre 0 e 100%');
    }

    if (params.averageTemperature != null &&
        (params.averageTemperature! < -50 || params.averageTemperature! > 60)) {
      return const ValidationFailure(
        'Temperatura deve estar entre -50°C e 60°C',
      );
    }

    return null;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

@injectable
class UpdateSpaceUseCase implements UseCase<Space, UpdateSpaceParams> {
  const UpdateSpaceUseCase(this.repository);

  final SpacesRepository repository;

  @override
  Future<Either<Failure, Space>> call(UpdateSpaceParams params) async {
    // Validate space data
    final validationResult = _validateSpace(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Get existing space first
    final existingResult = await repository.getSpaceById(params.id);

    return existingResult.fold((failure) => Left(failure), (existingSpace) {
      // Update space with new data and timestamp
      final updatedSpace = existingSpace.copyWith(
        name: params.name.trim(),
        description: params.description?.trim(),
        lightCondition: params.lightCondition,
        humidity: params.humidity,
        averageTemperature: params.averageTemperature,
        updatedAt: DateTime.now(),
        isDirty: true,
      );

      return repository.updateSpace(updatedSpace);
    });
  }

  ValidationFailure? _validateSpace(UpdateSpaceParams params) {
    if (params.id.trim().isEmpty) {
      return const ValidationFailure('ID do espaço é obrigatório');
    }

    if (params.name.trim().isEmpty) {
      return const ValidationFailure('Nome do espaço é obrigatório');
    }

    if (params.name.trim().length < 2) {
      return const ValidationFailure('Nome deve ter pelo menos 2 caracteres');
    }

    if (params.name.trim().length > 50) {
      return const ValidationFailure('Nome não pode ter mais de 50 caracteres');
    }

    if (params.description != null && params.description!.trim().length > 200) {
      return const ValidationFailure(
        'Descrição não pode ter mais de 200 caracteres',
      );
    }

    if (params.humidity != null &&
        (params.humidity! < 0 || params.humidity! > 100)) {
      return const ValidationFailure('Umidade deve estar entre 0 e 100%');
    }

    if (params.averageTemperature != null &&
        (params.averageTemperature! < -50 || params.averageTemperature! > 60)) {
      return const ValidationFailure(
        'Temperatura deve estar entre -50°C e 60°C',
      );
    }

    return null;
  }
}

@injectable
class DeleteSpaceUseCase implements UseCase<void, String> {
  const DeleteSpaceUseCase(this.repository);

  final SpacesRepository repository;

  @override
  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do espaço é obrigatório'));
    }

    // Check if space exists first
    final existingResult = await repository.getSpaceById(id);

    return existingResult.fold(
      (failure) => Left(failure),
      (_) => repository.deleteSpace(id),
    );
  }
}

class AddSpaceParams {
  final String? id;
  final String name;
  final String? description;
  final String? lightCondition;
  final double? humidity;
  final double? averageTemperature;

  const AddSpaceParams({
    this.id,
    required this.name,
    this.description,
    this.lightCondition,
    this.humidity,
    this.averageTemperature,
  });
}

class UpdateSpaceParams {
  final String id;
  final String name;
  final String? description;
  final String? lightCondition;
  final double? humidity;
  final double? averageTemperature;

  const UpdateSpaceParams({
    required this.id,
    required this.name,
    this.description,
    this.lightCondition,
    this.humidity,
    this.averageTemperature,
  });
}
