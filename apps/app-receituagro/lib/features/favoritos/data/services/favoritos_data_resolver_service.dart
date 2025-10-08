import 'dart:developer' as developer;

import 'package:core/core.dart' show GetIt, Result;
import 'package:flutter/foundation.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/diagnostico_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../domain/entities/favorito_entity.dart';

/// Service especializado para resolver dados de favoritos
/// Responsabilidade: Buscar dados completos de itens favoritos por tipo e ID
class FavoritosDataResolverService {
  /// Resolve dados de um item favorito de forma genérica
  ///
  /// Este método consolida 4 métodos duplicados (_resolveDefensivo, _resolvePraga,
  /// _resolveDiagnostico, _resolveCultura) em uma implementação única genérica
  Future<Map<String, dynamic>?> resolveItemData(String tipo, String id) async {
    if (kDebugMode) {
      developer.log(
        'Resolvendo dados: tipo=$tipo, id=$id',
        name: 'DataResolver',
      );
    }

    try {
      switch (tipo) {
        case TipoFavorito.defensivo:
          return await _resolveGeneric<dynamic>(
            tipo: tipo,
            id: id,
            getRepository: () => GetIt.instance<FitossanitarioHiveRepository>(),
            matcher: (item) =>
                item.idReg == id || item.objectId == id,
            extractor: (item) => {
              'nomeComum': item.nomeComum,
              'ingredienteAtivo': item.ingredienteAtivo ?? '',
              'fabricante': item.fabricante ?? '',
              'classeAgron': item.classeAgronomica ?? '',
              'modoAcao': item.modoAcao ?? '',
            },
            fallbackData: {
              'nomeComum': 'Defensivo $id',
              'ingredienteAtivo': 'Não disponível',
              'fabricante': 'Não disponível',
            },
          );

        case TipoFavorito.praga:
          return await _resolveGeneric<dynamic>(
            tipo: tipo,
            id: id,
            getRepository: () => GetIt.instance<PragasHiveRepository>(),
            matcher: (item) =>
                item.idReg == id || item.objectId == id,
            extractor: (item) => {
              'nomeComum': item.nomeComum,
              'nomeCientifico': item.nomeCientifico,
              'tipoPraga': item.tipoPraga,
              'dominio': item.dominio ?? '',
              'reino': item.reino ?? '',
              'familia': item.familia ?? '',
            },
            fallbackData: {
              'nomeComum': 'Praga $id',
              'nomeCientifico': 'Não disponível',
              'tipoPraga': '1',
            },
          );

        case TipoFavorito.diagnostico:
          return await _resolveGeneric<dynamic>(
            tipo: tipo,
            id: id,
            getRepository: () => GetIt.instance<DiagnosticoHiveRepository>(),
            matcher: (item) =>
                item.idReg == id || item.objectId == id,
            extractor: (item) => {
              'nomePraga': item.nomePraga ?? 'Praga não encontrada',
              'nomeDefensivo': item.nomeDefensivo ?? 'Defensivo não encontrado',
              'cultura': item.nomeCultura ?? 'Cultura não encontrada',
              'dosagem': '${item.dsMin ?? ''} - ${item.dsMax} ${item.um}',
              'fabricante': '',
              'modoAcao': '',
            },
            fallbackData: {
              'nomePraga': 'Diagnóstico $id',
              'nomeDefensivo': 'Não disponível',
              'cultura': 'Não disponível',
              'dosagem': 'Não especificada',
            },
          );

        case TipoFavorito.cultura:
          return await _resolveGeneric<dynamic>(
            tipo: tipo,
            id: id,
            getRepository: () => GetIt.instance<CulturaHiveRepository>(),
            matcher: (item) =>
                item.idReg == id || item.objectId == id,
            extractor: (item) => {
              'nomeCultura': item.cultura,
              'descricao': item.cultura,
              'nomeComum': item.nomeComum,
            },
            fallbackData: {
              'nomeCultura': 'Cultura $id',
              'descricao': 'Não disponível',
              'nomeComum': 'Não disponível',
            },
          );

        default:
          if (kDebugMode) {
            developer.log(
              'Tipo desconhecido: $tipo',
              name: 'DataResolver',
            );
          }
          return null;
      }
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

  /// Método genérico consolidado - substitui 200+ linhas de código duplicado
  ///
  /// Este método encapsula o padrão comum de:
  /// 1. Buscar repositório
  /// 2. Obter todos os itens
  /// 3. Filtrar por ID
  /// 4. Extrair dados relevantes
  /// 5. Retornar fallback em caso de erro
  Future<Map<String, dynamic>?> _resolveGeneric<T>({
    required String tipo,
    required String id,
    required dynamic Function() getRepository,
    required bool Function(dynamic) matcher,
    required Map<String, dynamic> Function(dynamic) extractor,
    required Map<String, dynamic> fallbackData,
  }) async {
    try {
      final repository = getRepository();
      final result = await repository.getAll();

      if (result is Result && result.isError) {
        if (kDebugMode) {
          developer.log(
            'Erro ao buscar dados do repositório: ${result.error}',
            name: 'DataResolver',
          );
        }
        return fallbackData;
      }

      final data = result is Result ? result.data! : result;
      final item = (data as List).firstWhere(
        matcher,
        orElse: () => throw Exception('Item não encontrado'),
      );

      if (kDebugMode) {
        developer.log(
          'Item encontrado com sucesso',
          name: 'DataResolver',
        );
      }

      return extractor(item);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao resolver $tipo: $e',
          name: 'DataResolver',
          error: e,
        );
      }
      return fallbackData;
    }
  }
}
