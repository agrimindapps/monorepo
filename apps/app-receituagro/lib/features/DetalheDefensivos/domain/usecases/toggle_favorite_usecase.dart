import 'package:core/core.dart';
import '../repositories/i_defensivo_details_repository.dart';

class ToggleFavoriteParams {
  final String defensivoId;
  final Map<String, dynamic> defensivoData;

  const ToggleFavoriteParams({
    required this.defensivoId,
    required this.defensivoData,
  });
}

/// Use case para alternar status de favorito de um defensivo
class ToggleFavoriteUsecase implements UseCase<bool, ToggleFavoriteParams> {
  final IDefensivoDetailsRepository repository;

  const ToggleFavoriteUsecase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) async {
    return await repository.toggleFavorite(params.defensivoId, params.defensivoData);
  }
}
