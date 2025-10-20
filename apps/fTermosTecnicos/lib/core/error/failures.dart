import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Following SOLID principles and Clean Architecture patterns
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

// ==================== General Failures ====================

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Erro no servidor. Tente novamente mais tarde.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erro ao acessar dados locais.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Sem conexão com a internet.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Erro desconhecido. Tente novamente.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Dados inválidos.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Storage Failures ====================

class StorageFailure extends Failure {
  const StorageFailure({
    String message = 'Erro ao acessar armazenamento.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class StorageReadFailure extends StorageFailure {
  const StorageReadFailure({
    String message = 'Erro ao ler dados do armazenamento.',
  }) : super(message: message);
}

class StorageWriteFailure extends StorageFailure {
  const StorageWriteFailure({
    String message = 'Erro ao salvar dados no armazenamento.',
  }) : super(message: message);
}

class StorageDeleteFailure extends StorageFailure {
  const StorageDeleteFailure({
    String message = 'Erro ao deletar dados do armazenamento.',
  }) : super(message: message);
}

// ==================== Data Failures ====================

class DataNotFoundFailure extends Failure {
  const DataNotFoundFailure({
    String message = 'Dados não encontrados.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class DataParseFailure extends Failure {
  const DataParseFailure({
    String message = 'Erro ao processar dados.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Permission Failures ====================

class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Permissão negada.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Premium Failures ====================

class PremiumFailure extends Failure {
  const PremiumFailure({
    String message = 'Erro ao verificar assinatura premium.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class SubscriptionNotFoundFailure extends PremiumFailure {
  const SubscriptionNotFoundFailure({
    String message = 'Assinatura não encontrada.',
  }) : super(message: message);
}

class PurchaseFailure extends PremiumFailure {
  const PurchaseFailure({
    String message = 'Erro ao processar compra.',
  }) : super(message: message);
}
