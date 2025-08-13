// Project imports:
import '../models/praga_item_model.dart';
import '../utils/praga_utils.dart';

abstract class IPragaFilterService {
  List<PragaItemModel> filterPragas(List<PragaItemModel> pragas, String searchText);
  bool matchesSearch(PragaItemModel praga, String query);
}

class PragaFilterService implements IPragaFilterService {
  @override
  List<PragaItemModel> filterPragas(List<PragaItemModel> pragas, String searchText) {
    if (!PragaUtils.isSearchValid(searchText)) {
      return pragas;
    }

    final query = PragaUtils.sanitizeSearch(searchText);
    return pragas.where((praga) => matchesSearch(praga, query)).toList();
  }

  @override
  bool matchesSearch(PragaItemModel praga, String query) {
    return praga.nomeComum.toLowerCase().contains(query) ||
        (praga.nomeSecundario?.toLowerCase().contains(query) ?? false) ||
        (praga.nomeCientifico?.toLowerCase().contains(query) ?? false);
  }
}
