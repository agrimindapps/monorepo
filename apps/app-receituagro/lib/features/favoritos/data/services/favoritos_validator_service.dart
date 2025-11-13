import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/favorito_entity.dart';
import 'favoritos_data_resolver_service.dart';

/// Strategy para validar dados fallback de diferentes tipos
/// Princípio: Strategy Pattern - Eliminando switch case
abstract class IFavoritoFallbackValidator {
  /// Verifica se os dados são fallback (item não existe)
  bool isFallback(Map<String, dynamic> data, String id);
}

/// Validador de fallback para defensivo
class DefensivoFallbackValidator implements IFavoritoFallbackValidator {
  @override
  bool isFallback(Map<String, dynamic> data, String id) {
    return data['nomeComum'] == 'Defensivo $id' ||
        data['ingredienteAtivo'] == 'Não disponível';
  }
}

/// Validador de fallback para praga
class PragaFallbackValidator implements IFavoritoFallbackValidator {
  @override
  bool isFallback(Map<String, dynamic> data, String id) {
    return data['nomeComum'] == 'Praga $id' ||
        data['nomeCientifico'] == 'Não disponível';
  }
}

/// Validador de fallback para diagnóstico
class DiagnosticoFallbackValidator implements IFavoritoFallbackValidator {
  @override
  bool isFallback(Map<String, dynamic> data, String id) {
    return data['nomePraga'] == 'Diagnóstico $id' ||
        data['nomeDefensivo'] == 'Não disponível';
  }
}

/// Validador de fallback para cultura
class CulturaFallbackValidator implements IFavoritoFallbackValidator {
  @override
  bool isFallback(Map<String, dynamic> data, String id) {
    return data['nomeCultura'] == 'Cultura $id' ||
        data['descricao'] == 'Não disponível';
  }
}

/// Registry de validadores fallback
class FavoritoFallbackValidatorRegistry {
  final Map<String, IFavoritoFallbackValidator> _validators = {};

  FavoritoFallbackValidatorRegistry() {
    _validators[TipoFavorito.defensivo] = DefensivoFallbackValidator();
    _validators[TipoFavorito.praga] = PragaFallbackValidator();
    _validators[TipoFavorito.diagnostico] = DiagnosticoFallbackValidator();
    _validators[TipoFavorito.cultura] = CulturaFallbackValidator();
  }

  /// Verifica se dados são fallback
  bool isFallback(String tipo, Map<String, dynamic> data, String id) {
    final validator = _validators[tipo];
    if (validator == null) return true; // Assume fallback se tipo desconhecido
    return validator.isFallback(data, id);
  }
}

/// Service especializado para validações de favoritos
/// Responsabilidade: Validar tipo, ID e existência de itens antes de favoritá-los
///
/// Refatoração: Usa Strategy Pattern via FavoritoFallbackValidatorRegistry
/// - Eliminado switch case (OCP violation)
/// - Agora extensível sem modificar este serviço
@injectable
class FavoritosValidatorService {
  final FavoritosDataResolverService _dataResolver;
  late final FavoritoFallbackValidatorRegistry _fallbackValidators;

  FavoritosValidatorService({
    required FavoritosDataResolverService dataResolver,
  }) : _dataResolver = dataResolver {
    _fallbackValidators = FavoritoFallbackValidatorRegistry();
  }

  /// Valida se um item pode ser adicionado aos favoritos
  ///
  /// Verifica:
  /// - Tipo é válido
  /// - ID não está vazio
  /// - Item existe nos dados
  Future<bool> canAddToFavorites(String tipo, String id) async {
    return isValidTipo(tipo) && isValidId(id) && await existsInData(tipo, id);
  }

  /// Verifica se um tipo de favorito é válido
  bool isValidTipo(String tipo) {
    return TipoFavorito.isValid(tipo);
  }

  /// Verifica se um ID é válido (não vazio)
  bool isValidId(String id) {
    return id.trim().isNotEmpty;
  }

  /// Verifica se um item existe nos dados usando o resolver
  ///
  /// Consolidado: usa DataResolver em vez de switch case duplicado
  Future<bool> existsInData(String tipo, String id) async {
    try {
      if (!isValidTipo(tipo)) {
        if (kDebugMode) {
          print('Tipo inválido: $tipo');
        }
        return false;
      }

      // Usa o resolver para verificar se o item existe
      // Se o resolver retornar dados (não null e não fallback), o item existe
      final data = await _dataResolver.resolveItemData(tipo, id);

      if (data == null) {
        return false;
      }

      // Verifica se não é fallback data usando a estratégia apropriada
      final isFallback = _fallbackValidators.isFallback(tipo, data, id);

      if (kDebugMode && !isFallback) {
        print('Item existe: tipo=$tipo, id=$id');
      }

      return !isFallback;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar existência: $e');
      }
      return false;
    }
  }
}
