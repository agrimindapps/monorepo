import '../../domain/entities/praga_entity.dart';
import '../../domain/repositories/i_pragas_repository.dart';

/// Implementação do repositório de pragas usando Hive (Data Layer)
/// Princípios: Single Responsibility + Dependency Inversion
class PragasRepositoryImpl implements IPragasRepository {
  
  @override
  Future<List<PragaEntity>> getAll() async {
    try {
      // TODO: Implementar com ReceitaAgroHiveService quando disponível
      // final hivePragas = ReceitaAgroHiveService.getPragas();
      // return hivePragas.map((hive) => PragaEntity.fromHive(hive)).toList();
      
      // Mock implementation por enquanto
      return [];
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

      // TODO: Implementar com ReceitaAgroHiveService quando disponível
      // final hivePraga = ReceitaAgroHiveService.getPragaById(id);
      // return hivePraga != null ? PragaEntity.fromHive(hivePraga) : null;
      
      // Mock implementation por enquanto
      return null;
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar praga por ID: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByTipo(String tipo) async {
    try {
      final allPragas = await getAll();
      return allPragas.where((praga) => praga.tipoPraga == tipo).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por tipo: $e');
    }
  }

  @override
  Future<List<PragaEntity>> searchByName(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) return [];

      final allPragas = await getAll();
      final term = searchTerm.toLowerCase();
      
      return allPragas.where((praga) =>
        praga.nomeComum.toLowerCase().contains(term) ||
        praga.nomeCientifico.toLowerCase().contains(term)
      ).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por nome: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByFamilia(String familia) async {
    try {
      if (familia.isEmpty) return [];

      final allPragas = await getAll();
      return allPragas.where((praga) => praga.familia == familia).toList();
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por família: $e');
    }
  }

  @override
  Future<List<PragaEntity>> getByCultura(String culturaId) async {
    try {
      if (culturaId.isEmpty) return [];

      // TODO: Implementar com ReceitaAgroHiveService quando disponível
      // Busca diagnósticos para a cultura
      // final diagnosticos = ReceitaAgroHiveService.getDiagnosticosByPragaCultura('', culturaId);
      
      // Mock implementation por enquanto
      return [];
    } catch (e) {
      throw PragasRepositoryException('Erro ao buscar pragas por cultura: $e');
    }
  }

  @override
  Future<int> getCountByTipo(String tipo) async {
    try {
      final pragasByTipo = await getByTipo(tipo);
      return pragasByTipo.length;
    } catch (e) {
      throw PragasRepositoryException('Erro ao contar pragas por tipo: $e');
    }
  }

  @override
  Future<int> getTotalCount() async {
    try {
      final allPragas = await getAll();
      return allPragas.length;
    } catch (e) {
      throw PragasRepositoryException('Erro ao contar total de pragas: $e');
    }
  }
}

/// Implementação do repositório de histórico usando LocalStorage
/// Princípio: Single Responsibility - Apenas gerencia histórico
class PragasHistoryRepositoryImpl implements IPragasHistoryRepository {
  final IPragasRepository _pragasRepository;
  // Aqui você injetaria o LocalStorageService via DI
  // final ILocalStorageService _localStorage;

  static const int _maxRecentItems = 7;
  static const int _maxSuggestedItems = 5;

  PragasHistoryRepositoryImpl({
    required IPragasRepository pragasRepository,
    // required ILocalStorageService localStorage,
  }) : _pragasRepository = pragasRepository;
       // _localStorage = localStorage;

  @override
  Future<List<PragaEntity>> getRecentlyAccessed() async {
    try {
      // TODO: Implementar com LocalStorage real
      // final accessedIds = await _localStorage.getRecentItems('acessadosPragas');
      final accessedIds = <String>[]; // Mock por enquanto
      
      final recentPragas = <PragaEntity>[];
      for (final id in accessedIds.take(_maxRecentItems)) {
        final praga = await _pragasRepository.getById(id);
        if (praga != null) {
          recentPragas.add(praga);
        }
      }
      
      return recentPragas;
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
      final allPragas = await _pragasRepository.getAll();
      if (allPragas.isEmpty) return [];

      // Algoritmo simples de sugestão (pode ser melhorado)
      allPragas.shuffle();
      return allPragas.take(limit.clamp(1, _maxSuggestedItems)).toList();
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