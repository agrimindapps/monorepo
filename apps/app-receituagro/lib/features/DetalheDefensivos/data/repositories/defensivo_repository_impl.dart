import 'package:core/core.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/repositories/defensivo_repository.dart';
import '../models/defensivo_model.dart';

/// Implementação do repositório de defensivos
/// 
/// Esta classe implementa o contrato definido no domain layer,
/// usando o FitossanitarioHiveRepository como fonte de dados
class DefensivoRepositoryImpl implements DefensivoRepository {
  const DefensivoRepositoryImpl(this._hiveRepository);

  final FitossanitarioHiveRepository _hiveRepository;

  @override
  ResultFuture<DefensivoEntity> getDefensivoById(String idReg) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao acessar dados: ${result.error}'));
      }
      
      final defensivos = result.data!;
      final defensivo = defensivos
          .where((d) => d.idReg == idReg)
          .firstOrNull;

      if (defensivo == null) {
        return Left(CacheFailure('Defensivo não encontrado com ID: $idReg'));
      }

      final model = DefensivoModel.fromHive(defensivo);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivo: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<DefensivoEntity> getDefensivoByName(String nome) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao acessar dados: ${result.error}'));
      }
      
      final defensivos = result.data!;
      final defensivo = defensivos
          .where((d) => 
              d.nomeComum.toLowerCase() == nome.toLowerCase() ||
              d.nomeTecnico.toLowerCase() == nome.toLowerCase())
          .firstOrNull;

      if (defensivo == null) {
        return Left(CacheFailure('Defensivo não encontrado com nome: $nome'));
      }

      final model = DefensivoModel.fromHive(defensivo);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivo por nome: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DefensivoEntity>> getDefensivosByFabricante(String fabricante) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao acessar dados: ${result.error}'));
      }
      
      final defensivos = result.data!;
      final filteredDefensivos = defensivos
          .where((d) => d.fabricante?.toLowerCase().contains(fabricante.toLowerCase()) == true)
          .map((hive) => DefensivoModel.fromHive(hive))
          .toList();

      return Right(filteredDefensivos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por fabricante: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DefensivoEntity>> getDefensivosByIngredienteAtivo(String ingredienteAtivo) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao acessar dados: ${result.error}'));
      }
      
      final defensivos = result.data!;
      final filteredDefensivos = defensivos
          .where((d) => d.ingredienteAtivo?.toLowerCase().contains(ingredienteAtivo.toLowerCase()) == true)
          .map((hive) => DefensivoModel.fromHive(hive))
          .toList();

      return Right(filteredDefensivos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por ingrediente ativo: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DefensivoEntity>> getDefensivos({
    String? fabricante,
    String? classeAgronomica,
    String? ingredienteAtivo,
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao acessar dados: ${result.error}'));
      }
      
      var defensivos = result.data!;
      if (fabricante != null && fabricante.isNotEmpty) {
        defensivos = defensivos
            .where((d) => d.fabricante?.toLowerCase().contains(fabricante.toLowerCase()) == true)
            .toList();
      }

      if (classeAgronomica != null && classeAgronomica.isNotEmpty) {
        defensivos = defensivos
            .where((d) => d.classeAgronomica?.toLowerCase().contains(classeAgronomica.toLowerCase()) == true)
            .toList();
      }

      if (ingredienteAtivo != null && ingredienteAtivo.isNotEmpty) {
        defensivos = defensivos
            .where((d) => d.ingredienteAtivo?.toLowerCase().contains(ingredienteAtivo.toLowerCase()) == true)
            .toList();
      }
      if (offset != null && offset > 0) {
        if (offset >= defensivos.length) {
          return const Right([]);
        }
        defensivos = defensivos.skip(offset).toList();
      }

      if (limit != null && limit > 0) {
        defensivos = defensivos.take(limit).toList();
      }

      final models = defensivos
          .map((hive) => DefensivoModel.fromHive(hive))
          .toList();

      return Right(models);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DefensivoEntity>> searchDefensivos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final searchQuery = query.toLowerCase();
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao acessar dados: ${result.error}'));
      }
      
      final defensivos = result.data!;
      
      final filteredDefensivos = defensivos
          .where((d) => 
              d.nomeComum.toLowerCase().contains(searchQuery) ||
              d.nomeTecnico.toLowerCase().contains(searchQuery) ||
              (d.fabricante?.toLowerCase().contains(searchQuery) == true) ||
              (d.ingredienteAtivo?.toLowerCase().contains(searchQuery) == true) ||
              (d.classeAgronomica?.toLowerCase().contains(searchQuery) == true))
          .map((hive) => DefensivoModel.fromHive(hive))
          .toList();
      filteredDefensivos.sort((a, b) {
        final aComumMatch = a.nomeComum.toLowerCase().contains(searchQuery);
        final bComumMatch = b.nomeComum.toLowerCase().contains(searchQuery);
        
        if (aComumMatch && !bComumMatch) return -1;
        if (!aComumMatch && bComumMatch) return 1;
        return a.nomeComum.compareTo(b.nomeComum);
      });

      return Right(filteredDefensivos);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar defensivos: ${e.toString()}'));
    }
  }

  @override
  Stream<List<DefensivoEntity>> watchDefensivos() async* {
    try {
      while (true) {
        final result = await _hiveRepository.getAll();
        if (result.isError) {
          yield [];
          await Future<void>.delayed(const Duration(seconds: 5));
          continue;
        }
        
        final defensivos = result.data!;
        final models = defensivos
            .map((hive) => DefensivoModel.fromHive(hive))
            .toList();
        
        yield models;
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      yield [];
    }
  }
}
