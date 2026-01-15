import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:core/core.dart' show AuthProvider;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

/// DataSource abstrato para operações remotas de autenticação
///
/// Define contratos para comunicação com API/servidor
/// Inclui tratamento de erros e mapeamento de responses
abstract class AuthRemoteDataSource {
  /// Autentica usuário no servidor
  Future<UserModel> login({required String email, required String password});

  /// Registra novo usuário no servidor
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Cria sessão anônima (guest user)
  Future<UserModel> signInAnonymously();

  /// Vincula conta anônima com email/senha
  Future<UserModel> linkAnonymousWithEmail({
    required String anonymousUserId,
    required String name,
    required String email,
    required String password,
  });

  /// Encerra sessão no servidor
  Future<void> logout();

  /// Obtém usuário atual do servidor
  Future<UserModel?> getCurrentUser();

  /// Atualiza perfil no servidor
  Future<UserModel?> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  });

  /// Renova token de acesso
  Future<String> refreshToken();

  /// Altera senha no servidor
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Solicita recuperação de senha
  Future<void> forgotPassword({required String email});

  /// Redefine senha com token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Verifica se email já está em uso
  Future<bool> isEmailTaken({required String email});
}

/// Implementação do datasource remoto de autenticação
///
/// Comunicação com API usando Dio Client
/// Inclui tratamento robusto de erros e timeout
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Fazendo login para $email');

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data!['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Login bem-sucedido');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        final message =
            response.data!['message'] as String? ?? 'Falha no login';
        debugPrint('AuthRemoteDataSourceImpl: Login falhou - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro no login - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Registrando usuário $email');

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data!['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Registro bem-sucedido');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        final message =
            response.data!['message'] as String? ?? 'Falha no registro';
        debugPrint('AuthRemoteDataSourceImpl: Registro falhou - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro no registro - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Fazendo logout');

      await _dioClient.post<Map<String, dynamic>>('/auth/logout');

      debugPrint('AuthRemoteDataSourceImpl: Logout bem-sucedido');
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro no logout - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Obtendo usuário atual');

      final response = await _dioClient.get<Map<String, dynamic>>('/auth/me');

      if (response.statusCode == 200) {
        final userData = response.data!['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Usuário obtido do servidor');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        debugPrint('AuthRemoteDataSourceImpl: Usuário não autenticado');
        return null;
      } else {
        final message =
            response.data!['message'] as String? ?? 'Falha ao obter usuário';
        debugPrint(
          'AuthRemoteDataSourceImpl: Erro ao obter usuário - $message',
        );
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro ao obter usuário - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Renovando token');

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/refresh',
      );

      if (response.statusCode == 200) {
        final token = response.data!['access_token'] ?? response.data!['token'];
        debugPrint('AuthRemoteDataSourceImpl: Token renovado');
        return token as String;
      } else {
        final message =
            response.data!['message'] as String? ??
            'Falha na renovação do token';
        debugPrint('AuthRemoteDataSourceImpl: Falha na renovação - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na renovação - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel?> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Atualizando perfil $userId');

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (profileImageUrl != null) data['profile_image_url'] = profileImageUrl;

      if (data.isEmpty) {
        debugPrint('AuthRemoteDataSourceImpl: Nenhum dado para atualizar');
        return null;
      }

      final response = await _dioClient.put<Map<String, dynamic>>(
        '/users/$userId',
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data!['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Perfil atualizado');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        final message =
            response.data!['message'] as String? ??
            'Falha na atualização do perfil';
        debugPrint('AuthRemoteDataSourceImpl: Falha na atualização - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na atualização - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Alterando senha');

      final response = await _dioClient.put<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('AuthRemoteDataSourceImpl: Senha alterada com sucesso');
      } else {
        final message =
            response.data!['message'] as String? ??
            'Falha na alteração da senha';
        debugPrint('AuthRemoteDataSourceImpl: Falha na alteração - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na alteração - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      debugPrint(
        'AuthRemoteDataSourceImpl: Solicitando recuperação para $email',
      );

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        debugPrint('AuthRemoteDataSourceImpl: Email de recuperação enviado');
      } else {
        final message =
            response.data!['message'] as String? ??
            'Falha na recuperação de senha';
        debugPrint('AuthRemoteDataSourceImpl: Falha na recuperação - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na recuperação - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Redefinindo senha com token');

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        debugPrint('AuthRemoteDataSourceImpl: Senha redefinida com sucesso');
      } else {
        final message =
            response.data!['message'] as String? ??
            'Falha na redefinição da senha';
        debugPrint('AuthRemoteDataSourceImpl: Falha na redefinição - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na redefinição - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<bool> isEmailTaken({required String email}) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Verificando email $email');

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/check-email',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final isTaken = response.data!['is_taken'] ?? false;
        debugPrint('AuthRemoteDataSourceImpl: Email em uso: $isTaken');
        return isTaken as bool;
      } else {
        final message =
            response.data!['message'] as String? ??
            'Falha na verificação de email';
        debugPrint('AuthRemoteDataSourceImpl: Falha na verificação - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na verificação - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Criando sessão anônima');

      // Tenta criar guest no servidor se endpoint existir
      try {
        final response = await _dioClient.post<Map<String, dynamic>>(
          '/auth/guest',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final userData = response.data!['user'] ?? response.data;
          debugPrint('AuthRemoteDataSourceImpl: Guest criado no servidor');
          return UserModel.fromJson(userData as Map<String, dynamic>);
        }
      } catch (_) {
        // Endpoint não existe, criar guest local
        debugPrint('AuthRemoteDataSourceImpl: Endpoint guest não disponível, criando local');
      }

      // Cria usuário anônimo local (UUID v4 pattern)
      final anonymousId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      final anonymousUser = UserModel(
        userModelId: anonymousId,
        userModelEmail: '',
        userModelDisplayName: 'Visitante',
        userModelProvider: AuthProvider.anonymous,
        userModelIsEmailVerified: false,
        userModelCreatedAt: DateTime.now(),
      );

      debugPrint('AuthRemoteDataSourceImpl: Usuário anônimo criado localmente - $anonymousId');
      return anonymousUser;
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro ao criar sessão anônima - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel> linkAnonymousWithEmail({
    required String anonymousUserId,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Vinculando conta anônima $anonymousUserId com $email');

      // Tenta vincular no servidor se endpoint existir
      try {
        final response = await _dioClient.post<Map<String, dynamic>>(
          '/auth/link-account',
          data: {
            'anonymous_user_id': anonymousUserId,
            'name': name,
            'email': email,
            'password': password,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final userData = response.data!['user'] ?? response.data;
          debugPrint('AuthRemoteDataSourceImpl: Conta vinculada no servidor');
          return UserModel.fromJson(userData as Map<String, dynamic>);
        }
      } catch (_) {
        // Endpoint não existe, registrar como novo usuário
        debugPrint('AuthRemoteDataSourceImpl: Endpoint link não disponível, registrando como novo');
      }

      // Fallback: registra como novo usuário
      final registeredUser = await register(
        name: name,
        email: email,
        password: password,
      );

      debugPrint('AuthRemoteDataSourceImpl: Conta vinculada via registro - ${registeredUser.id}');
      return registeredUser;
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro ao vincular conta - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  /// Mapeia códigos de status para failures específicas
  ServerException _mapStatusCodeToFailure(int? statusCode, String message) {
    switch (statusCode) {
      case 400:
        return const ServerException('Dados inválidos');
      case 401:
        return const ServerException('Credenciais inválidas');
      case 403:
        return const ServerException('Permissão negada');
      case 404:
        return const ServerException('Usuário não encontrado');
      case 409:
        return const ServerException('Email já em uso');
      case 422:
        return ServerException(message);
      case 429:
        return const ServerException('Muitas tentativas');
      case 500:
      case 502:
      case 503:
        return ServerException('Erro no servidor: $message');
      default:
        return ServerException('Erro desconhecido ($statusCode): $message');
    }
  }

  /// Mapeia exceções para failures específicas
  ServerException _mapExceptionToFailure(dynamic exception) {
    final errorMessage = exception.toString().toLowerCase();

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return const ServerException('Erro de conexão');
    } else if (errorMessage.contains('timeout')) {
      return const ServerException('Timeout na conexão');
    } else if (errorMessage.contains('unauthorized')) {
      return const ServerException('Credenciais inválidas');
    } else if (errorMessage.contains('email already')) {
      return const ServerException('Email já em uso');
    } else if (errorMessage.contains('user not found')) {
      return const ServerException('Usuário não encontrado');
    } else if (errorMessage.contains('token expired')) {
      return const ServerException('Token expirado');
    } else if (errorMessage.contains('invalid token')) {
      return const ServerException('Token inválido');
    } else {
      return ServerException('Erro inesperado: ${exception.toString()}');
    }
  }
}
