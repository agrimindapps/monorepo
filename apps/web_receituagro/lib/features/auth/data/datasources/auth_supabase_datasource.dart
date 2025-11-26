import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Supabase implementation of auth remote data source
class AuthSupabaseDataSource implements AuthRemoteDataSource {
  final SupabaseClient client;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  AuthSupabaseDataSource(this.client) {
    // Listen to Supabase auth state changes
    client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session?.user != null) {
        _authStateController.add(UserModel.fromJson(session!.user.toJson()));
      } else {
        _authStateController.add(null);
      }
    });
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login falhou: usuário não encontrado');
      }

      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw Exception('Erro de autenticação: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao fazer login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Erro ao fazer logout: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao fazer logout: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      return UserModel.fromJson(user.toJson());
    } catch (e) {
      throw Exception('Erro ao obter usuário atual: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = client.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
