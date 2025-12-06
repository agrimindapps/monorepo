import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/device_entity.dart';
import '../../domain/entities/device_limit_config.dart';
import '../../domain/repositories/i_device_repository.dart';
import '../../shared/utils/failure.dart';

/// Serviço para integração com Firebase Cloud Functions e Firestore
/// Responsável por operações de dispositivos no backend
class FirebaseDeviceService implements IDeviceRepository {
  /// Instância do Firebase Functions para executar cloud functions
  final FirebaseFunctions _functions;

  /// Instância do Firestore para operações de banco de dados
  final FirebaseFirestore _firestore;

  /// Configuração de limites de dispositivos
  final DeviceLimitConfig _limitConfig;

  /// Cria uma instância de FirebaseDeviceService
  FirebaseDeviceService({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    DeviceLimitConfig? limitConfig,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _limitConfig = limitConfig ?? const DeviceLimitConfig();

  /// Valida um dispositivo via Cloud Function
  @override
  Future<Either<Failure, DeviceEntity>> validateDevice({
    required String userId,
    required DeviceEntity device,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 FirebaseDevice: Validating device ${device.uuid}');
      }

      final callable = _functions.httpsCallable('validateDevice');

      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'device': device.toJson(),
      });

      final data = result.data;

      if (data['success'] == true) {
        if (kDebugMode) {
          debugPrint('✅ FirebaseDevice: Device validation successful');
        }

        final validatedDevice = DeviceEntity.fromJson(
          data['device'] as Map<String, dynamic>,
        );

        return Right(validatedDevice);
      } else {
        if (kDebugMode) {
          debugPrint(
            '❌ FirebaseDevice: Device validation failed - ${data['error']}',
          );
        }

        return Left(
          ValidationFailure(
            data['error'] as String? ?? 'Falha na validação do dispositivo',
            code: data['errorCode'] as String? ?? 'VALIDATION_FAILED',
            details: data,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ FirebaseDevice: Functions exception - ${e.code}: ${e.message}',
        );
      }

      return Left(
        FirebaseFailure(
          _mapFirebaseFunctionsError(e),
          code: e.code,
          details: e.details,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseDevice: Unexpected error - $e');
      }

      return Left(
        ServerFailure(
          'Erro ao validar dispositivo via Firebase',
          code: 'FIREBASE_VALIDATE_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Revoga um dispositivo via Cloud Function
  @override
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 FirebaseDevice: Revoking device $deviceUuid');
      }

      final callable = _functions.httpsCallable('revokeDevice');

      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'deviceUuid': deviceUuid,
      });

      final data = result.data;

      if (data['success'] == true) {
        if (kDebugMode) {
          debugPrint('✅ FirebaseDevice: Device revocation successful');
        }
        return const Right(null);
      } else {
        if (kDebugMode) {
          debugPrint(
            '❌ FirebaseDevice: Device revocation failed - ${data['error']}',
          );
        }

        return Left(
          ServerFailure(
            data['error'] as String? ?? 'Falha ao revogar dispositivo',
            code: data['errorCode'] as String? ?? 'REVOKE_FAILED',
            details: data,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ FirebaseDevice: Functions exception - ${e.code}: ${e.message}',
        );
      }

      return Left(
        FirebaseFailure(
          _mapFirebaseFunctionsError(e),
          code: e.code,
          details: e.details,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseDevice: Unexpected error - $e');
      }

      return Left(
        ServerFailure(
          'Erro ao revogar dispositivo via Firebase',
          code: 'FIREBASE_REVOKE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices(
    String userId,
  ) async {
    return getDevicesFromFirestore(userId);
  }

  /// Obtém dispositivos diretamente do Firestore
  Future<Either<Failure, List<DeviceEntity>>> getDevicesFromFirestore(
    String userId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 FirebaseDevice: Getting devices from Firestore for user $userId',
        );
      }

      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('devices')
              .where('isActive', isEqualTo: true)
              .orderBy('lastActiveAt', descending: true)
              .get();

      final devices =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Adiciona o ID do documento
            return DeviceEntity.fromJson(data);
          }).toList();

      if (kDebugMode) {
        debugPrint(
          '✅ FirebaseDevice: Found ${devices.length} devices in Firestore',
        );
      }

      return Right(devices);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ FirebaseDevice: Firestore exception - ${e.code}: ${e.message}',
        );
      }

      return Left(
        FirebaseFailure(
          e.message ?? 'Erro ao acessar Firestore',
          code: e.code,
          details: e,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseDevice: Unexpected error - $e');
      }

      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos no Firestore',
          code: 'FIRESTORE_GET_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String deviceUuid) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 FirebaseDevice: Getting device by UUID $deviceUuid');
      }

      // Note: This requires knowing the userId or doing a collection group query
      // For now, returning not implemented as this would require additional context
      return const Left(
        ServerFailure(
          'getDeviceByUuid requires userId context',
          code: 'NOT_IMPLEMENTED',
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivo por UUID',
          code: 'GET_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 FirebaseDevice: Revoking all devices except $currentDeviceUuid',
        );
      }

      final devicesResult = await getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) async {
          for (final device in devices) {
            if (device.uuid != currentDeviceUuid) {
              final result = await revokeDevice(
                userId: userId,
                deviceUuid: device.uuid,
              );

              if (result.isLeft()) {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ FirebaseDevice: Failed to revoke device ${device.uuid}',
                  );
                }
              }
            }
          }

          if (kDebugMode) {
            debugPrint('✅ FirebaseDevice: All other devices revoked');
          }

          return const Right(null);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseDevice: Error revoking devices - $e');
      }

      return Left(
        ServerFailure(
          'Erro ao revogar dispositivos',
          code: 'REVOKE_ALL_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    return updateDeviceLastActivity(userId: userId, deviceUuid: deviceUuid);
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    try {
      final devicesResult = await getUserDevices(userId);
      
      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          // Conta dispositivos por tipo de plataforma
          int mobileCount = 0;
          int webCount = 0;
          
          for (final device in devices) {
            if (_limitConfig.isMobilePlatform(device.platform)) {
              mobileCount++;
            } else if (_limitConfig.isWebOrDesktopPlatform(device.platform)) {
              webCount++;
            }
          }
          
          // Verifica se pode adicionar mais dispositivos mobile
          // Web não conta no limite por padrão
          final canAdd = mobileCount < _limitConfig.maxMobileDevices;
          
          if (kDebugMode) {
            debugPrint(
              '📱 FirebaseDevice: Mobile: $mobileCount/${_limitConfig.maxMobileDevices}, '
              'Web: $webCount (não conta no limite), canAdd: $canAdd',
            );
          }
          
          return Right(canAdd);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao verificar limite de dispositivos',
          code: 'CHECK_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Verifica limite com resultado detalhado
  Future<Either<Failure, DeviceLimitCheckResult>> checkDeviceLimit(
    String userId, {
    bool isPremium = false,
    String? newDevicePlatform,
  }) async {
    try {
      final devicesResult = await getUserDevices(userId);
      
      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          int mobileCount = 0;
          int webCount = 0;
          
          for (final device in devices) {
            if (_limitConfig.isMobilePlatform(device.platform)) {
              mobileCount++;
            } else if (_limitConfig.isWebOrDesktopPlatform(device.platform)) {
              webCount++;
            }
          }
          
          final mobileLimit = _limitConfig.getLimit(isPremium: isPremium);
          final webLimit = isPremium 
              ? _limitConfig.premiumMaxWebDevices 
              : _limitConfig.maxWebDevices;
          
          // Se está verificando para um novo dispositivo específico
          if (newDevicePlatform != null) {
            final canAdd = _limitConfig.canAddMoreDevices(
              currentMobileCount: mobileCount,
              currentWebCount: webCount,
              isPremium: isPremium,
              newDevicePlatform: newDevicePlatform,
            );
            
            if (canAdd) {
              return Right(DeviceLimitCheckResult.allowed(
                currentMobileCount: mobileCount,
                currentWebCount: webCount,
                mobileLimit: mobileLimit,
                webLimit: webLimit,
              ));
            } else {
              return Right(DeviceLimitCheckResult.limitExceeded(
                currentMobileCount: mobileCount,
                currentWebCount: webCount,
                mobileLimit: mobileLimit,
                webLimit: webLimit,
              ));
            }
          }
          
          // Verifica apenas mobile (padrão)
          final canAdd = mobileCount < mobileLimit;
          
          if (canAdd) {
            return Right(DeviceLimitCheckResult.allowed(
              currentMobileCount: mobileCount,
              currentWebCount: webCount,
              mobileLimit: mobileLimit,
              webLimit: webLimit,
            ));
          } else {
            return Right(DeviceLimitCheckResult.limitExceeded(
              currentMobileCount: mobileCount,
              currentWebCount: webCount,
              mobileLimit: mobileLimit,
              webLimit: webLimit,
            ));
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao verificar limite de dispositivos',
          code: 'CHECK_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getDeviceLimit(String userId) async {
    // Retorna o limite de dispositivos mobile da configuração
    // TODO: Integrar com subscription status para premium
    return Right(_limitConfig.maxMobileDevices);
  }

  /// Obtém a configuração atual de limites
  DeviceLimitConfig get limitConfig => _limitConfig;

  /// Obtém contagem de dispositivos por tipo
  Future<Either<Failure, Map<String, int>>> getDeviceCountByType(String userId) async {
    try {
      final devicesResult = await getUserDevices(userId);
      
      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          int mobileCount = 0;
          int webCount = 0;
          int otherCount = 0;
          
          for (final device in devices) {
            if (_limitConfig.isMobilePlatform(device.platform)) {
              mobileCount++;
            } else if (_limitConfig.isWebOrDesktopPlatform(device.platform)) {
              webCount++;
            } else {
              otherCount++;
            }
          }
          
          return Right({
            'mobile': mobileCount,
            'web': webCount,
            'other': otherCount,
            'total': devices.length,
          });
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao contar dispositivos por tipo',
          code: 'COUNT_BY_TYPE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> cleanupInactiveDevices({
    required String userId,
    required int inactiveDays,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🧹 FirebaseDevice: Cleaning up devices inactive for $inactiveDays days',
        );
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: inactiveDays));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .where('isActive', isEqualTo: true)
          .get();

      final deletedDevices = <String>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final lastActiveStr = data['lastActiveAt'] as String?;

        if (lastActiveStr != null) {
          final lastActive = DateTime.parse(lastActiveStr);

          if (lastActive.isBefore(cutoffDate)) {
            await doc.reference.update({
              'isActive': false,
              'updatedAt': DateTime.now().toIso8601String(),
            });
            deletedDevices.add(data['uuid'] as String? ?? doc.id);
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '✅ FirebaseDevice: Cleaned up ${deletedDevices.length} devices',
        );
      }

      return Right(deletedDevices);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseDevice: Cleanup error - $e');
      }

      return Left(
        ServerFailure(
          'Erro ao limpar dispositivos inativos',
          code: 'CLEANUP_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(
    String userId,
  ) async {
    try {
      final devicesResult = await getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          final platformCounts = <String, int>{};
          DeviceEntity? lastActive;
          DeviceEntity? oldest;
          DeviceEntity? newest;

          for (final device in devices) {
            // Count by platform
            platformCounts[device.platform] =
                (platformCounts[device.platform] ?? 0) + 1;

            // Find last active device
            if (lastActive == null) {
              lastActive = device;
            } else if (device.lastActiveAt.isAfter(lastActive.lastActiveAt)) {
              lastActive = device;
            }

            // Find oldest device
            if (oldest == null) {
              oldest = device;
            } else if (device.createdAt != null) {
              final oldestCreated = oldest.createdAt;
              if (oldestCreated != null &&
                  device.createdAt!.isBefore(oldestCreated)) {
                oldest = device;
              }
            }

            // Find newest device
            if (newest == null) {
              newest = device;
            } else if (device.createdAt != null) {
              final newestCreated = newest.createdAt;
              if (newestCreated != null &&
                  device.createdAt!.isAfter(newestCreated)) {
                newest = device;
              }
            }
          }

          final stats = DeviceStatistics(
            totalDevices: devices.length,
            activeDevices: devices.length,
            devicesByPlatform: platformCounts,
            lastActiveDevice: lastActive,
            oldestDevice: oldest,
            newestDevice: newest,
          );

          return Right(stats);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas de dispositivos',
          code: 'STATS_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> syncDevices(String userId) async {
    // For Firebase-based implementation, sync is automatic
    // Just return current devices
    return getUserDevices(userId);
  }

  /// Atualiza última atividade de um dispositivo diretamente no Firestore
  Future<Either<Failure, DeviceEntity>> updateDeviceLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 FirebaseDevice: Updating last activity for device $deviceUuid',
        );
      }

      final deviceQuery =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('devices')
              .where('uuid', isEqualTo: deviceUuid)
              .limit(1)
              .get();

      if (deviceQuery.docs.isEmpty) {
        return const Left(
          NotFoundFailure(
            'Dispositivo não encontrado',
            code: 'DEVICE_NOT_FOUND',
          ),
        );
      }

      final deviceDoc = deviceQuery.docs.first;
      final now = DateTime.now();

      await deviceDoc.reference.update({
        'lastActiveAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
      final updatedDoc = await deviceDoc.reference.get();
      final data = updatedDoc.data()!;
      data['id'] = updatedDoc.id;

      final updatedDevice = DeviceEntity.fromJson(data);

      if (kDebugMode) {
        debugPrint('✅ FirebaseDevice: Device activity updated successfully');
      }

      return Right(updatedDevice);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ FirebaseDevice: Firestore exception - ${e.code}: ${e.message}',
        );
      }

      return Left(
        FirebaseFailure(
          e.message ?? 'Erro ao atualizar atividade no Firestore',
          code: e.code,
          details: e,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseDevice: Unexpected error - $e');
      }

      return Left(
        ServerFailure(
          'Erro ao atualizar atividade do dispositivo',
          code: 'FIRESTORE_UPDATE_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Obtém contagem de dispositivos ativos
  /// Por padrão, conta apenas dispositivos mobile (não web)
  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    try {
      // Busca todos os dispositivos ativos
      final devicesResult = await getUserDevices(userId);
      
      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          // Conta apenas dispositivos mobile
          final mobileCount = devices
              .where((d) => _limitConfig.isMobilePlatform(d.platform))
              .length;
          
          if (kDebugMode) {
            debugPrint(
              '📱 FirebaseDevice: Active mobile devices: $mobileCount '
              '(total: ${devices.length}, web/desktop não contados)',
            );
          }
          
          return Right(mobileCount);
        },
      );
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(
          e.message ?? 'Erro ao contar dispositivos',
          code: e.code,
          details: e,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao contar dispositivos ativos',
          code: 'FIRESTORE_COUNT_ERROR',
          details: e,
        ),
      );
    }
  }

  /// Mapeia erros do Firebase Functions para mensagens user-friendly
  String _mapFirebaseFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'permission-denied':
        return 'Você não tem permissão para esta operação.';
      case 'not-found':
        return 'Recurso não encontrado.';
      case 'already-exists':
        return 'O recurso já existe.';
      case 'resource-exhausted':
        return 'Limite de recursos excedido. Tente novamente mais tarde.';
      case 'failed-precondition':
        return 'Condições não atendidas para a operação.';
      case 'aborted':
        return 'Operação cancelada devido a conflito.';
      case 'out-of-range':
        return 'Parâmetros fora do intervalo válido.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno do servidor. Tente novamente.';
      case 'unavailable':
        return 'Serviço temporariamente indisponível.';
      case 'data-loss':
        return 'Perda de dados detectada.';
      case 'unknown':
      default:
        return e.message ?? 'Erro desconhecido no Firebase Functions.';
    }
  }
}

/// Resultado de operação do Firebase
///
/// Encapsula o resultado de uma operação Firebase com suporte para
/// dados de sucesso, mensagens de erro, códigos e detalhes adicionais.
/// Usado internamente para padronizar respostas de operações Firebase.
class FirebaseOperationResult<T> {
  /// Indica se a operação foi bem-sucedida
  final bool success;

  /// Dados retornados em caso de sucesso (null se falha)
  final T? data;

  /// Mensagem de erro em caso de falha (null se sucesso)
  final String? error;

  /// Código de erro para categorização (null se sucesso)
  final String? errorCode;

  /// Detalhes adicionais da operação (exceções, stack traces, etc)
  final Map<String, dynamic>? details;

  /// Cria uma instância de FirebaseOperationResult
  const FirebaseOperationResult({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
    this.details,
  });

  /// Factory para criar resultado de sucesso
  factory FirebaseOperationResult.success(T data) {
    return FirebaseOperationResult(success: true, data: data);
  }

  /// Factory para criar resultado de erro
  factory FirebaseOperationResult.error(
    String error, {
    String? errorCode,
    Map<String, dynamic>? details,
  }) {
    return FirebaseOperationResult(
      success: false,
      error: error,
      errorCode: errorCode,
      details: details,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'errorCode': errorCode,
      'details': details,
    };
  }

  /// Cria instância do JSON
  factory FirebaseOperationResult.fromJson(Map<String, dynamic> json) {
    return FirebaseOperationResult(
      success: json['success'] as bool,
      data: json['data'] as T?,
      error: json['error'] as String?,
      errorCode: json['errorCode'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() =>
      'FirebaseOperationResult(success: $success, error: $error)';
}
