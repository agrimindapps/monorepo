import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_status.dart';

/// Data source responsável por sincronizar status premium via Firebase
///
/// Fornece sincronização cross-device em tempo real e cache distribuído
/// do status de assinatura premium
@injectable
class PremiumFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final core.IAuthRepository _authService;

  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();

  StreamSubscription<DocumentSnapshot>? _firebaseSubscription;
  Timer? _syncTimer;

  PremiumFirebaseDataSource(this._firestore, this._authService) {
    _initializeFirebaseSync();
  }

  Stream<PremiumStatus> get premiumStatusStream => _statusController.stream;

  /// Inicializa sincronização com Firebase
  void _initializeFirebaseSync() {
    // Escuta mudanças no usuário atual e inicia sync quando logado
    _authService.currentUser.listen((user) {
      if (user != null) {
        _startFirebaseListener(user.id);
        _startPeriodicSync();
      } else {
        _stopFirebaseListener();
        _stopPeriodicSync();
      }
    });
  }

  /// Inicia listener do Firebase para mudanças em tempo real
  void _startFirebaseListener(String userId) {
    _stopFirebaseListener(); // Para listener anterior se existir

    try {
      _firebaseSubscription = _firestore
          .collection('user_subscriptions')
          .doc(userId)
          .snapshots()
          .listen(
            (DocumentSnapshot doc) {
              if (doc.exists && doc.data() != null) {
                final data = doc.data() as Map<String, dynamic>;
                final status = _mapFirebaseDataToPremiumStatus(data);
                _statusController.add(status);
                debugPrint('[FirebaseDataSource] Status atualizado via Firebase');
              }
            },
            onError: (error) {
              debugPrint('[FirebaseDataSource] Erro no stream: $error');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseDataSource] Erro ao iniciar listener: $e');
    }
  }

  /// Para listener do Firebase
  void _stopFirebaseListener() {
    _firebaseSubscription?.cancel();
    _firebaseSubscription = null;
  }

  /// Inicia sincronização periódica (fallback)
  void _startPeriodicSync() {
    _stopPeriodicSync();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      // Get current user from stream
      _authService.currentUser.first.then((user) {
        if (user != null) {
          _syncPremiumStatus(user.id);
        }
      });
    });
  }

  /// Para sincronização periódica
  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sincroniza status premium com Firebase
  Future<Either<Failure, void>> syncPremiumStatus({
    required String userId,
    required PremiumStatus status,
  }) async {
    try {
      final data = _mapPremiumStatusToFirebaseData(status);

      await _firestore
          .collection('user_subscriptions')
          .doc(userId)
          .set(data, SetOptions(merge: true));

      debugPrint('[FirebaseDataSource] Status sincronizado para $userId');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro na sincronização: ${e.toString()}'));
    }
  }

  /// Busca status premium do Firebase
  Future<Either<Failure, PremiumStatus?>> getPremiumStatusFromFirebase({
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('user_subscriptions')
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }

      final data = doc.data() as Map<String, dynamic>;
      final status = _mapFirebaseDataToPremiumStatus(data);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar dados: ${e.toString()}'));
    }
  }

  /// Sincroniza status de múltiplos dispositivos
  Future<Either<Failure, void>> syncCrossDevice({
    required String userId,
  }) async {
    try {
      // Busca dados mais recentes do Firebase
      final firebaseResult = await getPremiumStatusFromFirebase(userId: userId);

      return firebaseResult.fold(
        (failure) => Left(failure),
        (firebaseStatus) async {
          if (firebaseStatus != null) {
            // Notifica sobre atualização
            _statusController.add(firebaseStatus);
            debugPrint('[FirebaseDataSource] Cross-device sync realizado');
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro na sincronização cross-device: ${e.toString()}'));
    }
  }

  /// Cache premium status com TTL
  Future<Either<Failure, void>> cachePremiumStatus({
    required String userId,
    required PremiumStatus status,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    try {
      final data = _mapPremiumStatusToFirebaseData(status);
      data['cache_expires_at'] = DateTime.now().add(ttl).toIso8601String();
      data['cached_at'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('premium_cache')
          .doc(userId)
          .set(data);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer cache: ${e.toString()}'));
    }
  }

  /// Busca premium status do cache
  Future<Either<Failure, PremiumStatus?>> getCachedPremiumStatus({
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('premium_cache')
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }

      final data = doc.data() as Map<String, dynamic>;

      // Verifica se cache expirou
      final expiresAtStr = data['cache_expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          // Cache expirado, remove
          _firestore.collection('premium_cache').doc(userId).delete();
          return const Right(null);
        }
      }

      final status = _mapFirebaseDataToPremiumStatus(data);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar cache: ${e.toString()}'));
    }
  }

  /// Força sincronização imediata
  Future<Either<Failure, void>> forceSyncPremiumStatus({
    required String userId,
  }) async {
    return syncCrossDevice(userId: userId);
  }

  /// Resolve conflitos de sincronização
  Future<Either<Failure, void>> resolveConflicts({
    required String userId,
    required PremiumStatus localStatus,
    required PremiumStatus remoteStatus,
  }) async {
    try {
      final resolvedStatus = _resolveStatusConflict(localStatus, remoteStatus);

      return syncPremiumStatus(
        userId: userId,
        status: resolvedStatus,
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao resolver conflitos: ${e.toString()}'));
    }
  }

  /// Método privado para sincronização automática
  Future<void> _syncPremiumStatus(String userId) async {
    try {
      await syncCrossDevice(userId: userId);
    } catch (e) {
      debugPrint('[FirebaseDataSource] Erro na sincronização automática: $e');
    }
  }

  /// Mapeia PremiumStatus para dados do Firebase
  Map<String, dynamic> _mapPremiumStatusToFirebaseData(PremiumStatus status) {
    return {
      'app_name': 'gasometer',
      'is_premium': status.isPremium,
      'is_expired': status.isExpired,
      'premium_source': status.premiumSource,
      'expiration_date': status.expirationDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'limits': {
        'max_vehicles': status.limits.maxVehicles,
        'max_fuel_records': status.limits.maxFuelRecords,
        'max_maintenance_records': status.limits.maxMaintenanceRecords,
      },
      'features': status.features ?? [],
    };
  }

  /// Mapeia dados do Firebase para PremiumStatus
  PremiumStatus _mapFirebaseDataToPremiumStatus(Map<String, dynamic> data) {
    final isPremium = data['is_premium'] as bool? ?? false;
    final expirationDateStr = data['expiration_date'] as String?;
    DateTime? expirationDate;

    if (expirationDateStr != null) {
      try {
        expirationDate = DateTime.parse(expirationDateStr);
      } catch (e) {
        debugPrint('[FirebaseDataSource] Erro ao parsear data: $e');
      }
    }

    if (!isPremium) {
      return PremiumStatus.free;
    }

    if (data['premium_source'] == 'local_license') {
      return PremiumStatus.localLicense(expiration: expirationDate ?? DateTime.now());
    }

    return PremiumStatus.premium(
      expirationDate: expirationDate ?? DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Resolve conflito entre status local e remoto
  PremiumStatus _resolveStatusConflict(
    PremiumStatus localStatus,
    PremiumStatus remoteStatus,
  ) {
    // Estratégia: sempre priorizar premium
    if (localStatus.isPremium && !remoteStatus.isPremium) {
      return localStatus;
    }
    if (!localStatus.isPremium && remoteStatus.isPremium) {
      return remoteStatus;
    }
    if (localStatus.isPremium && remoteStatus.isPremium) {
      // Ambos premium, usar o com expiração mais distante
      if (localStatus.expirationDate != null && remoteStatus.expirationDate != null) {
        return localStatus.expirationDate!.isAfter(remoteStatus.expirationDate!)
            ? localStatus
            : remoteStatus;
      }
      return localStatus.expirationDate != null ? localStatus : remoteStatus;
    }
    // Ambos free, usar qualquer um
    return localStatus;
  }

  /// Dispose resources
  void dispose() {
    _stopFirebaseListener();
    _stopPeriodicSync();
    _statusController.close();
  }
}