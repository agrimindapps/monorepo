import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/promo_model.dart';

abstract class IPromoLocalDataSource {
  Future<List<PromoModel>> getCachedPromos();
  Future<void> cachePromos(List<PromoModel> promos);
  Future<void> markPromoAsViewed(String promoId);
  Future<List<String>> getViewedPromoIds();
}

class PromoLocalDataSource implements IPromoLocalDataSource {
  static const String _cachedPromosKey = 'CACHED_PROMOS';
  static const String _viewedPromosKey = 'VIEWED_PROMOS';

  final SharedPreferences sharedPreferences;

  PromoLocalDataSource({required this.sharedPreferences});

  @override
  Future<List<PromoModel>> getCachedPromos() async {
    final jsonString = sharedPreferences.getString(_cachedPromosKey);

    if (jsonString == null) {
      throw CacheException();
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => PromoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cachePromos(List<PromoModel> promos) async {
    final jsonList = promos.map((promo) => promo.toJson()).toList();
    await sharedPreferences.setString(
      _cachedPromosKey,
      json.encode(jsonList),
    );
  }

  @override
  Future<void> markPromoAsViewed(String promoId) async {
    final viewedIds = await getViewedPromoIds();
    if (!viewedIds.contains(promoId)) {
      viewedIds.add(promoId);
      await sharedPreferences.setStringList(_viewedPromosKey, viewedIds);
    }
  }

  @override
  Future<List<String>> getViewedPromoIds() async {
    return sharedPreferences.getStringList(_viewedPromosKey) ?? [];
  }
}

class CacheException implements Exception {}
