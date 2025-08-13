import 'package:get_it/get_it.dart';
import 'package:core/core.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // App Rating Repository
  sl.registerLazySingleton<IAppRatingRepository>(() => AppRatingService(
    appStoreId: '123456789', // TODO: Replace with actual App Store ID for ReceitaAgro
    googlePlayId: 'br.com.agrimind.receituagro', // TODO: Replace with actual Play Store ID
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  ));
}