import 'package:core/core.dart';

/// Registry pattern para gerenciar múltiplos sync adapters
///
/// **Responsabilidades:**
/// - Registrar adapters para sincronização
/// - Providenciar acesso aos adapters registrados
/// - Facilitar padrões genéricos (loop sobre adapters)
/// - Suportar registro dinâmico e estático
///
/// **Princípio SOLID:**
/// - Open/Closed: Fácil adicionar novos adapters sem modificar push/pull services
/// - Dependency Inversion: Services dependem de registry, não de adapters específicos
///
/// **Exemplo de Uso:**
/// ```dart
/// final registry = SyncAdapterRegistry(
///   adapters: [
///     VehicleDriftSyncAdapter(...),
///     FuelSupplyDriftSyncAdapter(...),
///     MaintenanceDriftSyncAdapter(...),
///   ],
/// );
///
/// // Em SyncPushService:
/// for (final adapter in registry.adapters) {
///   final result = await adapter.pushDirtyRecords(userId);
///   results.add(result);
/// }
/// ```
class SyncAdapterRegistry {
  /// Cria um novo registry com adapters
  ///
  /// [adapters]: Lista de adapters a registrar
  SyncAdapterRegistry({
    required List<IDriftSyncAdapter<dynamic, dynamic>> adapters,
  }) : _adapters = List.unmodifiable(adapters);

  final List<IDriftSyncAdapter<dynamic, dynamic>> _adapters;

  /// Retorna lista imutável de adapters registrados
  List<IDriftSyncAdapter<dynamic, dynamic>> get adapters => _adapters;

  /// Retorna número de adapters registrados
  int get count => _adapters.length;

  /// Encontra adapter por nome
  IDriftSyncAdapter<dynamic, dynamic>? findByName(String name) {
    try {
      return _adapters.firstWhere((adapter) => adapter.collectionName == name);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se adapter está registrado
  bool has(String adapterName) {
    return _adapters.any((adapter) => adapter.collectionName == adapterName);
  }

  /// Retorna lista de nomes de adapters registrados
  List<String> get adapterNames =>
      _adapters.map((a) => a.collectionName).toList();
}
