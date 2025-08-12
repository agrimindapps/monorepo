// app-page.dart - App principal migrado para GetX

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'controllers/auth_controller.dart';
import 'controllers/realtime_task_controller.dart';
import 'dependency_injection.dart';
import 'pages/home_screen.dart';
import 'pages/login_screen.dart';
import 'providers/theme_controller.dart';
import 'services/todoist_hive_service.dart';

class TodoistApp extends StatelessWidget {
  const TodoistApp({super.key});

  Future<void> _initializeTodoistApp() async {
    // Inicializar Hive para o módulo app-todoist
    await TodoistHiveService.initialize();

    // Inicializar dependency injection
    await setupDependencyInjection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeTodoistApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing app: ${snapshot.error}'),
              ),
            ),
          );
        }

        // GetX não precisa de providers - usa dependency injection
        return GetMaterialApp(
          title: 'Task Manager',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const AuthWrapper(),
          // Configurações GetX
          enableLog: false,
          defaultTransition: Transition.cupertino,
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar GetX para reatividade
    return Obx(() {
      final authController = Get.find<TodoistAuthController>();
      
      // Mostrar loading durante a inicialização
      if (authController.isLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (authController.isLoggedIn) {
        // Sistema RealtimeController funciona tanto online quanto offline
        return const HomeScreen();
      } else {
        // Mostrar tela de login
        return const LoginScreen();
      }
    });
  }
}

/// Wrapper de inicialização para garantir que controllers estão prontos
class TodoistAppWrapper extends StatefulWidget {
  const TodoistAppWrapper({super.key});

  @override
  State<TodoistAppWrapper> createState() => _TodoistAppWrapperState();
}

class _TodoistAppWrapperState extends State<TodoistAppWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    try {
      // Aguarda a inicialização do container de dependências
      await setupDependencyInjection();
      
      // Registra os controllers GetX
      if (!Get.isRegistered<TodoistAuthController>()) {
        Get.put<TodoistAuthController>(getIt<TodoistAuthController>());
      }
      
      if (!Get.isRegistered<RealtimeTaskController>()) {
        Get.put<RealtimeTaskController>(getIt<RealtimeTaskController>());
      }

      if (!Get.isRegistered<TodoistThemeController>()) {
        Get.put<TodoistThemeController>(getIt<TodoistThemeController>());
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Em caso de erro, mostra tela de erro
      debugPrint('Erro ao inicializar controllers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Inicializando...'),
              ],
            ),
          ),
        ),
      );
    }

    return const TodoistApp();
  }
}
