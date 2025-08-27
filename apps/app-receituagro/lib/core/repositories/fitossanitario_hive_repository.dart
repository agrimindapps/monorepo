import '../models/fitossanitario_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para FitossanitarioHive
/// Implementa os métodos abstratos do BaseHiveRepository
class FitossanitarioHiveRepository extends BaseHiveRepository<FitossanitarioHive> {
  FitossanitarioHiveRepository() : super('receituagro_fitossanitarios');

  @override
  FitossanitarioHive createFromJson(Map<String, dynamic> json) {
    return FitossanitarioHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(FitossanitarioHive entity) {
    return entity.idReg;
  }

  /// Busca defensivo por nome comum
  FitossanitarioHive? findByNomeComum(String nomeComum) {
    final results = findBy((item) => item.nomeComum.toLowerCase() == nomeComum.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }

  /// Lista defensivos por classe agronômica
  List<FitossanitarioHive> findByClasseAgronomica(String classeAgronomica) {
    return findBy((item) => 
        item.classeAgronomica?.toLowerCase() == classeAgronomica.toLowerCase());
  }

  /// Lista defensivos por fabricante
  List<FitossanitarioHive> findByFabricante(String fabricante) {
    return findBy((item) => 
        item.fabricante?.toLowerCase() == fabricante.toLowerCase());
  }

  /// Lista defensivos ativos/comercializados
  List<FitossanitarioHive> getActiveDefensivos() {
    return findBy((item) => item.status && item.comercializado == 1);
  }

  /// Lista defensivos elegíveis
  List<FitossanitarioHive> getElegibleDefensivos() {
    return findBy((item) => item.elegivel);
  }
}