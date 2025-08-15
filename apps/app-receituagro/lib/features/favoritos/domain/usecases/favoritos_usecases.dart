import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';

/// Use Case para buscar todos os favoritos (Domain Layer)
/// Princípio: Single Responsibility
class GetAllFavoritosUseCase {
  final IFavoritosRepository _repository;

  const GetAllFavoritosUseCase({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  Future<List<FavoritoEntity>> execute() async {
    return await _repository.getAll();
  }
}

/// Use Case para buscar favoritos por tipo
class GetFavoritosByTipoUseCase {
  final IFavoritosRepository _repository;

  const GetFavoritosByTipoUseCase({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  Future<List<FavoritoEntity>> execute(String tipo) async {
    if (!TipoFavorito.isValid(tipo)) {
      throw ArgumentError('Tipo de favorito inválido: $tipo');
    }
    return await _repository.getByTipo(tipo);
  }
}

/// Use Case para buscar favoritos de defensivos
class GetDefensivosFavoritosUseCase {
  final IFavoritosDefensivosRepository _repository;

  const GetDefensivosFavoritosUseCase({
    required IFavoritosDefensivosRepository repository,
  }) : _repository = repository;

  Future<List<FavoritoDefensivoEntity>> execute() async {
    return await _repository.getDefensivos();
  }
}

/// Use Case para buscar favoritos de pragas
class GetPragasFavoritosUseCase {
  final IFavoritosPragasRepository _repository;

  const GetPragasFavoritosUseCase({
    required IFavoritosPragasRepository repository,
  }) : _repository = repository;

  Future<List<FavoritoPragaEntity>> execute() async {
    return await _repository.getPragas();
  }
}

/// Use Case para buscar favoritos de diagnósticos
class GetDiagnosticosFavoritosUseCase {
  final IFavoritosDiagnosticosRepository _repository;

  const GetDiagnosticosFavoritosUseCase({
    required IFavoritosDiagnosticosRepository repository,
  }) : _repository = repository;

  Future<List<FavoritoDiagnosticoEntity>> execute() async {
    return await _repository.getDiagnosticos();
  }
}

/// Use Case para adicionar defensivo aos favoritos
class AddDefensivoFavoritoUseCase {
  final IFavoritosDefensivosRepository _repository;
  final IFavoritosValidator _validator;

  const AddDefensivoFavoritoUseCase({
    required IFavoritosDefensivosRepository repository,
    required IFavoritosValidator validator,
  }) : _repository = repository,
       _validator = validator;

  Future<bool> execute(String defensivoId) async {
    if (!_validator.isValidId(defensivoId)) {
      throw ArgumentError('ID do defensivo inválido: $defensivoId');
    }

    final canAdd = await _validator.canAddToFavorites(TipoFavorito.defensivo, defensivoId);
    if (!canAdd) {
      throw FavoritosException(
        'Não é possível adicionar defensivo aos favoritos',
        tipo: TipoFavorito.defensivo,
        id: defensivoId,
      );
    }

    return await _repository.addDefensivo(defensivoId);
  }
}

/// Use Case para remover defensivo dos favoritos
class RemoveDefensivoFavoritoUseCase {
  final IFavoritosDefensivosRepository _repository;

  const RemoveDefensivoFavoritoUseCase({
    required IFavoritosDefensivosRepository repository,
  }) : _repository = repository;

  Future<bool> execute(String defensivoId) async {
    if (defensivoId.trim().isEmpty) {
      throw ArgumentError('ID do defensivo não pode ser vazio');
    }

    return await _repository.removeDefensivo(defensivoId);
  }
}

/// Use Case para adicionar praga aos favoritos
class AddPragaFavoritoUseCase {
  final IFavoritosPragasRepository _repository;
  final IFavoritosValidator _validator;

  const AddPragaFavoritoUseCase({
    required IFavoritosPragasRepository repository,
    required IFavoritosValidator validator,
  }) : _repository = repository,
       _validator = validator;

  Future<bool> execute(String pragaId) async {
    if (!_validator.isValidId(pragaId)) {
      throw ArgumentError('ID da praga inválido: $pragaId');
    }

    final canAdd = await _validator.canAddToFavorites(TipoFavorito.praga, pragaId);
    if (!canAdd) {
      throw FavoritosException(
        'Não é possível adicionar praga aos favoritos',
        tipo: TipoFavorito.praga,
        id: pragaId,
      );
    }

    return await _repository.addPraga(pragaId);
  }
}

/// Use Case para remover praga dos favoritos
class RemovePragaFavoritoUseCase {
  final IFavoritosPragasRepository _repository;

  const RemovePragaFavoritoUseCase({
    required IFavoritosPragasRepository repository,
  }) : _repository = repository;

  Future<bool> execute(String pragaId) async {
    if (pragaId.trim().isEmpty) {
      throw ArgumentError('ID da praga não pode ser vazio');
    }

    return await _repository.removePraga(pragaId);
  }
}

/// Use Case para verificar se item é favorito
class IsFavoritoUseCase {
  final IFavoritosRepository _repository;

  const IsFavoritoUseCase({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  Future<bool> execute(String tipo, String id) async {
    if (!TipoFavorito.isValid(tipo)) {
      throw ArgumentError('Tipo de favorito inválido: $tipo');
    }
    
    if (id.trim().isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }

    return await _repository.isFavorito(tipo, id);
  }
}

/// Use Case para alternar favorito (toggle)
class ToggleFavoritoUseCase {
  final IFavoritosDefensivosRepository _defensivosRepository;
  final IFavoritosPragasRepository _pragasRepository;
  final IFavoritosDiagnosticosRepository _diagnosticosRepository;
  final IFavoritosCulturasRepository _culturasRepository;
  final IFavoritosRepository _repository;

  const ToggleFavoritoUseCase({
    required IFavoritosDefensivosRepository defensivosRepository,
    required IFavoritosPragasRepository pragasRepository,
    required IFavoritosDiagnosticosRepository diagnosticosRepository,
    required IFavoritosCulturasRepository culturasRepository,
    required IFavoritosRepository repository,
  }) : _defensivosRepository = defensivosRepository,
       _pragasRepository = pragasRepository,
       _diagnosticosRepository = diagnosticosRepository,
       _culturasRepository = culturasRepository,
       _repository = repository;

  Future<bool> execute(String tipo, String id) async {
    if (!TipoFavorito.isValid(tipo)) {
      throw ArgumentError('Tipo de favorito inválido: $tipo');
    }
    
    if (id.trim().isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }

    final isFavorito = await _repository.isFavorito(tipo, id);

    switch (tipo) {
      case TipoFavorito.defensivo:
        return isFavorito 
            ? await _defensivosRepository.removeDefensivo(id)
            : await _defensivosRepository.addDefensivo(id);
            
      case TipoFavorito.praga:
        return isFavorito 
            ? await _pragasRepository.removePraga(id)
            : await _pragasRepository.addPraga(id);
            
      case TipoFavorito.diagnostico:
        return isFavorito 
            ? await _diagnosticosRepository.removeDiagnostico(id)
            : await _diagnosticosRepository.addDiagnostico(id);
            
      case TipoFavorito.cultura:
        return isFavorito 
            ? await _culturasRepository.removeCultura(id)
            : await _culturasRepository.addCultura(id);
            
      default:
        throw ArgumentError('Tipo de favorito não suportado: $tipo');
    }
  }
}

/// Use Case para buscar favoritos
class SearchFavoritosUseCase {
  final IFavoritosRepository _repository;

  const SearchFavoritosUseCase({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  Future<List<FavoritoEntity>> execute(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return await _repository.search(query.trim());
  }
}

/// Use Case para obter estatísticas de favoritos
class GetFavoritosStatsUseCase {
  final IFavoritosRepository _repository;

  const GetFavoritosStatsUseCase({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  Future<FavoritosStats> execute() async {
    return await _repository.getStats();
  }
}

/// Use Case para limpar favoritos por tipo
class ClearFavoritosByTipoUseCase {
  final IFavoritosStorage _storage;

  const ClearFavoritosByTipoUseCase({
    required IFavoritosStorage storage,
  }) : _storage = storage;

  Future<void> execute(String tipo) async {
    if (!TipoFavorito.isValid(tipo)) {
      throw ArgumentError('Tipo de favorito inválido: $tipo');
    }

    await _storage.clearFavorites(tipo);
  }
}

/// Use Case para sincronizar favoritos
class SyncFavoritosUseCase {
  final IFavoritosStorage _storage;

  const SyncFavoritosUseCase({
    required IFavoritosStorage storage,
  }) : _storage = storage;

  Future<void> execute() async {
    await _storage.syncFavorites();
  }
}