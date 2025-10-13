import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/utils/failure.dart';
import '../../shared/utils/secure_logger.dart';
import '../../shared/utils/supabase_failure.dart';

/// Serviço de configuração e inicialização do Supabase
///
/// Gerencia a conexão com o Supabase de forma segura, usando
/// environment variables para credenciais.
///
/// Exemplo de uso:
/// ```dart
/// final service = SupabaseConfigService();
/// final result = await service.initialize(
///   url: const String.fromEnvironment('SUPABASE_URL'),
///   anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
/// );
/// ```
class SupabaseConfigService {
  static SupabaseConfigService? _instance;
  static SupabaseConfigService get instance =>
      _instance ??= SupabaseConfigService._();

  SupabaseConfigService._();

  /// Cliente Supabase (disponível após inicialização)
  SupabaseClient? _client;
  bool _isInitialized = false;

  /// Obtém o cliente Supabase
  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw StateError(
        'Supabase não foi inicializado. Chame initialize() primeiro.',
      );
    }
    return _client!;
  }

  /// Verifica se o Supabase foi inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa o Supabase com as credenciais fornecidas
  ///
  /// [url] - URL do projeto Supabase
  /// [anonKey] - Chave anônima do projeto
  /// [environment] - Ambiente (dev, staging, prod)
  /// [enableDebug] - Habilita logs de debug
  ///
  /// Retorna Right(void) em caso de sucesso ou Left(Failure) em caso de erro
  Future<Either<Failure, void>> initialize({
    required String url,
    required String anonKey,
    String environment = 'production',
    bool enableDebug = false,
  }) async {
    try {
      // Validações
      if (url.isEmpty) {
        return const Left(
          ValidationFailure('URL do Supabase não pode ser vazia'),
        );
      }

      if (anonKey.isEmpty) {
        return const Left(
          ValidationFailure('Anon Key do Supabase não pode ser vazia'),
        );
      }

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return const Left(
          ValidationFailure('URL do Supabase deve começar com http:// ou https://'),
        );
      }

      // Inicializa o Supabase
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: enableDebug,
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      SecureLogger.info(
        'Supabase inicializado com sucesso (environment: $environment)',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao inicializar Supabase',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SupabaseConnectionFailure(e.toString()));
    }
  }

  /// Testa a conexão com o Supabase
  ///
  /// Retorna Right(true) se conectado ou Left(Failure) em caso de erro
  Future<Either<Failure, bool>> testConnection() async {
    try {
      if (!_isInitialized || _client == null) {
        return const Left(
          SupabaseConnectionFailure('Supabase não inicializado'),
        );
      }

      // Tenta fazer uma query simples para testar a conexão
      await _client!.from('_health_check').select().limit(1);

      SecureLogger.debug('Conexão com Supabase testada com sucesso');
      return const Right(true);
    } catch (e) {
      // Conexão falhou, mas não é crítico
      SecureLogger.warning('Falha ao testar conexão com Supabase', error: e);
      return Left(e.toSupabaseFailure());
    }
  }

  /// Obtém informações sobre o ambiente do Supabase
  Map<String, dynamic> getEnvironmentInfo() {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'message': 'Supabase não inicializado',
      };
    }

    return {
      'initialized': true,
      'has_client': _client != null,
      'auth_state': _client?.auth.currentUser != null ? 'authenticated' : 'unauthenticated',
    };
  }

  /// Reseta a instância (útil para testes)
  void reset() {
    _client = null;
    _isInitialized = false;
    _instance = null;
  }
}

/// Provider singleton para facilitar uso com Riverpod
final supabaseConfigServiceProvider = SupabaseConfigService.instance;

/// Extension para facilitar acesso ao cliente Supabase
extension SupabaseConfigExtension on SupabaseConfigService {
  /// Obtém o cliente Supabase de forma segura
  Either<Failure, SupabaseClient> getClientSafely() {
    if (!isInitialized) {
      return const Left(
        SupabaseConnectionFailure('Supabase não foi inicializado'),
      );
    }

    try {
      return Right(client);
    } catch (e) {
      return Left(SupabaseConnectionFailure(e.toString()));
    }
  }
}
