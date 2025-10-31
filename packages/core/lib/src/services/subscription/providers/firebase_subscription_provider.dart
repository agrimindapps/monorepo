import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/services/i_subscription_data_provider.dart';
import '../../../shared/utils/failure.dart';

/// Firebase Firestore subscription data provider
///
/// Secondary source for cross-device subscription sync.
///
/// Priority: 80
/// - Enables real-time sync across devices
/// - Acts as distributed cache
/// - Survives app reinstalls
///
/// Firestore structure:
/// ```
/// user_subscriptions/{userId}
///   - isActive: bool
///   - productId: string
///   - expirationDate: timestamp
///   - updatedAt: timestamp
///   - syncedFrom: string (revenuecat/webhook)
/// ```
///
/// Usage:
/// ```dart
/// final provider = FirebaseSubscriptionProvider(
///   firestore: FirebaseFirestore.instance,
///   authRepository: authRepo,
/// );
///
/// await provider.initialize();
///
/// // Listen to updates
/// provider.updates.listen((subscription) {
///   print('Firebase: ${subscription?.isActive}');
/// });
/// ```
@lazySingleton
class FirebaseSubscriptionProvider implements ISubscriptionDataProvider {
  /// Creates a Firebase subscription provider.
  FirebaseSubscriptionProvider({
    required FirebaseFirestore firestore,
    required IAuthRepository authRepository,
  }) : _firestore = firestore,
       _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final IAuthRepository _authRepository;

  static const String _collectionPath = 'user_subscriptions';

  final BehaviorSubject<SubscriptionEntity?> _updatesController =
      BehaviorSubject<SubscriptionEntity?>.seeded(null);

  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;
  StreamSubscription<dynamic>? _authSubscription;
  Timer? _periodicSyncTimer;

  String? _currentUserId;
  bool _isEnabled = true;
  bool _isInitialized = false;

  // ==================== ISubscriptionDataProvider Implementation ====================

  @override
  String get name => 'Firebase';

  @override
  Stream<SubscriptionEntity?> get updates => _updatesController.stream;

  @override
  int get priority => 80; // High priority, below RevenueCat

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<Either<Failure, SubscriptionEntity?>> fetch() async {
    try {
      if (_currentUserId == null) {
        _log('No user logged in', isError: true);
        return const Right(null);
      }

      _log('Fetching subscription from Firebase for user: $_currentUserId');

      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_currentUserId)
          .get();

      if (!doc.exists || doc.data() == null) {
        _log('No data found in Firebase');
        return const Right(null);
      }

      final subscription = _mapFirestoreDataToSubscription(doc.data()!);
      _log('Fetched: ${subscription?.isActive}');

      // Update stream
      if (!_updatesController.isClosed) {
        _updatesController.add(subscription);
      }

      return Right(subscription);
    } catch (e) {
      _log('Fetch error: $e', isError: true);
      return Left(ServerFailure('Firebase fetch failed: ${e.toString()}'));
    }
  }

  // ==================== Lifecycle ====================

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _log('Initializing provider');

    // Listen to auth changes
    _authSubscription = _authRepository.currentUser.listen(_onAuthChanged);

    // Start periodic sync (fallback if realtime fails)
    _startPeriodicSync();

    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _log('Disposing provider');

    await _firestoreSubscription?.cancel();
    await _authSubscription?.cancel();
    _periodicSyncTimer?.cancel();

    await _updatesController.close();

    _isInitialized = false;
  }

  // ==================== Auth Integration ====================

  /// Handle auth state changes
  void _onAuthChanged(dynamic user) {
    if (user != null && user.id != null) {
      final userId = user.id as String;
      _log('User logged in: $userId');

      _currentUserId = userId;
      _startFirestoreListener(userId);
    } else {
      _log('User logged out');

      _currentUserId = null;
      _stopFirestoreListener();

      if (!_updatesController.isClosed) {
        _updatesController.add(null);
      }
    }
  }

  // ==================== Firestore Realtime Listener ====================

  /// Start listening to Firestore changes
  void _startFirestoreListener(String userId) {
    _stopFirestoreListener();

    _log('Starting Firestore listener for user: $userId');

    try {
      _firestoreSubscription = _firestore
          .collection(_collectionPath)
          .doc(userId)
          .snapshots()
          .listen(
            (snapshot) => _onFirestoreUpdate(snapshot),
            onError: (Object error) => _onFirestoreError(error),
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

  /// Handle Firestore document update
  void _onFirestoreUpdate(DocumentSnapshot snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      _log('Document deleted or empty');

      if (!_updatesController.isClosed) {
        _updatesController.add(null);
      }
      return;
    }

    try {
      final data = snapshot.data() as Map<String, dynamic>;
      final subscription = _mapFirestoreDataToSubscription(data);

      _log('Realtime update: ${subscription?.isActive}');

      if (!_updatesController.isClosed) {
        _updatesController.add(subscription);
      }
    } catch (e) {
      _log('Error parsing Firestore data: $e', isError: true);
    }
  }

  /// Handle Firestore errors
  void _onFirestoreError(Object error) {
    _log('Firestore stream error: $error', isError: true);
  }

  // ==================== Periodic Sync ====================

  /// Start periodic sync as fallback
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();

    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _performPeriodicSync(),
    );
  }

  /// Perform periodic sync
  Future<void> _performPeriodicSync() async {
    if (_currentUserId == null || !_isEnabled) return;

    _log('Performing periodic sync');
    await fetch();
  }

  // ==================== Public Methods ====================

  /// Sync subscription to Firebase
  ///
  /// Called by sync service to propagate changes to Firebase
  Future<Either<Failure, void>> syncToFirebase({
    required String userId,
    required SubscriptionEntity? subscription,
  }) async {
    try {
      _log('Syncing to Firebase for user: $userId');

      final data = _mapSubscriptionToFirestoreData(subscription);

      await _firestore
          .collection(_collectionPath)
          .doc(userId)
          .set(data, SetOptions(merge: true));

      _log('Sync completed');
      return const Right(null);
    } catch (e) {
      _log('Sync failed: $e', isError: true);
      return Left(ServerFailure('Firebase sync failed: ${e.toString()}'));
    }
  }

  /// Enable provider
  void enable() {
    if (!_isEnabled) {
      _isEnabled = true;
      _log('Provider enabled');
    }
  }

  /// Disable provider
  void disable() {
    if (_isEnabled) {
      _isEnabled = false;
      _log('Provider disabled');
    }
  }

  // ==================== Data Mapping ====================

  /// Map Firestore data to SubscriptionEntity
  SubscriptionEntity? _mapFirestoreDataToSubscription(
    Map<String, dynamic> data,
  ) {
    try {
      // Check if we have required fields
      if (!data.containsKey('isActive')) return null;

      final isActive = data['isActive'] as bool? ?? false;
      if (!isActive) return null;

      final productId = data['productId'] as String? ?? 'unknown';
      final userId = _currentUserId ?? 'unknown';

      // Parse timestamps
      DateTime? expirationDate;
      if (data['expirationDate'] != null) {
        final timestamp = data['expirationDate'];
        if (timestamp is Timestamp) {
          expirationDate = timestamp.toDate();
        } else if (timestamp is String) {
          expirationDate = DateTime.tryParse(timestamp);
        }
      }

      DateTime? updatedAt;
      if (data['updatedAt'] != null) {
        final timestamp = data['updatedAt'];
        if (timestamp is Timestamp) {
          updatedAt = timestamp.toDate();
        } else if (timestamp is String) {
          updatedAt = DateTime.tryParse(timestamp);
        }
      }

      return SubscriptionEntity(
        id: '$userId-$productId',
        productId: productId,
        status: isActive
            ? SubscriptionStatus.active
            : SubscriptionStatus.expired,
        tier: SubscriptionTier.premium,
        expirationDate: expirationDate,
        updatedAt: updatedAt,
        userId: userId,
      );
    } catch (e) {
      _log('Error mapping Firestore data: $e', isError: true);
      return null;
    }
  }

  /// Map SubscriptionEntity to Firestore data
  Map<String, dynamic> _mapSubscriptionToFirestoreData(
    SubscriptionEntity? subscription,
  ) {
    if (subscription == null) {
      return {
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncedFrom': 'revenuecat',
      };
    }

    return {
      'isActive': subscription.isActive,
      'productId': subscription.productId,
      'status': subscription.status.name,
      'tier': subscription.tier.name,
      'expirationDate': subscription.expirationDate != null
          ? Timestamp.fromDate(subscription.expirationDate!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'syncedFrom': 'revenuecat',
    };
  }

  // ==================== Utilities ====================

  void _log(String message, {bool isError = false}) {
    final prefix = '[FirebaseProvider]';
    if (isError) {
      debugPrint('$prefix ERROR: $message');
    } else {
      debugPrint('$prefix $message');
    }
  }
}
