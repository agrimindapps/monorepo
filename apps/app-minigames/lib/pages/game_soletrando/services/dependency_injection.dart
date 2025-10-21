// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/models/soletrando_game.dart';
import 'package:app_minigames/services/dialog_service.dart';
import 'package:app_minigames/services/timer_service.dart';
import '../viewmodels/soletrando_view_model.dart';

/// Container simples para injeção de dependências
/// Gerencia instâncias e suas dependências de forma centralizada
class DependencyInjection {
  static DependencyInjection? _instance;
  
  static DependencyInjection get instance {
    _instance ??= DependencyInjection._();
    return _instance!;
  }
  
  DependencyInjection._();
  
  // Armazena as instâncias registradas
  final Map<Type, dynamic> _services = {};
  final Map<Type, dynamic Function()> _factories = {};
  final Map<Type, bool> _singletons = {};
  
  /// Registra um serviço como singleton
  void registerSingleton<T>(T instance) {
    _services[T] = instance;
    _singletons[T] = true;
  }
  
  /// Registra uma factory para criar instâncias
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
    _singletons[T] = false;
  }
  
  /// Registra um lazy singleton (criado apenas quando solicitado)
  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = factory;
    _singletons[T] = true;
  }
  
  /// Obtém uma instância do tipo solicitado
  T get<T>() {
    final type = T;
    
    // Se já existe uma instância singleton, retorna ela
    if (_services.containsKey(type)) {
      return _services[type] as T;
    }
    
    // Se tem uma factory registrada
    if (_factories.containsKey(type)) {
      final factory = _factories[type]!;
      final instance = factory() as T;
      
      // Se é singleton, armazena a instância
      if (_singletons[type] == true) {
        _services[type] = instance;
      }
      
      return instance;
    }
    
    throw Exception('Service of type $type is not registered');
  }
  
  /// Verifica se um tipo está registrado
  bool isRegistered<T>() {
    final type = T;
    return _services.containsKey(type) || _factories.containsKey(type);
  }
  
  /// Remove um serviço registrado
  void unregister<T>() {
    final type = T;
    _services.remove(type);
    _factories.remove(type);
    _singletons.remove(type);
  }
  
  /// Remove todas as dependências registradas
  void clear() {
    // Dispose das instâncias que implementam Disposable
    for (final service in _services.values) {
      if (service is ChangeNotifier) {
        service.dispose();
      }
    }
    
    _services.clear();
    _factories.clear();
    _singletons.clear();
  }
  
  /// Reseta o container (útil para testes)
  void reset() {
    clear();
    _instance = null;
  }
  
  /// Registra todas as dependências do jogo Soletrando
  void registerSoletrandoDependencies() {
    // Registra serviços básicos como singletons
    registerLazySingleton<DialogService>(() => DialogService.instance);
    
    // Registra factories para criar novas instâncias quando necessário
    registerFactory<TimerService>(() => TimerService());
    registerFactory<SoletrandoGame>(() => SoletrandoGame());
    
    // Registra o ViewModel como factory (nova instância a cada chamada)
    registerFactory<SoletrandoViewModel>(() => SoletrandoViewModel(
      game: get<SoletrandoGame>(),
      timerService: get<TimerService>(),
    ));
  }
  
  /// Método de conveniência para debug
  Map<String, dynamic> getRegisteredServices() {
    return {
      'services': _services.keys.map((k) => k.toString()).toList(),
      'factories': _factories.keys.map((k) => k.toString()).toList(),
      'singletons': _singletons.entries
          .where((e) => e.value)
          .map((e) => e.key.toString())
          .toList(),
    };
  }
}

/// Widget provider para injeção de dependências
class DependencyProvider extends InheritedWidget {
  final DependencyInjection di;
  
  const DependencyProvider({
    super.key,
    required this.di,
    required super.child,
  });
  
  static DependencyProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DependencyProvider>();
  }
  
  @override
  bool updateShouldNotify(DependencyProvider oldWidget) {
    return di != oldWidget.di;
  }
}

/// Extension para facilitar o acesso às dependências
extension BuildContextDI on BuildContext {
  T get<T>() {
    final provider = DependencyProvider.of(this);
    if (provider != null) {
      return provider.di.get<T>();
    }
    return DependencyInjection.instance.get<T>();
  }
}

/// Classe base para ViewModels com injeção de dependências
abstract class BaseViewModel extends ChangeNotifier {
  late final DependencyInjection _di;
  
  BaseViewModel([DependencyInjection? di]) {
    _di = di ?? DependencyInjection.instance;
  }
  
  /// Obtém uma dependência
  T get<T>() => _di.get<T>();
  
  /// Método para cleanup de recursos
  @override
  void dispose() {
    super.dispose();
  }
}

/// Mixin para classes que precisam de acesso à injeção de dependências
mixin DependencyInjectionMixin {
  late final DependencyInjection _di = DependencyInjection.instance;
  
  T get<T>() => _di.get<T>();
}

/// Decorator para métodos que precisam de retry com injeção de dependências
class DIRetryDecorator {
  final DependencyInjection _di;
  
  const DIRetryDecorator(this._di);
  
  Future<T> execute<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    Exception? lastException;
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await action();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        if (attempt < maxRetries - 1) {
          await Future.delayed(delay);
          // Optionally stop services from DI if needed
          if (_di.isRegistered<TimerService>()) {
            _di.get<TimerService>().stop();
          }
        }
      }
    }
    
    throw lastException!;
  }
}
