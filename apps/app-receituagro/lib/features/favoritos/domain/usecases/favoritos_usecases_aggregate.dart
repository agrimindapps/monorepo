import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';
import 'favoritos_usecases.dart';

/// Classe agregadora que unifica todos os use cases de favoritos
/// Facilita o uso em providers e reduz a complexidade de injeção de dependências
class FavoritosUsecases {
  final GetAllFavoritosUseCase _getAllFavoritos;
  final GetFavoritosByTipoUseCase _getFavoritosByTipo;
  final GetDefensivosFavoritosUseCase _getDefensivosFavoritos;
  final GetPragasFavoritosUseCase _getPragasFavoritos;
  final GetDiagnosticosFavoritosUseCase _getDiagnosticosFavoritos;
  final GetCulturasFavoritosUseCase _getCulturasFavoritos;
  final AddDefensivoFavoritoUseCase _addDefensivoFavorito;
  final RemoveDefensivoFavoritoUseCase _removeDefensivoFavorito;
  final AddPragaFavoritoUseCase _addPragaFavorito;
  final RemovePragaFavoritoUseCase _removePragaFavorito;
  final IsFavoritoUseCase _isFavorito;
  final ToggleFavoritoUseCase _toggleFavorito;
  final SearchFavoritosUseCase _searchFavoritos;
  final GetFavoritosStatsUseCase _getFavoritosStats;
  final ClearFavoritosByTipoUseCase _clearFavoritosByTipo;
  final SyncFavoritosUseCase _syncFavoritos;

  const FavoritosUsecases({
    required GetAllFavoritosUseCase getAllFavoritos,
    required GetFavoritosByTipoUseCase getFavoritosByTipo,
    required GetDefensivosFavoritosUseCase getDefensivosFavoritos,
    required GetPragasFavoritosUseCase getPragasFavoritos,
    required GetDiagnosticosFavoritosUseCase getDiagnosticosFavoritos,
    required GetCulturasFavoritosUseCase getCulturasFavoritos,
    required AddDefensivoFavoritoUseCase addDefensivoFavorito,
    required RemoveDefensivoFavoritoUseCase removeDefensivoFavorito,
    required AddPragaFavoritoUseCase addPragaFavorito,
    required RemovePragaFavoritoUseCase removePragaFavorito,
    required IsFavoritoUseCase isFavorito,
    required ToggleFavoritoUseCase toggleFavorito,
    required SearchFavoritosUseCase searchFavoritos,
    required GetFavoritosStatsUseCase getFavoritosStats,
    required ClearFavoritosByTipoUseCase clearFavoritosByTipo,
    required SyncFavoritosUseCase syncFavoritos,
  }) : _getAllFavoritos = getAllFavoritos,
       _getFavoritosByTipo = getFavoritosByTipo,
       _getDefensivosFavoritos = getDefensivosFavoritos,
       _getPragasFavoritos = getPragasFavoritos,
       _getDiagnosticosFavoritos = getDiagnosticosFavoritos,
       _getCulturasFavoritos = getCulturasFavoritos,
       _addDefensivoFavorito = addDefensivoFavorito,
       _removeDefensivoFavorito = removeDefensivoFavorito,
       _addPragaFavorito = addPragaFavorito,
       _removePragaFavorito = removePragaFavorito,
       _isFavorito = isFavorito,
       _toggleFavorito = toggleFavorito,
       _searchFavoritos = searchFavoritos,
       _getFavoritosStats = getFavoritosStats,
       _clearFavoritosByTipo = clearFavoritosByTipo,
       _syncFavoritos = syncFavoritos;

  // =============================================================================
  // MÉTODOS DE LEITURA
  // =============================================================================

  /// Obtém todos os favoritos
  Future<List<FavoritoEntity>> getAllFavoritos() async {
    return await _getAllFavoritos.execute();
  }

  /// Obtém favoritos por tipo específico
  Future<List<FavoritoEntity>> getFavoritosByTipo(String tipo) async {
    return await _getFavoritosByTipo.execute(tipo);
  }

  /// Obtém favoritos de defensivos
  Future<List<FavoritoDefensivoEntity>> getDefensivosFavoritos() async {
    return await _getDefensivosFavoritos.execute();
  }

  /// Obtém favoritos de pragas
  Future<List<FavoritoPragaEntity>> getPragasFavoritos() async {
    return await _getPragasFavoritos.execute();
  }

  /// Obtém favoritos de diagnósticos
  Future<List<FavoritoDiagnosticoEntity>> getDiagnosticosFavoritos() async {
    return await _getDiagnosticosFavoritos.execute();
  }

  /// Obtém favoritos de culturas
  Future<List<FavoritoCulturaEntity>> getCulturasFavoritos() async {
    return await _getCulturasFavoritos.execute();
  }

  // =============================================================================
  // MÉTODOS DE ESCRITA - DEFENSIVOS
  // =============================================================================

  /// Adiciona defensivo aos favoritos
  Future<bool> addDefensivoFavorito(String defensivoId) async {
    return await _addDefensivoFavorito.execute(defensivoId);
  }

  /// Remove defensivo dos favoritos
  Future<bool> removeDefensivoFavorito(String defensivoId) async {
    return await _removeDefensivoFavorito.execute(defensivoId);
  }

  // =============================================================================
  // MÉTODOS DE ESCRITA - PRAGAS
  // =============================================================================

  /// Adiciona praga aos favoritos
  Future<bool> addPragaFavorito(String pragaId) async {
    return await _addPragaFavorito.execute(pragaId);
  }

  /// Remove praga dos favoritos
  Future<bool> removePragaFavorito(String pragaId) async {
    return await _removePragaFavorito.execute(pragaId);
  }

  // =============================================================================
  // MÉTODOS DE VERIFICAÇÃO
  // =============================================================================

  /// Verifica se item é favorito
  Future<bool> isFavorito(String tipo, String id) async {
    return await _isFavorito.execute(tipo, id);
  }

  /// Alterna favorito (toggle)
  Future<bool> toggleFavorito(String tipo, String id) async {
    return await _toggleFavorito.execute(tipo, id);
  }

  // =============================================================================
  // MÉTODOS DE BUSCA E ESTATÍSTICAS
  // =============================================================================

  /// Busca favoritos por query
  Future<List<FavoritoEntity>> searchFavoritos(String query) async {
    return await _searchFavoritos.execute(query);
  }

  /// Obtém estatísticas de favoritos
  Future<FavoritosStats> getFavoritosStats() async {
    return await _getFavoritosStats.execute();
  }

  // =============================================================================
  // MÉTODOS DE GERENCIAMENTO
  // =============================================================================

  /// Limpa favoritos por tipo
  Future<void> clearFavoritosByTipo(String tipo) async {
    await _clearFavoritosByTipo.execute(tipo);
  }

  /// Sincroniza favoritos
  Future<void> syncFavoritos() async {
    await _syncFavoritos.execute();
  }

  // =============================================================================
  // MÉTODOS CONVENIENTES
  // =============================================================================

  /// Verifica se defensivo é favorito
  Future<bool> isDefensivoFavorito(String defensivoId) async {
    return await isFavorito(TipoFavorito.defensivo, defensivoId);
  }

  /// Verifica se praga é favorita
  Future<bool> isPragaFavorita(String pragaId) async {
    return await isFavorito(TipoFavorito.praga, pragaId);
  }

  /// Verifica se diagnóstico é favorito
  Future<bool> isDiagnosticoFavorito(String diagnosticoId) async {
    return await isFavorito(TipoFavorito.diagnostico, diagnosticoId);
  }

  /// Alterna defensivo favorito
  Future<bool> toggleDefensivoFavorito(String defensivoId) async {
    return await toggleFavorito(TipoFavorito.defensivo, defensivoId);
  }

  /// Alterna praga favorita
  Future<bool> togglePragaFavorita(String pragaId) async {
    return await toggleFavorito(TipoFavorito.praga, pragaId);
  }

  /// Alterna diagnóstico favorito
  Future<bool> toggleDiagnosticoFavorito(String diagnosticoId) async {
    return await toggleFavorito(TipoFavorito.diagnostico, diagnosticoId);
  }

  /// Obtém contagem de favoritos por tipo
  Future<int> getCountByTipo(String tipo) async {
    final favoritos = await getFavoritosByTipo(tipo);
    return favoritos.length;
  }

  /// Verifica se há favoritos de um tipo específico
  Future<bool> hasFavoritosByTipo(String tipo) async {
    final count = await getCountByTipo(tipo);
    return count > 0;
  }
}