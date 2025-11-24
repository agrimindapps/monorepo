import 'package:core/core.dart'
    hide GetUserDevicesUseCase, GetUserDevicesParams;

import '../../domain/usecases/get_device_statistics_usecase.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';

/// Service para inicialização de dispositivos
/// Centraliza lógica de carregamento de dados
class DeviceInitializationService {
  final GetUserDevicesUseCase _getUserDevicesUseCase;
  final GetDeviceStatisticsUseCase _getDeviceStatisticsUseCase;

  DeviceInitializationService({
    required GetUserDevicesUseCase getUserDevicesUseCase,
    required GetDeviceStatisticsUseCase getDeviceStatisticsUseCase,
  })  : _getUserDevicesUseCase = getUserDevicesUseCase,
        _getDeviceStatisticsUseCase = getDeviceStatisticsUseCase;

  /// Carrega lista de dispositivos do usuário
  Future<Either<Failure, List<dynamic>>> loadUserDevices() async {
    return _getUserDevicesUseCase(const GetUserDevicesParams());
  }

  /// Carrega estatísticas de dispositivos
  Future<Either<Failure, dynamic>> loadDeviceStatistics() async {
    return _getDeviceStatisticsUseCase(null);
  }
}
