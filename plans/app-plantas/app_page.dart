// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/themes/manager.dart';
import 'services/application/initialization/interfaces.dart';
import 'services/application/initialization/plantas_app_initialization_service.dart';
import 'services/application/navigation/navigation_interfaces.dart';
import 'services/application/navigation/navigation_service.dart';
import 'services/infrastructure/degraded_mode_service.dart';

class PlantasApp extends StatefulWidget {
  const PlantasApp({super.key});

  @override
  State<PlantasApp> createState() => _PlantasAppState();
}

class _PlantasAppState extends State<PlantasApp> with WidgetsBindingObserver {
  // Serviços principais
  late final PlantasAppInitializationService _initializationService;
  late final NavigationService _navigationService;

  // Streams
  StreamSubscription<InitializationStatus>? _statusSubscription;
  StreamSubscription<RecoveryEvent>? _recoverySubscription;

  // Estado atual
  InitializationStatus _currentStatus = InitializationStatus.idle;
  String? _lastError;

  @override
  void initState() {
    super.initState();

    // Adicionar observer para mudanças de tema do sistema
    WidgetsBinding.instance.addObserver(this);

    // Inicializar serviços
    _initializeServices();
  }

  void _initializeServices() {
    // Criar serviço principal de inicialização
    _initializationService = PlantasAppInitializationService();

    // Criar serviço de navegação
    _navigationService = NavigationService.withDefaults(
      degradedModeService: DegradedModeService(),
    );

    // Escutar mudanças de status
    _statusSubscription = _initializationService.statusStream.listen(
      (status) {
        if (mounted) {
          setState(() {
            _currentStatus = status;
          });
        }
      },
    );

    // Iniciar processo de inicialização
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      final result = await _initializationService.initialize();

      if (!result.success && result.error != null) {
        setState(() {
          _lastError = result.error;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = e.toString();
        });
      }
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Atualizar tema quando o sistema muda o tema (se ThemeManager estiver disponível)
    try {
      if (Get.isRegistered<ThemeManager>()) {
        Get.find<ThemeManager>().theme.refresh();
      }
    } catch (e) {
      // Ignorar erros se ThemeManager não estiver disponível
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusSubscription?.cancel();
    _recoverySubscription?.cancel();
    _initializationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Criar contexto de navegação baseado no status atual
    final navigationContext = _createNavigationContext(context);

    // Usar NavigationService para resolver e construir o widget apropriado
    return _navigationService.resolveAndBuildWidget(navigationContext);
  }

  NavigationContext _createNavigationContext(BuildContext context) {
    // Determinar o que mostrar baseado no status de inicialização
    AppDestination? overrideDestination;

    switch (_currentStatus) {
      case InitializationStatus.idle:
      case InitializationStatus.initializing:
        overrideDestination = AppDestination.loading;
        break;

      case InitializationStatus.error:
        overrideDestination = AppDestination.error;
        break;

      case InitializationStatus.recovering:
        overrideDestination = AppDestination.recoveringView;
        break;

      case InitializationStatus.partial:
      case InitializationStatus.success:
        // Para estes estados, deixar o NavigationService decidir normalmente
        overrideDestination = null;
        break;
    }

    return NavigationContext.fromGetPlatform(
      authState: _determineAuthState(),
      userRole: _determineUserRole(),
      degradationLevel: _initializationService.isDegraded
          ? _getDegradationLevel()
          : DegradationLevel.none,
      isRecovering: _currentStatus == InitializationStatus.recovering,
      additionalData: {
        'buildContext': context,
        'initializationStatus': _currentStatus,
        'lastError': _lastError,
        'overrideDestination': overrideDestination,
        'retryCallback': _retryInitialization,
        'recoveryCallback': _performRecovery,
        'initializedServicesCount':
            _initializationService.initializedServices.length,
      },
    );
  }

  AuthState _determineAuthState() {
    // Se ainda não inicializou completamente, considerar unavailable
    if (_currentStatus != InitializationStatus.success &&
        _currentStatus != InitializationStatus.partial) {
      return AuthState.unavailable;
    }

    // Se não há controller de auth disponível, unavailable
    final authController = _initializationService.authController;
    if (authController == null) {
      return AuthState.unavailable;
    }

    // Verificar estado real de autenticação
    try {
      if (!authController.isUserLoggedIn()) {
        return AuthState.unauthenticated;
      }

      final user = authController.getCurrentUser();
      if (user?.isGuest == true) {
        return AuthState.anonymous;
      }

      return AuthState.authenticated;
    } catch (e) {
      return AuthState.unavailable;
    }
  }

  UserRole _determineUserRole() {
    final authState = _determineAuthState();

    switch (authState) {
      case AuthState.authenticated:
        // Poderia verificar se é admin aqui
        return UserRole.user;
      case AuthState.anonymous:
        return UserRole.anonymous;
      case AuthState.unauthenticated:
      case AuthState.unavailable:
        return UserRole.guest;
    }
  }

  // Helper method para obter nível de degradação
  DegradationLevel _getDegradationLevel() {
    try {
      return Get.find<DegradedModeService>().currentLevel;
    } catch (e) {
      return DegradationLevel.none;
    }
  }

  // Action methods
  Future<void> _retryInitialization() async {
    setState(() {
      _lastError = null;
    });

    final result = await _initializationService.restart();

    if (!result.success && result.error != null) {
      setState(() {
        _lastError = result.error;
      });
    }
  }

  Future<void> _performRecovery() async {
    await _initializationService.performRecovery();
  }
}
