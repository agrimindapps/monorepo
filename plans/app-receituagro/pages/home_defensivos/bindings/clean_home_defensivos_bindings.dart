// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/application/di/clean_architecture_bindings.dart';
import '../../../core/application/use_cases/get_defensivos_home_data_use_case.dart';
import '../../../core/application/use_cases/register_defensivo_access_use_case.dart';
import '../controller/clean_home_defensivos_controller.dart';

/// Bindings para a página Home Defensivos com Clean Architecture
/// 
/// Demonstra como configurar dependency injection seguindo os princípios
/// de Clean Architecture, onde o controller depende apenas de abstrações (UseCases)
class CleanHomeDefensivosBindings extends Bindings {
  @override
  void dependencies() {
    // Primeiro, garante que as dependências de Clean Architecture estão registradas
    CleanArchitectureBindings().dependencies();

    // Depois, registra o controller injetando os UseCases
    Get.lazyPut<CleanHomeDefensivosController>(
      () => CleanHomeDefensivosController(
        getHomeDataUseCase: Get.find<GetDefensivosHomeDataUseCase>(),
        registerAccessUseCase: Get.find<RegisterDefensivoAccessUseCase>(),
      ),
    );
  }
}