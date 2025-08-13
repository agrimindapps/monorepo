// Project imports:
import '../models/praga_item_model.dart';

abstract class IPragaSortService {
  List<PragaItemModel> sortPragas(List<PragaItemModel> pragas, bool isAscending);
}

class PragaSortService implements IPragaSortService {
  @override
  List<PragaItemModel> sortPragas(List<PragaItemModel> pragas, bool isAscending) {
    final sortedList = List<PragaItemModel>.from(pragas);
    
    sortedList.sort((a, b) {
      final compareResult = a.nomeComum.compareTo(b.nomeComum);
      return isAscending ? compareResult : -compareResult;
    });

    return sortedList;
  }
}
