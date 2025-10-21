// Project imports:
import '../../core/controllers/base_auth_controller.dart';
import '../../core/models/auth_models.dart';

/// Controller padronizado para autenticação do módulo Nutrituti
class NutrituitAuthController extends BaseAuthController {
  @override
  ModuleAuthConfig get moduleConfig => ModuleAuthConfig.nutrituti;
}
