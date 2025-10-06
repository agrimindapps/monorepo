import 'package:core/core.dart' show Equatable;

/// Base class for all application errors
/// Provides consistent error handling across the entire app
abstract class AppError extends Equatable {
  const AppError({
    required this.message,
    this.technicalDetails,
    this.userFriendlyMessage,
    this.severity = ErrorSeverity.error,
    this.isRecoverable = true,
    this.metadata,
  });
  final String message;
  final String? technicalDetails;
  final String? userFriendlyMessage;
  final ErrorSeverity severity;
  final bool isRecoverable;
  final Map<String, dynamic>? metadata;

  /// Get user-friendly message with fallback
  String get displayMessage => userFriendlyMessage ?? _getDefaultUserMessage();

  /// Get default user message based on error type
  String _getDefaultUserMessage();

  /// Convert error to map for logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'technicalDetails': technicalDetails,
      'userFriendlyMessage': userFriendlyMessage,
      'severity': severity.name,
      'isRecoverable': isRecoverable,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    message,
    technicalDetails,
    userFriendlyMessage,
    severity,
    isRecoverable,
    metadata,
  ];
}

/// Error severity levels
enum ErrorSeverity { info, warning, error, critical, fatal }

class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.error, isRecoverable: true);

  @override
  String _getDefaultUserMessage() =>
      'Problemas de conexão. Verifique sua internet e tente novamente.';
}

class TimeoutError extends NetworkError {
  const TimeoutError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage:
             'A operação demorou muito para responder. Tente novamente.',
       );
}

class NoInternetError extends NetworkError {
  const NoInternetError({
    super.message = 'No internet connection',
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage:
             'Sem conexão com a internet. Verifique sua conectividade.',
       );
}

class ServerError extends AppError {
  const ServerError({
    required super.message,
    this.statusCode,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.error, isRecoverable: true);
  final int? statusCode;

  @override
  String _getDefaultUserMessage() =>
      'Erro no servidor. Tente novamente em alguns minutos.';
}

class BadRequestError extends ServerError {
  const BadRequestError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(statusCode: 400, userFriendlyMessage: 'Dados inválidos enviados.');
}

class UnauthorizedError extends ServerError {
  const UnauthorizedError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         statusCode: 401,
         userFriendlyMessage: 'Sessão expirada. Faça login novamente.',
       );
}

class ForbiddenError extends ServerError {
  const ForbiddenError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         statusCode: 403,
         userFriendlyMessage: 'Você não tem permissão para esta operação.',
       );
}

class NotFoundError extends ServerError {
  const NotFoundError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(statusCode: 404, userFriendlyMessage: 'Recurso não encontrado.');
}

class InternalServerError extends ServerError {
  const InternalServerError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         statusCode: 500,
         userFriendlyMessage:
             'Erro interno do servidor. Tente novamente mais tarde.',
       );
}

class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    this.fieldErrors = const {},
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.warning, isRecoverable: true);
  final Map<String, List<String>> fieldErrors;

  @override
  String _getDefaultUserMessage() =>
      'Dados inválidos. Verifique os campos e tente novamente.';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['fieldErrors'] = fieldErrors;
    return map;
  }
}

class BusinessLogicError extends AppError {
  const BusinessLogicError({
    required super.message,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.warning, isRecoverable: true);

  @override
  String _getDefaultUserMessage() => message;
}

class VehicleNotFoundError extends BusinessLogicError {
  const VehicleNotFoundError({
    super.message = 'Vehicle not found',
    super.technicalDetails,
    super.metadata,
  }) : super(userFriendlyMessage: 'Veículo não encontrado.');
}

class ExpenseNotFoundError extends BusinessLogicError {
  const ExpenseNotFoundError({
    super.message = 'Expense not found',
    super.technicalDetails,
    super.metadata,
  }) : super(userFriendlyMessage: 'Despesa não encontrada.');
}

class DuplicateVehicleError extends BusinessLogicError {
  const DuplicateVehicleError({
    super.message = 'Vehicle already exists',
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage: 'Já existe um veículo com essas informações.',
       );
}

class InvalidOdometerError extends BusinessLogicError {
  const InvalidOdometerError({
    super.message = 'Invalid odometer reading',
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage:
             'Quilometragem inválida. Deve ser maior que a anterior.',
       );
}

class StorageError extends AppError {
  const StorageError({
    required super.message,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.error, isRecoverable: true);

  @override
  String _getDefaultUserMessage() => 'Erro ao salvar dados. Tente novamente.';
}

class CacheError extends StorageError {
  const CacheError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage:
             'Erro de cache local. Os dados podem estar desatualizados.',
       );
}

class DatabaseError extends StorageError {
  const DatabaseError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage: 'Erro no banco de dados. Tente reiniciar o app.',
       );
}

class SyncError extends AppError {
  const SyncError({
    required super.message,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.warning, isRecoverable: true);

  @override
  String _getDefaultUserMessage() =>
      'Erro de sincronização. Seus dados locais estão seguros.';
}

class ConflictError extends SyncError {
  const ConflictError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage:
             'Conflito de dados detectado. Resolução automática aplicada.',
       );
}

class AuthenticationError extends AppError {
  const AuthenticationError({
    required super.message,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.critical, isRecoverable: true);

  @override
  String _getDefaultUserMessage() =>
      'Erro de autenticação. Verifique suas credenciais.';
}

class InvalidCredentialsError extends AuthenticationError {
  const InvalidCredentialsError({
    super.message = 'Invalid credentials',
    super.technicalDetails,
    super.metadata,
  }) : super(userFriendlyMessage: 'Email ou senha incorretos.');
}

class AccountDisabledError extends AuthenticationError {
  const AccountDisabledError({
    super.message = 'Account disabled',
    super.technicalDetails,
    super.metadata,
  }) : super(
         userFriendlyMessage:
             'Sua conta foi desabilitada. Entre em contato conosco.',
       );
}

class PermissionError extends AppError {
  const PermissionError({
    required this.permission,
    required super.message,
    super.technicalDetails,
    super.userFriendlyMessage,
    super.metadata,
  }) : super(severity: ErrorSeverity.warning, isRecoverable: true);
  final String permission;

  @override
  String _getDefaultUserMessage() => 'Permissão necessária para continuar.';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['permission'] = permission;
    return map;
  }
}

class UnexpectedError extends AppError {
  const UnexpectedError({
    required super.message,
    super.technicalDetails,
    super.metadata,
  }) : super(
         severity: ErrorSeverity.fatal,
         isRecoverable: true,
         userFriendlyMessage: 'Erro inesperado. Tente reiniciar o aplicativo.',
       );

  @override
  String _getDefaultUserMessage() =>
      'Algo deu errado. Tente novamente ou reinicie o aplicativo.';
}
