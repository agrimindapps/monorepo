import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'auth_remote_datasource.dart';
import 'user_model.dart';

class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  UserModel? _currentUser;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  @override
  Future<UserModel> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email e senha são obrigatórios');
    }

    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }
    final user = UserModel(
      id: FirebaseFirestore.instance.collection('_').doc().id,
      name: email.split('@').first, // Nome do email
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Todos os campos são obrigatórios');
    }

    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }
    final user = UserModel(
      id: FirebaseFirestore.instance.collection('_').doc().id,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Email inválido');
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (_currentUser == null) {
      throw Exception('Nenhum usuário logado para deletar');
    }
    final deletedUserId = _currentUser!.id;

    _currentUser = null;
    _authStateController.add(null);
    debugPrint('🗑️ Account deleted for user: $deletedUserId');
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return _authStateController.stream;
  }

  void dispose() {
    _authStateController.close();
  }
}
