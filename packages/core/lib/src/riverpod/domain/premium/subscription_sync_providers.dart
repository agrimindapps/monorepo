import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/repositories/i_subscription_repository.dart';

/// Provider para o SubscriptionSyncCoordinator simplificado
///
/// Gerencia a sincronização entre RevenueCat e Firebase Firestore.
/// Usa FirebaseAuth diretamente para detectar mudanças de usuário.
///
/// Uso:
/// ```dart
/// final subscription = ref.watch(syncedSubscriptionStreamProvider);
/// final isPremium = ref.watch(hasSyncedSubscriptionProvider);
/// ```
final subscriptionSyncCoordinatorProvider =
    Provider<_SubscriptionSyncCoordinatorSimple>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);

  final coordinator = _SubscriptionSyncCoordinatorSimple(
    subscriptionRepository: subscriptionRepository,
  );

  // Initialize on first access
  coordinator.initialize();

  // Cleanup on dispose
  ref.onDispose(() {
    coordinator.dispose();
  });

  return coordinator;
});

/// Implementação simplificada do coordinator que não depende de IAuthRepository
class _SubscriptionSyncCoordinatorSimple {
  _SubscriptionSyncCoordinatorSimple({
    required ISubscriptionRepository subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository;

  final ISubscriptionRepository _subscriptionRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionPath = 'user_subscriptions';
  static const String _tag = '[SubscriptionSync]';

  final BehaviorSubject<SubscriptionEntity?> _subscriptionController =
      BehaviorSubject<SubscriptionEntity?>.seeded(null);

  StreamSubscription<SubscriptionEntity?>? _revenueCatSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;
  StreamSubscription<User?>? _authSubscription;

  String? _currentUserId;
  bool _isInitialized = false;
  bool _isDisposed = false;

  Stream<SubscriptionEntity?> get subscriptionStream =>
      _subscriptionController.stream;

  SubscriptionEntity? get currentSubscription => _subscriptionController.value;

  bool get hasActiveSubscription =>
      _subscriptionController.value?.isActive ?? false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _log('Initializing...');

    // Listen to Firebase Auth changes directly
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthChanged,
      onError: (Object error) => _log('Auth error: $error', isError: true),
    );

    // Listen to RevenueCat updates (only on mobile)
    if (!kIsWeb) {
      _revenueCatSubscription =
          _subscriptionRepository.subscriptionStatus.listen(
        _onRevenueCatUpdate,
        onError: (Object error) =>
            _log('RevenueCat error: $error', isError: true),
      );
    }

    _isInitialized = true;
    _log('Initialized');
  }

  Future<void> forceSync() async {
    if (_currentUserId == null) return;

    _log('Force sync for user: $_currentUserId');

    try {
      SubscriptionEntity? subscription;

      if (!kIsWeb) {
        final result = await _subscriptionRepository.getCurrentSubscription();
        subscription = result.fold((f) => null, (s) => s);
      }

      if (subscription == null) {
        subscription = await _fetchFromFirebase();
      }

      if (!_subscriptionController.isClosed) {
        _subscriptionController.add(subscription);
      }

      if (subscription != null && !kIsWeb) {
        await _syncToFirebase(subscription);
      }

      _log('Sync completed: ${subscription?.isActive}');
    } catch (e) {
      _log('Sync error: $e', isError: true);
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _revenueCatSubscription?.cancel();
    await _firestoreSubscription?.cancel();
    await _authSubscription?.cancel();
    await _subscriptionController.close();

    _log('Disposed');
  }

  void _onAuthChanged(User? user) {
    if (user != null) {
      _log('User logged in: ${user.uid}');
      _currentUserId = user.uid;
      _startFirestoreListener(user.uid);
      forceSync();
    } else {
      _log('User logged out');
      _currentUserId = null;
      _stopFirestoreListener();
      if (!_subscriptionController.isClosed) {
        _subscriptionController.add(null);
      }
    }
  }

  void _onRevenueCatUpdate(SubscriptionEntity? subscription) {
    _log('RevenueCat update: ${subscription?.isActive}');

    if (!_subscriptionController.isClosed) {
      _subscriptionController.add(subscription);
    }

    if (_currentUserId != null && subscription != null) {
      _syncToFirebase(subscription);
    }
  }

  void _startFirestoreListener(String userId) {
    _stopFirestoreListener();

    _log('Starting Firestore listener for: $userId');

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
      _log('Failed to start listener: $e', isError: true);
    }
  }

  void _stopFirestoreListener() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  void _onFirestoreUpdate(DocumentSnapshot snapshot) {
    if (!snapshot.exists || snapshot.data() == null) return;

    try {
      final data = snapshot.data() as Map<String, dynamic>;
      final subscription = _mapFirestoreToSubscription(data);

      // On web, Firebase is the primary source
      if (kIsWeb && subscription != null) {
        _log('Firestore update (web): ${subscription.isActive}');
        if (!_subscriptionController.isClosed) {
          _subscriptionController.add(subscription);
        }
      }
    } catch (e) {
      _log('Parse error: $e', isError: true);
    }
  }

  Future<SubscriptionEntity?> _fetchFromFirebase() async {
    if (_currentUserId == null) return null;

    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(_currentUserId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return _mapFirestoreToSubscription(doc.data()!);
    } catch (e) {
      _log('Firebase fetch error: $e', isError: true);
      return null;
    }
  }

  Future<void> _syncToFirebase(SubscriptionEntity subscription) async {
    if (_currentUserId == null) return;

    try {
      _log('Syncing to Firebase...');

      await _firestore
          .collection(_collectionPath)
          .doc(_currentUserId)
          .set(_mapSubscriptionToFirestore(subscription), SetOptions(merge: true));

      _log('Synced to Firebase');
    } catch (e) {
      _log('Firebase sync error: $e', isError: true);
    }
  }

  SubscriptionEntity? _mapFirestoreToSubscription(Map<String, dynamic> data) {
    try {
      final isActive = data['isActive'] as bool? ?? false;
      if (!isActive) return null;

      final productId = data['productId'] as String? ?? 'unknown';
      final userId = _currentUserId ?? 'unknown';

      DateTime? expirationDate;
      if (data['expirationDate'] != null) {
        final ts = data['expirationDate'];
        if (ts is Timestamp) expirationDate = ts.toDate();
      }

      DateTime? purchaseDate;
      if (data['purchaseDate'] != null) {
        final ts = data['purchaseDate'];
        if (ts is Timestamp) purchaseDate = ts.toDate();
      }

      return SubscriptionEntity(
        id: '$userId-$productId',
        userId: userId,
        productId: productId,
        status: SubscriptionStatus.active,
        tier: SubscriptionTier.premium,
        expirationDate: expirationDate,
        purchaseDate: purchaseDate,
        store: Store.unknown,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _mapSubscriptionToFirestore(SubscriptionEntity sub) {
    return {
      'isActive': sub.isActive,
      'productId': sub.productId,
      'status': sub.status.name,
      'tier': sub.tier.name,
      'store': sub.store.name,
      'expirationDate': sub.expirationDate != null
          ? Timestamp.fromDate(sub.expirationDate!)
          : null,
      'purchaseDate': sub.purchaseDate != null
          ? Timestamp.fromDate(sub.purchaseDate!)
          : null,
      'isInTrial': sub.isInTrial,
      'isSandbox': sub.isSandbox,
      'updatedAt': FieldValue.serverTimestamp(),
      'syncedFrom': kIsWeb ? 'web' : 'mobile',
    };
  }

  void _log(String message, {bool isError = false}) {
    if (kDebugMode) {
      debugPrint('$_tag ${isError ? "ERROR: " : ""}$message');
    }
  }
}

/// Provider de ISubscriptionRepository
///
/// Deve ser sobrescrito no app com a implementação concreta (RevenueCatService)
final subscriptionRepositoryProvider = Provider<ISubscriptionRepository>((ref) {
  throw UnimplementedError(
    'subscriptionRepositoryProvider must be overridden in the app',
  );
});

/// Stream provider para subscription sincronizada
///
/// Emite atualizações tanto do RevenueCat quanto do Firebase
final syncedSubscriptionStreamProvider =
    StreamProvider<SubscriptionEntity?>((ref) {
  final coordinator = ref.watch(subscriptionSyncCoordinatorProvider);
  return coordinator.subscriptionStream;
});

/// Provider para verificar se tem subscription ativa
final hasSyncedSubscriptionProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(syncedSubscriptionStreamProvider);
  return subscriptionAsync.maybeWhen(
    data: (subscription) => subscription?.isActive ?? false,
    orElse: () => false,
  );
});

/// Provider para obter a subscription atual (síncrono)
final currentSyncedSubscriptionProvider = Provider<SubscriptionEntity?>((ref) {
  final coordinator = ref.watch(subscriptionSyncCoordinatorProvider);
  return coordinator.currentSubscription;
});

/// Provider para forçar sincronização
final forceSyncSubscriptionProvider = Provider<Future<void> Function()>((ref) {
  final coordinator = ref.watch(subscriptionSyncCoordinatorProvider);
  return () async {
    await coordinator.forceSync();
  };
});

/// Provider para verificar subscription por app específico
final hasSubscriptionForAppProvider =
    FutureProvider.family<bool, String>((ref, appName) async {
  final subscription = ref.watch(syncedSubscriptionStreamProvider).value;
  if (subscription == null || !subscription.isActive) return false;
  
  return subscription.productId.toLowerCase().contains(appName.toLowerCase());
});
