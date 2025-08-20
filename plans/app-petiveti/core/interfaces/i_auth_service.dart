// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../models/user_model.dart';

/// Interface para o serviço de autenticação
/// Quebra dependência circular entre AuthService e outros services
abstract class IAuthService {
  /// Usuário atual logado
  UserModel? get currentUser;
  
  /// Stream reativo do usuário atual
  Rx<UserModel?> get currentUserStream;
  
  /// Indica se há um usuário logado
  bool get isLoggedIn;
  
  /// Indica se está carregando
  bool get isLoading;
  
  /// Fazer login com email e senha
  Future<bool> login(String email, String senha);
  
  /// Registrar novo usuário
  Future<bool> register(String nome, String email, String senha);
  
  /// Fazer logout
  Future<void> logout();
  
  /// Atualizar status premium do usuário
  Future<void> updateUserPremiumStatus(bool isPremium);
  
  /// Navegar para tela de login
  void navegarParaLogin();
  
  /// Mostrar diálogo de confirmação de logout
  Future<bool> mostrarDialogoLogout();
}
