import 'package:core/core.dart';

import '../entities/odometer_entity.dart';

/// Interface abstrata para repositório de odômetro
abstract class OdometerRepository {
  /// Busca todas as leituras de odômetro
  Future<Either<Failure, List<OdometerEntity>>> getAllOdometerReadings();

  /// Busca leitura por ID
  Future<Either<Failure, OdometerEntity?>> getOdometerReadingById(String id);

  /// Adiciona nova leitura
  Future<Either<Failure, OdometerEntity?>> addOdometerReading(
    OdometerEntity reading,
  );

  /// Atualiza leitura existente
  Future<Either<Failure, OdometerEntity?>> updateOdometerReading(
    OdometerEntity reading,
  );

  /// Remove leitura
  Future<Either<Failure, bool>> deleteOdometerReading(String id);

  /// Busca leituras por veículo
  Future<Either<Failure, List<OdometerEntity>>> getOdometerReadingsByVehicle(
    String vehicleId,
  );

  /// Busca última leitura de um veículo
  Future<Either<Failure, OdometerEntity?>> getLastOdometerReading(
    String vehicleId,
  );

  /// Busca leituras por período
  Future<Either<Failure, List<OdometerEntity>>> getOdometerReadingsByPeriod(
    DateTime startDate,
    DateTime endDate,
  );

  /// Busca leituras por tipo
  Future<Either<Failure, List<OdometerEntity>>> getOdometerReadingsByType(
    OdometerType type,
  );

  /// Busca duplicatas
  Future<Either<Failure, List<OdometerEntity>>> findDuplicates();

  /// Busca por texto
  Future<Either<Failure, List<OdometerEntity>>> searchOdometerReadings(
    String query,
  );

  /// Busca estatísticas do veículo
  Future<Either<Failure, Map<String, dynamic>>> getVehicleStats(
    String vehicleId,
  );
}
