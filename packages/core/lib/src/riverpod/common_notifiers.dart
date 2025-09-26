// ========== COMMON RIVERPOD NOTIFIERS ==========
// StateNotifiers compartilhados e reutilizáveis entre apps

import 'package:riverpod/riverpod.dart';

// ========== GENERIC LIST NOTIFIER ==========
/// StateNotifier genérico para listas
class ListNotifier<T> extends StateNotifier<List<T>> {
  ListNotifier([List<T>? initialList]) : super(initialList ?? []);

  /// Adicionar item à lista
  void add(T item) {
    state = [...state, item];
  }

  /// Adicionar múltiplos itens
  void addAll(List<T> items) {
    state = [...state, ...items];
  }

  /// Remover item da lista
  void remove(T item) {
    state = state.where((element) => element != item).toList();
  }

  /// Remover item por índice
  void removeAt(int index) {
    if (index >= 0 && index < state.length) {
      final newList = List<T>.from(state);
      newList.removeAt(index);
      state = newList;
    }
  }

  /// Atualizar item por índice
  void updateAt(int index, T newItem) {
    if (index >= 0 && index < state.length) {
      final newList = List<T>.from(state);
      newList[index] = newItem;
      state = newList;
    }
  }

  /// Limpar lista
  void clear() {
    state = [];
  }

  /// Substituir lista completa
  void replace(List<T> newList) {
    state = newList;
  }

  /// Filtrar lista
  void filter(bool Function(T) predicate) {
    state = state.where(predicate).toList();
  }

  /// Ordenar lista
  void sort([int Function(T, T)? compare]) {
    final newList = List<T>.from(state);
    newList.sort(compare);
    state = newList;
  }
}

// ========== GENERIC MAP NOTIFIER ==========
/// StateNotifier genérico para Maps
class MapNotifier<K, V> extends StateNotifier<Map<K, V>> {
  MapNotifier([Map<K, V>? initialMap]) : super(initialMap ?? {});

  /// Adicionar/atualizar entrada
  void set(K key, V value) {
    state = {...state, key: value};
  }

  /// Adicionar múltiplas entradas
  void setAll(Map<K, V> entries) {
    state = {...state, ...entries};
  }

  /// Remover entrada
  void remove(K key) {
    final newMap = Map<K, V>.from(state);
    newMap.remove(key);
    state = newMap;
  }

  /// Limpar mapa
  void clear() {
    state = {};
  }

  /// Verificar se contém chave
  bool containsKey(K key) => state.containsKey(key);

  /// Obter valor ou default
  V? get(K key) => state[key];
}

// ========== COUNTER NOTIFIER ==========
/// StateNotifier para contadores simples
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier([int initialValue = 0]) : super(initialValue);

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
  void set(int value) => state = value;
  void add(int value) => state += value;
  void subtract(int value) => state -= value;
}

// ========== TOGGLE NOTIFIER ==========
/// StateNotifier para boolean toggles
class ToggleNotifier extends StateNotifier<bool> {
  ToggleNotifier([bool initialValue = false]) : super(initialValue);

  void toggle() => state = !state;
  void setTrue() => state = true;
  void setFalse() => state = false;
  void set(bool value) => state = value;
}

// ========== LOADING STATE NOTIFIER ==========
/// StateNotifier para estados de loading com dados
class LoadingStateNotifier<T> extends StateNotifier<LoadingState<T>> {
  LoadingStateNotifier() : super(const LoadingState.idle());

  void setLoading() => state = const LoadingState.loading();
  
  void setData(T data) => state = LoadingState.data(data);
  
  void setError(String error) => state = LoadingState.error(error);
  
  void setIdle() => state = const LoadingState.idle();
}

// ========== LOADING STATE DATA CLASS ==========
/// Data class para estados de loading
sealed class LoadingState<T> {
  const LoadingState();

  const factory LoadingState.idle() = IdleState<T>;
  const factory LoadingState.loading() = LoadingStateLoading<T>;
  const factory LoadingState.data(T data) = DataState<T>;
  const factory LoadingState.error(String message) = ErrorState<T>;

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(String message) error,
  }) {
    return switch (this) {
      IdleState<T>() => idle(),
      LoadingStateLoading<T>() => loading(),
      DataState<T>(data: final d) => data(d),
      ErrorState<T>(message: final m) => error(m),
    };
  }
}

class IdleState<T> extends LoadingState<T> {
  const IdleState();
}

class LoadingStateLoading<T> extends LoadingState<T> {
  const LoadingStateLoading();
}

class DataState<T> extends LoadingState<T> {
  final T data;
  const DataState(this.data);
}

class ErrorState<T> extends LoadingState<T> {
  final String message;
  const ErrorState(this.message);
}