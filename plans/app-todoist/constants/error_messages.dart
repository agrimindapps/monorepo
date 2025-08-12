/// Mensagens de erro centralizadas para o módulo app-todoist
/// Facilita manutenção e futura internacionalização
class ErrorMessages {
  // === Storage Service Errors ===
  static const String fileUploadError = 'Erro ao fazer upload do arquivo';
  static const String fileDownloadError = 'Erro ao fazer download do arquivo';
  static const String fileDeleteError = 'Erro ao deletar arquivo';
  
  // === Task Repository Errors ===
  static const String taskNotFoundForUpdate = 'Task não encontrada para atualização';
  static const String taskNotFound = 'Task não encontrada';
  static const String taskNotFoundForDuplicate = 'Task não encontrada para duplicar';
  
  // === Task List Repository Errors ===
  static const String taskListNotFoundForDuplicate = 'Lista não encontrada para duplicar';
  
  // === Auth Repository Errors ===
  static const String userDataFetchError = 'Erro ao buscar dados do usuário';
  
  // === Dependency Injection Errors ===
  static const String typeNotRegistered = 'Tipo não registrado no DependencyContainer';
  static const String dependencyContainerNotInitialized = 'DependencyContainer não está inicializado. Chame setupDependencyInjection() primeiro.';
  
  // === Notification Service Errors ===
  static const String notificationCreateError = 'Erro ao criar notificação';
  static const String notificationMarkAsReadError = 'Erro ao marcar notificação como lida';
  static const String notificationMarkMultipleAsReadError = 'Erro ao marcar notificações como lidas';
  
  // === Validation Errors ===
  static const String invalidTaskData = 'Dados da tarefa são inválidos';
  static const String invalidUserData = 'Dados do usuário são inválidos';
  static const String invalidTaskListData = 'Dados da lista são inválidos';
  
  // === Network Errors ===
  static const String networkConnectionError = 'Erro de conexão com a rede';
  static const String serverError = 'Erro interno do servidor';
  static const String requestTimeoutError = 'Timeout na requisição';
  
  // === Database Errors ===
  static const String databaseConnectionError = 'Erro ao conectar com o banco de dados';
  static const String databaseWriteError = 'Erro ao salvar dados no banco';
  static const String databaseReadError = 'Erro ao ler dados do banco';
  
  // === Authentication Errors ===
  static const String invalidCredentials = 'Credenciais inválidas';
  static const String userNotAuthenticated = 'Usuário não autenticado';
  static const String authenticationExpired = 'Sessão expirada. Faça login novamente';
  
  // === Generic Errors ===
  static const String unknownError = 'Erro desconhecido';
  static const String operationFailed = 'Operação falhou';
  static const String dataProcessingError = 'Erro ao processar dados';
  
  /// Formatar mensagem de erro com contexto adicional
  static String formatError(String baseMessage, Object error) {
    return '$baseMessage: $error';
  }
  
  /// Formatar mensagem de erro com ID específico
  static String formatErrorWithId(String baseMessage, String id) {
    return '$baseMessage $id';
  }
  
  /// Formatar mensagem de erro de tipo não registrado
  static String formatTypeNotRegistered(Type type) {
    return '$typeNotRegistered: $type';
  }
}