// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/logging_service.dart';

/// Registro puro de dependências com responsabilidade única
/// Abstrai o GetX para permitir substituição futura e melhor testabilidade
class ServiceRegistry {
  static ServiceRegistry? _instance;
  static ServiceRegistry get instance => _instance ??= ServiceRegistry._();
  
  ServiceRegistry._();

  // Controle de estado para thread safety
  static bool _isRegistering = false;
  static final _registrationLock = Object();

  /// Registra uma dependência de forma thread-safe
  /// 
  /// [instance] - A instância do serviço a ser registrada
  /// [tag] - Tag opcional para diferenciação
  /// [permanent] - Se deve manter a instância permanentemente
  /// [lazy] - Se deve usar carregamento lazy
  void register<T>(
    T instance, {
    String? tag,
    bool permanent = false,
    bool lazy = false,
  }) {
    _synchronized(_registrationLock, () {
      try {
        if (isRegistered<T>(tag: tag)) {
          LoggingService.debug(
            'Serviço ${T.toString()} já registrado${tag != null ? ' com tag: $tag' : ''}',
            tag: 'ServiceRegistry'
          );
          return;
        }

        if (lazy) {
          _registerLazy<T>(() => instance, tag: tag, permanent: permanent);
        } else {
          _registerEager<T>(instance, tag: tag, permanent: permanent);
        }

        LoggingService.debug(
          'Serviço ${T.toString()} registrado com sucesso${tag != null ? ' (tag: $tag)' : ''}',
          tag: 'ServiceRegistry'
        );

      } catch (e, stackTrace) {
        LoggingService.error(
          'Erro ao registrar serviço ${T.toString()}',
          tag: 'ServiceRegistry',
          error: e,
          stackTrace: stackTrace
        );
        rethrow;
      }
    });
  }

  /// Registra uma dependência com factory (lazy)
  /// 
  /// [factory] - Função que cria a instância quando necessário
  /// [tag] - Tag opcional para diferenciação
  /// [permanent] - Se deve manter a instância permanentemente
  void registerLazy<T>(
    T Function() factory, {
    String? tag,
    bool permanent = false,
  }) {
    _synchronized(_registrationLock, () {
      try {
        if (isRegistered<T>(tag: tag)) {
          LoggingService.debug(
            'Serviço lazy ${T.toString()} já registrado${tag != null ? ' com tag: $tag' : ''}',
            tag: 'ServiceRegistry'
          );
          return;
        }

        _registerLazy<T>(factory, tag: tag, permanent: permanent);

        LoggingService.debug(
          'Serviço lazy ${T.toString()} registrado com sucesso${tag != null ? ' (tag: $tag)' : ''}',
          tag: 'ServiceRegistry'
        );

      } catch (e, stackTrace) {
        LoggingService.error(
          'Erro ao registrar serviço lazy ${T.toString()}',
          tag: 'ServiceRegistry',
          error: e,
          stackTrace: stackTrace
        );
        rethrow;
      }
    });
  }

  /// Registra uma dependência assíncrona
  /// 
  /// [factory] - Future que resolve a instância
  /// [tag] - Tag opcional para diferenciação
  /// [permanent] - Se deve manter a instância permanentemente
  void registerAsync<T>(
    Future<T> Function() factory, {
    String? tag,
    bool permanent = false,
  }) {
    _synchronized(_registrationLock, () {
      try {
        if (isRegistered<T>(tag: tag)) {
          LoggingService.debug(
            'Serviço async ${T.toString()} já registrado${tag != null ? ' com tag: $tag' : ''}',
            tag: 'ServiceRegistry'
          );
          return;
        }

        if (tag != null) {
          Get.putAsync<T>(factory, tag: tag, permanent: permanent);
        } else {
          Get.putAsync<T>(factory, permanent: permanent);
        }

        LoggingService.debug(
          'Serviço async ${T.toString()} registrado com sucesso${tag != null ? ' (tag: $tag)' : ''}',
          tag: 'ServiceRegistry'
        );

      } catch (e, stackTrace) {
        LoggingService.error(
          'Erro ao registrar serviço async ${T.toString()}',
          tag: 'ServiceRegistry',
          error: e,
          stackTrace: stackTrace
        );
        rethrow;
      }
    });
  }

  /// Resolve uma dependência registrada
  /// 
  /// [tag] - Tag opcional para diferenciação
  /// Throws [Exception] se dependência não estiver registrada
  T get<T>({String? tag}) {
    try {
      if (tag != null) {
        return Get.find<T>(tag: tag);
      } else {
        return Get.find<T>();
      }
    } catch (e) {
      LoggingService.error(
        'Erro ao resolver dependência ${T.toString()}${tag != null ? ' com tag: $tag' : ''}',
        tag: 'ServiceRegistry',
        error: e
      );
      rethrow;
    }
  }

  /// Resolve uma dependência de forma opcional
  /// 
  /// [tag] - Tag opcional para diferenciação
  /// Retorna null se dependência não estiver registrada
  T? tryGet<T>({String? tag}) {
    try {
      return get<T>(tag: tag);
    } catch (e) {
      LoggingService.debug(
        'Dependência ${T.toString()}${tag != null ? ' com tag: $tag' : ''} não encontrada',
        tag: 'ServiceRegistry'
      );
      return null;
    }
  }

  /// Verifica se uma dependência está registrada
  /// 
  /// [tag] - Tag opcional para diferenciação
  bool isRegistered<T>({String? tag}) {
    try {
      if (tag != null) {
        return Get.isRegistered<T>(tag: tag);
      } else {
        return Get.isRegistered<T>();
      }
    } catch (e) {
      LoggingService.debug(
        'Erro ao verificar registro de ${T.toString()}${tag != null ? ' com tag: $tag' : ''}',
        tag: 'ServiceRegistry'
      );
      return false;
    }
  }

  /// Remove uma dependência registrada
  /// 
  /// [tag] - Tag opcional para diferenciação
  /// [force] - Se deve forçar remoção mesmo se tiver dependentes
  Future<bool> unregister<T>({String? tag, bool force = false}) async {
    try {
      bool result;
      if (tag != null) {
        result = await Get.delete<T>(tag: tag, force: force);
      } else {
        result = await Get.delete<T>(force: force);
      }

      LoggingService.debug(
        'Dependência ${T.toString()}${tag != null ? ' com tag: $tag' : ''} ${result ? 'removida' : 'não removida'}',
        tag: 'ServiceRegistry'
      );

      return result;
    } catch (e) {
      LoggingService.error(
        'Erro ao remover dependência ${T.toString()}${tag != null ? ' com tag: $tag' : ''}',
        tag: 'ServiceRegistry',
        error: e
      );
      return false;
    }
  }

  /// Limpa todas as dependências não permanentes
  void clearNonPermanent() {
    try {
      Get.reset();
      LoggingService.info('Dependências não permanentes limpas', tag: 'ServiceRegistry');
    } catch (e) {
      LoggingService.error(
        'Erro ao limpar dependências não permanentes',
        tag: 'ServiceRegistry',
        error: e
      );
    }
  }

  /// Obtém estatísticas do registry
  Map<String, dynamic> getStats() {
    // GetX não expõe estatísticas diretamente, mas podemos implementar tracking
    return {
      'isRegistering': _isRegistering,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Registra dependência eager (imediata)
  void _registerEager<T>(T instance, {String? tag, bool permanent = false}) {
    if (tag != null) {
      Get.put<T>(instance, tag: tag, permanent: permanent);
    } else {
      Get.put<T>(instance, permanent: permanent);
    }
  }

  /// Registra dependência lazy (sob demanda)
  void _registerLazy<T>(T Function() factory, {String? tag, bool permanent = false}) {
    if (tag != null) {
      Get.lazyPut<T>(factory, tag: tag, fenix: permanent);
    } else {
      Get.lazyPut<T>(factory, fenix: permanent);
    }
  }

  /// Função auxiliar para sincronização
  void _synchronized(Object lock, void Function() callback) {
    // Implementação simplificada - Dart não tem threads reais
    _isRegistering = true;
    try {
      callback();
    } finally {
      _isRegistering = false;
    }
  }

  /// Limpa instância (para testes)
  static void resetInstance() {
    _instance = null;
  }
}