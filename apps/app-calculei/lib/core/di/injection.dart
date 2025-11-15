import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({bool firebaseEnabled = false}) async {
  // Initialize generated dependencies
  await getIt.init();

  // Register Logger
  getIt.registerSingleton<Logger>(Logger());
}

/// Module for registering external dependencies
@module
abstract class ExternalDependenciesModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
