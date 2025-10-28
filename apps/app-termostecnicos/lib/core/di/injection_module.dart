import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injectable module for third-party dependencies
@module
abstract class InjectableModule {
  /// Register SharedPreferences as singleton
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
