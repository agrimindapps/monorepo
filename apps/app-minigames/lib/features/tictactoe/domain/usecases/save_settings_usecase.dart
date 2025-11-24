import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_settings.dart';
import '../repositories/tictactoe_repository.dart';

/// Use case for saving game settings to storage
class SaveSettingsUseCase {
  final TicTacToeRepository repository;

  SaveSettingsUseCase(this.repository);

  /// Saves game settings to storage
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> call(GameSettings settings) async {
    return await repository.saveSettings(settings);
  }
}
