import 'package:get_it/get_it.dart';
import '../../../../core/models/pragas_hive.dart';
import '../../../../core/repositories/pragas_hive_repository.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/repositories/i_pragas_repository.dart';

/// Implementação do repositório de pragas usando Hive (Data Layer)
/// Princípios: Single Responsibility + Dependency Inversion
class PragasRepositoryImpl implements IPragasRepository {
  final PragasHiveRepository _hiveRepository;

  PragasRepositoryImpl({PragasHiveRepository? hiveRepository})
    : _hiveRepository =
          hiveRepository ?? GetIt.instance<PragasHiveRepository>();

  @override
  Future<List<PragaEntity>> getAll() async {
    try {
      // Usa método assíncrono para aguardar box estar aberto
      final hivePragas = await _hiveRepository.getAllAsync();
      print('🔍 PragasRepositoryImpl.getAll() carregou ${hivePragas.length} pragas');
      return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.getAll(): $e');
      throw PragasRepositoryException('Erro ao carregar todas as pragas: $e');
    }
  }

  @override
  Future<PragaEntity?> getById(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('ID não pode ser vazio');
      }

      final hivePraga = _hiveRepository.getById(id);
      return hivePraga != null ? PragaEntity.fromHive(hivePraga) : null;
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar praga por ID: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByTipo(String tipo) async {
    try {
      // Usa método assíncrono para aguardar box estar aberto
      final hivePragas = await _hiveRepository.findByTipoAsync(tipo);
      print('🔍 PragasRepositoryImpl.getByTipo($tipo) carregou ${hivePragas.length} pragas');
      return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.getByTipo(): $e');
      throw PragasRepositoryException('Erro ao buscar pragas por tipo: $e');
    }
  }

  @override
  Future<List<PragaEntity>> searchByName(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) return [];

      // Usa método assíncrono para aguardar box estar aberto
      final allPragas = await _hiveRepository.getAllAsync();
      final term = searchTerm.toLowerCase();

      final filteredPragas =
          allPragas
              .where(
                (praga) =>
                    praga.nomeComum.toLowerCase().contains(term) ||
                    praga.nomeCientifico.toLowerCase().contains(term),
              )
              .toList();

      print('🔍 PragasRepositoryImpl.searchByName("$searchTerm") encontrou ${filteredPragas.length} pragas');
      return filteredPragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.searchByName(): $e');
      throw PragasRepositoryException('Erro ao buscar pragas por nome: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByFamilia(String familia) async {
    try {
      if (familia.isEmpty) return [];

      // Usa método assíncrono para aguardar box estar aberto
      final hivePragas = await _hiveRepository.findByFamiliaAsync(familia);
      print('🔍 PragasRepositoryImpl.getByFamilia("$familia") carregou ${hivePragas.length} pragas');
      return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.getByFamilia(): $e');
      throw PragasRepositoryException('Erro ao buscar pragas por família: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByCultura(String culturaId) async {
    try {
      if (culturaId.isEmpty) return [];

      // Por enquanto retorna todas as pragas usando método assíncrono
      // TODO: Implementar busca por cultura usando DiagnosticoHiveRepository
      final allPragas = await _hiveRepository.getAllAsync();
      print('🔍 PragasRepositoryImpl.getByCultura("$culturaId") carregou ${allPragas.length} pragas');
      return allPragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.getByCultura(): $e');
      throw PragasRepositoryException('Erro ao buscar pragas por cultura: $e');
    }
  }

  @override
  Future<int> getCountByTipo(String tipo) async {
    try {
      // Usa método assíncrono para aguardar box estar aberto
      final pragasByTipo = await _hiveRepository.findByTipoAsync(tipo);
      print('🔍 PragasRepositoryImpl.getCountByTipo("$tipo") contou ${pragasByTipo.length} pragas');
      return pragasByTipo.length;
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.getCountByTipo(): $e');
      throw PragasRepositoryException('Erro ao contar pragas por tipo: $e');
    }
  }

  @override
  Future<int> getTotalCount() async {
    try {
      // Usa método assíncrono para aguardar box estar aberto
      final allPragas = await _hiveRepository.getAllAsync();
      print('🔍 PragasRepositoryImpl.getTotalCount() contou ${allPragas.length} pragas');
      return allPragas.length;
    } catch (e) {
      print('❌ Erro em PragasRepositoryImpl.getTotalCount(): $e');
      throw PragasRepositoryException('Erro ao contar total de pragas: $e');
    }
  }
}

/// Implementação do repositório de histórico usando LocalStorage
/// Princípio: Single Responsibility - Apenas gerencia histórico
class PragasHistoryRepositoryImpl implements IPragasHistoryRepository {
  final PragasHiveRepository _hiveRepository;

  static const int _maxRecentItems = 7;
  static const int _maxSuggestedItems = 5;

  PragasHistoryRepositoryImpl({PragasHiveRepository? hiveRepository})
    : _hiveRepository =
          hiveRepository ?? GetIt.instance<PragasHiveRepository>();

  @override
  Future<List<PragaEntity>> getRecentlyAccessed() async {
    try {
      // Por enquanto retorna algumas pragas aleatórias como "recentes"
      // TODO: Implementar com LocalStorage real para histórico
      final allPragas = await _hiveRepository.getAllAsync();
      if (allPragas.isEmpty) return [];

      // Pega algumas pragas como mock de recentes
      final recentHivePragas = allPragas.take(_maxRecentItems).toList();
      print('🔍 PragasHistoryRepositoryImpl.getRecentlyAccessed() retornou ${recentHivePragas.length} pragas recentes');
      return recentHivePragas
          .map((hive) => PragaEntity.fromHive(hive))
          .toList();
    } catch (e) {
      print('❌ Erro em PragasHistoryRepositoryImpl.getRecentlyAccessed(): $e');
      throw PragasRepositoryException('Erro ao carregar pragas recentes: $e');
    }
  }

  @override
  Future<void> markAsAccessed(String pragaId) async {
    try {
      if (pragaId.isEmpty) {
        throw ArgumentError('ID da praga não pode ser vazio');
      }

      // TODO: Implementar com LocalStorage real
      // await _localStorage.setRecentItem('acessadosPragas', pragaId);
    } catch (e) {
      throw PragasRepositoryException('Erro ao marcar praga como acessada: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getSuggested(int limit) async {
    try {
      final allPragas = await _hiveRepository.getAllAsync();
      if (allPragas.isEmpty) return [];

      // Algoritmo simples de sugestão (pode ser melhorado)
      final shuffledPragas = List<PragasHive>.from(allPragas)..shuffle();
      final suggestedHivePragas =
          shuffledPragas.take(limit.clamp(1, _maxSuggestedItems)).toList();
      print('🔍 PragasHistoryRepositoryImpl.getSuggested($limit) retornou ${suggestedHivePragas.length} pragas sugeridas');
      return suggestedHivePragas
          .map((hive) => PragaEntity.fromHive(hive))
          .toList();
    } catch (e) {
      print('❌ Erro em PragasHistoryRepositoryImpl.getSuggested(): $e');
      throw PragasRepositoryException('Erro ao buscar pragas sugeridas: $e');
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

/// Exception customizada para o repositório
class PragasRepositoryException implements Exception {
  final String message;
  const PragasRepositoryException(this.message);

  @override
  String toString() => 'PragasRepositoryException: $message';
}
