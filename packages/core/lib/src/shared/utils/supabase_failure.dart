import 'failure.dart';

/// Classe base para falhas relacionadas ao Supabase
abstract class SupabaseFailure extends Failure {
  const SupabaseFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de conexão com o Supabase
class SupabaseConnectionFailure extends SupabaseFailure {
  const SupabaseConnectionFailure([String? message])
      : super(
          message ?? 'Falha ao conectar com o Supabase',
        );
}

/// Falha quando recurso não é encontrado no Supabase
class SupabaseNotFoundFailure extends SupabaseFailure {
  const SupabaseNotFoundFailure(String resource)
      : super('$resource não encontrado');
}

/// Falha de servidor do Supabase
class SupabaseServerFailure extends SupabaseFailure {
  const SupabaseServerFailure([String? message])
      : super(
          message ?? 'Erro no servidor Supabase',
        );
}

/// Falha de autenticação no Supabase
class SupabaseAuthFailure extends SupabaseFailure {
  const SupabaseAuthFailure([String? message])
      : super(
          message ?? 'Erro de autenticação no Supabase',
        );
}

/// Falha de parsing de dados do Supabase
class SupabaseParseFailure extends SupabaseFailure {
  const SupabaseParseFailure([String? message])
      : super(
          message ?? 'Erro ao processar dados do Supabase',
        );
}

/// Falha de timeout do Supabase
class SupabaseTimeoutFailure extends SupabaseFailure {
  const SupabaseTimeoutFailure([String? message])
      : super(
          message ?? 'Tempo de resposta excedido',
        );
}

/// Falha de query inválida do Supabase
class SupabaseQueryFailure extends SupabaseFailure {
  const SupabaseQueryFailure([String? message])
      : super(
          message ?? 'Erro na consulta ao Supabase',
        );
}

/// Extension para converter exceções do Supabase em Failures
extension SupabaseExceptionExtension on Object {
  /// Converte exceção do Supabase em Failure apropriado
  Failure toSupabaseFailure() {
    final errorString = toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return SupabaseTimeoutFailure(toString());
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return SupabaseNotFoundFailure(toString());
    }

    if (errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('unauthorized')) {
      return SupabaseAuthFailure(toString());
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return SupabaseServerFailure(toString());
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return SupabaseConnectionFailure(toString());
    }

    if (errorString.contains('parse') || errorString.contains('json')) {
      return SupabaseParseFailure(toString());
    }

    return SupabaseServerFailure(toString());
  }
}
