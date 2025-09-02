import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/defensivo_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../../../core/repositories/fitossanitario_core_repository.dart';
import '../mappers/defensivo_mapper.dart';

/// Implementação do repositório de defensivos
/// Segue padrões Clean Architecture + Either pattern para error handling
class DefensivosRepositoryImpl implements IDefensivosRepository {
  final FitossanitarioCoreRepository _coreRepository;

  DefensivosRepositoryImpl(this._coreRepository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getAllDefensivos() async {
    try {
      final defensivosModels = await _coreRepository.getAllItems();
      final defensivosEntities = DefensivoMapper.toEntityList(defensivosModels);
      
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByClasse(String classe) async {
    try {
      final allDefensivos = await _coreRepository.getAllItems();
      final defensivosFiltrados = allDefensivos
          .where((defensivo) => 
              defensivo.classeAgronomica?.toLowerCase().contains(classe.toLowerCase()) == true)
          .toList();
      
      final defensivosEntities = DefensivoMapper.toEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por classe: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivoEntity?>> getDefensivoById(String id) async {
    try {
      final defensivo = await _coreRepository.getItemById(id);
      
      if (defensivo == null) {
        return const Right(null);
      }
      
      final defensivoEntity = DefensivoMapper.toEntity(defensivo);
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

      final allDefensivos = await _coreRepository.getAllItems();
      final defensivosFiltrados = allDefensivos.where((defensivo) {
        final nomeMatch = defensivo.line1.toLowerCase().contains(query.toLowerCase());
        final nomeComumMatch = defensivo.nomeComum?.toLowerCase().contains(query.toLowerCase()) == true;
        final ingredienteMatch = defensivo.line2.toLowerCase().contains(query.toLowerCase());
        final ingredienteAtivoMatch = defensivo.ingredienteAtivo?.toLowerCase().contains(query.toLowerCase()) == true;
        
        return nomeMatch || nomeComumMatch || ingredienteMatch || ingredienteAtivoMatch;
      }).toList();
      
      final defensivosEntities = DefensivoMapper.toEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByFabricante(String fabricante) async {
    try {
      final allDefensivos = await _coreRepository.getAllItems();
      final defensivosFiltrados = allDefensivos
          .where((defensivo) => 
              defensivo.fabricante?.toLowerCase().contains(fabricante.toLowerCase()) == true)
          .toList();
      
      final defensivosEntities = DefensivoMapper.toEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por fabricante: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByModoAcao(String modoAcao) async {
    try {
      final allDefensivos = await _coreRepository.getAllItems();
      final defensivosFiltrados = allDefensivos
          .where((defensivo) => 
              defensivo.modoAcao?.toLowerCase().contains(modoAcao.toLowerCase()) == true)
          .toList();
      
      final defensivosEntities = DefensivoMapper.toEntityList(defensivosFiltrados);
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por modo de ação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getClassesAgronomicas() async {
    try {
      final allDefensivos = await _coreRepository.getAllItems();
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
      final allDefensivos = await _coreRepository.getAllItems();
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
      final allDefensivos = await _coreRepository.getAllItems();
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
      final allDefensivos = await _coreRepository.getAllItems();
      
      // Como não temos timestamp real, vamos pegar os primeiros N
      final defensivosRecentes = allDefensivos.take(limit).toList();
      final defensivosEntities = DefensivoMapper.toEntityList(defensivosRecentes);
      
      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos recentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDefensivosStats() async {
    try {
      final allDefensivos = await _coreRepository.getAllItems();
      
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
      final defensivo = await _coreRepository.getItemById(defensivoId);
      return Right(defensivo != null);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar status do defensivo: ${e.toString()}'));
    }
  }
}