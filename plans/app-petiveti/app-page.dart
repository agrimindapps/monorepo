// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'core/error_manager.dart';
import 'pages/desktop_page.dart';
import 'pages/mobile_page.dart';
import 'services/petiveti_hive_service.dart';

class PetivetiApp extends StatefulWidget {
  const PetivetiApp({super.key});

  @override
  State<PetivetiApp> createState() => _PetivetiAppState();
}

class _PetivetiAppState extends State<PetivetiApp> {
  bool _isInitialized = false;
  bool _hasInitError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePetivetiModule();
  }

  Future<void> _initializePetivetiModule() async {
    // Inicializar ErrorManager primeiro
    Get.put(ErrorManager());
    final errorManager = ErrorManager.instance;

    try {
      // Inicialização crítica com retry
      await errorManager.executeWithRetry(
        operationName: 'Inicialização Hive app-petiveti',
        operation: () => PetivetiHiveService.initialize(),
        config: const RetryConfig(
          strategy: RetryStrategy.exponential,
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 500),
        ),
        category: ErrorCategory.initialization,
        context: {'module': 'app-petiveti'},
      );
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      // Erro crítico na inicialização
      final error = AppErrorInfo.critical(
        message: 'Falha crítica na inicialização do módulo app-petiveti',
        details: 'O sistema de armazenamento local não pôde ser inicializado',
        category: ErrorCategory.initialization,
        originalError: e,
        stackTrace: stackTrace,
        context: {
          'module': 'app-petiveti',
          'phase': 'hive_initialization',
        },
      );
      
      errorManager.reportError(error);
      
      setState(() {
        _hasInitError = true;
        _errorMessage = 'Erro na inicialização: ${error.message}';
        _isInitialized = true; // Para não ficar em loop infinito
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Inicializando módulo PetiVeti...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar tela de erro se houve falha crítica
    if (_hasInitError) {
      return _buildErrorScreen();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return const DesktopPageMain();
        } else {
          return const MobilePageMain();
        }
      },
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Erro na Inicialização',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Erro desconhecido na inicialização',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitialized = false;
                    _hasInitError = false;
                    _errorMessage = null;
                  });
                  _initializePetivetiModule();
                },
                child: const Text('Tentar Novamente'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Continuar em modo degradado
                  setState(() {
                    _hasInitError = false;
                  });
                },
                child: const Text('Continuar Mesmo Assim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
