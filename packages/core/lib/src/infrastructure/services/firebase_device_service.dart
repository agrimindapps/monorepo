import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/device_entity.dart';
import '../../shared/utils/failure.dart';

/// Serviço para integração com Firebase Cloud Functions e Firestore
/// Responsável por operações de dispositivos no backend
class FirebaseDeviceService {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  FirebaseDeviceService({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Valida um dispositivo via Cloud Function
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

      // Retorna o dispositivo atualizado
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
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('devices')
              .where('isActive', isEqualTo: true)
              .count()
              .get();

      return Right(querySnapshot.count ?? 0);
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
class FirebaseOperationResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;
  final Map<String, dynamic>? details;

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
