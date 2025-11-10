import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Módulo para registrar dependências externas do core package
@module
abstract class ExternalModule {
  /// Registra SharedPreferences como dependência injetável
  ///
  /// Usado por LocalSubscriptionProvider para cache offline
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
