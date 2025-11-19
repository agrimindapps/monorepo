import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/services/i_subscription_data_provider.dart';
import '../../../shared/utils/failure.dart';

/// Local storage subscription data provider
///
/// Lowest priority source for offline fallback.
///
/// Priority: 40 (lowest)
/// - Offline support
/// - Instant access
/// - Survives app restarts
/// - No network required
///
/// Storage: SharedPreferences
/// Key: 'subscription_cache'
///
/// Usage:
/// ```dart
/// final provider = LocalSubscriptionProvider(
///   sharedPreferences: prefs,
/// );
///
/// await provider.initialize();
///
/// // Save subscription locally
/// await provider.saveLocal(subscription);
///
/// // Fetch from local
/// final result = await provider.fetch();
/// ```
@lazySingleton
class LocalSubscriptionProvider implements ISubscriptionDataProvider {
  /// Creates a local subscription provider.
  LocalSubscriptionProvider({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _cacheKey = 'subscription_cache';
  static const String _timestampKey = 'subscription_cache_timestamp';
  static const Duration _cacheValidity = Duration(hours: 24);

  final BehaviorSubject<SubscriptionEntity?> _updatesController =
      BehaviorSubject<SubscriptionEntity?>.seeded(null);

  bool _isEnabled = true;
  bool _isInitialized = false;

  // ==================== ISubscriptionDataProvider Implementation ====================

  @override
  String get name => 'Local';

  @override
  Stream<SubscriptionEntity?> get updates => _updatesController.stream;

  @override
  int get priority => 40; // Lowest priority

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<Either<Failure, SubscriptionEntity?>> fetch() async {
    try {
      _log('Fetching subscription from local storage');

      // Check if cache is valid
      if (!_isCacheValid()) {
        _log('Cache expired or invalid');
        return const Right(null);
      }

      final jsonString = _sharedPreferences.getString(_cacheKey);
      if (jsonString == null || jsonString.isEmpty) {
        _log('No cached data found');
        return const Right(null);
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final subscription = _mapJsonToSubscription(json);

      _log('Fetched from cache: ${subscription?.isActive}');

      // Update stream
      if (!_updatesController.isClosed) {
        _updatesController.add(subscription);
      }

      return Right(subscription);
    } catch (e) {
      _log('Fetch error: $e', isError: true);
      return Left(CacheFailure('Local fetch failed: ${e.toString()}'));
    }
  }

  // ==================== Lifecycle ====================

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _log('Initializing provider');

    // Load initial data from cache
    await fetch();

    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _log('Disposing provider');

    await _updatesController.close();
    _isInitialized = false;
  }

  // ==================== Public Methods ====================

  /// Save subscription to local storage
  ///
  /// Called by sync service to cache subscription locally
  Future<Either<Failure, void>> saveLocal(
    SubscriptionEntity? subscription,
  ) async {
    try {
      _log('Saving to local storage');

      if (subscription == null) {
        await _sharedPreferences.remove(_cacheKey);
        await _sharedPreferences.remove(_timestampKey);

        _log('Cleared local cache');

        if (!_updatesController.isClosed) {
          _updatesController.add(null);
        }

        return const Right(null);
      }

      final json = _mapSubscriptionToJson(subscription);
      final jsonString = jsonEncode(json);

      await _sharedPreferences.setString(_cacheKey, jsonString);
      await _sharedPreferences.setInt(
        _timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      _log('Saved successfully');

      // Update stream
      if (!_updatesController.isClosed) {
        _updatesController.add(subscription);
      }

      return const Right(null);
    } catch (e) {
      _log('Save error: $e', isError: true);
      return Left(CacheFailure('Local save failed: ${e.toString()}'));
    }
  }

  /// Clear local cache
  Future<Either<Failure, void>> clearCache() async {
    try {
      _log('Clearing cache');

      await _sharedPreferences.remove(_cacheKey);
      await _sharedPreferences.remove(_timestampKey);

      if (!_updatesController.isClosed) {
        _updatesController.add(null);
      }

      return const Right(null);
    } catch (e) {
      _log('Clear error: $e', isError: true);
      return Left(CacheFailure('Cache clear failed: ${e.toString()}'));
    }
  }

  /// Check if cache is valid
  bool _isCacheValid() {
    final timestamp = _sharedPreferences.getInt(_timestampKey);
    if (timestamp == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final age = DateTime.now().difference(cacheDate);

    return age <= _cacheValidity;
  }

  /// Get cache age
  Duration? getCacheAge() {
    final timestamp = _sharedPreferences.getInt(_timestampKey);
    if (timestamp == null) return null;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheDate);
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

  /// Map JSON to SubscriptionEntity
  SubscriptionEntity? _mapJsonToSubscription(Map<String, dynamic> json) {
    try {
      // Check required fields
      if (!json.containsKey('id') || !json.containsKey('productId')) {
        return null;
      }

      return SubscriptionEntity(
        id: json['id'] as String,
        productId: json['productId'] as String,
        status: SubscriptionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SubscriptionStatus.expired,
        ),
        tier: SubscriptionTier.values.firstWhere(
          (t) => t.name == json['tier'],
          orElse: () => SubscriptionTier.free,
        ),
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'] as String)
            : null,
        purchaseDate: json['purchaseDate'] != null
            ? DateTime.parse(json['purchaseDate'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        userId: json['userId'] as String,
        store: json['store'] != null
            ? Store.values.firstWhere(
                (s) => s.name == json['store'],
                orElse: () => Store.appStore,
              )
            : Store.appStore,
        isInTrial: json['isInTrial'] as bool? ?? false,
        isSandbox: json['isSandbox'] as bool? ?? false,
      );
    } catch (e) {
      _log('Error mapping JSON: $e', isError: true);
      return null;
    }
  }

  /// Map SubscriptionEntity to JSON
  Map<String, dynamic> _mapSubscriptionToJson(SubscriptionEntity subscription) {
    return {
      'id': subscription.id,
      'productId': subscription.productId,
      'status': subscription.status.name,
      'tier': subscription.tier.name,
      'expirationDate': subscription.expirationDate?.toIso8601String(),
      'purchaseDate': subscription.purchaseDate?.toIso8601String(),
      'updatedAt': subscription.updatedAt?.toIso8601String(),
      'userId': subscription.userId,
      'store': subscription.store.name,
      'isInTrial': subscription.isInTrial,
      'isSandbox': subscription.isSandbox,
    };
  }

  // ==================== Utilities ====================

  void _log(String message, {bool isError = false}) {
    const prefix = '[LocalProvider]';
    if (isError) {
      debugPrint('$prefix ERROR: $message');
    } else {
      debugPrint('$prefix $message');
    }
  }
}
