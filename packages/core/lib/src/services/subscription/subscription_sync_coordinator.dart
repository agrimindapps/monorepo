import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../domain/interfaces/i_disposable_service.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../shared/utils/failure.dart';

/// Coordenador de sincronização de subscription entre RevenueCat e Firebase
///
/// Este serviço:
/// 1. Escuta atualizações do RevenueCat (compras, restaurações, etc)
/// 2. Sincroniza automaticamente para o Firebase Firestore
/// 3. Escuta atualizações do Firebase (cross-device sync)
/// 4. Mantém cache local para acesso offline
///
/// Fluxo de sincronização:
/// ```
/// RevenueCat Purchase → SubscriptionSyncCoordinator → Firebase Firestore
///                                                    ↓
/// Firebase Listener ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ↑
///       ↓
/// Local Cache Update → UI Notification
/// ```
class SubscriptionSyncCoordinator implements IDisposableService {
  SubscriptionSyncCoordinator({
    required ISubscriptionRepository subscriptionRepository,
    required IAuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _subscriptionRepository = subscriptionRepository,
        _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final ISubscriptionRepository _subscriptionRepository;
  final IAuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  static const String _collectionPath = 'user_subscriptions';
  static const String _tag = '[SubscriptionSyncCoordinator]';

  // Stream controllers
  final BehaviorSubject<SubscriptionEntity?> _subscriptionController =
      BehaviorSubject<SubscriptionEntity?>.seeded(null);

  // Subscriptions
  StreamSubscription<SubscriptionEntity?>? _revenueCatSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;
  StreamSubscription<dynamic>? _authSubscription;

  // State
  String? _currentUserId;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isSyncing = false;

  // ==================== Public API ====================

  /// Stream com status atual da subscription (offline-first)
  Stream<SubscriptionEntity?> get subscriptionStream =>
      _subscriptionController.stream;

  /// Subscription atual em cache
  SubscriptionEntity? get currentSubscription => _subscriptionController.value;

  /// Se há subscription ativa
  bool get hasActiveSubscription =>
      _subscriptionController.value?.isActive ?? false;

  /// Se está sincronizando
  bool get isSyncing => _isSyncing;

  @override
  bool get isDisposed => _isDisposed;

  /// Inicializa o coordenador
  Future<void> initialize() async {
    if (_isInitialized) return;

    _log('Initializing...');

    // Listen to auth changes
    _authSubscription = _authRepository.currentUser.listen(_onAuthChanged);

    // Listen to RevenueCat updates (only on mobile)
    if (!kIsWeb) {
      _revenueCatSubscription =
          _subscriptionRepository.subscriptionStatus.listen(
        _onRevenueCatUpdate,
        onError: (Object error) => _log('RevenueCat error: $error', isError: true),
      );
    }

    _isInitialized = true;
    _log('Initialized successfully');
  }

  /// Força sincronização completa
  Future<Either<Failure, SubscriptionEntity?>> forceSync() async {
    if (_currentUserId == null) {
      return const Left(ServerFailure('User not authenticated'));
    }

    _isSyncing = true;
    _log('Force sync started for user: $_currentUserId');

    try {
      // 1. Fetch from RevenueCat (primary source)
      SubscriptionEntity? subscription;
      
      if (!kIsWeb) {
        final revenueCatResult =
            await _subscriptionRepository.getCurrentSubscription();
        subscription = revenueCatResult.fold(
          (failure) {
            _log('RevenueCat fetch failed: ${failure.message}', isError: true);
            return null;
          },
          (sub) => sub,
        );
      }

      // 2. If no RevenueCat data, try Firebase
      if (subscription == null) {
        final firebaseResult = await _fetchFromFirebase();
        subscription = firebaseResult.fold(
          (failure) => null,
          (sub) => sub,
        );
      }

      // 3. Update local state
      if (!_subscriptionController.isClosed) {
        _subscriptionController.add(subscription);
      }

      // 4. Sync to Firebase if we have data from RevenueCat
      if (subscription != null && !kIsWeb) {
        await _syncToFirebase(subscription);
      }

      _log('Force sync completed: ${subscription?.isActive}');
      return Right(subscription);
    } catch (e) {
      _log('Force sync error: $e', isError: true);
      return Left(ServerFailure('Sync failed: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Verifica se tem subscription ativa para um app específico
  Future<Either<Failure, bool>> hasActiveSubscriptionForApp(
    String appName,
  ) async {
    final subscription = _subscriptionController.value;
    if (subscription == null || !subscription.isActive) {
      return const Right(false);
    }

    final productId = subscription.productId.toLowerCase();
    return Right(productId.contains(appName.toLowerCase()));
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _log('Disposing...');

    await _revenueCatSubscription?.cancel();
    await _firestoreSubscription?.cancel();
    await _authSubscription?.cancel();

    await _subscriptionController.close();

    _isInitialized = false;
    _log('Disposed');
  }

  // ==================== Private Methods ====================

  /// Handle auth state changes
  void _onAuthChanged(dynamic user) {
    if (user != null && user.id != null) {
      final userId = user.id as String;
      _log('User logged in: $userId');

      _currentUserId = userId;
      _startFirestoreListener(userId);

      // Trigger initial sync
      unawaited(forceSync());
    } else {
      _log('User logged out');

      _currentUserId = null;
      _stopFirestoreListener();

      if (!_subscriptionController.isClosed) {
        _subscriptionController.add(null);
      }
    }
  }

  /// Handle RevenueCat subscription update
  void _onRevenueCatUpdate(SubscriptionEntity? subscription) {
    _log('RevenueCat update received: ${subscription?.isActive}');

    // Update local state
    if (!_subscriptionController.isClosed) {
      _subscriptionController.add(subscription);
    }

    // Sync to Firebase
    if (_currentUserId != null && subscription != null) {
      unawaited(_syncToFirebase(subscription));
    }
  }

  /// Start listening to Firebase changes
  void _startFirestoreListener(String userId) {
    _stopFirestoreListener();

    _log('Starting Firestore listener for user: $userId');

    try {
      _firestoreSubscription = _firestore
          .collection(_collectionPath)
          .doc(userId)
          .snapshots()
          .listen(
            _onFirestoreUpdate,
            onError: (Object error) =>
                _log('Firestore error: $error', isError: true),
          );
    } catch (e) {
      _log('Failed to start Firestore listener: $e', isError: true);
    }
  }

  /// Stop Firestore listener
  void _stopFirestoreListener() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  /// Handle Firestore document update (cross-device sync)
  void _onFirestoreUpdate(DocumentSnapshot snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      _log('Firestore: document empty or deleted');
      return;
    }

    try {
      final data = snapshot.data() as Map<String, dynamic>;
      final subscription = _mapFirestoreToSubscription(data);

      if (subscription != null) {
        final current = _subscriptionController.value;

        // Only update if Firebase has newer/different data
        if (current == null || _isFirebaseNewer(current, subscription, data)) {
          _log('Firestore update: syncing newer data');
          if (!_subscriptionController.isClosed) {
            _subscriptionController.add(subscription);
          }
        }
      }
    } catch (e) {
      _log('Firestore parse error: $e', isError: true);
    }
  }

  /// Fetch subscription from Firebase
  Future<Either<Failure, SubscriptionEntity?>> _fetchFromFirebase() async {
    if (_currentUserId == null) {
      return const Right(null);
    }

    try {
      _log('Fetching from Firebase...');

      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_currentUserId)
          .get();

      if (!doc.exists || doc.data() == null) {
        _log('No data in Firebase');
        return const Right(null);
      }

      final subscription = _mapFirestoreToSubscription(doc.data()!);
      _log('Fetched from Firebase: ${subscription?.isActive}');

      return Right(subscription);
    } catch (e) {
      _log('Firebase fetch error: $e', isError: true);
      return Left(ServerFailure('Firebase fetch failed: $e'));
    }
  }

  /// Sync subscription to Firebase
  Future<void> _syncToFirebase(SubscriptionEntity subscription) async {
    if (_currentUserId == null) return;

    try {
      _log('Syncing to Firebase...');

      final data = _mapSubscriptionToFirestore(subscription);

      await _firestore
          .collection(_collectionPath)
          .doc(_currentUserId)
          .set(data, SetOptions(merge: true));

      _log('Synced to Firebase successfully');
    } catch (e) {
      _log('Firebase sync error: $e', isError: true);
    }
  }

  /// Check if Firebase data is newer than local
  bool _isFirebaseNewer(
    SubscriptionEntity local,
    SubscriptionEntity firebase,
    Map<String, dynamic> data,
  ) {
    // If local is from RevenueCat and we're on mobile, local is authoritative
    if (!kIsWeb) return false;

    // On web, Firebase is the only source
    final firebaseUpdatedAt = data['updatedAt'];
    if (firebaseUpdatedAt == null) return false;

    DateTime? firebaseTime;
    if (firebaseUpdatedAt is Timestamp) {
      firebaseTime = firebaseUpdatedAt.toDate();
    }

    if (firebaseTime == null || local.updatedAt == null) return true;

    return firebaseTime.isAfter(local.updatedAt!);
  }

  /// Map Firestore data to SubscriptionEntity
  SubscriptionEntity? _mapFirestoreToSubscription(Map<String, dynamic> data) {
    try {
      final isActive = data['isActive'] as bool? ?? false;
      if (!isActive) return null;

      final productId = data['productId'] as String? ?? 'unknown';
      final userId = _currentUserId ?? 'unknown';

      DateTime? expirationDate;
      if (data['expirationDate'] != null) {
        final timestamp = data['expirationDate'];
        if (timestamp is Timestamp) {
          expirationDate = timestamp.toDate();
        } else if (timestamp is String) {
          expirationDate = DateTime.tryParse(timestamp);
        }
      }

      DateTime? purchaseDate;
      if (data['purchaseDate'] != null) {
        final timestamp = data['purchaseDate'];
        if (timestamp is Timestamp) {
          purchaseDate = timestamp.toDate();
        } else if (timestamp is String) {
          purchaseDate = DateTime.tryParse(timestamp);
        }
      }

      DateTime? updatedAt;
      if (data['updatedAt'] != null) {
        final timestamp = data['updatedAt'];
        if (timestamp is Timestamp) {
          updatedAt = timestamp.toDate();
        }
      }

      final statusStr = data['status'] as String? ?? 'active';
      final status = SubscriptionStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => SubscriptionStatus.active,
      );

      final tierStr = data['tier'] as String? ?? 'premium';
      final tier = SubscriptionTier.values.firstWhere(
        (t) => t.name == tierStr,
        orElse: () => SubscriptionTier.premium,
      );

      final storeStr = data['store'] as String? ?? 'unknown';
      final store = Store.values.firstWhere(
        (s) => s.name == storeStr,
        orElse: () => Store.unknown,
      );

      return SubscriptionEntity(
        id: '$userId-$productId',
        userId: userId,
        productId: productId,
        status: status,
        tier: tier,
        expirationDate: expirationDate,
        purchaseDate: purchaseDate,
        store: store,
        isInTrial: data['isInTrial'] as bool? ?? false,
        isSandbox: data['isSandbox'] as bool? ?? false,
        updatedAt: updatedAt,
      );
    } catch (e) {
      _log('Error mapping Firestore data: $e', isError: true);
      return null;
    }
  }

  /// Map SubscriptionEntity to Firestore data
  Map<String, dynamic> _mapSubscriptionToFirestore(
    SubscriptionEntity subscription,
  ) {
    return {
      'isActive': subscription.isActive,
      'productId': subscription.productId,
      'status': subscription.status.name,
      'tier': subscription.tier.name,
      'store': subscription.store.name,
      'expirationDate': subscription.expirationDate != null
          ? Timestamp.fromDate(subscription.expirationDate!)
          : null,
      'purchaseDate': subscription.purchaseDate != null
          ? Timestamp.fromDate(subscription.purchaseDate!)
          : null,
      'isInTrial': subscription.isInTrial,
      'isSandbox': subscription.isSandbox,
      'updatedAt': FieldValue.serverTimestamp(),
      'syncedFrom': kIsWeb ? 'web' : 'mobile',
      'platform': kIsWeb
          ? 'web'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
    };
  }

  void _log(String message, {bool isError = false}) {
    if (kDebugMode) {
      if (isError) {
        debugPrint('$_tag ERROR: $message');
      } else {
        debugPrint('$_tag $message');
      }
    }
  }
}
