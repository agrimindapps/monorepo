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
      : _hiveRepository = hiveRepository ?? GetIt.instance<PragasHiveRepository>();
  
  @override
  Future<List<PragaEntity>> getAll() async {
    try {
      final hivePragas = _hiveRepository.getAll();
      return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
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
      final hivePragas = _hiveRepository.findByTipo(tipo);
      return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por tipo: $e');
    }
  }

  @override
  Future<List<PragaEntity>> searchByName(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) return [];

      final allPragas = _hiveRepository.getAll();
      final term = searchTerm.toLowerCase();
      
      final filteredPragas = allPragas.where((praga) =>
        praga.nomeComum.toLowerCase().contains(term) ||
        praga.nomeCientifico.toLowerCase().contains(term)
      ).toList();
      
      return filteredPragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por nome: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByFamilia(String familia) async {
    try {
      if (familia.isEmpty) return [];

      final hivePragas = _hiveRepository.findByFamilia(familia);
      return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por família: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByCultura(String culturaId) async {
    try {
      if (culturaId.isEmpty) return [];

      // Por enquanto retorna todas as pragas
      // TODO: Implementar busca por cultura usando DiagnosticoHiveRepository
      final allPragas = _hiveRepository.getAll();
      return allPragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por cultura: $e');
    }
  }

  @override
  Future<int> getCountByTipo(String tipo) async {
    try {
      final pragasByTipo = _hiveRepository.findByTipo(tipo);
      return pragasByTipo.length;
    } catch (e) {
      throw PragasRepositoryException('Erro ao contar pragas por tipo: $e');
    }
  }

  @override
  Future<int> getTotalCount() async {
    try {
      return _hiveRepository.count;
    } catch (e) {
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

  PragasHistoryRepositoryImpl({
    PragasHiveRepository? hiveRepository,
  }) : _hiveRepository = hiveRepository ?? GetIt.instance<PragasHiveRepository>();

  @override
  Future<List<PragaEntity>> getRecentlyAccessed() async {
    try {
      // Por enquanto retorna algumas pragas aleatórias como "recentes"
      // TODO: Implementar com LocalStorage real para histórico
      final allPragas = _hiveRepository.getAll();
      if (allPragas.isEmpty) return [];
      
      // Pega algumas pragas como mock de recentes
      final recentHivePragas = allPragas.take(_maxRecentItems).toList();
      return recentHivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
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
      final allPragas = _hiveRepository.getAll();
      if (allPragas.isEmpty) return [];

      // Algoritmo simples de sugestão (pode ser melhorado)
      final shuffledPragas = List<PragasHive>.from(allPragas)..shuffle();
      final suggestedHivePragas = shuffledPragas.take(limit.clamp(1, _maxSuggestedItems)).toList();
      return suggestedHivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas sugeridas: $e');
    }
  }
}

/// Implementação do formatador de pragas
/// Princípio: Single Responsibility - Apenas formatação
class PragasFormatterImpl implements IPragasFormatter {
  
  @override
  String formatImageName(String nomeCientifico) {
    if (['Espalhante adesivo para calda de pulverização', 'Não classificado']
        .contains(nomeCientifico)) {
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