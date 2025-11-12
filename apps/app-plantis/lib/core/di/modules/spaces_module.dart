import 'package:core/core.dart' hide Column;

class SpacesModule {
  static void init(GetIt sl) {
    // SpacesLocalDatasource - auto-registered by @LazySingleton in spaces_local_datasource.dart
    // SpacesRemoteDatasource - auto-registered by @LazySingleton in spaces_remote_datasource.dart
    // SpacesRepository - auto-registered by @LazySingleton in spaces_repository_impl.dart
    // Use Cases are registered automatically by injectable

    // No manual registrations needed - all handled by @injectable
  }
}
