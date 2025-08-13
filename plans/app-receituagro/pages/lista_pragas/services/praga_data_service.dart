// Project imports:
import '../../../repository/pragas_repository.dart';
import '../models/praga_item_model.dart';
import '../utils/praga_type_helper.dart';

abstract class IPragaDataService {
  Future<List<PragaItemModel>> loadPragas(String pragaType);
  Future<void> getPragaById(String id);
}

class PragaDataService implements IPragaDataService {
  final PragasRepository _pragasRepository;

  PragaDataService({PragasRepository? pragasRepository})
      : _pragasRepository = pragasRepository ?? PragasRepository();

  @override
  Future<List<PragaItemModel>> loadPragas(String pragaType) async {
    final pragasData = await _pragasRepository.getPragas(pragaType);
    return pragasData
        .where((item) => PragaTypeHelper.isValidPragaItem(item))
        .map((item) => PragaItemModel.fromMap(item))
        .toList();
  }

  @override
  Future<void> getPragaById(String id) async {
    await _pragasRepository.getPragaById(id);
  }
}
