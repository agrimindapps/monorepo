// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/cache/i_cache_service.dart';
import '../services/mock_admob_service.dart';

/// Refactored AdmobController using unified cache service for performance
class AdmobController extends GetxController {
  static final AdmobController _singleton = AdmobController._internal();
  factory AdmobController() => _singleton;
  AdmobController._internal();

  static const String _serviceInstanceCacheKey = 'admob_service_instance';
  static const String _premiumStatusCacheKey = 'admob_premium_status';
  static const String _premiumHoursCacheKey = 'admob_premium_hours';
  static const Duration _serviceCacheTtl = Duration(hours: 1);
  
  MockAdmobService? _cachedService;
  final RxBool _fallbackIsPremiumAd = false.obs;
  final RxInt _fallbackPremiumAdHours = 0.obs;
  final ICacheService _cacheService = Get.find<ICacheService>();

  MockAdmobService? get _service {
    if (_cachedService != null) return _cachedService;
    
    try {
      _cachedService = Get.find<MockAdmobService>();
      
      // Cache service instance metadata for analytics
      _cacheServiceInstance();
      
      return _cachedService;
    } catch (e) {
      debugPrint('MockAdmobService não encontrado: $e');
      return null;
    }
  }

  RxBool get isPremiumAd => _service?.isPremiumAd ?? _fallbackIsPremiumAd;
  RxInt get premiumAdHours => _service?.premiumAdHours ?? _fallbackPremiumAdHours;

  void init() {
    _service?.init();
  }

  Future<bool> checkIsPremiumAd() async {
    try {
      // Check cache first
      final cachedStatus = await _cacheService.get<bool>(_premiumStatusCacheKey);
      if (cachedStatus != null) {
        return cachedStatus;
      }
      
      // Get from service and cache result
      final status = await (_service?.checkIsPremiumAd() ?? Future.value(false));
      await _cacheService.put(_premiumStatusCacheKey, status, ttl: _serviceCacheTtl);
      
      return status;
    } catch (e) {
      debugPrint('Erro ao verificar status premium: $e');
      return false;
    }
  }

  void setPremiumAd(int hours) {
    _service?.setPremiumAd(hours);
    
    // Update cache with new values
    _updatePremiumCache(hours);
  }

  Future<void> getPremiumAd() async {
    try {
      await (_service?.getPremiumAd() ?? Future.value());
      
      // Invalidate cache to force fresh data on next check
      await _invalidatePremiumCache();
    } catch (e) {
      debugPrint('Erro ao obter premium ad: $e');
    }
  }
  
  @override
  void onClose() {
    // Limpar cache do serviço para evitar memory leaks
    _cachedService = null;
    
    // Limpar cache entries relacionadas
    _clearAllCache();
    
    super.onClose();
  }
  
  // Private helper methods for cache management
  
  void _cacheServiceInstance() {
    try {
      _cacheService.put(
        _serviceInstanceCacheKey,
        {
          'initialized': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'serviceType': 'MockAdmobService',
        },
        ttl: _serviceCacheTtl,
      );
    } catch (e) {
      // Silent error for cache metadata
    }
  }
  
  void _updatePremiumCache(int hours) {
    try {
      _cacheService.put(_premiumHoursCacheKey, hours, ttl: _serviceCacheTtl);
      _cacheService.put(_premiumStatusCacheKey, hours > 0, ttl: _serviceCacheTtl);
    } catch (e) {
      // Silent error for cache update
    }
  }
  
  Future<void> _invalidatePremiumCache() async {
    try {
      await _cacheService.remove(_premiumStatusCacheKey);
      await _cacheService.remove(_premiumHoursCacheKey);
    } catch (e) {
      // Silent error for cache invalidation
    }
  }
  
  void _clearAllCache() {
    try {
      _cacheService.remove(_serviceInstanceCacheKey);
      _cacheService.remove(_premiumStatusCacheKey);
      _cacheService.remove(_premiumHoursCacheKey);
    } catch (e) {
      // Silent error for cache cleanup
    }
  }
  
  /// Get cache statistics for this controller
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final hasServiceCache = await _cacheService.has(_serviceInstanceCacheKey);
      final hasPremiumStatus = await _cacheService.has(_premiumStatusCacheKey);
      final hasPremiumHours = await _cacheService.has(_premiumHoursCacheKey);
      
      return {
        'serviceInstanceCached': hasServiceCache,
        'premiumStatusCached': hasPremiumStatus,
        'premiumHoursCached': hasPremiumHours,
        'totalCacheEntries': [hasServiceCache, hasPremiumStatus, hasPremiumHours]
            .where((cached) => cached).length,
        'strategy': 'unified_cache_service',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'totalCacheEntries': 0,
      };
    }
  }
}
