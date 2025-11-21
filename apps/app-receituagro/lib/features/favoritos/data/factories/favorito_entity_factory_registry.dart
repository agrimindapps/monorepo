
import '../../domain/entities/favorito_entity.dart';
import 'favorito_entity_factory.dart';

/// Registry for FavoritoEntity factories.
/// Manages a collection of factories and routes creation requests to the appropriate one.
///
/// This eliminates the switch case from FavoritosService (OCP violation fix).
///
/// Benefits:
/// - Adding new tipos doesn't require modifying existing code
/// - Easy to test (can mock registry)
/// - Extensible via dependency injection
abstract class IFavoritoEntityFactoryRegistry {
  /// Create entity using the appropriate factory for the given type
  FavoritoEntity create({
    required String tipo,
    required String id,
    required Map<String, dynamic> data,
  });

  /// Register a factory for a specific type
  void register(String tipo, IFavoritoEntityFactory factory);

  /// Check if registry can handle the given type
  bool canHandle(String tipo);

  /// Get all registered tipos
  List<String> getRegisteredTipos();
}

/// Default implementation of factory registry
class FavoritoEntityFactoryRegistry implements IFavoritoEntityFactoryRegistry {
  final Map<String, IFavoritoEntityFactory> _factories = {};

  FavoritoEntityFactoryRegistry() {
    // Register default factories
    _registerDefaults();
  }

  /// Register all default factories
  void _registerDefaults() {
    register('defensivo', FavoritoDefensivoEntityFactory());
    register('praga', FavoritoPragaEntityFactory());
    register('diagnostico', FavoritoDiagnosticoEntityFactory());
    register('cultura', FavoritoCulturaEntityFactory());
  }

  @override
  FavoritoEntity create({
    required String tipo,
    required String id,
    required Map<String, dynamic> data,
  }) {
    final factory = _factories[tipo];

    if (factory == null) {
      throw ArgumentError(
        'Nenhuma factory registrada para tipo: $tipo. '
        'Tipos disponíveis: ${getRegisteredTipos().join(", ")}',
      );
    }

    return factory.create(id: id, data: data);
  }

  @override
  void register(String tipo, IFavoritoEntityFactory factory) {
    _factories[tipo] = factory;
  }

  @override
  bool canHandle(String tipo) {
    return _factories.containsKey(tipo);
  }

  @override
  List<String> getRegisteredTipos() {
    return _factories.keys.toList()..sort();
  }
}
