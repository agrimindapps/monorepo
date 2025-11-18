import 'package:injectable/injectable.dart';

/// Database module for Drift integration
///
/// **NOTA:** PetivetiDatabase agora usa @lazySingleton diretamente,
/// então este módulo não é mais necessário. Mantido para compatibilidade.
///
/// O Injectable irá registrar automaticamente PetivetiDatabase.injectable()
/// como singleton através do @lazySingleton + @factoryMethod.
@module
abstract class DatabaseModule {
  // Módulo vazio - PetivetiDatabase gerencia seu próprio registro
}
