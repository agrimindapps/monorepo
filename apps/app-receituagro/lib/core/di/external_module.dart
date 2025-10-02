import 'package:core/core.dart';

/// Módulo para registrar dependências externas do core package
///
/// IMPORTANTE: Este módulo foi esvaziado pois as dependências do core
/// são registradas diretamente no injection_container.dart para evitar
/// dependências circulares no GetIt.
@module
abstract class ExternalModule {
  // As dependências ISubscriptionRepository e ILocalStorageRepository
  // são registradas diretamente em injection_container.dart (linhas 174-242)
  // para evitar loops infinitos de resolução de dependências.
}
