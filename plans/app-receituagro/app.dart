// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'core/bootstrap/app_bootstrapper.dart';
import 'core/bootstrap/bootstrap_phase.dart';
import 'pages/loading_page/index.dart';

class AppReceituagro extends StatefulWidget {
  const AppReceituagro({super.key});

  @override
  State<AppReceituagro> createState() => _AppReceituagroState();
}

class _AppReceituagroState extends State<AppReceituagro>
    with WidgetsBindingObserver {
  late AppBootstrapper _bootstrapper;
  bool _isInitialized = false;
  bool _initializationFailed = false;
  BootstrapPhase _currentPhase = BootstrapPhase.notStarted;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    AppBootstrapper.instance.then((instance) { _bootstrapper = instance; }).catchError((error) { debugPrint('❌ Erro ao inicializar AppBootstrapper: $error'); setState(() { _initializationFailed = true; }); });
    _initializeApp();
  }

  /// Inicializa a aplicação usando o AppBootstrapper
  Future<void> _initializeApp() async {
    try {
      // Aguarda a inicialização do AppBootstrapper
      AppBootstrapper.instance.then((instance) => _bootstrapper = instance);

      // Monitora o progresso da inicialização
      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (_bootstrapper.currentPhase != _currentPhase) {
          setState(() {
            _currentPhase = BootstrapPhase.values.firstWhere((phase) => phase.name == _bootstrapper.currentPhase.name);
          });
        }
        
        if (_bootstrapper.isInitialized || _initializationFailed) {
          timer.cancel();
        }
      });
      
      final success = await _bootstrapper.initialize(
        onEntitlementChange: () => setState(() {}),
      );
      
      setState(() {
        _isInitialized = success;
        _initializationFailed = !success;
        _currentPhase = BootstrapPhase.values.firstWhere((phase) => phase.name == _bootstrapper.currentPhase.name);
      });
      
      if (!success) {
        _handleInitializationFailure();
      }
      
    } catch (e) {
      debugPrint('❌ Erro durante inicialização da app: $e');
      setState(() {
        _initializationFailed = true;
      });
    }
  }

  /// Trata falhas de inicialização
  void _handleInitializationFailure() {
    debugPrint('⚠️ Inicialização falhou. Erros: ${_bootstrapper.initializationErrors}');
    
    // Aqui você pode mostrar uma tela de erro ou tentar reinicializar
    // Por enquanto, vamos apenas logar os erros
  }
  
  /// Reinicializa o app após erro
  Future<void> _retryInitialization() async {
    setState(() {
      _isInitialized = false;
      _initializationFailed = false;
      _currentPhase = BootstrapPhase.notStarted;
    });
    
    await _bootstrapper.reinitialize(
      onEntitlementChange: () => setState(() {}),
    );
    
    _initializeApp();
  }

  @override
  void didChangePlatformBrightness() {
    // O gerenciamento de tema agora é feito pelo bootstrapper
    // Mas mantemos este método para compatibilidade futura
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mostra tela de carregamento enquanto inicializa
        if (!_isInitialized && !_initializationFailed) {
          return CarregandoPage(
            currentPhase: _currentPhase,
            hasError: false,
            onRetry: () => _retryInitialization(),
          );
        }
        
        // Mostra tela de erro se inicialização falhou
        if (_initializationFailed) {
          return CarregandoPage(
            currentPhase: _currentPhase,
            hasError: true,
            onRetry: () => _retryInitialization(),
          );
        }
        
        // App inicializado com sucesso
        return const CarregandoPage(); // Placeholder - será substituído pela navegação principal
      },
    );
  }

}
