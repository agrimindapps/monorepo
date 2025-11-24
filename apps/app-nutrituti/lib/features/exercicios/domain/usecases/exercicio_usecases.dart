import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/exercicio.dart';
import '../repositories/exercicio_repository.dart';

/// Parameters for adding an exercise
class AddExercicioParams {
  final String nome;
  final String categoria;
  final int duracao;
  final int caloriasQueimadas;
  final int dataRegistro;
  final String? observacoes;

  const AddExercicioParams({
    required this.nome,
    required this.categoria,
    required this.duracao,
    required this.caloriasQueimadas,
    required this.dataRegistro,
    this.observacoes,
  });
}

/// Use case for getting all exercises
class GetAllExerciciosUseCase {
  final ExercicioRepository _repository;

  const GetAllExerciciosUseCase(this._repository);

  Future<Either<Failure, List<Exercicio>>> call() {
    return _repository.getAllExercicios();
  }
}

/// Use case for adding an exercise
class AddExercicioUseCase {
  final ExercicioRepository _repository;

  const AddExercicioUseCase(this._repository);

  Future<Either<Failure, Exercicio>> call(AddExercicioParams params) {
    final exercicio = Exercicio(
      nome: params.nome,
      categoria: params.categoria,
      duracao: params.duracao,
      caloriasQueimadas: params.caloriasQueimadas,
      dataRegistro: params.dataRegistro,
      observacoes: params.observacoes,
    );
    return _repository.addExercicio(exercicio);
  }
}

/// Use case for updating an exercise
class UpdateExercicioUseCase {
  final ExercicioRepository _repository;

  const UpdateExercicioUseCase(this._repository);

  Future<Either<Failure, Exercicio>> call(Exercicio exercicio) {
    return _repository.updateExercicio(exercicio);
  }
}

/// Use case for deleting an exercise
class DeleteExercicioUseCase {
  final ExercicioRepository _repository;

  const DeleteExercicioUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteExercicio(id);
  }
}
