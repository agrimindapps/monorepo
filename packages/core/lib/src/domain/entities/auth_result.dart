import 'package:dartz/dartz.dart';
import 'user_entity.dart';
import '../../shared/utils/failure.dart';

/// Resultado unificado para operações de autenticação no monorepo
/// Fornece API consistente para todos os projetos/módulos
class AuthResult<T> {
  const AuthResult._({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.moduleName,
  });

  /// Se a operação foi bem-sucedida
  final bool success;

  /// Dados retornados (usuário, etc.)
  final T? data;

  /// Mensagem de erro amigável
  final String? errorMessage;

  /// Código específico do erro para tratamento programático
  final String? errorCode;

  /// Nome do módulo que originou a operação
  final String? moduleName;

  /// Cria resultado de sucesso
  const AuthResult.success(T data, [String? moduleName])
      : this._(
          success: true,
          data: data,
          moduleName: moduleName,
        );

  /// Cria resultado de falha
  const AuthResult.failure(String errorMessage, [String? errorCode, String? moduleName])
      : this._(
          success: false,
          errorMessage: errorMessage,
          errorCode: errorCode,
          moduleName: moduleName,
        );

  /// Converte Either<Failure, T> para AuthResult<T>
  factory AuthResult.fromEither(Either<Failure, T> either, [String? moduleName]) {
    return either.fold(
      (failure) => AuthResult.failure(
        failure.message,
        failure.code,
        moduleName,
      ),
      (data) => AuthResult.success(data, moduleName),
    );
  }

  /// Converte Future<Either<Failure, T>> para Future<AuthResult<T>>
  static Future<AuthResult<T>> fromFutureEither<T>(
    Future<Either<Failure, T>> futureEither, [
    String? moduleName,
  ]) async {
    final either = await futureEither;
    return AuthResult.fromEither(either, moduleName);
  }

  /// Retorna true se a operação falhou
  bool get isFailure => !success;

  /// Retorna true se existe dados
  bool get hasData => data != null;

  /// Executa callback se sucesso
  AuthResult<T> onSuccess(void Function(T data) callback) {
    if (success && data != null) {
      callback(data as T);
    }
    return this;
  }

  /// Executa callback se falha
  AuthResult<T> onFailure(void Function(String message, String? code) callback) {
    if (!success && errorMessage != null) {
      callback(errorMessage!, errorCode);
    }
    return this;
  }

  /// Transforma os dados se sucesso
  AuthResult<R> map<R>(R Function(T data) transform) {
    if (success && data != null) {
      try {
        final transformedData = transform(data as T);
        return AuthResult.success(transformedData, moduleName);
      } catch (e) {
        return AuthResult.failure('Erro na transformação: $e', 'transformation_error', moduleName);
      }
    }
    return AuthResult.failure(errorMessage ?? 'Operação falhou', errorCode, moduleName);
  }

  /// Combina com outro AuthResult
  AuthResult<List<dynamic>> combine<R>(AuthResult<R> other) {
    if (success && other.success) {
      return AuthResult.success([data, other.data], moduleName);
    }
    
    final errorMessage = this.errorMessage ?? other.errorMessage ?? 'Operação combinada falhou';
    final errorCode = this.errorCode ?? other.errorCode;
    
    return AuthResult.failure(errorMessage, errorCode, moduleName);
  }

  @override
  String toString() {
    if (success) {
      return 'AuthResult.success(data: $data, module: $moduleName)';
    } else {
      return 'AuthResult.failure(error: $errorMessage, code: $errorCode, module: $moduleName)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResult<T> &&
        other.success == success &&
        other.data == data &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode &&
        other.moduleName == moduleName;
  }

  @override
  int get hashCode {
    return Object.hash(success, data, errorMessage, errorCode, moduleName);
  }
}

/// Resultado específico para autenticação de usuário
typedef AuthUserResult = AuthResult<UserEntity>;

/// Resultado para operações void (logout, envio de email, etc.)
typedef AuthVoidResult = AuthResult<void>;

/// Extension methods para facilitar uso
extension AuthResultExtension<T> on AuthResult<T> {
  /// Converte para Either<Failure, T>
  Either<Failure, T> toEither() {
    if (success && data != null) {
      return Right(data as T);
    } else {
      return Left(
        AuthFailure(errorMessage ?? 'Erro desconhecido', code: errorCode),
      );
    }
  }

  /// Retorna dados ou lança exceção
  T get dataOrThrow {
    if (success && data != null) {
      return data as T;
    }
    throw Exception(errorMessage ?? 'AuthResult não contém dados válidos');
  }

  /// Retorna dados ou valor padrão
  T? dataOrDefault(T? defaultValue) {
    return success ? data : defaultValue;
  }
}

/// Factory methods convenientes para casos comuns
class AuthResults {
  /// Resultado de login bem-sucedido
  static AuthUserResult loginSuccess(UserEntity user, [String? moduleName]) {
    return AuthResult.success(user, moduleName);
  }

  /// Resultado de login falhou
  static AuthUserResult loginFailure(String message, [String? code, String? moduleName]) {
    return AuthResult.failure(message, code, moduleName);
  }

  /// Resultado de logout bem-sucedido
  static AuthVoidResult logoutSuccess([String? moduleName]) {
    return AuthResult.success(null, moduleName);
  }

  /// Resultado de cadastro bem-sucedido
  static AuthUserResult signupSuccess(UserEntity user, [String? moduleName]) {
    return AuthResult.success(user, moduleName);
  }

  /// Resultado genérico de sucesso para operações void
  static AuthVoidResult operationSuccess([String? moduleName]) {
    return AuthResult.success(null, moduleName);
  }

  /// Resultado genérico de falha
  static AuthResult<T> operationFailure<T>(String message, [String? code, String? moduleName]) {
    return AuthResult.failure(message, code, moduleName);
  }
}