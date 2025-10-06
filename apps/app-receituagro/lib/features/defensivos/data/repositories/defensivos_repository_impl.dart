import 'package:core/core.dart';

import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../mappers/defensivo_mapper.dart';

/// Implementação do repositório de defensivos
/// Segue padrões Clean Architecture + Either pattern para error handling
/// TEMPORARY: Using FitossanitarioHiveRepository instead of FitossanitarioCoreRepository
class DefensivosRepositoryImpl implements IDefensivosRepository {
  final FitossanitarioHiveRepository _repository;

  DefensivosRepositoryImpl(this._repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getAllDefensivos() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final defensivosHive = result.data ?? [];
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosHive);
      
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByClasse(String classe) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final defensivosFiltrados = allDefensivos
          .where((defensivo) => 
              defensivo.classeAgronomica?.toLowerCase().contains(classe.toLowerCase()) == true)
          .toList();
      
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por classe: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivoEntity?>> getDefensivoById(String id) async {
    try {
      final result = await _repository.getByKey(id);
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivo por ID: ${result.error?.message}'));
      }
      final defensivo = result.data;
      
      if (defensivo == null) {
        return const Right(null);
      }
      
      final defensivoEntity = DefensivoMapper.fromHiveToEntity(defensivo);
      return Right(defensivoEntity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivo por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchDefensivos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllDefensivos();
      }

      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final defensivosFiltrados = allDefensivos.where((defensivo) {
        final nomeComumMatch = defensivo.nomeComum.toLowerCase().contains(query.toLowerCase());
        final nomeTecnicoMatch = defensivo.nomeTecnico.toLowerCase().contains(query.toLowerCase());
        final ingredienteAtivoMatch = defensivo.ingredienteAtivo?.toLowerCase().contains(query.toLowerCase()) == true;
        
        return nomeComumMatch || nomeTecnicoMatch || ingredienteAtivoMatch;
      }).toList();
      
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByFabricante(String fabricante) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final defensivosFiltrados = allDefensivos
          .where((defensivo) => 
              defensivo.fabricante?.toLowerCase().contains(fabricante.toLowerCase()) == true)
          .toList();
      
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por fabricante: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByModoAcao(String modoAcao) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final defensivosFiltrados = allDefensivos
          .where((defensivo) => 
              defensivo.modoAcao?.toLowerCase().contains(modoAcao.toLowerCase()) == true)
          .toList();
      
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por modo de ação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getClassesAgronomicas() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final classes = allDefensivos
          .map((defensivo) => defensivo.classeAgronomica)
          .where((classe) => classe != null && classe.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      
      classes.sort();
      return Right(classes);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar classes agronômicas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFabricantes() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final fabricantes = allDefensivos
          .map((defensivo) => defensivo.fabricante)
          .where((fabricante) => fabricante != null && fabricante.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      
      fabricantes.sort();
      return Right(fabricantes);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar fabricantes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getModosAcao() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final modosAcao = allDefensivos
          .map((defensivo) => defensivo.modoAcao)
          .where((modo) => modo != null && modo.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      
      modosAcao.sort();
      return Right(modosAcao);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar modos de ação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosRecentes({int limit = 10}) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final defensivosRecentes = allDefensivos.take(limit).toList();
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosRecentes);
      
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos recentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDefensivosStats() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      
      final stats = <String, int>{
        'total': allDefensivos.length,
        'classes': allDefensivos
            .map((d) => d.classeAgronomica)
            .where((c) => c != null && c.isNotEmpty)
            .toSet()
            .length,
        'fabricantes': allDefensivos
            .map((d) => d.fabricante)
            .where((f) => f != null && f.isNotEmpty)
            .toSet()
            .length,
        'modosAcao': allDefensivos
            .map((d) => d.modoAcao)
            .where((m) => m != null && m.isNotEmpty)
            .toSet()
            .length,
      };
      
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar estatísticas dos defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isDefensivoActive(String defensivoId) async {
    try {
      final result = await _repository.getByKey(defensivoId);
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao verificar status do defensivo: ${result.error?.message}'));
      }
      final defensivo = result.data;
      return Right(defensivo != null);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar status do defensivo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      var defensivosFiltrados = allDefensivos.toList();
      if (filtroTexto != null && filtroTexto.isNotEmpty) {
        defensivosFiltrados = defensivosFiltrados.where((defensivo) {
          final nomeMatch = defensivo.nomeComum.toLowerCase().contains(filtroTexto.toLowerCase());
          final ingredienteMatch = defensivo.ingredienteAtivo?.toLowerCase().contains(filtroTexto.toLowerCase()) == true;
          final classeMatch = defensivo.classeAgronomica?.toLowerCase().contains(filtroTexto.toLowerCase()) == true;
          return nomeMatch || ingredienteMatch || classeMatch;
        }).toList();
      }
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos agrupados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosCompletos() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      final defensivosEntities = allDefensivos.map((hive) {
        return DefensivoMapper.fromHiveToEntity(hive).copyWith(
          quantidadeDiagnosticos: 0, // TODO: integrar com DiagnosticoIntegrationService
          nivelPrioridade: 1,
          isComercializado: hive.status,
          isElegivel: hive.status,
        );
      }).toList();
      
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos completos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosComFiltros({
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool apenasComercializados = false,
    bool apenasElegiveis = false,
  }) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'));
      }
      final allDefensivos = result.data ?? [];
      var defensivosFiltrados = DefensivoMapper.fromHiveToEntityList(allDefensivos);
      if (apenasComercializados) {
        defensivosFiltrados = defensivosFiltrados.where((d) => d.isComercializado).toList();
      }
      
      if (apenasElegiveis) {
        defensivosFiltrados = defensivosFiltrados.where((d) => d.isElegivel).toList();
      }
      
      if (filtroToxicidade != null && filtroToxicidade != 'todos') {
        defensivosFiltrados = defensivosFiltrados.where((d) {
          final toxico = d.displayToxico.toLowerCase();
          switch (filtroToxicidade) {
            case 'baixa': return toxico.contains('iv') || toxico.contains('4');
            case 'media': return toxico.contains('iii') || toxico.contains('3');
            case 'alta': return toxico.contains('ii') || toxico.contains('2');
            case 'extrema': return toxico.contains('i') && !toxico.contains('ii') && !toxico.contains('iii') && !toxico.contains('iv');
            default: return true;
          }
        }).toList();
      }
      
      if (filtroTipo != null && filtroTipo != 'todos') {
        defensivosFiltrados = defensivosFiltrados.where((d) {
          final classe = d.displayClass.toLowerCase();
          return classe.contains(filtroTipo);
        }).toList();
      }
      switch (ordenacao) {
        case 'nome':
          defensivosFiltrados.sort((a, b) => a.displayName.compareTo(b.displayName));
          break;
        case 'fabricante':
          defensivosFiltrados.sort((a, b) => a.displayFabricante.compareTo(b.displayFabricante));
          break;
        case 'usos':
          defensivosFiltrados.sort((a, b) => (b.quantidadeDiagnosticos ?? 0).compareTo(a.quantidadeDiagnosticos ?? 0));
          break;
        case 'prioridade':
        default:
          defensivosFiltrados.sort((a, b) => (b.nivelPrioridade ?? 0).compareTo(a.nivelPrioridade ?? 0));
      }
      
      return Right(defensivosFiltrados);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos com filtros: ${e.toString()}'));
    }
  }
}