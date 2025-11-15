import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../features/fuel/domain/entities/fuel_record_entity.dart';
import '../../features/fuel/domain/services/i_fuel_query_service.dart';
import '../../features/fuel/domain/usecases/get_all_fuel_records.dart';
import '../../features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';

/// Serviço especializado em consultas e filtragem de combustível
///
/// **Responsabilidades:**
/// - Carregar todos os registros
/// - Filtrar registros por veículo
/// - Buscar/pesquisar registros
/// - Cache de resultados
/// - Apenas operações de leitura, sem modificações
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas query/read operations
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
/// - Interface Segregation: Implementa IFuelQueryService
///
/// **Exemplo:**
/// ```dart
/// final service = FuelQueryService(getAllUseCase, getByVehicleUseCase);
/// final result = await service.loadAllRecords();
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (records) => print('Loaded ${records.length} records'),
/// );
/// ```
class FuelQueryService implements IFuelQueryService {
  FuelQueryService({
    required GetAllFuelRecords getAllFuelRecords,
    required GetFuelRecordsByVehicle getFuelRecordsByVehicle,
  })  : _getAllFuelRecords = getAllFuelRecords,
        _getFuelRecordsByVehicle = getFuelRecordsByVehicle;

  final GetAllFuelRecords _getAllFuelRecords;
  final GetFuelRecordsByVehicle _getFuelRecordsByVehicle;

  // Cache para avoid repeated queries
  List<FuelRecordEntity>? _cachedRecords;
  DateTime? _cacheTimestamp;
  static const _cacheExpireMs = 60000; // 60 segundos

  /// Carrega todos os registros de combustível
  ///
  /// **Cache behavior:**
  /// - Reutiliza cache se <60s de idade
  /// - Força fresh load se cacheDuration excedido
  ///
  /// **Retorna:**
  /// - Right(records): Lista de combustíveis carregada
  /// - Left(failure): Erro ao carregar
  Future<Either<Failure, List<FuelRecordEntity>>> loadAllRecords({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cachedRecords != null && _cacheTimestamp != null) {
        final age = DateTime.now().difference(_cacheTimestamp!).inMilliseconds;
        if (age < _cacheExpireMs) {
          developer.log(
            '💾 Using cached fuel records (${_cachedRecords!.length} items, age: ${age}ms)',
            name: 'FuelQuery',
          );
          return Right(_cachedRecords!);
        }
      }

      developer.log(
        '📥 Loading all fuel records...',
        name: 'FuelQuery',
      );

      final result = await _getAllFuelRecords();

      return result.fold(
        (failure) {
          developer.log(
            '❌ Failed to load fuel records: ${failure.message}',
            name: 'FuelQuery',
          );
          return Left(failure);
        },
        (records) {
          _cachedRecords = records;
          _cacheTimestamp = DateTime.now();

          developer.log(
            '✅ Loaded ${records.length} fuel records',
            name: 'FuelQuery',
          );
          return Right(records);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Exception loading fuel records: $e',
        name: 'FuelQuery',
      );
      return Left(CacheFailure('Failed to load fuel records: $e'));
    }
  }

  /// Carrega registros de combustível para um veículo específico
  ///
  /// **Quando usar:**
  /// - Filtrar histórico por veículo
  /// - Ver apenas abastecimentos de um veículo
  ///
  /// **Retorna:**
  /// - Right(records): Lista de combustíveis do veículo
  /// - Left(failure): Erro ao carregar
  Future<Either<Failure, List<FuelRecordEntity>>> loadRecordsByVehicle(
    String vehicleId,
  ) async {
    try {
      developer.log(
        '🔍 Loading fuel records for vehicle: $vehicleId',
        name: 'FuelQuery',
      );

      final result = await _getFuelRecordsByVehicle(
        GetFuelRecordsByVehicleParams(vehicleId: vehicleId),
      );

      return result.fold(
        (failure) {
          developer.log(
            '❌ Failed to load vehicle fuel records: ${failure.message}',
            name: 'FuelQuery',
          );
          return Left(failure);
        },
        (records) {
          developer.log(
            '✅ Loaded ${records.length} fuel records for vehicle $vehicleId',
            name: 'FuelQuery',
          );
          return Right(records);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Exception loading vehicle fuel records: $e',
        name: 'FuelQuery',
      );
      return Left(CacheFailure('Failed to load vehicle fuel records: $e'));
    }
  }

  /// Filtra registros por ID de veículo (alias para loadRecordsByVehicle)
  ///
  /// **Quando usar:**
  /// - Implementação obrigatória de IFuelQueryService.filterByVehicle
  /// - Delega para loadRecordsByVehicle internamente
  ///
  /// **Retorna:**
  /// - Right(records): Lista de combustíveis do veículo
  /// - Left(failure): Erro ao carregar
  @override
  Future<Either<Failure, List<FuelRecordEntity>>> filterByVehicle(
    String vehicleId,
  ) async {
    return loadRecordsByVehicle(vehicleId);
  }

  /// Busca registros de combustível por termo (nome do posto, marca, notas)
  ///
  /// **Quando usar:**
  /// - Usuário pesquisa por nome de posto
  /// - Usuário pesquisa por marca
  /// - Usuário pesquisa por notas
  ///
  /// **Retorna:**
  /// - Right(records): Lista de combustíveis encontrados
  /// - Left(failure): Erro na busca
  Future<Either<Failure, List<FuelRecordEntity>>> searchRecords(
    String query,
  ) async {
    try {
      if (query.trim().isEmpty) {
        return Right([]);
      }

      developer.log(
        '🔎 Searching fuel records: "$query"',
        name: 'FuelQuery',
      );

      final allResult = await loadAllRecords();

      return allResult.fold(
        (failure) => Left(failure),
        (records) {
          final queryLower = query.toLowerCase();
          final filtered = records.where((record) {
            return record.gasStationName?.toLowerCase().contains(queryLower) ==
                    true ||
                record.gasStationBrand?.toLowerCase().contains(queryLower) ==
                    true ||
                record.notes?.toLowerCase().contains(queryLower) == true ||
                record.fuelType.displayName.toLowerCase().contains(queryLower);
          }).toList();

          developer.log(
            '✅ Found ${filtered.length} matching fuel records',
            name: 'FuelQuery',
          );
          return Right(filtered);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Exception searching fuel records: $e',
        name: 'FuelQuery',
      );
      return Left(CacheFailure('Failed to search fuel records: $e'));
    }
  }

  /// Invalida cache para forçar reload na próxima consulta
  void invalidateCache() {
    _cachedRecords = null;
    _cacheTimestamp = null;
    developer.log(
      '🔄 Fuel records cache invalidated',
      name: 'FuelQuery',
    );
  }
}
