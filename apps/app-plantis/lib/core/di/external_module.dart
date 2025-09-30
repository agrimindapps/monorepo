import 'package:core/core.dart';

/// Módulo para registrar dependências externas do core package
@module
abstract class ExternalModule {
  /// Auth Repository do core
  @lazySingleton
  IAuthRepository get authRepository => GetIt.instance<IAuthRepository>();

  /// Subscription Repository do core
  @lazySingleton
  ISubscriptionRepository get subscriptionRepository =>
      GetIt.instance<ISubscriptionRepository>();

  /// Local Storage Repository do core
  @lazySingleton
  ILocalStorageRepository get localStorageRepository =>
      GetIt.instance<ILocalStorageRepository>();
}
