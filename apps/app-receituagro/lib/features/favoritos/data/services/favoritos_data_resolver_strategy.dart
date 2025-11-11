import 'package:core/core.dart' show GetIt;

import '../../../../core/data/repositories/cultura_legacy_repository.dart';
import '../../../../core/data/repositories/diagnostico_legacy_repository.dart';
import '../../../../core/data/repositories/fitossanitario_legacy_repository.dart';
import '../../../../core/data/repositories/pragas_legacy_repository.dart';
import '../../domain/entities/favorito_entity.dart';

/// Strategy Pattern para resolver dados de diferentes tipos de favoritos
/// Princípio: Open/Closed Principle - Extensível sem modificar código existente
abstract class IFavoritosDataResolverStrategy {
  /// Resolve dados do item pelo tipo e ID
  Future<Map<String, dynamic>?> resolveItemData(String id);
}

/// Estratégia para resolver dados de defensivos
class DefensivoResolverStrategy implements IFavoritosDataResolverStrategy {
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  FitossanitarioLegacyRepository get _repository =>
      GetIt.instance<FitossanitarioLegacyRepository>();

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.getById(id);
      if (item == null) return null;

      return {
        'nomeComum': item.nomeComum,
        'ingredienteAtivo': item.ingredienteAtivo ?? '',
        'fabricante': item.fabricante ?? '',
        'classeAgron': item.classeAgronomica ?? '',
        'modoAcao': item.modoAcao ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de pragas
class PragaResolverStrategy implements IFavoritosDataResolverStrategy {
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  PragasLegacyRepository get _repository =>
      GetIt.instance<PragasLegacyRepository>();

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.getById(id);
      if (item == null) return null;

      return {
        'nomeComum': item.nomeComum,
        'nomeCientifico': item.nomeCientifico,
        'tipoPraga': item.tipoPraga,
        'dominio': item.dominio ?? '',
        'reino': item.reino ?? '',
        'familia': item.familia ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de diagnósticos
class DiagnosticoResolverStrategy implements IFavoritosDataResolverStrategy {
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  DiagnosticoLegacyRepository get _repository =>
      GetIt.instance<DiagnosticoLegacyRepository>();

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.getByIdOrObjectId(id);
      if (item == null) return null;

      return {
        'nomePraga': item.nomePraga ?? '',
        'nomeDefensivo': item.nomeDefensivo ?? '',
        'cultura': item.nomeCultura ?? '',
        'dosagem': '${item.dsMin} - ${item.dsMax} ${item.um}',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de culturas
class CulturaResolverStrategy implements IFavoritosDataResolverStrategy {
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  CulturaLegacyRepository get _repository =>
      GetIt.instance<CulturaLegacyRepository>();

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.getById(id);
      if (item == null) return null;

      return {
        'nomeCultura': item.cultura,
        'descricao': item.cultura,
        'nomeComum': item.nomeComum,
      };
    } catch (e) {
      return null;
    }
  }
}

/// Registry de estratégias (Strategy Factory Pattern)
class FavoritosDataResolverStrategyRegistry {
  final Map<String, IFavoritosDataResolverStrategy> _strategies = {};

  FavoritosDataResolverStrategyRegistry() {
    _strategies[TipoFavorito.defensivo] = DefensivoResolverStrategy();
    _strategies[TipoFavorito.praga] = PragaResolverStrategy();
    _strategies[TipoFavorito.diagnostico] = DiagnosticoResolverStrategy();
    _strategies[TipoFavorito.cultura] = CulturaResolverStrategy();
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
