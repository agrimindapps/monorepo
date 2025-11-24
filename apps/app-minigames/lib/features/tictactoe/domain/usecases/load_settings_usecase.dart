import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_settings.dart';
import '../repositories/tictactoe_repository.dart';

/// Use case for loading game settings from storage
class LoadSettingsUseCase {
  final TicTacToeRepository repository;

  LoadSettingsUseCase(this.repository);

  /// Loads game settings from storage
  /// Returns [GameSettings] on success or [Failure] on error
  Future<Either<Failure, GameSettings>> call() async {
    return await repository.getSettings();
  }
}
