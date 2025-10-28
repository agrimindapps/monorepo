import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Parameters for updating TTS settings
class UpdateTTSSettingsParams {
  final double? speed;
  final double? pitch;
  final double? volume;
  final String? language;

  const UpdateTTSSettingsParams({
    this.speed,
    this.pitch,
    this.volume,
    this.language,
  });
}

/// Use case for updating TTS settings
@injectable
class UpdateTTSSettings {
  final SettingsRepository _repository;

  UpdateTTSSettings(this._repository);

  Future<Either<Failure, Unit>> call(UpdateTTSSettingsParams params) async {
    try {
      // Validate TTS parameters
      if (params.speed != null) {
        if (params.speed! < 0.1 || params.speed! > 1.0) {
          return const Left(
            ValidationFailure('TTS speed must be between 0.1 and 1.0'),
          );
        }
      }

      if (params.pitch != null) {
        if (params.pitch! < 0.5 || params.pitch! > 2.0) {
          return const Left(
            ValidationFailure('TTS pitch must be between 0.5 and 2.0'),
          );
        }
      }

      if (params.volume != null) {
        if (params.volume! < 0.0 || params.volume! > 1.0) {
          return const Left(
            ValidationFailure('TTS volume must be between 0.0 and 1.0'),
          );
        }
      }

      return await _repository.updateTTSSettings(
        speed: params.speed,
        pitch: params.pitch,
        volume: params.volume,
        language: params.language,
      );
    } catch (e) {
      return Left(CacheFailure('Failed to update TTS settings: ${e.toString()}'));
    }
  }
}
