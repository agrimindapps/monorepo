import 'package:core/core.dart';
import '../../../features/fuel/domain/entities/fuel_record_entity.dart';

/// Interface para operações de query em combustível
/// 
/// Segregada conforme ISP - apenas responsável por Read/Filter/Search
/// Não inclui mutações ou sincronização
abstract class IFuelQueryService {
  /// Carrega todos os registros de combustível
  Future<Either<Failure, List<FuelRecordEntity>>> loadAllRecords();

  /// Carrega registros de combustível por veículo
  Future<Either<Failure, List<FuelRecordEntity>>> loadRecordsByVehicle(String vehicleId);

  /// Filtra registros por critério
  List<FuelRecordEntity> filterRecords(
    List<FuelRecordEntity> records,
    String query,
  );

  /// Busca registros de combustível
  Future<Either<Failure, List<FuelRecordEntity>>> searchRecords(String query);
}
