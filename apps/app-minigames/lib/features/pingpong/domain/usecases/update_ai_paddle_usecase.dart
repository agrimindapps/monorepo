import 'package:core/core.dart';
import '../entities/game_state_entity.dart';
import '../services/ai_paddle_service.dart';

class UpdateAiPaddleUseCase {
  final AiPaddleService _aiPaddleService;

  UpdateAiPaddleUseCase(this._aiPaddleService);

  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return const Left(ValidationFailure('Game is not active'));
    }

    try {
      final aiPaddle = _aiPaddleService.updatePaddle(
        aiPaddle: state.aiPaddle,
        ball: state.ball,
        difficulty: state.difficulty,
      );

      return Right(state.copyWith(aiPaddle: aiPaddle));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update AI paddle: $e'));
    }
  }
}
