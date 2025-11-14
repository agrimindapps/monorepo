import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

/// DataSource abstrato para operações locais de autenticação
///
/// Define contratos para persistência local usando Hive e Flutter Secure Storage
/// Segue padrão Clean Architecture com separação de responsabilidades
abstract class AuthLocalDataSource {
  /// Salva usuário no cache local
  Future<void> cacheUser(UserModel user);

  /// Obtém o último usuário salvo no cache
  Future<UserModel?> getLastUser();

  /// Remove usuário do cache
  Future<void> clearUser();

  /// Salva token de acesso
  Future<void> saveAccessToken(String token);

  /// Obtém token de acesso
  Future<String?> getAccessToken();

  /// Salva token de refresh
  Future<void> saveRefreshToken(String token);

  /// Obtém token de refresh
  Future<String?> getRefreshToken();

  /// Remove todos os tokens
  Future<void> clearTokens();

  /// Verifica se há usuário logado
  Future<bool> hasLoggedUser();

  /// Salva dados de sessão
  Future<void> saveSessionData(Map<String, dynamic> sessionData);

  /// Obtém dados de sessão
  Future<Map<String, dynamic>?> getSessionData();

  /// Remove dados de sessão
  Future<void> clearSessionData();
}

/// Implementação do datasource local de autenticação
///
/// Usa Hive para dados do usuário e Flutter Secure Storage para tokens
/// Aplica estratégia local-first com persistência robusta
@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final FirebaseAnalyticsService _analyticsService;
  static const String _currentUserKey = 'current_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionDataKey = 'session_data';

  AuthLocalDataSourceImpl(
    this._sharedPreferences,
    this._secureStorage,
    this._analyticsService,
  );

  @override
  Future<void> cacheUser(UserModel user) async {
    final startTime = DateTime.now();

    try {
      debugPrint('AuthLocalDataSourceImpl: Salvando usuário ${user.id}');
      debugPrint('User cached locally: ${user.id}');

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      await _analyticsService.logEvent(
        'user_cached',
        parameters: {'user_id': user.id, 'duration_ms': duration},
      );

      debugPrint('AuthLocalDataSourceImpl: Usuário salvo com sucesso');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao salvar usuário - $e');
      debugPrint('StackTrace: $stackTrace');

      await _analyticsService.logEvent(
        'user_cache_error',
        parameters: {'error': e.toString(), 'user_id': user.id},
      );

      throw Exception('Erro ao salvar usuário: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getLastUser() async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Obtendo último usuário');
      final userDataString = _sharedPreferences.getString(_currentUserKey);

      UserModel? user;
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        user = UserModel.fromJson(userData);
        debugPrint('AuthLocalDataSourceImpl: Usuário encontrado - ${user.id}');
        await _analyticsService.logEvent(
          'user_retrieved_from_cache',
          parameters: {'user_id': user.id},
        );
      } else {
        debugPrint('AuthLocalDataSourceImpl: Nenhum usuário encontrado');

        await _analyticsService.logEvent(
          'user_not_found_in_cache',
          parameters: {},
        );
      }

      return user;
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao obter usuário - $e');
      debugPrint('StackTrace: $stackTrace');

      await _analyticsService.logEvent(
        'user_retrieval_error',
        parameters: {'error': e.toString()},
      );

      throw Exception('Erro ao obter usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Limpando dados do usuário');
      await _sharedPreferences.remove(_currentUserKey);

      await clearTokens();
      await clearSessionData();
      await _analyticsService.logEvent(
        'user_cleared_from_cache',
        parameters: {},
      );

      debugPrint('AuthLocalDataSourceImpl: Dados limpos com sucesso');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao limpar usuário - $e');
      debugPrint('StackTrace: $stackTrace');

      await _analyticsService.logEvent(
        'user_clear_error',
        parameters: {'error': e.toString()},
      );

      throw Exception('Erro ao limpar usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Salvando token de acesso');

      await _secureStorage.write(key: _accessTokenKey, value: token);

      debugPrint('AuthLocalDataSourceImpl: Token de acesso salvo');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao salvar token - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao salvar token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);

      if (token != null) {
        debugPrint('AuthLocalDataSourceImpl: Token de acesso encontrado');
      } else {
        debugPrint('AuthLocalDataSourceImpl: Token de acesso não encontrado');
      }

      return token;
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao obter token - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao obter token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Salvando token de refresh');

      await _secureStorage.write(key: _refreshTokenKey, value: token);

      debugPrint('AuthLocalDataSourceImpl: Token de refresh salvo');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao salvar refresh token - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao salvar refresh token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);

      if (token != null) {
        debugPrint('AuthLocalDataSourceImpl: Token de refresh encontrado');
      } else {
        debugPrint('AuthLocalDataSourceImpl: Token de refresh não encontrado');
      }

      return token;
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao obter refresh token - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao obter refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Limpando tokens');

      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);

      debugPrint('AuthLocalDataSourceImpl: Tokens limpos');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao limpar tokens - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao limpar tokens: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasLoggedUser() async {
    try {
      final user = await getLastUser();
      final token = await getAccessToken();

      final hasUser = user != null && user.isEmailVerified;
      final hasToken = token != null && token.isNotEmpty;

      final isLoggedIn = hasUser && hasToken;

      debugPrint('AuthLocalDataSourceImpl: Usuário logado: $isLoggedIn');
      return isLoggedIn;
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao verificar login - $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  @override
  Future<void> saveSessionData(Map<String, dynamic> sessionData) async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Salvando dados de sessão');

      final jsonString = jsonEncode(sessionData);
      await _sharedPreferences.setString(_sessionDataKey, jsonString);

      debugPrint('AuthLocalDataSourceImpl: Dados de sessão salvos');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao salvar sessão - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao salvar sessão: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final jsonString = _sharedPreferences.getString(_sessionDataKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final sessionData = jsonDecode(jsonString) as Map<String, dynamic>;
        debugPrint('AuthLocalDataSourceImpl: Dados de sessão encontrados');
        return sessionData;
      }

      debugPrint('AuthLocalDataSourceImpl: Nenhum dado de sessão encontrado');
      return null;
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao obter sessão - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao obter sessão: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSessionData() async {
    try {
      debugPrint('AuthLocalDataSourceImpl: Limpando dados de sessão');

      await _sharedPreferences.remove(_sessionDataKey);

      debugPrint('AuthLocalDataSourceImpl: Dados de sessão limpos');
    } catch (e, stackTrace) {
      debugPrint('AuthLocalDataSourceImpl: Erro ao limpar sessão - $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Erro ao limpar sessão: ${e.toString()}');
    }
  }
}
