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
    super.message = 'Erro no servidor. Tente novamente mais tarde.',
    super.statusCode,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Erro ao acessar dados locais.',
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sem conexão com a internet.',
    super.statusCode,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Erro desconhecido. Tente novamente.',
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Dados inválidos.',
    super.statusCode,
  });
}

// ==================== Storage Failures ====================

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Erro ao acessar armazenamento.',
    super.statusCode,
  });
}

class StorageReadFailure extends StorageFailure {
  const StorageReadFailure({
    super.message = 'Erro ao ler dados do armazenamento.',
  });
}

class StorageWriteFailure extends StorageFailure {
  const StorageWriteFailure({
    super.message = 'Erro ao salvar dados no armazenamento.',
  });
}

class StorageDeleteFailure extends StorageFailure {
  const StorageDeleteFailure({
    super.message = 'Erro ao deletar dados do armazenamento.',
  });
}

// ==================== Data Failures ====================

class DataNotFoundFailure extends Failure {
  const DataNotFoundFailure({
    super.message = 'Dados não encontrados.',
    super.statusCode,
  });
}

class DataParseFailure extends Failure {
  const DataParseFailure({
    super.message = 'Erro ao processar dados.',
    super.statusCode,
  });
}

// ==================== Permission Failures ====================

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permissão negada.',
    super.statusCode,
  });
}

// ==================== Premium Failures ====================

class PremiumFailure extends Failure {
  const PremiumFailure({
    super.message = 'Erro ao verificar assinatura premium.',
    super.statusCode,
  });
}

class SubscriptionNotFoundFailure extends PremiumFailure {
  const SubscriptionNotFoundFailure({
    super.message = 'Assinatura não encontrada.',
  });
}

class PurchaseFailure extends PremiumFailure {
  const PurchaseFailure({
    super.message = 'Erro ao processar compra.',
  });
}
