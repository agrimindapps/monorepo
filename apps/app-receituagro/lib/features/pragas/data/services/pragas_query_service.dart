import 'package:injectable/injectable.dart';

import '../../domain/entities/praga_entity.dart';
import '../../domain/services/i_pragas_query_service.dart';

/// Default implementation of query service
@LazySingleton(as: IPragasQueryService)
class PragasQueryService implements IPragasQueryService {
  @override
  List<PragaEntity> getByTipo(List<PragaEntity> pragas, String tipo) {
    if (tipo.isEmpty) {
      return [];
    }
    return pragas.where((p) => p.tipoPraga == tipo).toList();
  }

  @override
  List<PragaEntity> getByFamilia(List<PragaEntity> pragas, String familia) {
    if (familia.isEmpty) {
      return [];
    }
    return pragas.where((p) => p.familia == familia).toList();
  }

  @override
  List<PragaEntity> getByCultura(List<PragaEntity> pragas, String culturaId) {
    if (culturaId.isEmpty) {
      return [];
    }
    // Note: Pragas are not directly linked to cultura in the model
    // This method returns all pragas (can be used for general queries)
    return pragas;
  }

  @override
  List<PragaEntity> getRecentes(
    List<PragaEntity> pragas, {
    int limit = 10,
  }) {
    return pragas.take(limit).toList();
  }

  @override
  List<String> getTiposPragas(List<PragaEntity> pragas) {
    final tipos = pragas
        .map((praga) => praga.tipoPraga)
        .where((tipo) => tipo.isNotEmpty)
        .toSet()
        .toList();

    tipos.sort();
    return tipos;
  }

  @override
  List<String> getFamiliasPragas(List<PragaEntity> pragas) {
    final familias = pragas
        .map((praga) => praga.familia)
        .where((familia) => familia != null && familia.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    familias.sort();
    return familias;
  }
}
