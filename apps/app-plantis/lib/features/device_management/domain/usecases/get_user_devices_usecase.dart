import 'package:core/core.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../data/models/device_model.dart';
import '../repositories/device_repository.dart';

/// Use case para obter dispositivos do usuário no app-plantis
/// Adapta o use case do core para as necessidades específicas do app
class GetUserDevicesUseCase {
  final DeviceRepository _deviceRepository;
  final AuthStateNotifier _authStateNotifier;

  GetUserDevicesUseCase(this._deviceRepository, this._authStateNotifier);

  /// Executa o use case obtendo dispositivos do usuário atual
  Future<Either<Failure, List<DeviceModel>>> call([
    GetUserDevicesParams? params,
  ]) async {
    try {
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final userId = currentUser.id;
      final activeOnly = params?.activeOnly ?? false;
      final result = await _deviceRepository.getUserDevices(userId);

      return result.fold((failure) => Left(failure), (devices) {
        if (activeOnly) {
          final activeDevices =
              devices.where((device) => device.isActive).toList();
          return Right(activeDevices);
        }
        final sortedDevices = List<DeviceModel>.from(devices)
          ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));

        return Right(sortedDevices);
      });
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos do usuário',
          code: 'GET_USER_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }
}

/// Parâmetros para GetUserDevicesUseCase
class GetUserDevicesParams {
  final bool activeOnly;
  final bool refreshCache;

  const GetUserDevicesParams({
    this.activeOnly = false,
    this.refreshCache = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetUserDevicesParams &&
        other.activeOnly == activeOnly &&
        other.refreshCache == refreshCache;
  }

  @override
  int get hashCode => activeOnly.hashCode ^ refreshCache.hashCode;

  @override
  String toString() =>
      'GetUserDevicesParams(activeOnly: $activeOnly, refreshCache: $refreshCache)';
}
