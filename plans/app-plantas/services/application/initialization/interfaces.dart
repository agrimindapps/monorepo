// Dart imports:
import 'dart:async';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';

/// Status de inicialização do sistema
enum InitializationStatus {
  idle,
  initializing,
  success,
  partial,
  error,
  recovering,
}

/// Resultado de uma operação de inicialização
class InitializationResult {
  final bool success;
  final String? error;
  final List<String> initializedServices;
  final List<ServiceFailure> failures;

  const InitializationResult({
    required this.success,
    this.error,
    this.initializedServices = const [],
    this.failures = const [],
  });

  InitializationResult.success({
    required List<String> services,
  }) : this(
          success: true,
          initializedServices: services,
        );

  InitializationResult.failure({
    required String error,
    List<String> services = const [],
    List<ServiceFailure> failures = const [],
  }) : this(
          success: false,
          error: error,
          initializedServices: services,
          failures: failures,
        );
}

/// Interface base para inicializadores de serviços
abstract class IServiceInitializer {
  /// Nome do inicializador para logs e debug
  String get name;

  /// Lista de dependências necessárias
  List<String> get dependencies;

  /// Se o inicializador está completamente inicializado
  bool get isInitialized;

  /// Lista de serviços que este inicializador gerencia
  List<String> get managedServices;

  /// Inicializa os serviços gerenciados
  Future<InitializationResult> initialize();

  /// Verifica se pode tentar inicialização (dependências satisfeitas)
  bool canInitialize(List<String> availableServices);

  /// Limpa recursos e reseta estado
  Future<void> dispose();
}

/// Interface para serviços que suportam fallback
abstract class IFallbackService extends IServiceInitializer {
  /// Tenta inicializar normalmente, com fallback em caso de falha
  Future<InitializationResult> initializeWithFallback();

  /// Se está atualmente usando fallback
  bool get isUsingFallback;

  /// Lista limitações quando em modo fallback
  List<String> get fallbackLimitations;
}

/// Interface para serviços que podem ser recuperados
abstract class IRecoverableService {
  /// Tenta recuperar serviço de um estado de falha
  Future<bool> recover();

  /// Se o serviço pode ser recuperado do estado atual
  bool get canRecover;

  /// Número de tentativas de recovery já realizadas
  int get recoveryAttempts;

  /// Reseta contador de tentativas de recovery
  void resetRecoveryAttempts();
}

/// Interface para o serviço principal de inicialização
abstract class IPlantasAppInitializationService {
  /// Stream do status atual de inicialização
  Stream<InitializationStatus> get statusStream;

  /// Status atual
  InitializationStatus get currentStatus;

  /// Se está em modo degradado
  bool get isDegraded;

  /// Lista de serviços inicializados
  List<String> get initializedServices;

  /// Lista de falhas de serviços
  List<ServiceFailure> get serviceFailures;

  /// Inicia processo completo de inicialização
  Future<InitializationResult> initialize();

  /// Tenta recovery de serviços falhos
  Future<void> performRecovery();

  /// Reinicia completamente o processo de inicialização
  Future<InitializationResult> restart();

  /// Libera recursos
  Future<void> dispose();
}

/// Interface para o serviço de recovery
abstract class IRecoveryService {
  /// Stream de eventos de recovery
  Stream<RecoveryEvent> get recoveryStream;

  /// Se auto-recovery está ativo
  bool get isAutoRecoveryActive;

  /// Inicia recovery inteligente
  Future<void> performIntelligentRecovery(List<ServiceFailure> failures);

  /// Inicia auto-recovery em background
  void startAutoRecovery();

  /// Para auto-recovery
  void stopAutoRecovery();

  /// Registra um serviço como recuperável
  void registerRecoverableService(
      String serviceName, IRecoverableService service);
}

/// Evento de recovery
class RecoveryEvent {
  final RecoveryEventType type;
  final String serviceName;
  final String? message;
  final DateTime timestamp;

  RecoveryEvent({
    required this.type,
    required this.serviceName,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum RecoveryEventType {
  started,
  success,
  failure,
  completed,
}

/// Interface para factory de inicializadores
abstract class IInitializerFactory {
  /// Cria inicializador para serviços core
  IServiceInitializer createCoreServicesInitializer();

  /// Cria inicializador para controllers
  IServiceInitializer createControllersInitializer();

  /// Cria inicializador para autenticação
  IServiceInitializer createAuthenticationInitializer();

  /// Cria serviço de recovery
  IRecoveryService createRecoveryService();
}
