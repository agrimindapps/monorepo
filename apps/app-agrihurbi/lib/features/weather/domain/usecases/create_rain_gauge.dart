import 'package:core/core.dart';

import '../entities/rain_gauge_entity.dart';
import '../failures/weather_failures.dart';
import '../repositories/weather_repository.dart';

class CreateRainGauge {
  final WeatherRepository _repository;

  CreateRainGauge(this._repository);

  Future<Either<WeatherFailure, RainGaugeEntity>> call(RainGaugeEntity rainGauge) {
    return _repository.createRainGauge(rainGauge);
  }
}
