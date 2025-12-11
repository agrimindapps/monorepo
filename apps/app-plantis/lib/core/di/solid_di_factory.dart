import 'package:flutter/foundation.dart';

import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../data/adapters/auth_state_provider_adapter.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/form_validation_service.dart';
import '../services/image_management_service.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';

/// Factory para criar instâncias seguindo padrão Dependency Injection
/// Resolve violação de Service Locator anti-pattern
class SolidDIFactory {
  static SolidDIFactory? _instance;

  SolidDIFactory._();

  static SolidDIFactory get instance {
    _instance ??= SolidDIFactory._();
    return _instance!;
  }

  /// ==== AUTH SERVICES ====

  IAuthStateProvider createAuthStateProvider() {
    return AuthStateProviderAdapter.instance();
  }

  /// ==== PLANTS SERVICES ====

  PlantsDataService createPlantsDataService({
    IAuthStateProvider? authProvider,
  }) {
    // TODO: Implement proper dependency injection
    // For now, return a stub implementation
    throw UnimplementedError(
      'PlantsDataService creation not implemented in DI factory',
    );
  }

  PlantsFilterService createPlantsFilterService() {
    return PlantsFilterService();
  }

  PlantsCareCalculator createPlantsCareCalculator() {
    return PlantsCareCalculator();
  }

  PlantsStateManager createPlantsStateManager({
    PlantsDataService? dataService,
    PlantsFilterService? filterService,
    PlantsCareCalculator? careCalculator,
    IAuthStateProvider? authProvider,
  }) {
    return PlantsStateManager(
      dataService: dataService ?? createPlantsDataService(),
      filterService: filterService ?? createPlantsFilterService(),
      careCalculator: careCalculator ?? createPlantsCareCalculator(),
      authProvider: authProvider ?? createAuthStateProvider(),
    );
  }

  /// ==== FORM SERVICES ====

  FormValidationService createFormValidationService() {
    return FormValidationService();
  }

  ImageManagementService createImageManagementService({
    IImageService? imageService,
  }) {
    return ImageManagementService.create(imageService: imageService);
  }

  PlantFormStateManager createPlantFormStateManager({
    FormValidationService? validationService,
    ImageManagementService? imageService,
    required GetPlantsUseCase getPlantsUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
  }) {
    return PlantFormStateManager(
      validationService: validationService ?? createFormValidationService(),
      imageService: imageService ?? createImageManagementService(),
      getPlantsUseCase: getPlantsUseCase,
      addPlantUseCase: addPlantUseCase,
      updatePlantUseCase: updatePlantUseCase,
    );
  }

  /// ==== FACTORY METHODS COM CONFIGURAÇÃO ====

  /// Cria PlantsStateManager com configuração otimizada
  PlantsStateManager createOptimizedPlantsStateManager() {
    final authProvider = createAuthStateProvider();
    final dataService = createPlantsDataService(authProvider: authProvider);
    final filterService = createPlantsFilterService();
    final careCalculator = createPlantsCareCalculator();

    return PlantsStateManager(
      dataService: dataService,
      filterService: filterService,
      careCalculator: careCalculator,
      authProvider: authProvider,
    );
  }

  /// ==== REGISTRO NO CONTAINER DI ====

  /// Registra todas as dependências SOLID via Riverpod
  void registerSolidDependencies() {
    // Dependências agora gerenciadas via Riverpod providers
  }

  /// ==== HELPERS DE CONFIGURAÇÃO ====

  /// Verifica se todas as dependências SOLID estão registradas
  bool areSolidDependenciesRegistered() {
    return false;
  }

  /// Limpa todas as dependências SOLID registradas (para testes)
  void clearSolidDependencies() {
    // Dependências agora gerenciadas via Riverpod providers
  }
}

/// Stub classes for state managers - to be implemented
class PlantsStateManager {
  final PlantsDataService dataService;
  final PlantsFilterService filterService;
  final PlantsCareCalculator careCalculator;
  final IAuthStateProvider authProvider;

  PlantsStateManager({
    required this.dataService,
    required this.filterService,
    required this.careCalculator,
    required this.authProvider,
  });
}

class PlantFormStateManager {
  final FormValidationService validationService;
  final ImageManagementService imageService;
  final GetPlantsUseCase getPlantsUseCase;
  final AddPlantUseCase addPlantUseCase;
  final UpdatePlantUseCase updatePlantUseCase;

  PlantFormStateManager({
    required this.validationService,
    required this.imageService,
    required this.getPlantsUseCase,
    required this.addPlantUseCase,
    required this.updatePlantUseCase,
  });
}

/// Enum para configuração de dependências
enum DIMode { production, development, testing }

/// Configurador de DI para diferentes ambientes
class SolidDIConfigurator {
  static void configure(DIMode mode) {
    final factory = SolidDIFactory.instance;

    switch (mode) {
      case DIMode.production:
        _configureProduction(factory);
        break;
      case DIMode.development:
        _configureDevelopment(factory);
        break;
      case DIMode.testing:
        _configureTesting(factory);
        break;
    }
  }

  static void _configureProduction(SolidDIFactory factory) {
    factory.registerSolidDependencies();
  }

  static void _configureDevelopment(SolidDIFactory factory) {
    factory.registerSolidDependencies();
    if (kDebugMode) {
      print('🔧 SOLID DI configurado para desenvolvimento');
    }
  }

  static void _configureTesting(SolidDIFactory factory) {
    factory.clearSolidDependencies();
    factory.registerSolidDependencies();

    if (kDebugMode) {
      print('🧪 SOLID DI configurado para testes');
    }
  }
}
