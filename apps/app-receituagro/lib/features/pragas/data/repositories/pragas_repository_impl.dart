import 'package:core/core.dart';

import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/repositories/i_pragas_repository.dart';
import '../mappers/praga_mapper.dart';

/// Implementação do repositório de pragas usando Hive (Data Layer)
/// Princípios: Single Responsibility + Dependency Inversion
/// Segue padrão Either for error handling consistente
class PragasRepositoryImpl implements IPragasRepository {
  final PragasHiveRepository _hiveRepository;

  PragasRepositoryImpl(this._hiveRepository);

  @override
  Future<Either<Failure, List<PragaEntity>>> getAll() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final pragasHive = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(pragasHive);
      
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PragaEntity?>> getById(String id) async {
    try {
      if (id.isEmpty) {
        return const Left(CacheFailure('ID não pode ser vazio'));
      }

      final result = await _hiveRepository.getByKey(id);
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar praga por ID: ${result.error?.message}'));
      }
      final praga = result.data;
      
      if (praga == null) {
        return const Right(null);
      }
      
      final pragaEntity = PragaMapper.fromHiveToEntity(praga);
      return Right(pragaEntity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar praga por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByTipo(String tipo) async {
    try {
      final result = await _hiveRepository.findByTipo(tipo);
      final pragasEntities = PragaMapper.fromHiveToEntityList(result);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por tipo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> searchByName(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return const Right([]);
      }

      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      
      final allPragas = result.data ?? [];
      final term = searchTerm.trim().toLowerCase();
      final filteredPragas = allPragas.where((praga) {
        final nomeComumLower = praga.nomeComum.toLowerCase();
        final nomeCientificoLower = praga.nomeCientifico.toLowerCase();
        return nomeComumLower.contains(term) || 
               nomeCientificoLower.contains(term) ||
               (praga.nomeComum.contains(';') && 
                praga.nomeComum.toLowerCase().split(';').any((name) => 
                  name.trim().toLowerCase().contains(term)));
      }).toList();
      final entities = PragaMapper.fromHiveToEntityList(filteredPragas);
      entities.sort((a, b) {
        final aNameLower = a.nomeComum.toLowerCase();
        final bNameLower = b.nomeComum.toLowerCase();
        if (aNameLower == term && bNameLower != term) return -1;
        if (bNameLower == term && aNameLower != term) return 1;
        final aStartsWith = aNameLower.startsWith(term);
        final bStartsWith = bNameLower.startsWith(term);
        if (aStartsWith && !bStartsWith) return -1;
        if (bStartsWith && !aStartsWith) return 1;
        return a.nomeComum.compareTo(b.nomeComum);
      });

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por nome: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByFamilia(String familia) async {
    try {
      if (familia.isEmpty) {
        return const Right([]);
      }

      final result = await _hiveRepository.findByFamilia(familia);
      final pragasEntities = PragaMapper.fromHiveToEntityList(result);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por família: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByCultura(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return const Right([]);
      }
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final pragasEntities = PragaMapper.fromHiveToEntityList(result.data ?? []);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCountByTipo(String tipo) async {
    try {
      final result = await _hiveRepository.findByTipo(tipo);
      return Right(result.length);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar pragas por tipo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalCount() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      return Right(result.data?.length ?? 0);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar total de pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getPragasRecentes({int limit = 10}) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      final pragasRecentes = allPragas.take(limit).toList();
      final pragasEntities = PragaMapper.fromHiveToEntityList(pragasRecentes);
      
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas recentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getPragasStats() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      
      final stats = <String, int>{
        'total': allPragas.length,
        'insetos': allPragas.where((p) => p.tipoPraga == '1').length,
        'doencas': allPragas.where((p) => p.tipoPraga == '2').length,
        'plantas': allPragas.where((p) => p.tipoPraga == '3').length,
        'familias': allPragas
            .map((p) => p.familia)
            .where((f) => f != null && f.isNotEmpty)
            .toSet()
            .length,
      };
      
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar estatísticas das pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTiposPragas() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      final tipos = allPragas
          .map((praga) => praga.tipoPraga)
          .where((tipo) => tipo.isNotEmpty)
          .toSet()
          .toList();
      
      tipos.sort();
      return Right(tipos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar tipos de pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFamiliasPragas() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      final familias = allPragas
          .map((praga) => praga.familia)
          .where((familia) => familia != null && familia.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      
      familias.sort();
      return Right(familias);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar famílias de pragas: ${e.toString()}'));
    }
  }
}

/// Implementação do repositório de histórico usando LocalStorage
/// Princípio: Single Responsibility - Apenas gerencia histórico
class PragasHistoryRepositoryImpl implements IPragasHistoryRepository {
  final PragasHiveRepository _hiveRepository;

  static const int _maxRecentItems = 7;
  static const int _maxSuggestedItems = 5;

  PragasHistoryRepositoryImpl(this._hiveRepository);

  @override
  Future<Either<Failure, List<PragaEntity>>> getRecentlyAccessed() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      if (allPragas.isEmpty) return const Right([]);
      final recentHivePragas = allPragas.take(_maxRecentItems).toList();
      final pragasEntities = PragaMapper.fromHiveToEntityList(recentHivePragas);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar pragas recentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsAccessed(String pragaId) async {
    try {
      if (pragaId.isEmpty) {
        return const Left(CacheFailure('ID da praga não pode ser vazio'));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar praga como acessada: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getSuggested(int limit) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      if (allPragas.isEmpty) return const Right([]);
      final shuffledPragas = allPragas.toList()..shuffle();
      final suggestedHivePragas = shuffledPragas
          .take(limit.clamp(1, _maxSuggestedItems))
          .toList();
      final pragasEntities = PragaMapper.fromHiveToEntityList(suggestedHivePragas);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas sugeridas: ${e.toString()}'));
    }
  }
}

/// Implementação do formatador de pragas
/// Princípio: Single Responsibility - Apenas formatação
class PragasFormatterImpl implements IPragasFormatter {
  @override
  String formatImageName(String nomeCientifico) {
    if ([
      'Espalhante adesivo para calda de pulverização',
      'Não classificado',
    ].contains(nomeCientifico)) {
      return 'a';
    }
    return nomeCientifico
        .replaceAll('/', '-')
        .replaceAll('ç', 'c')
        .replaceAll('ã', 'a');
  }

  @override
  Map<String, dynamic> formatForDisplay(PragaEntity praga) {
    return {
      'idReg': praga.idReg,
      'nomeComum': praga.nomeFormatado,
      'nomeSecundario': praga.nomesSecundarios.join(', '),
      'nomeCientifico': praga.nomeCientifico,
      'nomeImagem': formatImageName(praga.nomeCientifico),
      'tipoPraga': praga.tipoPraga,
      'isInseto': praga.isInseto,
      'isDoenca': praga.isDoenca,
      'isPlanta': praga.isPlanta,
    };
  }

  @override
  String formatNomeComum(String nomeCompleto) {
    final nomeList = nomeCompleto.split(';');
    return nomeList[0].split('-')[0].trim();
  }
}