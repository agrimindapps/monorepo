import '../entities/favorito_entity.dart';

/// Interface principal do repositório de favoritos (Domain Layer)
/// Princípios: Dependency Inversion + Interface Segregation
abstract class IFavoritosRepository {
  /// Operações de consulta
  Future<List<FavoritoEntity>> getAll();
  Future<List<FavoritoEntity>> getByTipo(String tipo);
  Future<FavoritosStats> getStats();

  /// Verificação de status
  Future<bool> isFavorito(String tipo, String id);

  /// Operações CRUD genéricas (novos métodos para consolidação)
  /// Substitui os específicos (addDefensivo, addPraga, etc)
  Future<bool> addFavorito(FavoritoEntity favorito);
  Future<bool> removeFavorito(String tipo, String id);
  Future<bool> toggleFavorito(String tipo, String id);

  /// Busca
  Future<List<FavoritoEntity>> search(String query);
}

/// Interface específica para operações de favoritos de defensivos
/// Princípio: Interface Segregation
abstract class IFavoritosDefensivosRepository {
  Future<List<FavoritoDefensivoEntity>> getDefensivos();
  Future<bool> addDefensivo(String defensivoId);
  Future<bool> removeDefensivo(String defensivoId);
  Future<bool> isDefensivoFavorito(String defensivoId);
}

/// Interface específica para operações de favoritos de pragas
/// Princípio: Interface Segregation
abstract class IFavoritosPragasRepository {
  Future<List<FavoritoPragaEntity>> getPragas();
  Future<bool> addPraga(String pragaId);
  Future<bool> removePraga(String pragaId);
  Future<bool> isPragaFavorito(String pragaId);
}

/// Interface específica para operações de favoritos de diagnósticos
/// Princípio: Interface Segregation
abstract class IFavoritosDiagnosticosRepository {
  Future<List<FavoritoDiagnosticoEntity>> getDiagnosticos();
  Future<bool> addDiagnostico(String diagnosticoId);
  Future<bool> removeDiagnostico(String diagnosticoId);
  Future<bool> isDiagnosticoFavorito(String diagnosticoId);
}

/// Interface específica para operações de favoritos de culturas
/// Princípio: Interface Segregation
abstract class IFavoritosCulturasRepository {
  Future<List<FavoritoCulturaEntity>> getCulturas();
  Future<bool> addCultura(String culturaId);
  Future<bool> removeCultura(String culturaId);
  Future<bool> isCulturaFavorito(String culturaId);
}

/// Interface para storage local de favoritos
/// Princípio: Dependency Inversion
abstract class IFavoritosStorage {
  /// Operações básicas de storage
  Future<List<String>> getFavoriteIds(String tipo);
  Future<bool> addFavoriteId(String tipo, String id);
  Future<bool> removeFavoriteId(String tipo, String id);
  Future<bool> isFavoriteId(String tipo, String id);

  /// Operações de limpeza
  Future<void> clearFavorites(String tipo);
  Future<void> clearAllFavorites();

  /// Sincronização
  Future<void> syncFavorites();
}

/// Interface para cache de dados de favoritos
/// Princípio: Dependency Inversion
abstract class IFavoritosCache {
  /// Operações de cache
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T data, {Duration? ttl});
  Future<void> remove(String key);

  /// Operações de limpeza
  Future<void> clearByPrefix(String prefix);
  Future<void> clearAll();

  /// Estatísticas
  Future<Map<String, dynamic>> getStats();
  Future<List<String>> getKeys();
}

/// Interface para resolver dados de entidades
/// Princípio: Dependency Inversion
abstract class IFavoritosDataResolver {
  /// Resolve dados de defensivo por ID
  Future<Map<String, dynamic>?> resolveDefensivo(String id);

  /// Resolve dados de praga por ID
  Future<Map<String, dynamic>?> resolvePraga(String id);

  /// Resolve dados de diagnóstico por ID
  Future<Map<String, dynamic>?> resolveDiagnostico(String id);

  /// Resolve dados de cultura por ID
  Future<Map<String, dynamic>?> resolveCultura(String id);
}

/// Interface para factory de entidades favoritos
/// Princípio: Factory Pattern + Single Responsibility
abstract class IFavoritosEntityFactory {
  /// Cria entidade de favorito defensivo
  FavoritoDefensivoEntity createDefensivo({
    required String id,
    required Map<String, dynamic> data,
  });

  /// Cria entidade de favorito praga
  FavoritoPragaEntity createPraga({
    required String id,
    required Map<String, dynamic> data,
  });

  /// Cria entidade de favorito diagnóstico
  FavoritoDiagnosticoEntity createDiagnostico({
    required String id,
    required Map<String, dynamic> data,
  });

  /// Cria entidade de favorito cultura
  FavoritoCulturaEntity createCultura({
    required String id,
    required Map<String, dynamic> data,
  });

  /// Cria entidade genérica baseada no tipo
  FavoritoEntity create({
    required String tipo,
    required String id,
    required Map<String, dynamic> data,
  });
}

/// Interface para validação de favoritos
/// Princípio: Single Responsibility
abstract class IFavoritosValidator {
  /// Valida se pode adicionar aos favoritos
  Future<bool> canAddToFavorites(String tipo, String id);

  /// Valida se existe no sistema
  Future<bool> exists(String tipo, String id);

  /// Valida tipo de favorito
  bool isValidTipo(String tipo);

  /// Valida ID
  bool isValidId(String id);
}

/// Exception customizada para favoritos
class FavoritosException implements Exception {
  final String message;
  final String? tipo;
  final String? id;

  const FavoritosException(this.message, {this.tipo, this.id});

  @override
  String toString() {
    var msg = 'FavoritosException: $message';
    if (tipo != null) msg += ' (tipo: $tipo)';
    if (id != null) msg += ' (id: $id)';
    return msg;
  }
}
