import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../repositories/spaces_repository.dart';

class DeleteSpaceUseCase implements UseCase<void, String> {
  final SpacesRepository repository;
  
  DeleteSpaceUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do espaço é obrigatório'));
    }
    
    // Check if space has plants before deleting
    final plantCountResult = await repository.getPlantCountBySpace(id);
    
    return plantCountResult.fold(
      (failure) => Left(failure),
      (plantCount) {
        if (plantCount > 0) {
          return const Left(ValidationFailure(
            'Não é possível excluir um espaço que possui plantas. '
            'Remova ou mova todas as plantas primeiro.'
          ));
        }
        
        return repository.deleteSpace(id);
      },
    );
  }
}