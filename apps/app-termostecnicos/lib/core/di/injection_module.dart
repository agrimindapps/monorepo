import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../database/termostecnicos_database.dart';

/// Injectable module for third-party dependencies
@module
abstract class InjectableModule {
  /// Register SharedPreferences as singleton
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// Register Drift database as singleton
  // @singleton
  // TermosTecnicosDatabase get database => TermosTecnicosDatabase();
}
