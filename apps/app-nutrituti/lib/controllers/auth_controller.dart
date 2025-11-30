// Project imports:
import '../../core/controllers/base_auth_controller.dart';
import '../../core/models/auth_models.dart';

/// Controller padronizado para autenticação do módulo Nutrituti
class NutrituitAuthController extends BaseAuthController {
  ModuleAuthConfig get moduleConfig => const ModuleAuthConfig(
        loginRoute: '/login',
        homeRoute: '/home',
      );
}
