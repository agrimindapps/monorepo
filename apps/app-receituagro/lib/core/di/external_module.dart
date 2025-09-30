import 'package:core/core.dart';

/// Módulo para registrar dependências externas do core package
@module
abstract class ExternalModule {
  /// Registra o repository de subscription do core
  @lazySingleton
  ISubscriptionRepository get subscriptionRepository =>
      GetIt.instance<ISubscriptionRepository>();

  /// Registra o repository de storage local do core
  @lazySingleton
  ILocalStorageRepository get localStorageRepository =>
      GetIt.instance<ILocalStorageRepository>();
}
