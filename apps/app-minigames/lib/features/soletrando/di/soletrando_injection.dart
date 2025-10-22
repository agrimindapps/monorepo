import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/soletrando_local_datasource.dart';
import '../data/datasources/soletrando_words_datasource.dart';
import '../data/repositories/soletrando_repository_impl.dart';
import '../domain/repositories/soletrando_repository.dart';

/// Initialize dependency injection for Soletrando feature
Future<void> initSoletrandoDI(GetIt sl) async {
  // Get SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();

  // Data sources
  sl.registerLazySingleton<SoletrandoWordsDataSource>(
    () => SoletrandoWordsDataSource(),
  );

  sl.registerLazySingleton<SoletrandoLocalDataSource>(
    () => SoletrandoLocalDataSource(sharedPreferences),
  );

  // Repository
  sl.registerLazySingleton<SoletrandoRepository>(
    () => SoletrandoRepositoryImpl(
      localDataSource: sl<SoletrandoLocalDataSource>(),
      wordsDataSource: sl<SoletrandoWordsDataSource>(),
    ),
  );
}
