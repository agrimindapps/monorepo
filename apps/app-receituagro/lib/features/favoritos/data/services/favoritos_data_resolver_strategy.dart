import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../domain/entities/favorito_entity.dart';

/// Strategy Pattern para resolver dados de diferentes tipos de favoritos
/// Princípio: Open/Closed Principle - Extensível sem modificar código existente
abstract class IFavoritosDataResolverStrategy {
  /// Resolve dados do item pelo tipo e ID
  Future<Map<String, dynamic>?> resolveItemData(String id);
}

/// Estratégia para resolver dados de defensivos
class DefensivoResolverStrategy implements IFavoritosDataResolverStrategy {
  final FitossanitariosRepository _repository;

  DefensivoResolverStrategy(this._repository);

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.findByIdDefensivo(id);
      if (item == null) return null;

      return {
        'nomeComum': item.nome,
        'ingredienteAtivo': item.ingredienteAtivo ?? '',
        'fabricante': item.fabricante ?? '',
        'classeAgron': item.classeAgronomica ?? '',
        'modoAcao': item.modoAcao ?? '', // Now in Fitossanitarios table
        'formulacao': item.formulacao ?? '', // Now in Fitossanitarios table
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de pragas
class PragaResolverStrategy implements IFavoritosDataResolverStrategy {
  final PragasRepository _repository;

  PragaResolverStrategy(this._repository);

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.findByIdPraga(id);
      if (item == null) return null;

      return {
        'nomeComum': item.nome,
        'nomeCientifico': item.nomeLatino ?? '',
        'tipoPraga': item.tipo ?? '',
        'dominio': '',
        'reino': '',
        'familia': '',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de diagnósticos
class DiagnosticoResolverStrategy implements IFavoritosDataResolverStrategy {
  final DiagnosticoRepository _repository;
  final PragasRepository _pragasRepository;
  final FitossanitariosRepository _fitossanitariosRepository;
  final CulturasRepository _culturasRepository;

  DiagnosticoResolverStrategy(
    this._repository,
    this._pragasRepository,
    this._fitossanitariosRepository,
    this._culturasRepository,
  );

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.getByIdOrObjectId(id);
      if (item == null) return null;

      // Fetch related data using FKs (string PKs)
      final praga = await _pragasRepository.findByIdPraga(item.fkIdPraga);
      final defensivo =
          await _fitossanitariosRepository.findByIdDefensivo(item.fkIdDefensivo);
      final cultura = await _culturasRepository.findByIdCultura(item.fkIdCultura);

      return {
        'nomePraga': praga?.nome ?? '',
        'nomeDefensivo': defensivo?.nome ?? '',
        'cultura': cultura?.nome ?? '',
        'dosagem': '${item.dsMin ?? ''} - ${item.dsMax} ${item.um}',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de culturas
class CulturaResolverStrategy implements IFavoritosDataResolverStrategy {
  final CulturasRepository _repository;

  CulturaResolverStrategy(this._repository);

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.findByIdCultura(id);
      if (item == null) return null;

      return {
        'nomeCultura': item.nome,
        'descricao': item.nome,
        'nomeComum': item.nome,
      };
    } catch (e) {
      return null;
    }
  }
}

/// Registry de estratégias (Strategy Factory Pattern)
class FavoritosDataResolverStrategyRegistry {
  final Map<String, IFavoritosDataResolverStrategy> _strategies = {};

  FavoritosDataResolverStrategyRegistry({
    required DefensivoResolverStrategy defensivoStrategy,
    required PragaResolverStrategy pragaStrategy,
    required DiagnosticoResolverStrategy diagnosticoStrategy,
    required CulturaResolverStrategy culturaStrategy,
  }) {
    _strategies[TipoFavorito.defensivo] = defensivoStrategy;
    _strategies[TipoFavorito.praga] = pragaStrategy;
    _strategies[TipoFavorito.diagnostico] = diagnosticoStrategy;
    _strategies[TipoFavorito.cultura] = culturaStrategy;
  }

  /// Obtém a estratégia para um tipo
  IFavoritosDataResolverStrategy? getStrategy(String tipo) => _strategies[tipo];

  /// Resolve dados usando a estratégia apropriada
  Future<Map<String, dynamic>?> resolve(String tipo, String id) async {
    final strategy = getStrategy(tipo);
    if (strategy == null) return null;
    return strategy.resolveItemData(id);
  }
}
