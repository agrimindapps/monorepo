import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
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
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Fazendo login para $email');

      final response = await _dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Login bem-sucedido');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        final message = response.data['message'] as String? ?? 'Falha no login';
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

      final response = await _dioClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Registro bem-sucedido');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        final message =
            response.data['message'] as String? ?? 'Falha no registro';
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

      await _dioClient.post('/auth/logout');

      debugPrint('AuthRemoteDataSourceImpl: Logout bem-sucedido');
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro no logout - $e');
      // Logout pode falhar remotamente mas deve continuar localmente
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      debugPrint('AuthRemoteDataSourceImpl: Obtendo usuário atual');

      final response = await _dioClient.get('/auth/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Usuário obtido do servidor');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        debugPrint('AuthRemoteDataSourceImpl: Usuário não autenticado');
        return null;
      } else {
        final message =
            response.data['message'] as String? ?? 'Falha ao obter usuário';
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

      final response = await _dioClient.post('/auth/refresh');

      if (response.statusCode == 200) {
        final token = response.data['access_token'] ?? response.data['token'];
        debugPrint('AuthRemoteDataSourceImpl: Token renovado');
        return token as String;
      } else {
        final message =
            response.data['message'] as String? ??
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

      final response = await _dioClient.put('/users/$userId', data: data);

      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data;
        debugPrint('AuthRemoteDataSourceImpl: Perfil atualizado');
        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        final message =
            response.data['message'] as String? ??
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

      final response = await _dioClient.put(
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
            response.data['message'] as String? ??
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

      final response = await _dioClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        debugPrint('AuthRemoteDataSourceImpl: Email de recuperação enviado');
      } else {
        final message =
            response.data['message'] as String? ??
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

      final response = await _dioClient.post(
        '/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        debugPrint('AuthRemoteDataSourceImpl: Senha redefinida com sucesso');
      } else {
        final message =
            response.data['message'] as String? ??
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

      final response = await _dioClient.post(
        '/auth/check-email',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final isTaken = response.data['is_taken'] ?? false;
        debugPrint('AuthRemoteDataSourceImpl: Email em uso: $isTaken');
        return isTaken as bool;
      } else {
        final message =
            response.data['message'] as String? ??
            'Falha na verificação de email';
        debugPrint('AuthRemoteDataSourceImpl: Falha na verificação - $message');
        throw _mapStatusCodeToFailure(response.statusCode, message);
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSourceImpl: Erro na verificação - $e');
      throw _mapExceptionToFailure(e);
    }
  }

  // === MÉTODOS PRIVADOS AUXILIARES ===

  /// Mapeia códigos de status para failures específicas
  Exception _mapStatusCodeToFailure(int? statusCode, String message) {
    switch (statusCode) {
      case 400:
        return Exception('Dados inválidos');
      case 401:
        return Exception('Credenciais inválidas');
      case 403:
        return Exception('Permissão negada');
      case 404:
        return Exception('Usuário não encontrado');
      case 409:
        return Exception('Email já em uso');
      case 422:
        return Exception(message);
      case 429:
        return Exception('Muitas tentativas');
      case 500:
      case 502:
      case 503:
        return Exception('Erro no servidor: $message');
      default:
        return Exception('Erro desconhecido ($statusCode): $message');
    }
  }

  /// Mapeia exceções para failures específicas
  Exception _mapExceptionToFailure(dynamic exception) {
    final errorMessage = exception.toString().toLowerCase();

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return Exception('Erro de conexão');
    } else if (errorMessage.contains('timeout')) {
      return Exception('Timeout na conexão');
    } else if (errorMessage.contains('unauthorized')) {
      return Exception('Credenciais inválidas');
    } else if (errorMessage.contains('email already')) {
      return Exception('Email já em uso');
    } else if (errorMessage.contains('user not found')) {
      return Exception('Usuário não encontrado');
    } else if (errorMessage.contains('token expired')) {
      return Exception('Token expirado');
    } else if (errorMessage.contains('invalid token')) {
      return Exception('Token inválido');
    } else {
      return Exception('Erro inesperado: ${exception.toString()}');
    }
  }
}
