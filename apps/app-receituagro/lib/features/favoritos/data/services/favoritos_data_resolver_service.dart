import 'dart:developer' as developer;

import 'package:core/core.dart' show GetIt;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/diagnostico_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/errors/failures.dart';
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
          return await _resolveDiagnosticoWithLookups(id);

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

  /// Resolve dados de diagnóstico com lookups nas outras HiveBoxes
  ///
  /// Busca o diagnóstico pelo ID e faz lookups para obter:
  /// - Nome do defensivo (via fkIdDefensivo)
  /// - Nome da praga (via fkIdPraga)
  /// - Nome da cultura (via fkIdCultura)
  Future<Map<String, dynamic>?> _resolveDiagnosticoWithLookups(String id) async {
    if (kDebugMode) {
      developer.log(
        'Resolvendo diagnóstico com lookups: id=$id',
        name: 'DataResolver',
      );
    }

    try {
      // 1. Buscar o diagnóstico
      final diagRepo = GetIt.instance<DiagnosticoHiveRepository>();
      final diagResult = await diagRepo.getAll();

      // Handle both Result<T> (legacy) and direct List responses
      List<dynamic> diagData;
      if (diagResult is List) {
        diagData = diagResult;
      } else {
        // Legacy Result<T> handling
        final resultData = diagResult as dynamic;
        if (resultData.isError) {
          if (kDebugMode) {
            developer.log('Erro ao buscar diagnóstico', name: 'DataResolver');
          }
          return _getDiagnosticoFallback(id);
        }
        diagData = resultData.data as List;
      }

      final diagnostico = diagData.firstWhere(
        (item) => (item as dynamic).idReg == id || (item as dynamic).objectId == id,
        orElse: () => throw Exception('Diagnóstico não encontrado'),
      ) as dynamic;

      // 2. Buscar nome do defensivo se nomeDefensivo estiver vazio
      String nomeDefensivo = (diagnostico.nomeDefensivo as String?) ?? '';
      final fkIdDefensivo = (diagnostico.fkIdDefensivo as String?) ?? '';
      if (nomeDefensivo.isEmpty && fkIdDefensivo.isNotEmpty) {
        final defensivoData = await _lookupDefensivo(fkIdDefensivo);
        nomeDefensivo = defensivoData?['nomeComum'] as String? ?? 'Defensivo não encontrado';
      }

      // 3. Buscar nome da praga se nomePraga estiver vazio
      String nomePraga = (diagnostico.nomePraga as String?) ?? '';
      final fkIdPraga = (diagnostico.fkIdPraga as String?) ?? '';
      if (nomePraga.isEmpty && fkIdPraga.isNotEmpty) {
        final pragaData = await _lookupPraga(fkIdPraga);
        nomePraga = pragaData?['nomeComum'] as String? ?? 'Praga não encontrada';
      }

      // 4. Buscar nome da cultura se nomeCultura estiver vazio
      String nomeCultura = (diagnostico.nomeCultura as String?) ?? '';
      final fkIdCultura = (diagnostico.fkIdCultura as String?) ?? '';
      if (nomeCultura.isEmpty && fkIdCultura.isNotEmpty) {
        final culturaData = await _lookupCultura(fkIdCultura);
        nomeCultura = culturaData?['nomeCultura'] as String? ?? 'Cultura não encontrada';
      }

      // 5. Montar dosagem
      final dsMin = (diagnostico.dsMin as String?) ?? '0';
      final dsMax = (diagnostico.dsMax as String?) ?? '0';
      final um = (diagnostico.um as String?) ?? '';
      final dosagem = um.isNotEmpty ? '$dsMin - $dsMax $um / 100 Lt' : '$dsMin - $dsMax';

      final result = {
        'nomeDefensivo': nomeDefensivo,
        'nomePraga': nomePraga,
        'cultura': nomeCultura,
        'dosagem': dosagem,
      };

      if (kDebugMode) {
        developer.log(
          'Diagnóstico resolvido: $result',
          name: 'DataResolver',
        );
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao resolver diagnóstico: $e',
          name: 'DataResolver',
          error: e,
        );
      }
      return _getDiagnosticoFallback(id);
    }
  }

  /// Lookup de defensivo por ID
  Future<Map<String, dynamic>?> _lookupDefensivo(String id) async {
    try {
      final repo = GetIt.instance<FitossanitarioHiveRepository>();
      final data = await repo.getAll() as List;

      final item = data.firstWhere(
        (item) => (item as dynamic).idReg == id || (item as dynamic).objectId == id,
        orElse: () => null,
      );

      if (item == null) return null;

      final dynamicItem = item as dynamic;
      return {
        'nomeComum': (dynamicItem.nomeComum as String?) ?? '',
        'ingredienteAtivo': (dynamicItem.ingredienteAtivo as String?) ?? '',
      };
    } catch (e) {
      if (kDebugMode) {
        developer.log('Erro ao buscar defensivo $id: $e', name: 'DataResolver');
      }
      return null;
    }
  }

  /// Lookup de praga por ID
  Future<Map<String, dynamic>?> _lookupPraga(String id) async {
    try {
      final repo = GetIt.instance<PragasHiveRepository>();
      final data = await repo.getAll() as List;

      final item = data.firstWhere(
        (item) => (item as dynamic).idReg == id || (item as dynamic).objectId == id,
        orElse: () => null,
      );

      if (item == null) return null;

      final dynamicItem = item as dynamic;
      return {
        'nomeComum': (dynamicItem.nomeComum as String?) ?? '',
        'nomeCientifico': (dynamicItem.nomeCientifico as String?) ?? '',
      };
    } catch (e) {
      if (kDebugMode) {
        developer.log('Erro ao buscar praga $id: $e', name: 'DataResolver');
      }
      return null;
    }
  }

  /// Lookup de cultura por ID
  Future<Map<String, dynamic>?> _lookupCultura(String id) async {
    try {
      final repo = GetIt.instance<CulturaHiveRepository>();
      final data = await repo.getAll() as List;

      final item = data.firstWhere(
        (item) => (item as dynamic).idReg == id || (item as dynamic).objectId == id,
        orElse: () => null,
      );

      if (item == null) return null;

      final dynamicItem = item as dynamic;
      return {
        'nomeCultura': (dynamicItem.cultura as String?) ?? '',
        'nomeComum': (dynamicItem.nomeComum as String?) ?? '',
      };
    } catch (e) {
      if (kDebugMode) {
        developer.log('Erro ao buscar cultura $id: $e', name: 'DataResolver');
      }
      return null;
    }
  }

  /// Fallback data para diagnóstico
  Map<String, dynamic> _getDiagnosticoFallback(String id) {
    return {
      'nomeDefensivo': 'Defensivo não encontrado',
      'nomePraga': 'Praga não encontrada',
      'cultura': 'Cultura não encontrada',
      'dosagem': 'Não especificada',
    };
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

      // Handle both Result<T> (legacy) and direct List responses
      List<dynamic> data;
      if (result is List) {
        data = result;
      } else {
        // Legacy Result<T> handling
        final resultData = result as dynamic;
        if (resultData.isError) {
          if (kDebugMode) {
            developer.log(
              'Erro ao buscar dados do repositório: ${resultData.error}',
              name: 'DataResolver',
            );
          }
          return fallbackData;
        }
        data = resultData.data as List;
      }

      final item = data.firstWhere(
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
