import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/i_device_repository.dart';
import '../../shared/utils/failure.dart';
import 'firebase_analytics_service.dart';
import 'firebase_auth_service.dart';
import 'firebase_device_service.dart';

/// Serviço de alto nível para gerenciamento de dispositivos
/// Integra Firebase, Analytics e Repository para operações de dispositivos
class DeviceManagementService {
  final FirebaseDeviceService _firebaseDeviceService;
  final FirebaseAuthService _authService;
  final FirebaseAnalyticsService _analyticsService;
  final IDeviceRepository _deviceRepository;

  DeviceManagementService({
    required FirebaseDeviceService firebaseDeviceService,
    required FirebaseAuthService authService,
    required FirebaseAnalyticsService analyticsService,
    required IDeviceRepository deviceRepository,
  })  : _firebaseDeviceService = firebaseDeviceService,
        _authService = authService,
        _analyticsService = analyticsService,
        _deviceRepository = deviceRepository;

  /// Obtém todos os dispositivos do usuário atual
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual via stream (primeiro valor)
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      if (kDebugMode) {
        debugPrint('🔄 DeviceManagement: Getting devices for user ${user.id}');
      }

      final result = await _deviceRepository.getUserDevices(user.id);
      
      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceManagement: Failed to get devices - $failure');
          }
          return Left(failure);
        },
        (devices) {
          if (kDebugMode) {
            debugPrint('✅ DeviceManagement: Found ${devices.length} devices');
          }
          
          // Log analytics event
          unawaited(_analyticsService.logEvent(
            'device_list_viewed',
            parameters: {
              'device_count': devices.length,
              'active_devices': devices.where((d) => d.isActive).length,
            },
          ));
          
          return Right(devices);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagement: Unexpected error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos',
          code: 'GET_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Valida um dispositivo para o usuário atual
  Future<Either<Failure, DeviceEntity>> validateDevice(DeviceEntity device) async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      if (kDebugMode) {
        debugPrint('🔄 DeviceManagement: Validating device ${device.uuid} for user ${user.id}');
      }

      // Primeiro verifica se pode adicionar mais dispositivos
      final canAddResult = await _deviceRepository.canAddMoreDevices(user.id);
      
      return await canAddResult.fold(
        (failure) async => Left(failure),
        (canAdd) async {
          // Verifica se o dispositivo já existe
          final existingResult = await _deviceRepository.getDeviceByUuid(device.uuid);
          
          return await existingResult.fold(
            (failure) async => Left(failure),
            (existingDevice) async {
              if (existingDevice != null) {
                // Dispositivo já existe, apenas atualiza atividade
                if (kDebugMode) {
                  debugPrint('📱 DeviceManagement: Device exists, updating activity');
                }
                
                final updateResult = await _deviceRepository.updateLastActivity(
                  userId: user.id,
                  deviceUuid: device.uuid,
                );
                
                // Log analytics
                unawaited(_analyticsService.logEvent(
                  'device_activity_updated',
                  parameters: {
                    'device_uuid': device.uuid,
                    'device_platform': device.platform,
                  },
                ));
                
                return updateResult;
              }
              
              // Dispositivo novo
              if (!canAdd) {
                if (kDebugMode) {
                  debugPrint('❌ DeviceManagement: Device limit exceeded');
                }
                
                // Log analytics
                unawaited(_analyticsService.logEvent(
                  'device_limit_exceeded',
                  parameters: {
                    'user_id': user.id,
                    'attempted_device': device.uuid,
                  },
                ));
                
                return const Left(
                  ValidationFailure(
                    'Limite de dispositivos atingido',
                    code: 'DEVICE_LIMIT_EXCEEDED',
                  ),
                );
              }
              
              // Valida via Firebase Cloud Function
              final validationResult = await _firebaseDeviceService.validateDevice(
                userId: user.id,
                device: device,
              );
              
              return validationResult.fold(
                (failure) {
                  if (kDebugMode) {
                    debugPrint('❌ DeviceManagement: Firebase validation failed - $failure');
                  }
                  
                  // Log analytics
                  unawaited(_analyticsService.logEvent(
                    'device_validation_failed',
                    parameters: {
                      'device_uuid': device.uuid,
                      'error_code': failure.code,
                    },
                  ));
                  
                  return Left(failure);
                },
                (validatedDevice) {
                  if (kDebugMode) {
                    debugPrint('✅ DeviceManagement: Device validated successfully');
                  }
                  
                  // Log analytics
                  unawaited(_analyticsService.logEvent(
                    'device_validated',
                    parameters: {
                      'device_uuid': validatedDevice.uuid,
                      'device_platform': validatedDevice.platform,
                      'device_model': validatedDevice.model,
                      'is_physical': validatedDevice.isPhysicalDevice,
                    },
                  ));
                  
                  return Right(validatedDevice);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagement: Unexpected validation error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao validar dispositivo',
          code: 'VALIDATE_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Revoga um dispositivo específico
  Future<Either<Failure, void>> revokeDevice(String deviceUuid) async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      if (kDebugMode) {
        debugPrint('🔄 DeviceManagement: Revoking device $deviceUuid for user ${user.id}');
      }

      // Revoga via Firebase Cloud Function
      final revokeResult = await _firebaseDeviceService.revokeDevice(
        userId: user.id,
        deviceUuid: deviceUuid,
      );
      
      return revokeResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceManagement: Failed to revoke device - $failure');
          }
          
          // Log analytics
          unawaited(_analyticsService.logEvent(
            'device_revoke_failed',
            parameters: {
              'device_uuid': deviceUuid,
              'error_code': failure.code,
            },
          ));
          
          return Left(failure);
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ DeviceManagement: Device revoked successfully');
          }
          
          // Log analytics
          unawaited(_analyticsService.logEvent(
            'device_revoked',
            parameters: {
              'device_uuid': deviceUuid,
            },
          ));
          
          return const Right(null);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagement: Unexpected revoke error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao revogar dispositivo',
          code: 'REVOKE_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Verifica se o usuário pode adicionar mais dispositivos
  Future<Either<Failure, bool>> canAddMoreDevices() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      return await _deviceRepository.canAddMoreDevices(user.id);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao verificar limite de dispositivos',
          code: 'CHECK_DEVICE_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Obtém estatísticas de dispositivos do usuário
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      final result = await _deviceRepository.getDeviceStatistics(user.id);
      
      result.fold(
        (failure) => null,
        (stats) {
          // Log analytics
          unawaited(_analyticsService.logEvent(
            'device_statistics_viewed',
            parameters: {
              'total_devices': stats.totalDevices,
              'active_devices': stats.activeDevices,
            },
          ));
        },
      );
      
      return result;
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas de dispositivos',
          code: 'GET_DEVICE_STATS_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<Either<Failure, void>> revokeAllOtherDevices(String currentDeviceUuid) async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      if (kDebugMode) {
        debugPrint('🔄 DeviceManagement: Revoking all other devices for user ${user.id}');
      }

      final result = await _deviceRepository.revokeAllOtherDevices(
        userId: user.id,
        currentDeviceUuid: currentDeviceUuid,
      );
      
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceManagement: Failed to revoke other devices - $failure');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ DeviceManagement: All other devices revoked');
          }
          
          // Log analytics
          unawaited(_analyticsService.logEvent(
            'all_other_devices_revoked',
            parameters: {
              'current_device': currentDeviceUuid,
            },
          ));
        },
      );
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagement: Unexpected error revoking other devices - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao revogar outros dispositivos',
          code: 'REVOKE_OTHER_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Limpa dispositivos inativos por mais de X dias
  Future<Either<Failure, int>> cleanupInactiveDevices({int inactiveDays = 90}) async {
    try {
      final isLoggedIn = await _authService.isLoggedIn;
      if (!isLoggedIn) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Obtém o usuário atual
      final userStream = _authService.currentUser;
      final user = await userStream.first;
      
      if (user == null) {
        return const Left(AuthFailure('Usuário não encontrado'));
      }

      final result = await _deviceRepository.cleanupInactiveDevices(
        userId: user.id,
        inactiveDays: inactiveDays,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (removedDevices) {
          if (kDebugMode) {
            debugPrint('✅ DeviceManagement: Cleaned up ${removedDevices.length} inactive devices');
          }
          
          // Log analytics
          unawaited(_analyticsService.logEvent(
            'inactive_devices_cleaned',
            parameters: {
              'removed_count': removedDevices.length,
              'inactive_days': inactiveDays,
            },
          ));
          
          return Right(removedDevices.length);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao limpar dispositivos inativos',
          code: 'CLEANUP_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }
}