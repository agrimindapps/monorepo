// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../repository/pragas_repository.dart';
import '../models/praga_cultura_item_model.dart';
import '../utils/praga_cultura_utils.dart';

class ListaPragasService {
  final PragasRepository _pragasRepository;

  ListaPragasService(this._pragasRepository);

  /// Carrega as pragas relacionadas a uma cultura específica
  Future<List<PragaCulturaItemModel>> loadPragasPorCultura(String culturaId) async {
    if (culturaId.isEmpty) {
      throw ArgumentError('ID da cultura não pode estar vazio');
    }

    try {
      final pragasRelacionadas = await _pragasRepository.getPragasPorCultura(culturaId);
      
      return pragasRelacionadas
          .where(PragaCulturaUtils.isValidPragaItem)
          .map((item) => PragaCulturaItemModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Erro no serviço ao carregar pragas por cultura: $e');
      rethrow;
    }
  }

  /// Filtra pragas com base no texto de busca
  List<PragaCulturaItemModel> filterPragas(
    List<PragaCulturaItemModel> pragas,
    String searchText,
  ) {
    if (!PragaCulturaUtils.isSearchValid(searchText)) {
      return pragas;
    }

    final query = PragaCulturaUtils.sanitizeSearch(searchText);
    return pragas.where((praga) => _matchesSearch(praga, query)).toList();
  }

  /// Filtra pragas por tipo (plantas, doenças, insetos)
  List<PragaCulturaItemModel> filterPragasByType(
    List<PragaCulturaItemModel> pragas,
    String tipoPraga,
  ) {
    return pragas.where((praga) => (praga.tipoPraga ?? '') == tipoPraga).toList();
  }

  /// Combina filtros de busca e tipo
  List<PragaCulturaItemModel> applyFilters(
    List<PragaCulturaItemModel> pragas,
    String searchText,
    String tipoPraga,
  ) {
    var filteredPragas = filterPragas(pragas, searchText);
    return filterPragasByType(filteredPragas, tipoPraga);
  }

  /// Ordena pragas por critério especificado
  List<PragaCulturaItemModel> sortPragas(
    List<PragaCulturaItemModel> pragas,
    PragaSortCriteria criteria,
  ) {
    final sortedList = List<PragaCulturaItemModel>.from(pragas);
    
    switch (criteria) {
      case PragaSortCriteria.nomeComum:
        sortedList.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
        break;
      case PragaSortCriteria.nomeCientifico:
        sortedList.sort((a, b) {
          final aName = a.nomeCientifico ?? '';
          final bName = b.nomeCientifico ?? '';
          return aName.compareTo(bName);
        });
        break;
      case PragaSortCriteria.tipoPraga:
        sortedList.sort((a, b) {
          final aType = a.tipoPraga ?? '';
          final bType = b.tipoPraga ?? '';
          return aType.compareTo(bType);
        });
        break;
    }
    
    return sortedList;
  }

  /// Busca uma praga específica por ID
  Future<dynamic> getPragaById(String idReg, List<dynamic> pragasLista) async {
    try {
      final pragaData = pragasLista.firstWhere(
        (praga) => praga['idReg'].toString() == idReg,
        orElse: () => null,
      );

      if (pragaData != null) {
        // Valida se a praga existe no repositório
        await _pragasRepository.getPragaById(idReg);
        return pragaData;
      }
      
      throw Exception('Praga não encontrada');
    } catch (e) {
      debugPrint('Erro no serviço ao buscar praga por ID: $e');
      rethrow;
    }
  }

  /// Valida dados de entrada
  bool validateSearchInput(String searchText) {
    return PragaCulturaUtils.isSearchValid(searchText);
  }

  /// Sanitiza texto de busca
  String sanitizeSearchText(String searchText) {
    return PragaCulturaUtils.sanitizeSearch(searchText);
  }

  /// Verifica se uma praga corresponde ao critério de busca
  bool _matchesSearch(PragaCulturaItemModel praga, String searchText) {
    return praga.nomeComum.toLowerCase().contains(searchText) ||
        (praga.nomeSecundario?.toLowerCase().contains(searchText) ?? false) ||
        (praga.nomeCientifico?.toLowerCase().contains(searchText) ?? false);
  }

  /// Calcula estatísticas das pragas filtradas
  PragasStatistics calculateStatistics(List<PragaCulturaItemModel> pragas) {
    final plantas = pragas.where((p) => (p.tipoPraga ?? '') == '3').length;
    final doencas = pragas.where((p) => (p.tipoPraga ?? '') == '2').length;
    final insetos = pragas.where((p) => (p.tipoPraga ?? '') == '1').length;

    return PragasStatistics(
      total: pragas.length,
      plantas: plantas,
      doencas: doencas,
      insetos: insetos,
    );
  }
}

/// Enum para critérios de ordenação
enum PragaSortCriteria {
  nomeComum,
  nomeCientifico,
  tipoPraga,
}

/// Classe para estatísticas das pragas
class PragasStatistics {
  final int total;
  final int plantas;
  final int doencas;
  final int insetos;

  const PragasStatistics({
    required this.total,
    required this.plantas,
    required this.doencas,
    required this.insetos,
  });

  @override
  String toString() {
    return 'PragasStatistics(total: $total, plantas: $plantas, doenças: $doencas, insetos: $insetos)';
  }
}
