import 'package:core/core.dart' show GetIt;

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
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  FitossanitariosRepository get _repository =>
      GetIt.instance<FitossanitariosRepository>();

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
        'modoAcao': '', // Not available in Drift Fitossanitarios table
      };
    } catch (e) {
      return null;
    }
  }
}

/// Estratégia para resolver dados de pragas
class PragaResolverStrategy implements IFavoritosDataResolverStrategy {
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  PragasRepository get _repository => GetIt.instance<PragasRepository>();

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
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  DiagnosticoRepository get _repository =>
      GetIt.instance<DiagnosticoRepository>();
  PragasRepository get _pragasRepository => GetIt.instance<PragasRepository>();
  FitossanitariosRepository get _fitossanitariosRepository =>
      GetIt.instance<FitossanitariosRepository>();
  CulturasRepository get _culturasRepository =>
      GetIt.instance<CulturasRepository>();

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final item = await _repository.getByIdOrObjectId(id);
      if (item == null) return null;

      // Fetch related data using FKs
      final praga = await _pragasRepository.findById(item.pragaId);
      final defensivo =
          await _fitossanitariosRepository.findById(item.defenisivoId);
      final cultura = await _culturasRepository.findById(item.culturaId);

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
  // ✅ Lazy loading: obtém o repo apenas quando necessário
  CulturasRepository get _repository => GetIt.instance<CulturasRepository>();

  @override
  Future<Map<String, dynamic>?> resolveItemData(String id) async {
    try {
      final idInt = int.tryParse(id);
      if (idInt == null) return null;

      final item = await _repository.findById(idInt);
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
