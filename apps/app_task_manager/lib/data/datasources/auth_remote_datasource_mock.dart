import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  static const uuid = Uuid();
  UserModel? _currentUser;
  final StreamController<UserModel?> _authStateController = 
      StreamController<UserModel?>.broadcast();

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Validação simples para demo
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email e senha são obrigatórios');
    }
    
    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    // Criar usuário mock
    final user = UserModel(
      id: uuid.v4(),
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
  Future<UserModel> signUpWithEmailPassword(String email, String password, String name) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Validação simples para demo
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Todos os campos são obrigatórios');
    }
    
    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }

    // Criar usuário mock
    final user = UserModel(
      id: uuid.v4(),
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
    await Future.delayed(const Duration(milliseconds: 300));
    
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Email inválido');
    }
    
    // Em uma implementação real, enviaria email de reset
    // Por enquanto apenas simula sucesso
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return _authStateController.stream;
  }

  void dispose() {
    _authStateController.close();
  }
}