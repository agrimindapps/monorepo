import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use case for updating theme mode
@injectable
class UpdateTheme {
  final SettingsRepository _repository;

  UpdateTheme(this._repository);

  Future<Either<Failure, Unit>> call(bool isDarkMode) async {
    try {
      return await _repository.updateTheme(isDarkMode);
    } catch (e) {
      return Left(CacheFailure('Failed to update theme: ${e.toString()}'));
    }
  }
}
