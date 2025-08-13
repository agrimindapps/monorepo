// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../infrastructure/repositories/defensivos_repository_impl.dart';
import '../mappers/defensivos_mapper.dart';
import '../use_cases/get_defensivos_by_category_use_case.dart';
import '../use_cases/get_defensivos_home_data_use_case.dart';
import '../use_cases/register_defensivo_access_use_case.dart';

/// Bindings para Clean Architecture
/// 
/// Registra as dependências seguindo os princípios de dependency inversion:
/// - Interfaces são registradas (abstração)
/// - Implementações concretas são injetadas (detalhes)
class CleanArchitectureBindings extends Bindings {
  @override
  void dependencies() {
    // Registro do mapper
    Get.put<DefensivosMapper>(
      DefensivosMapper(),
      permanent: true,
    );

    // Registro da implementação do repositório
    Get.put<IDefensivosRepository>(
      DefensivosRepositoryImpl(),
      permanent: true,
    );

    // Registro dos UseCases
    Get.put<GetDefensivosHomeDataUseCase>(
      GetDefensivosHomeDataUseCase(
        Get.find<IDefensivosRepository>(),
        Get.find<DefensivosMapper>(),
      ),
      permanent: true,
    );

    Get.put<RegisterDefensivoAccessUseCase>(
      RegisterDefensivoAccessUseCase(
        Get.find<IDefensivosRepository>(),
      ),
      permanent: true,
    );

    Get.put<GetDefensivosByCategoryUseCase>(
      GetDefensivosByCategoryUseCase(
        Get.find<IDefensivosRepository>(),
        Get.find<DefensivosMapper>(),
      ),
      permanent: true,
    );
  }
}