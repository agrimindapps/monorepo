import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../adapters/auth_state_provider_adapter.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/form_validation_service.dart';
import '../services/image_management_service.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';
import '../state/plant_form_state_manager.dart';
import '../state/plants_state_manager.dart';

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
    return PlantsDataService.create(authProvider: authProvider);
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
    GetPlantsUseCase? getPlantsUseCase,
    AddPlantUseCase? addPlantUseCase,
    UpdatePlantUseCase? updatePlantUseCase,
  }) {
    return PlantFormStateManager(
      validationService: validationService ?? createFormValidationService(),
      imageService: imageService ?? createImageManagementService(),
      getPlantsUseCase: getPlantsUseCase ?? GetIt.instance<GetPlantsUseCase>(),
      addPlantUseCase: addPlantUseCase ?? GetIt.instance<AddPlantUseCase>(),
      updatePlantUseCase: updatePlantUseCase ?? GetIt.instance<UpdatePlantUseCase>(),
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
  
  /// Cria PlantFormStateManager com configuração otimizada
  PlantFormStateManager createOptimizedPlantFormStateManager() {
    final validationService = createFormValidationService();
    final imageService = createImageManagementService();
    
    return PlantFormStateManager(
      validationService: validationService,
      imageService: imageService,
      getPlantsUseCase: GetIt.instance<GetPlantsUseCase>(),
      addPlantUseCase: GetIt.instance<AddPlantUseCase>(),
      updatePlantUseCase: GetIt.instance<UpdatePlantUseCase>(),
    );
  }
  
  /// ==== REGISTRO NO CONTAINER DI ====
  
  /// Registra todas as dependências SOLID no GetIt
  void registerSolidDependencies() {
    final getIt = GetIt.instance;
    
    // Registrar serviços como singletons
    if (!getIt.isRegistered<IAuthStateProvider>()) {
      getIt.registerSingleton<IAuthStateProvider>(createAuthStateProvider());
    }
    
    if (!getIt.isRegistered<FormValidationService>()) {
      getIt.registerSingleton<FormValidationService>(createFormValidationService());
    }
    
    if (!getIt.isRegistered<ImageManagementService>()) {
      getIt.registerSingleton<ImageManagementService>(createImageManagementService());
    }
    
    if (!getIt.isRegistered<PlantsDataService>()) {
      getIt.registerSingleton<PlantsDataService>(
        createPlantsDataService(authProvider: getIt<IAuthStateProvider>())
      );
    }
    
    if (!getIt.isRegistered<PlantsFilterService>()) {
      getIt.registerSingleton<PlantsFilterService>(createPlantsFilterService());
    }
    
    if (!getIt.isRegistered<PlantsCareCalculator>()) {
      getIt.registerSingleton<PlantsCareCalculator>(createPlantsCareCalculator());
    }
    
    // Registrar factories para state managers (não singletons)
    if (!getIt.isRegistered<PlantsStateManager>()) {
      getIt.registerFactory<PlantsStateManager>(() => createPlantsStateManager(
        dataService: getIt<PlantsDataService>(),
        filterService: getIt<PlantsFilterService>(),
        careCalculator: getIt<PlantsCareCalculator>(),
        authProvider: getIt<IAuthStateProvider>(),
      ));
    }
    
    if (!getIt.isRegistered<PlantFormStateManager>()) {
      getIt.registerFactory<PlantFormStateManager>(() => createPlantFormStateManager(
        validationService: getIt<FormValidationService>(),
        imageService: getIt<ImageManagementService>(),
      ));
    }
  }
  
  /// ==== HELPERS DE CONFIGURAÇÃO ====
  
  /// Verifica se todas as dependências SOLID estão registradas
  bool areSolidDependenciesRegistered() {
    final getIt = GetIt.instance;
    
    return getIt.isRegistered<IAuthStateProvider>() &&
           getIt.isRegistered<FormValidationService>() &&
           getIt.isRegistered<ImageManagementService>() &&
           getIt.isRegistered<PlantsDataService>() &&
           getIt.isRegistered<PlantsFilterService>() &&
           getIt.isRegistered<PlantsCareCalculator>() &&
           getIt.isRegistered<PlantsStateManager>() &&
           getIt.isRegistered<PlantFormStateManager>();
  }
  
  /// Limpa todas as dependências SOLID registradas (para testes)
  void clearSolidDependencies() {
    final getIt = GetIt.instance;
    
    if (getIt.isRegistered<PlantFormStateManager>()) {
      getIt.unregister<PlantFormStateManager>();
    }
    if (getIt.isRegistered<PlantsStateManager>()) {
      getIt.unregister<PlantsStateManager>();
    }
    if (getIt.isRegistered<PlantsCareCalculator>()) {
      getIt.unregister<PlantsCareCalculator>();
    }
    if (getIt.isRegistered<PlantsFilterService>()) {
      getIt.unregister<PlantsFilterService>();
    }
    if (getIt.isRegistered<PlantsDataService>()) {
      getIt.unregister<PlantsDataService>();
    }
    if (getIt.isRegistered<ImageManagementService>()) {
      getIt.unregister<ImageManagementService>();
    }
    if (getIt.isRegistered<FormValidationService>()) {
      getIt.unregister<FormValidationService>();
    }
    if (getIt.isRegistered<IAuthStateProvider>()) {
      getIt.unregister<IAuthStateProvider>();
    }
  }
}

/// Enum para configuração de dependências
enum DIMode {
  production,
  development,
  testing,
}

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
    // Configuração otimizada para produção
    factory.registerSolidDependencies();
  }
  
  static void _configureDevelopment(SolidDIFactory factory) {
    // Configuração com debugging para desenvolvimento
    factory.registerSolidDependencies();
    
    // Adicionar logs de debug se necessário
    if (kDebugMode) {
      print('🔧 SOLID DI configurado para desenvolvimento');
    }
  }
  
  static void _configureTesting(SolidDIFactory factory) {
    // Configuração para testes - limpar dependências existentes
    factory.clearSolidDependencies();
    factory.registerSolidDependencies();
    
    if (kDebugMode) {
      print('🧪 SOLID DI configurado para testes');
    }
  }
}