import 'package:flutter/foundation.dart';

import '../../domain/entities/favorito_entity.dart';
import 'favoritos_data_resolver_service.dart';

/// Service especializado para validações de favoritos
/// Responsabilidade: Validar tipo, ID e existência de itens antes de favoritá-los
class FavoritosValidatorService {
  final FavoritosDataResolverService _dataResolver;

  FavoritosValidatorService({
    required FavoritosDataResolverService dataResolver,
  }) : _dataResolver = dataResolver;

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

      // Verifica se não é fallback data comparando valores conhecidos
      final isFallback = _isFallbackData(tipo, data, id);

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

  /// Verifica se os dados são fallback (item não existe)
  bool _isFallbackData(String tipo, Map<String, dynamic> data, String id) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return data['nomeComum'] == 'Defensivo $id' ||
            data['ingredienteAtivo'] == 'Não disponível';

      case TipoFavorito.praga:
        return data['nomeComum'] == 'Praga $id' ||
            data['nomeCientifico'] == 'Não disponível';

      case TipoFavorito.diagnostico:
        return data['nomePraga'] == 'Diagnóstico $id' ||
            data['nomeDefensivo'] == 'Não disponível';

      case TipoFavorito.cultura:
        return data['nomeCultura'] == 'Cultura $id' ||
            data['descricao'] == 'Não disponível';

      default:
        return true;
    }
  }
}
