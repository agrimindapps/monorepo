import 'package:injectable/injectable.dart';

import '../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../core/data/repositories/pragas_hive_repository.dart';

/// Service specialized in loading and formatting data for search dropdowns
/// Principle: Single Responsibility - Only handles data loading and transformation
@lazySingleton
class BuscaDataLoadingService {
  final CulturaHiveRepository _culturaRepo;
  final PragasHiveRepository _pragasRepo;
  final FitossanitarioHiveRepository _fitossanitarioRepo;

  BuscaDataLoadingService(
    this._culturaRepo,
    this._pragasRepo,
    this._fitossanitarioRepo,
  );

  /// Loads all culturas and formats them for dropdown display
  Future<List<Map<String, String>>> loadCulturas() async {
    final result = await _culturaRepo.getAll();

    if (result.isError) {
      return [];
    }

    final culturas =
        result.data!.map((c) => {'id': c.idReg, 'nome': c.cultura}).toList()
          ..sort((a, b) => a['nome']!.compareTo(b['nome']!));

    return culturas;
  }

  /// Loads all pragas and formats them for dropdown display
  Future<List<Map<String, String>>> loadPragas() async {
    final result = await _pragasRepo.getAll();

    if (result.isError) {
      return [];
    }

    final pragas =
        result.data!
            .map(
              (p) => {
                'id': p.idReg,
                'nome': p.nomeComum.isNotEmpty ? p.nomeComum : p.nomeCientifico,
              },
            )
            .toList()
          ..sort((a, b) => a['nome']!.compareTo(b['nome']!));

    return pragas;
  }

  /// Loads all defensivos and formats them for dropdown display
  Future<List<Map<String, String>>> loadDefensivos() async {
    final result = await _fitossanitarioRepo.getAll();

    if (result.isError) {
      return [];
    }

    final defensivos =
        result.data!
            .map(
              (d) => {
                'id': d.idReg,
                'nome': d.nomeComum.isNotEmpty ? d.nomeComum : d.nomeTecnico,
              },
            )
            .toList()
          ..sort((a, b) => a['nome']!.compareTo(b['nome']!));

    return defensivos;
  }

  /// Loads all dropdown data in parallel for better performance
  Future<Map<String, List<Map<String, String>>>> loadAllDropdownData() async {
    final results = await Future.wait([
      loadCulturas(),
      loadPragas(),
      loadDefensivos(),
    ]);

    return {
      'culturas': results[0],
      'pragas': results[1],
      'defensivos': results[2],
    };
  }

  /// Finds item name by ID in a list
  String findNameById(List<Map<String, String>> items, String? id) {
    if (id == null) return 'Desconhecido(a)';

    final item = items.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {'nome': 'Desconhecido(a)'},
    );

    return item['nome'] ?? 'Desconhecido(a)';
  }

  /// Builds a map of active filters with their display names
  Map<String, String> buildFiltrosDetalhados({
    required String? culturaId,
    required String? pragaId,
    required String? defensivoId,
    required List<Map<String, String>> culturas,
    required List<Map<String, String>> pragas,
    required List<Map<String, String>> defensivos,
  }) {
    final filtros = <String, String>{};

    if (culturaId != null) {
      filtros['Cultura'] = findNameById(culturas, culturaId);
    }

    if (pragaId != null) {
      filtros['Praga'] = findNameById(pragas, pragaId);
    }

    if (defensivoId != null) {
      filtros['Defensivo'] = findNameById(defensivos, defensivoId);
    }

    return filtros;
  }
}
