// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Bindings de Injeção de Dependências
// DESCRIÇÃO: Configura e registra todas as dependências necessárias para o módulo
// RESPONSABILIDADES: Injeção de dependências, configuração de serviços
// DEPENDÊNCIAS: GetX DI, Core Services, Interfaces customizadas
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/in_app_purchase_service.dart';
import '../../../../core/services/localstorage_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../repository/database_repository.dart';
import '../controller/detalhes_diagnostico_controller.dart';
import '../interfaces/i_database_repository.dart';
import '../interfaces/i_favorite_service.dart';
import '../interfaces/i_local_storage_service.dart';
import '../interfaces/i_premium_service.dart';
import '../interfaces/i_tts_service.dart';
import '../services/database_repository_impl.dart';
import '../services/favorite_service.dart';
import '../services/local_storage_service_impl.dart';
import '../services/premium_service_impl.dart';
import '../services/tts_service_impl.dart';

/// Bindings para a página de detalhes de diagnósticos
class DetalhesDiagnosticoBindings extends Bindings {
  @override
  void dependencies() {
    // Registrar serviços base se não estiverem registrados
    Get.lazyPut<TtsService>(() => TtsService(), fenix: true);
    Get.lazyPut<LocalStorageService>(() => LocalStorageService(), fenix: true);
    Get.lazyPut<InAppPurchaseService>(() => InAppPurchaseService(),
        fenix: true);

    // Usar DatabaseRepository já registrado globalmente
    // Get.find<DatabaseRepository>() será usado diretamente no controller

    // Registrar implementações das interfaces
    Get.lazyPut<ITtsService>(
      () => TtsServiceImpl(Get.find<TtsService>()),
      tag: 'diagnostico',
    );

    Get.lazyPut<ILocalStorageService>(
      () => LocalStorageServiceImpl(Get.find<LocalStorageService>()),
    );

    Get.lazyPut<IPremiumService>(
      () => PremiumServiceImpl(Get.find<InAppPurchaseService>()),
    );

    Get.lazyPut<IDatabaseRepository>(
      () => DatabaseRepositoryImpl(Get.find<DatabaseRepository>()),
    );

    // Registrar o serviço de favoritos
    Get.lazyPut<IFavoriteService>(
      () => DiagnosticoFavoriteService(),
      fenix: true,
      tag: 'diagnostico',
    );

    // Registrar o controller
    Get.lazyPut<DetalhesDiagnosticoController>(
      () => DetalhesDiagnosticoController(),
    );
  }
}
