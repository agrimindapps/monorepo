// ========== RIVERPOD UTILITIES ==========
// Utilities e helpers para Riverpod compartilhados entre apps

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

// ========== LOGGING OBSERVER ==========
/// Observer para logging de mudanças de providers (development)
class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('''
[RIVERPOD] ${provider.name ?? provider.runtimeType}
  Previous: $previousValue
  New: $newValue
''');
    }
  }

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('[RIVERPOD] Provider added: ${provider.name ?? provider.runtimeType} = $value');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('[RIVERPOD] Provider disposed: ${provider.name ?? provider.runtimeType}');
    }
  }
}

// ========== ASYNC VALUE EXTENSIONS ==========
/// Extension para simplificar o uso de AsyncValue
extension AsyncValueCore<T> on AsyncValue<T> {
  /// Mapeia apenas quando há dados, ignorando loading/error
  R? mapDataOrNull<R>(R Function(T data) mapper) {
    return whenOrNull(
      data: mapper,
    );
  }

  /// Executa callback apenas quando há dados
  void whenData(void Function(T data) callback) {
    whenOrNull(data: callback);
  }

  /// Retorna dados ou valor default
  T valueOrDefault(T defaultValue) {
    return whenOrNull(
      data: (data) => data,
    ) ?? defaultValue;
  }
}

// ========== PROVIDER FAMILIES HELPERS ==========
/// Helper para criar provider families com cache automático
class ProviderFamilyCache<Param, Value> {
  final Map<Param, Value> _cache = {};
  final Value Function(Param param) _factory;

  ProviderFamilyCache(this._factory);

  Value getOrCreate(Param param) {
    return _cache.putIfAbsent(param, () => _factory(param));
  }

  void clear() => _cache.clear();
  void remove(Param param) => _cache.remove(param);
  bool contains(Param param) => _cache.containsKey(param);
}

// ========== DEBOUNCE HELPER ==========
/// Helper para debounce em providers
class DebounceHelper {
  static Timer? _timer;

  static void debounce(Duration delay, VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

