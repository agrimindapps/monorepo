import '../models/fitossanitario_info_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para FitossanitarioInfoHive
/// Implementa os métodos abstratos do BaseHiveRepository
class FitossanitarioInfoHiveRepository extends BaseHiveRepository<FitossanitarioInfoHive> {
  FitossanitarioInfoHiveRepository() : super('receituagro_fitossanitarios_info');

  @override
  FitossanitarioInfoHive createFromJson(Map<String, dynamic> json) {
    return FitossanitarioInfoHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(FitossanitarioInfoHive entity) {
    return entity.idReg;
  }

  /// Busca informações complementares de um fitossanitário
  FitossanitarioInfoHive? findByIdReg(String idReg) {
    return getById(idReg);
  }
}