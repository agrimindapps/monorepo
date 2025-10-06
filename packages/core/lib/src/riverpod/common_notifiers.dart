import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifiers comuns que podem ser reutilizados entre todos os apps
/// Implementam padrões comuns de state management

/// Notifier base para estado de autenticação
/// Apps podem estender este notifier para implementação específica
abstract class BaseAuthNotifier extends StateNotifier<AuthState> {
  BaseAuthNotifier() : super(const AuthState.unauthenticated());

  Future<void> login(String email, String password);

  Future<void> logout();

  Future<void> register(
    String email,
    String password,
    Map<String, dynamic> userData,
  );

  Future<void> resetPassword(String email);

  Future<void> checkAuthStatus();

  /// Helpers comuns
  void setLoading() {
    state = const AuthState.loading();
  }

  void setAuthenticated(Map<String, dynamic> user) {
    state = AuthState.authenticated(user);
  }

  void setUnauthenticated() {
    state = const AuthState.unauthenticated();
  }

  void setError(String error) {
    state = AuthState.error(error);
  }
}

/// Estados possíveis de autenticação
class AuthState {
  const AuthState._();

  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(Map<String, dynamic> user) =
      _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;

  T when<T>({
    required T Function() loading,
    required T Function(Map<String, dynamic> user) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
  }) {
    if (this is _Loading) return loading();
    if (this is _Authenticated)
      return authenticated((this as _Authenticated).user);
    if (this is _Unauthenticated) return unauthenticated();
    if (this is _Error) return error((this as _Error).message);
    throw StateError('Unknown state: $this');
  }

  T maybeWhen<T>({
    T Function()? loading,
    T Function(Map<String, dynamic> user)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is _Loading && loading != null) return loading();
    if (this is _Authenticated && authenticated != null)
      return authenticated((this as _Authenticated).user);
    if (this is _Unauthenticated && unauthenticated != null)
      return unauthenticated();
    if (this is _Error && error != null) return error((this as _Error).message);
    return orElse();
  }
}

class _Loading extends AuthState {
  const _Loading() : super._();
}

class _Authenticated extends AuthState {
  const _Authenticated(this.user) : super._();
  final Map<String, dynamic> user;
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated() : super._();
}

class _Error extends AuthState {
  const _Error(this.message) : super._();
  final String message;
}

/// Notifier para gerenciar preferências do usuário
class PreferencesNotifier extends StateNotifier<Map<String, dynamic>> {
  PreferencesNotifier(this._prefs) : super({});

  final SharedPreferences _prefs;

  /// Carrega todas as preferências
  void loadPreferences() {
    final keys = _prefs.getKeys();
    final prefs = <String, dynamic>{};

    for (final key in keys) {
      final value = _prefs.get(key);
      if (value != null) {
        prefs[key] = value;
      }
    }

    state = prefs;
  }

  /// Define uma preferência string
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
    state = {...state, key: value};
  }

  /// Define uma preferência boolean
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    state = {...state, key: value};
  }

  /// Define uma preferência int
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
    state = {...state, key: value};
  }

  /// Define uma preferência double
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
    state = {...state, key: value};
  }

  /// Define uma lista de strings
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
    state = {...state, key: value};
  }

  /// Remove uma preferência
  Future<void> remove(String key) async {
    await _prefs.remove(key);
    final newState = Map<String, dynamic>.from(state);
    newState.remove(key);
    state = newState;
  }

  /// Limpa todas as preferências
  Future<void> clear() async {
    await _prefs.clear();
    state = {};
  }

  /// Getters helpers
  String? getString(String key) => state[key] as String?;
  bool? getBool(String key) => state[key] as bool?;
  int? getInt(String key) => state[key] as int?;
  double? getDouble(String key) => state[key] as double?;
  List<String>? getStringList(String key) => state[key] as List<String>?;
}

/// Notifier para gerenciar tema da aplicação
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier(this._prefs, this._lightTheme, this._darkTheme)
    : super(_lightTheme) {
    _loadTheme();
  }

  final SharedPreferences _prefs;
  final ThemeData _lightTheme;
  final ThemeData _darkTheme;
  static const String _themeKey = 'app_theme_mode';

  void _loadTheme() {
    final isDark = _prefs.getBool(_themeKey) ?? false;
    state = isDark ? _darkTheme : _lightTheme;
  }

  Future<void> toggleTheme() async {
    final isDark = state == _darkTheme;
    await _prefs.setBool(_themeKey, !isDark);
    state = isDark ? _lightTheme : _darkTheme;
  }

  Future<void> setLightTheme() async {
    await _prefs.setBool(_themeKey, false);
    state = _lightTheme;
  }

  Future<void> setDarkTheme() async {
    await _prefs.setBool(_themeKey, true);
    state = _darkTheme;
  }

  bool get isDarkTheme => state == _darkTheme;
}

/// Notifier para gerenciar estado de conectividade
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(ConnectivityState.unknown);

  void updateConnectivity(bool isConnected) {
    state =
        isConnected
            ? ConnectivityState.connected
            : ConnectivityState.disconnected;
  }

  void setUnknown() {
    state = ConnectivityState.unknown;
  }
}

enum ConnectivityState { connected, disconnected, unknown }

/// Notifier para gerenciar estado de sincronização
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState.idle());

  void startSync() {
    state = const SyncState.syncing(0.0);
  }

  void updateProgress(double progress) {
    state = SyncState.syncing(progress);
  }

  void completeSync({int? itemsSynced}) {
    state = SyncState.completed(
      itemsSynced: itemsSynced ?? 0,
      timestamp: DateTime.now(),
    );
  }

  void failSync(String error) {
    state = SyncState.error(error);
  }

  void resetSync() {
    state = const SyncState.idle();
  }
}

/// Estados de sincronização
class SyncState {
  const SyncState._();

  const factory SyncState.idle() = _SyncIdle;
  const factory SyncState.syncing(double progress) = _SyncSyncing;
  const factory SyncState.completed({
    required int itemsSynced,
    required DateTime timestamp,
  }) = _SyncCompleted;
  const factory SyncState.error(String message) = _SyncError;

  T when<T>({
    required T Function() idle,
    required T Function(double progress) syncing,
    required T Function(int itemsSynced, DateTime timestamp) completed,
    required T Function(String message) error,
  }) {
    if (this is _SyncIdle) return idle();
    if (this is _SyncSyncing) return syncing((this as _SyncSyncing).progress);
    if (this is _SyncCompleted) {
      final completedState = this as _SyncCompleted;
      return completed(completedState.itemsSynced, completedState.timestamp);
    }
    if (this is _SyncError) return error((this as _SyncError).message);
    throw StateError('Unknown state: $this');
  }
}

class _SyncIdle extends SyncState {
  const _SyncIdle() : super._();
}

class _SyncSyncing extends SyncState {
  const _SyncSyncing(this.progress) : super._();
  final double progress;
}

class _SyncCompleted extends SyncState {
  const _SyncCompleted({required this.itemsSynced, required this.timestamp})
    : super._();

  final int itemsSynced;
  final DateTime timestamp;
}

class _SyncError extends SyncState {
  const _SyncError(this.message) : super._();
  final String message;
}

/// Notifier base para formulários
abstract class BaseFormNotifier<T> extends StateNotifier<FormState<T>> {
  BaseFormNotifier() : super(const FormState.initial());

  String? validateData(T data);

  Future<void> submitForm(T data);

  /// Atualiza dados do formulário
  void updateData(T data) {
    state = FormState.editing(data);
  }

  /// Inicia submissão
  void startSubmitting() {
    if (state is _FormEditing<T>) {
      final data = (state as _FormEditing<T>).data;
      final validation = validateData(data);

      if (validation != null) {
        state = FormState.error(validation);
      } else {
        state = FormState.submitting(data);
        submitForm(data);
      }
    }
  }

  /// Marca como concluído
  void markCompleted() {
    state = const FormState.completed();
  }

  /// Marca erro
  void markError(String error) {
    state = FormState.error(error);
  }

  /// Reset formulário
  void reset() {
    state = const FormState.initial();
  }
}

/// Estados de formulário
class FormState<T> {
  const FormState._();

  const factory FormState.initial() = _FormInitial<T>;
  const factory FormState.editing(T data) = _FormEditing<T>;
  const factory FormState.submitting(T data) = _FormSubmitting<T>;
  const factory FormState.completed() = _FormCompleted<T>;
  const factory FormState.error(String message) = _FormError<T>;

  R when<R>({
    required R Function() initial,
    required R Function(T data) editing,
    required R Function(T data) submitting,
    required R Function() completed,
    required R Function(String message) error,
  }) {
    if (this is _FormInitial<T>) return initial();
    if (this is _FormEditing<T>) return editing((this as _FormEditing<T>).data);
    if (this is _FormSubmitting<T>)
      return submitting((this as _FormSubmitting<T>).data);
    if (this is _FormCompleted<T>) return completed();
    if (this is _FormError<T>) return error((this as _FormError<T>).message);
    throw StateError('Unknown state: $this');
  }
}

class _FormInitial<T> extends FormState<T> {
  const _FormInitial() : super._();
}

class _FormEditing<T> extends FormState<T> {
  const _FormEditing(this.data) : super._();
  final T data;
}

class _FormSubmitting<T> extends FormState<T> {
  const _FormSubmitting(this.data) : super._();
  final T data;
}

class _FormCompleted<T> extends FormState<T> {
  const _FormCompleted() : super._();
}

class _FormError<T> extends FormState<T> {
  const _FormError(this.message) : super._();
  final String message;
}

/// Notifier para gerenciar cache local
class CacheNotifier extends StateNotifier<Map<String, CacheItem>> {
  CacheNotifier() : super({});

  /// Adiciona item ao cache
  void put(String key, dynamic value, {Duration? ttl}) {
    final expiresAt = ttl != null ? DateTime.now().add(ttl) : null;
    state = {
      ...state,
      key: CacheItem(
        value: value,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
      ),
    };
  }

  /// Obtém item do cache
  T? get<T>(String key) {
    final item = state[key];
    if (item == null) return null;
    if (item.expiresAt != null && DateTime.now().isAfter(item.expiresAt!)) {
      remove(key);
      return null;
    }

    return item.value as T?;
  }

  /// Remove item do cache
  void remove(String key) {
    final newState = Map<String, CacheItem>.from(state);
    newState.remove(key);
    state = newState;
  }

  /// Limpa cache expirado
  void clearExpired() {
    final now = DateTime.now();
    final newState = <String, CacheItem>{};

    for (final entry in state.entries) {
      final item = entry.value;
      if (item.expiresAt == null || now.isBefore(item.expiresAt!)) {
        newState[entry.key] = item;
      }
    }

    state = newState;
  }

  void clear() {
    state = {};
  }

  /// Verifica se tem item
  bool has(String key) {
    return get<dynamic>(key) != null;
  }
}

/// Item do cache
class CacheItem {
  const CacheItem({
    required this.value,
    required this.createdAt,
    this.expiresAt,
  });

  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;
}
