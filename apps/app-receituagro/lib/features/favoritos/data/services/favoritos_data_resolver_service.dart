import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'favoritos_data_resolver_strategy.dart';

/// Service especializado para resolver dados de favoritos
/// Responsabilidade: Buscar dados completos de itens favoritos por tipo e ID
///
/// Refatoração: Usa Strategy Pattern via FavoritosDataResolverStrategyRegistry
/// - Eliminado switch case (OCP violation)
/// - Agora extensível sem modificar este serviço
class FavoritosDataResolverService {
  late final FavoritosDataResolverStrategyRegistry _strategyRegistry;

  FavoritosDataResolverService() {
    _strategyRegistry = FavoritosDataResolverStrategyRegistry();
  }

  /// Resolve dados de um item favorito usando a estratégia apropriada
  Future<Map<String, dynamic>?> resolveItemData(String tipo, String id) async {
    if (kDebugMode) {
      developer.log(
        'Resolvendo dados: tipo=$tipo, id=$id',
        name: 'DataResolver',
      );
    }

    try {
      final result = await _strategyRegistry.resolve(tipo, id);

      if (result != null && kDebugMode) {
        developer.log('Dados resolvidos: $result', name: 'DataResolver');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao resolver dados: $e',
          name: 'DataResolver',
          error: e,
        );
      }
      return null;
    }
  }
}
