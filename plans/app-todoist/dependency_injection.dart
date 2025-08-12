// dependency_injection.dart - Sistema usando SyncFirebaseService unificado com TodoistAuthController

// Project imports:
import 'constants/error_messages.dart';
import 'controllers/auth_controller.dart';
import 'controllers/realtime_task_controller.dart';
import 'providers/theme_controller.dart';
import 'repository/auth_repository.dart';
import 'repository/task_list_repository.dart';
import 'repository/task_repository.dart';
import 'repository/user_repository.dart';
import 'services/notification_manager.dart';
import 'services/notification_services.dart';
import 'services/storage_service.dart';
import 'services/task_notification_integration.dart';
import 'services/task_stream_service.dart';

/// Container de injeção de dependências usando SyncFirebaseService
class DependencyContainer {
  static final DependencyContainer _instance = DependencyContainer._internal();
  factory DependencyContainer() => _instance;
  DependencyContainer._internal();

  /// Singleton instance getter
  static DependencyContainer get instance => _instance;

  // Repositories
  late final AuthRepository authRepository;
  late final UserRepository userRepository;
  late final TaskRepository taskRepository;
  late final TaskListRepository taskListRepository;

  // Controllers
  late final RealtimeTaskController taskController;

  // Services
  late final StorageService storageService;
  late final TodoistCloudNotificationService cloudNotificationService;
  late final TodoistNotificationManager notificationManager;
  late final TaskNotificationIntegration notificationIntegration;

  // Controllers
  late final TodoistAuthController authController;

  // Providers
  late final TodoistThemeController themeController;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Dependency container initialization

      // 1. Inicializar repositórios
      authRepository = AuthRepository();

      userRepository = UserRepository();
      await userRepository.initialize();

      taskRepository = TaskRepository();
      await taskRepository.initialize();

      taskListRepository = TaskListRepository();
      await taskListRepository.initialize();

      // 2. Inicializar controllers
      taskController = RealtimeTaskController(taskRepository);
      // Controller GetX é inicializado automaticamente via onInit()

      // 3. Inicializar services
      storageService = StorageService();
      cloudNotificationService = TodoistCloudNotificationService();
      notificationManager = TodoistNotificationManager();
      
      // 4. Inicializar integração de notificações
      notificationIntegration = TaskNotificationIntegration();
      notificationIntegration.initialize(
        taskRepository: taskRepository,
        taskListRepository: taskListRepository,
        userRepository: userRepository,
      );
      
      // Inicializar o manager de notificações
      await notificationManager.initialize();

      // 5. Inicializar controllers de auth
      authController = TodoistAuthController();

      // 6. Inicializar providers
      themeController = TodoistThemeController();

      _isInitialized = true;

      // Dependency container initialized successfully
    } catch (e) {
      // Error initializing dependency container: logged internally
      _isInitialized = false;
      rethrow;
    }
  }

  /// Obter contagem de componentes registrados
  int _getComponentCount() {
    return 10; // auth, user, task, taskList, taskController, storage, cloudNotification, notificationManager, notificationIntegration, authController, theme
  }

  /// Verificar se está inicializado
  bool get isInitialized => _isInitialized;

  /// Limpar recursos
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      // Notificar observers sobre shutdown
      _notifyShutdownObservers();

      // Limpar controllers GetX (que possui streams)
      taskController.dispose();
      authController.dispose();
      themeController.dispose();

      // Limpar services com streams
      await _disposeServices();

      // Limpar repositories com subscriptions
      await _disposeRepositories();

      // Limpar TaskStreamService singleton
      await _disposeTaskStreamService();

      _isInitialized = false;
      _lastDisposeTime = DateTime.now();

      // Dependency container resources cleaned up
    } catch (e) {
      // Error cleaning dependency container: logged internally
      // Continue cleanup mesmo com erros para evitar vazamentos
    }
  }

  DateTime? _lastDisposeTime;

  /// Dispose services com resources
  Future<void> _disposeServices() async {
    try {
      // Limpar services de notificação
      await notificationManager.clearAllTodoistNotifications();
      
      // Dispose do storage service se tiver método dispose
      // storageService.dispose(); // Implementar se necessário
      
      // Dispose da integração de notificações se tiver método dispose
      // notificationIntegration.dispose(); // Implementar se necessário
    } catch (e) {
      // Log error but continue cleanup
    }
  }

  /// Dispose repositories com subscriptions
  Future<void> _disposeRepositories() async {
    try {
      userRepository.dispose();
      taskRepository.dispose();
      taskListRepository.dispose();
      // authRepository.dispose(); // Implementar se necessário
    } catch (e) {
      // Log error but continue cleanup
    }
  }

  /// Dispose TaskStreamService singleton
  Future<void> _disposeTaskStreamService() async {
    try {
      // Importar TaskStreamService e chamar dispose
      final taskStreamService = getTaskStreamServiceInstance();
      taskStreamService.dispose();
    } catch (e) {
      // Log error but continue cleanup
    }
  }

  /// Helper para obter instância do TaskStreamService
  TaskStreamService getTaskStreamServiceInstance() {
    return TaskStreamService();
  }

  /// List of shutdown observers
  final List<Function()> _shutdownObservers = [];

  /// Adicionar observer para shutdown
  void addShutdownObserver(Function() observer) {
    _shutdownObservers.add(observer);
  }

  /// Remover observer de shutdown
  void removeShutdownObserver(Function() observer) {
    _shutdownObservers.remove(observer);
  }

  /// Notificar observers sobre shutdown
  void _notifyShutdownObservers() {
    for (final observer in _shutdownObservers) {
      try {
        observer();
      } catch (e) {
        // Log error but continue with other observers
      }
    }
    _shutdownObservers.clear();
  }

  /// Obter informações de debug (apenas em debug mode)
  Future<Map<String, dynamic>> getDebugInfo() async {
    // Verificar se está em debug mode
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    
    if (!isDebug) {
      return {'message': 'Debug info only available in debug mode'};
    }
    
    final memoryInfo = _getMemoryTrackingInfo();
    
    return {
      'isInitialized': _isInitialized,
      'componentCount': _getComponentCount(),
      'shutdownObserversCount': _shutdownObservers.length,
      'memoryTracking': memoryInfo,
      'userRepositoryInfo': _isInitialized ? userRepository.getDebugInfo() : null,
      'taskRepositoryInfo': _isInitialized ? taskRepository.getDebugInfo() : null,
      'taskListRepositoryInfo': _isInitialized ? taskListRepository.getDebugInfo() : null,
      'notificationStats': _isInitialized 
          ? await notificationManager.getNotificationStats()
          : {'status': 'not_initialized'},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Tracking de recursos não liberados
  Map<String, dynamic> _getMemoryTrackingInfo() {
    return {
      'activeComponents': _getActiveComponentsList(),
      'potentialLeaks': _detectPotentialLeaks(),
      'lastDisposeTime': _lastDisposeTime?.toIso8601String(),
    };
  }

  List<String> _getActiveComponentsList() {
    if (!_isInitialized) return [];
    return [
      'authRepository',
      'userRepository', 
      'taskRepository',
      'taskListRepository',
      'taskController',
      'authController',
      'themeController',
      'storageService',
      'cloudNotificationService',
      'notificationManager',
      'notificationIntegration'
    ];
  }

  List<String> _detectPotentialLeaks() {
    final leaks = <String>[];
    
    try {
      if (_isInitialized) {
        // Verificar se controllers têm subscriptions ativas
        final controllerDebugInfo = taskController.getDebugInfo();
        if (controllerDebugInfo['subscriptions'] != null && 
            controllerDebugInfo['subscriptions'] > 0) {
          leaks.add('TaskController has ${controllerDebugInfo['subscriptions']} active subscriptions');
        }
      }
    } catch (e) {
      leaks.add('Error checking for leaks: $e');
    }
    
    return leaks;
  }
}

final container = DependencyContainer();

/// Função de setup principal
Future<void> setupDependencyInjection() async {
  await container.initialize();
}

/// Helper para obter dependências de forma type-safe
T getIt<T>() {
  if (!container.isInitialized) {
    throw Exception(ErrorMessages.dependencyContainerNotInitialized);
  }

  // Controllers
  if (T == RealtimeTaskController) return container.taskController as T;
  if (T == TodoistAuthController) return container.authController as T;

  // Repositories
  if (T == AuthRepository) return container.authRepository as T;
  if (T == UserRepository) return container.userRepository as T;
  if (T == TaskRepository) return container.taskRepository as T;
  if (T == TaskListRepository) return container.taskListRepository as T;

  // Services
  if (T == StorageService) return container.storageService as T;
  if (T == TodoistCloudNotificationService) return container.cloudNotificationService as T;
  if (T == TodoistNotificationManager) return container.notificationManager as T;
  if (T == TaskNotificationIntegration) return container.notificationIntegration as T;

  // Providers
  if (T == TodoistThemeController) return container.themeController as T;

  throw Exception(ErrorMessages.formatTypeNotRegistered(T));
}

/// Helper para verificar se um tipo está registrado
bool isRegistered<T>() {
  try {
    getIt<T>();
    return true;
  } catch (e) {
    return false;
  }
}

/// Helper para obter dependência opcional
T? tryGetIt<T>() {
  try {
    return getIt<T>();
  } catch (e) {
    return null;
  }
}
