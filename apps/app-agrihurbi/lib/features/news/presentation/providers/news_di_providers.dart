import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/news_local_datasource.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/get_commodity_prices.dart';
import '../../domain/usecases/get_news.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

// Datasources
final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  return NewsLocalDataSourceImpl();
});

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return NewsRemoteDataSource(dio);
});

// Repository
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final localDataSource = ref.watch(newsLocalDataSourceProvider);
  final remoteDataSource = ref.watch(newsRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  
  return NewsRepositoryImpl(
    remoteDataSource,
    localDataSource,
    networkInfo,
  );
});

// Usecases
final getNewsUseCaseProvider = Provider<GetNews>((ref) {
  return GetNews(ref.watch(newsRepositoryProvider));
});

final getArticleByIdUseCaseProvider = Provider<GetArticleById>((ref) {
  return GetArticleById(ref.watch(newsRepositoryProvider));
});

final searchArticlesUseCaseProvider = Provider<SearchArticles>((ref) {
  return SearchArticles(ref.watch(newsRepositoryProvider));
});

final getPremiumArticlesUseCaseProvider = Provider<GetPremiumArticles>((ref) {
  return GetPremiumArticles(ref.watch(newsRepositoryProvider));
});

final manageFavoritesUseCaseProvider = Provider<ManageFavorites>((ref) {
  return ManageFavorites(ref.watch(newsRepositoryProvider));
});

final refreshRSSFeedsUseCaseProvider = Provider<RefreshRSSFeeds>((ref) {
  return RefreshRSSFeeds(ref.watch(newsRepositoryProvider));
});

final getCommodityPricesUseCaseProvider = Provider<GetCommodityPrices>((ref) {
  return GetCommodityPrices(ref.watch(newsRepositoryProvider));
});

final getCommodityByIdUseCaseProvider = Provider<GetCommodityById>((ref) {
  return GetCommodityById(ref.watch(newsRepositoryProvider));
});

final getCommodityHistoryUseCaseProvider = Provider<GetCommodityHistory>((ref) {
  return GetCommodityHistory(ref.watch(newsRepositoryProvider));
});

final getMarketSummaryUseCaseProvider = Provider<GetMarketSummary>((ref) {
  return GetMarketSummary(ref.watch(newsRepositoryProvider));
});

final managePriceAlertsUseCaseProvider = Provider<ManagePriceAlerts>((ref) {
  return ManagePriceAlerts(ref.watch(newsRepositoryProvider));
});
