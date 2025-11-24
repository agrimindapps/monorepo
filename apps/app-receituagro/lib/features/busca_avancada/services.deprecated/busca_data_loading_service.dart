

import '../../../database/repositories/culturas_repository.dart';
import '../../../database/repositories/fitossanitarios_repository.dart';
import '../../../database/repositories/pragas_repository.dart';

/// Service specialized in loading and formatting data for search dropdowns
/// Principle: Single Responsibility - Only handles data loading and transformation

class BuscaDataLoadingService {
  final CulturasRepository _culturaRepo;
  final PragasRepository _pragasRepo;
  final FitossanitariosRepository _fitossanitarioRepo;

  BuscaDataLoadingService(
    this._culturaRepo,
    this._pragasRepo,
    this._fitossanitarioRepo,
  );

  /// Loads all culturas and formats them for dropdown display
  Future<List<Map<String, String>>> loadCulturas() async {
    try {
      final result = await _culturaRepo.findAll();

      final culturas =
          result.map((c) => {'id': c.idCultura, 'nome': c.nome}).toList()
            ..sort((a, b) => a['nome']!.compareTo(b['nome']!));

      return culturas;
    } catch (e) {
      return [];
    }
  }

  /// Loads all pragas and formats them for dropdown display
  Future<List<Map<String, String>>> loadPragas() async {
    try {
      final result = await _pragasRepo.findAll();

      final pragas =
          result
              .map(
                (p) => {
                  'id': p.idPraga,
                  'nome': p.nome.isNotEmpty
                      ? p.nome
                      : (p.nomeLatino ?? 'Praga desconhecida'),
                },
              )
              .toList()
            ..sort((a, b) => a['nome']!.compareTo(b['nome']!));

      return pragas;
    } catch (e) {
      return [];
    }
  }

  /// Loads all defensivos and formats them for dropdown display
  Future<List<Map<String, String>>> loadDefensivos() async {
    try {
      final result = await _fitossanitarioRepo.findAll();

      final defensivos =
          result.map((d) => {'id': d.idDefensivo, 'nome': d.nome}).toList()
            ..sort((a, b) => a['nome']!.compareTo(b['nome']!));

      return defensivos;
    } catch (e) {
      return [];
    }
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
