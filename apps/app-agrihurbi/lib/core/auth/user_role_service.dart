import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'user_role.dart';

/// Service para verificar role do usuário autenticado
class UserRoleService {
  final FirebaseAuth _firebaseAuth;
  
  UserRoleService(this._firebaseAuth);
  
  /// Verifica se o usuário atual é admin
  /// Usa Firebase Auth Custom Claims
  Future<UserRole> getUserRole() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        debugPrint('UserRoleService: No user authenticated');
        return UserRole.regular;
      }
      
      // Força refresh do token para pegar claims atualizados
      final idTokenResult = await user.getIdTokenResult(true);
      
      // Verifica custom claim 'admin'
      final isAdmin = idTokenResult.claims?['admin'] == true;
      
      debugPrint('UserRoleService: User ${user.email} is ${isAdmin ? 'ADMIN' : 'REGULAR'}');
      
      return isAdmin ? UserRole.admin : UserRole.regular;
      
    } catch (e) {
      debugPrint('UserRoleService: Error getting user role: $e');
      return UserRole.regular; // Default para regular em caso de erro
    }
  }
  
  /// Verifica se usuário atual tem permissão de admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role.isAdmin;
  }
  
  /// Stream do role do usuário (atualiza quando auth state muda)
  Stream<UserRole> watchUserRole() {
    return _firebaseAuth.authStateChanges().asyncMap((_) async {
      return await getUserRole();
    });
  }
}
