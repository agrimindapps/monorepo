import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/market_local_datasource.dart';
import '../../data/datasources/market_remote_datasource.dart';
import '../../data/repositories/market_repository_impl.dart';
import '../../domain/repositories/market_repository.dart';
import '../../domain/usecases/get_market_summary.dart';
import '../../domain/usecases/get_markets.dart';
import '../../domain/usecases/manage_market_favorites.dart';

// External dependencies
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});

// Datasources
final marketLocalDataSourceProvider = Provider<MarketLocalDataSource>((ref) {
  return MarketLocalDataSourceImpl();
});

final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MarketRemoteDataSourceImpl(dio);
});

// Repository
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final localDataSource = ref.watch(marketLocalDataSourceProvider);
  final remoteDataSource = ref.watch(marketRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return MarketRepositoryImpl(
    remoteDataSource,
    localDataSource,
    networkInfo,
  );
});

// Usecases
final getMarketsUseCaseProvider = Provider<GetMarkets>((ref) {
  return GetMarkets(ref.watch(marketRepositoryProvider));
});

final getMarketSummaryUseCaseProvider = Provider<GetMarketSummary>((ref) {
  return GetMarketSummary(ref.watch(marketRepositoryProvider));
});

final getTopGainersUseCaseProvider = Provider<GetTopGainers>((ref) {
  return GetTopGainers(ref.watch(marketRepositoryProvider));
});

final getTopLosersUseCaseProvider = Provider<GetTopLosers>((ref) {
  return GetTopLosers(ref.watch(marketRepositoryProvider));
});

final getMostActiveUseCaseProvider = Provider<GetMostActive>((ref) {
  return GetMostActive(ref.watch(marketRepositoryProvider));
});

final manageMarketFavoritesUseCaseProvider =
    Provider<ManageMarketFavorites>((ref) {
  return ManageMarketFavorites(ref.watch(marketRepositoryProvider));
});
