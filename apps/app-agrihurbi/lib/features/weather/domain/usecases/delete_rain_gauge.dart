import 'package:core/core.dart';

import '../failures/weather_failures.dart';
import '../repositories/weather_repository.dart';

class DeleteRainGauge {
  final WeatherRepository _repository;

  DeleteRainGauge(this._repository);

  Future<Either<WeatherFailure, void>> call(String id) {
    return _repository.deleteRainGauge(id);
  }
}
