// Project imports:
import '../models/pluviometros_models.dart';
import '../repository/pluviometros_repository.dart';

class PluviometrosController {
  // Singleton Pattern
  static final PluviometrosController _instance =
      PluviometrosController._internal();
  factory PluviometrosController() => _instance;
  PluviometrosController._internal();

  // Repository reference
  final _repository = PluviometrosRepository();

  // Properties from repository
  String get selectedPluviometroId => _repository.selectedPluviometroId;

  // Initialization
  static Future<void> initialize() => PluviometrosRepository.initialize();

  // Delegate methods
  Future<void> getSelectedPluviometroId() =>
      _repository.getSelectedPluviometroId();

  Future<void> setSelectedPluviometroId(String id) =>
      _repository.setSelectedPluviometroId(id);

  Future<List<Pluviometro>> getPluviometros() => _repository.getPluviometros();

  Future<Pluviometro?> getPluviometroById(String id) =>
      _repository.getPluviometroById(id);

  Future<bool> addPluviometro(Pluviometro pluviometro) =>
      _repository.addPluviometro(pluviometro);

  Future<bool> updatePluviometro(Pluviometro pluviometro) =>
      _repository.updatePluviometro(pluviometro);

  Future<bool> deletePluviometro(Pluviometro pluviometro) =>
      _repository.deletePluviometro(pluviometro);

  // Cleanup resources
  Future<void> dispose() => _repository.dispose();
}
