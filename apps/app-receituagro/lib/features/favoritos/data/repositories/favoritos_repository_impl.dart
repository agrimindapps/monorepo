import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Implementação do repositório principal de favoritos (Data Layer)
/// Princípio: Single Responsibility + Dependency Inversion
class FavoritosRepositoryImpl implements IFavoritosRepository {
  final IFavoritosDefensivosRepository _defensivosRepository;
  final IFavoritosPragasRepository _pragasRepository;
  final IFavoritosDiagnosticosRepository _diagnosticosRepository;
  final IFavoritosCulturasRepository _culturasRepository;

  const FavoritosRepositoryImpl({
    required IFavoritosDefensivosRepository defensivosRepository,
    required IFavoritosPragasRepository pragasRepository,
    required IFavoritosDiagnosticosRepository diagnosticosRepository,
    required IFavoritosCulturasRepository culturasRepository,
  }) : _defensivosRepository = defensivosRepository,
       _pragasRepository = pragasRepository,
       _diagnosticosRepository = diagnosticosRepository,
       _culturasRepository = culturasRepository;

  @override
  Future<List<FavoritoEntity>> getAll() async {
    try {
      final futures = await Future.wait([
        _defensivosRepository.getDefensivos(),
        _pragasRepository.getPragas(),
        _diagnosticosRepository.getDiagnosticos(),
        _culturasRepository.getCulturas(),
      ]);

      final List<FavoritoEntity> allFavoritos = [];
      
      // Adiciona todos os tipos
      allFavoritos.addAll(futures[0]); // defensivos
      allFavoritos.addAll(futures[1]); // pragas
      allFavoritos.addAll(futures[2]); // diagnosticos
      allFavoritos.addAll(futures[3]); // culturas

      // Ordena por nome para exibição
      allFavoritos.sort((a, b) => a.nomeDisplay.compareTo(b.nomeDisplay));
      
      return allFavoritos;
    } catch (e) {
      throw FavoritosException('Erro ao buscar todos os favoritos: $e');
    }
  }

  @override
  Future<List<FavoritoEntity>> getByTipo(String tipo) async {
    try {
      switch (tipo) {
        case TipoFavorito.defensivo:
          return await _defensivosRepository.getDefensivos();
          
        case TipoFavorito.praga:
          return await _pragasRepository.getPragas();
          
        case TipoFavorito.diagnostico:
          return await _diagnosticosRepository.getDiagnosticos();
          
        case TipoFavorito.cultura:
          return await _culturasRepository.getCulturas();
          
        default:
          throw ArgumentError('Tipo de favorito inválido: $tipo');
      }
    } catch (e) {
      throw FavoritosException('Erro ao buscar favoritos por tipo: $e', tipo: tipo);
    }
  }

  @override
  Future<FavoritosStats> getStats() async {
    try {
      final futures = await Future.wait([
        _defensivosRepository.getDefensivos(),
        _pragasRepository.getPragas(),
        _diagnosticosRepository.getDiagnosticos(),
        _culturasRepository.getCulturas(),
      ]);

      return FavoritosStats(
        totalDefensivos: futures[0].length,
        totalPragas: futures[1].length,
        totalDiagnosticos: futures[2].length,
        totalCulturas: futures[3].length,
      );
    } catch (e) {
      throw FavoritosException('Erro ao buscar estatísticas de favoritos: $e');
    }
  }

  @override
  Future<bool> isFavorito(String tipo, String id) async {
    try {
      switch (tipo) {
        case TipoFavorito.defensivo:
          return await _defensivosRepository.isDefensivoFavorito(id);
          
        case TipoFavorito.praga:
          return await _pragasRepository.isPragaFavorito(id);
          
        case TipoFavorito.diagnostico:
          return await _diagnosticosRepository.isDiagnosticoFavorito(id);
          
        case TipoFavorito.cultura:
          return await _culturasRepository.isCulturaFavorito(id);
          
        default:
          throw ArgumentError('Tipo de favorito inválido: $tipo');
      }
    } catch (e) {
      throw FavoritosException('Erro ao verificar favorito: $e', tipo: tipo, id: id);
    }
  }

  @override
  Future<List<FavoritoEntity>> search(String query) async {
    try {
      final allFavoritos = await getAll();
      final queryLower = query.toLowerCase();
      
      return allFavoritos.where((favorito) {
        return favorito.nomeDisplay.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw FavoritosException('Erro ao buscar favoritos: $e');
    }
  }
}

/// Implementação do repositório de favoritos de defensivos
/// Princípio: Single Responsibility
class FavoritosDefensivosRepositoryImpl implements IFavoritosDefensivosRepository {
  final IFavoritosStorage _storage;
  final IFavoritosDataResolver _dataResolver;
  final IFavoritosEntityFactory _entityFactory;
  final IFavoritosCache _cache;

  static const String _cachePrefix = 'favoritos_defensivos_';
  static const Duration _cacheTtl = Duration(minutes: 5);

  const FavoritosDefensivosRepositoryImpl({
    required IFavoritosStorage storage,
    required IFavoritosDataResolver dataResolver,
    required IFavoritosEntityFactory entityFactory,
    required IFavoritosCache cache,
  }) : _storage = storage,
       _dataResolver = dataResolver,
       _entityFactory = entityFactory,
       _cache = cache;

  @override
  Future<List<FavoritoDefensivoEntity>> getDefensivos() async {
    try {
      final ids = await _storage.getFavoriteIds(TipoFavorito.defensivo);
      final defensivos = <FavoritoDefensivoEntity>[];

      for (final id in ids) {
        final defensivo = await _getDefensivoById(id);
        if (defensivo != null) {
          defensivos.add(defensivo);
        }
      }

      return defensivos;
    } catch (e) {
      throw FavoritosException('Erro ao buscar defensivos favoritos: $e');
    }
  }

  @override
  Future<bool> addDefensivo(String defensivoId) async {
    try {
      final result = await _storage.addFavoriteId(TipoFavorito.defensivo, defensivoId);
      
      if (result) {
        // Remove do cache para forçar atualização
        await _cache.remove('$_cachePrefix$defensivoId');
      }
      
      return result;
    } catch (e) {
      throw FavoritosException('Erro ao adicionar defensivo aos favoritos: $e', id: defensivoId);
    }
  }

  @override
  Future<bool> removeDefensivo(String defensivoId) async {
    try {
      final result = await _storage.removeFavoriteId(TipoFavorito.defensivo, defensivoId);
      
      if (result) {
        // Remove do cache
        await _cache.remove('$_cachePrefix$defensivoId');
      }
      
      return result;
    } catch (e) {
      throw FavoritosException('Erro ao remover defensivo dos favoritos: $e', id: defensivoId);
    }
  }

  @override
  Future<bool> isDefensivoFavorito(String defensivoId) async {
    try {
      return await _storage.isFavoriteId(TipoFavorito.defensivo, defensivoId);
    } catch (e) {
      throw FavoritosException('Erro ao verificar defensivo favorito: $e', id: defensivoId);
    }
  }

  Future<FavoritoDefensivoEntity?> _getDefensivoById(String id) async {
    try {
      // Verifica cache primeiro
      final cacheKey = '$_cachePrefix$id';
      final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);
      
      Map<String, dynamic>? data;
      
      if (cachedData != null) {
        data = cachedData;
      } else {
        // Busca dados frescos
        data = await _dataResolver.resolveDefensivo(id);
        
        if (data != null) {
          // Salva no cache
          await _cache.put(cacheKey, data, ttl: _cacheTtl);
        }
      }

      if (data != null) {
        return _entityFactory.createDefensivo(id: id, data: data);
      }
      
      return null;
    } catch (e) {
      throw FavoritosException('Erro ao buscar defensivo por ID: $e', id: id);
    }
  }
}

/// Implementação do repositório de favoritos de pragas
/// Princípio: Single Responsibility
class FavoritosPragasRepositoryImpl implements IFavoritosPragasRepository {
  final IFavoritosStorage _storage;
  final IFavoritosDataResolver _dataResolver;
  final IFavoritosEntityFactory _entityFactory;
  final IFavoritosCache _cache;

  static const String _cachePrefix = 'favoritos_pragas_';
  static const Duration _cacheTtl = Duration(minutes: 5);

  const FavoritosPragasRepositoryImpl({
    required IFavoritosStorage storage,
    required IFavoritosDataResolver dataResolver,
    required IFavoritosEntityFactory entityFactory,
    required IFavoritosCache cache,
  }) : _storage = storage,
       _dataResolver = dataResolver,
       _entityFactory = entityFactory,
       _cache = cache;

  @override
  Future<List<FavoritoPragaEntity>> getPragas() async {
    try {
      final ids = await _storage.getFavoriteIds(TipoFavorito.praga);
      final pragas = <FavoritoPragaEntity>[];

      for (final id in ids) {
        final praga = await _getPragaById(id);
        if (praga != null) {
          pragas.add(praga);
        }
      }

      return pragas;
    } catch (e) {
      throw FavoritosException('Erro ao buscar pragas favoritas: $e');
    }
  }

  @override
  Future<bool> addPraga(String pragaId) async {
    try {
      final result = await _storage.addFavoriteId(TipoFavorito.praga, pragaId);
      
      if (result) {
        await _cache.remove('$_cachePrefix$pragaId');
      }
      
      return result;
    } catch (e) {
      throw FavoritosException('Erro ao adicionar praga aos favoritos: $e', id: pragaId);
    }
  }

  @override
  Future<bool> removePraga(String pragaId) async {
    try {
      final result = await _storage.removeFavoriteId(TipoFavorito.praga, pragaId);
      
      if (result) {
        await _cache.remove('$_cachePrefix$pragaId');
      }
      
      return result;
    } catch (e) {
      throw FavoritosException('Erro ao remover praga dos favoritos: $e', id: pragaId);
    }
  }

  @override
  Future<bool> isPragaFavorito(String pragaId) async {
    try {
      return await _storage.isFavoriteId(TipoFavorito.praga, pragaId);
    } catch (e) {
      throw FavoritosException('Erro ao verificar praga favorita: $e', id: pragaId);
    }
  }

  Future<FavoritoPragaEntity?> _getPragaById(String id) async {
    try {
      final cacheKey = '$_cachePrefix$id';
      final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);
      
      Map<String, dynamic>? data;
      
      if (cachedData != null) {
        data = cachedData;
      } else {
        data = await _dataResolver.resolvePraga(id);
        
        if (data != null) {
          await _cache.put(cacheKey, data, ttl: _cacheTtl);
        }
      }

      if (data != null) {
        return _entityFactory.createPraga(id: id, data: data);
      }
      
      return null;
    } catch (e) {
      throw FavoritosException('Erro ao buscar praga por ID: $e', id: id);
    }
  }
}

/// Implementação básica dos outros repositórios seguindo o mesmo padrão...
class FavoritosDiagnosticosRepositoryImpl implements IFavoritosDiagnosticosRepository {
  final IFavoritosStorage _storage;
  final IFavoritosDataResolver _dataResolver;
  final IFavoritosEntityFactory _entityFactory;
  final IFavoritosCache _cache;

  const FavoritosDiagnosticosRepositoryImpl({
    required IFavoritosStorage storage,
    required IFavoritosDataResolver dataResolver,
    required IFavoritosEntityFactory entityFactory,
    required IFavoritosCache cache,
  }) : _storage = storage,
       _dataResolver = dataResolver,
       _entityFactory = entityFactory,
       _cache = cache;

  @override
  Future<List<FavoritoDiagnosticoEntity>> getDiagnosticos() async {
    try {
      final ids = await _storage.getFavoriteIds(TipoFavorito.diagnostico);
      final diagnosticos = <FavoritoDiagnosticoEntity>[];

      for (final id in ids) {
        final data = await _dataResolver.resolveDiagnostico(id);
        if (data != null) {
          diagnosticos.add(_entityFactory.createDiagnostico(id: id, data: data));
        }
      }

      return diagnosticos;
    } catch (e) {
      throw FavoritosException('Erro ao buscar diagnósticos favoritos: $e');
    }
  }

  @override
  Future<bool> addDiagnostico(String diagnosticoId) async {
    return await _storage.addFavoriteId(TipoFavorito.diagnostico, diagnosticoId);
  }

  @override
  Future<bool> removeDiagnostico(String diagnosticoId) async {
    return await _storage.removeFavoriteId(TipoFavorito.diagnostico, diagnosticoId);
  }

  @override
  Future<bool> isDiagnosticoFavorito(String diagnosticoId) async {
    return await _storage.isFavoriteId(TipoFavorito.diagnostico, diagnosticoId);
  }
}

class FavoritosCulturasRepositoryImpl implements IFavoritosCulturasRepository {
  final IFavoritosStorage _storage;
  final IFavoritosDataResolver _dataResolver;
  final IFavoritosEntityFactory _entityFactory;

  const FavoritosCulturasRepositoryImpl({
    required IFavoritosStorage storage,
    required IFavoritosDataResolver dataResolver,
    required IFavoritosEntityFactory entityFactory,
  }) : _storage = storage,
       _dataResolver = dataResolver,
       _entityFactory = entityFactory;

  @override
  Future<List<FavoritoCulturaEntity>> getCulturas() async {
    try {
      final ids = await _storage.getFavoriteIds(TipoFavorito.cultura);
      final culturas = <FavoritoCulturaEntity>[];

      for (final id in ids) {
        final data = await _dataResolver.resolveCultura(id);
        if (data != null) {
          culturas.add(_entityFactory.createCultura(id: id, data: data));
        }
      }

      return culturas;
    } catch (e) {
      throw FavoritosException('Erro ao buscar culturas favoritas: $e');
    }
  }

  @override
  Future<bool> addCultura(String culturaId) async {
    return await _storage.addFavoriteId(TipoFavorito.cultura, culturaId);
  }

  @override
  Future<bool> removeCultura(String culturaId) async {
    return await _storage.removeFavoriteId(TipoFavorito.cultura, culturaId);
  }

  @override
  Future<bool> isCulturaFavorito(String culturaId) async {
    return await _storage.isFavoriteId(TipoFavorito.cultura, culturaId);
  }
}