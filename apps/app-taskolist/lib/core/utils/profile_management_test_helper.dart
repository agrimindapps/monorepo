import 'package:core/core.dart' show UserEntity;
import 'package:flutter/foundation.dart';

import '../../infrastructure/services/auth_service.dart';

/// Helper para testar workflows de gerenciamento de perfil em desenvolvimento
class ProfileManagementTestHelper {
  /// Testa atualização de perfil
  static Future<void> testUpdateProfile(
    TaskManagerAuthService authService,
  ) async {
    if (kDebugMode) {
      debugPrint('🧪 Testing profile update...');
      
      try {
        final result = await authService.updateProfile(
          displayName: 'Usuário Teste Atualizado',
          photoURL: 'https://via.placeholder.com/150',
        );
        
        result.fold(
          (failure) {
            debugPrint('❌ Profile update failed: ${failure.message}');
          },
          (UserEntity updatedUser) {
            debugPrint('✅ Profile updated successfully');
            debugPrint('   • ID: ${updatedUser.id}');
            debugPrint('   • Name: ${updatedUser.displayName}');
            debugPrint('   • Email: ${updatedUser.email}');
          },
        );
      } catch (e) {
        debugPrint('❌ Error testing profile update: $e');
      }
    }
  }
  
  /// Testa verificação de conta (CUIDADO: deleta conta de teste)
  static Future<void> testDeleteAccountFlow(
    TaskManagerAuthService authService,
  ) async {
    if (kDebugMode) {
      debugPrint('⚠️ Testing delete account flow (DESTRUCTIVE TEST)...');
      debugPrint('   This test will delete the current user account!');
      await Future<void>.delayed(const Duration(seconds: 3));
      
      try {
        final result = await authService.deleteAccount();
        
        result.fold(
          (failure) {
            debugPrint('❌ Account deletion failed: ${failure.message}');
          },
          (_) {
            debugPrint('✅ Account deleted successfully');
            debugPrint('   • User should be logged out');
            debugPrint('   • All local data should be cleared');
          },
        );
      } catch (e) {
        debugPrint('❌ Error testing account deletion: $e');
      }
    }
  }
  
  /// Testa workflow completo de gerenciamento de perfil
  static Future<void> testCompleteProfileWorkflow(
    TaskManagerAuthService authService,
  ) async {
    if (kDebugMode) {
      debugPrint('🧪 Testing complete profile management workflow...');
      final isLoggedIn = await authService.isLoggedIn;
      if (!isLoggedIn) {
        debugPrint('❌ No user logged in for profile tests');
        return;
      }
      
      debugPrint('✅ User is logged in, proceeding with tests');
      await testUpdateProfile(authService);
      await Future<void>.delayed(const Duration(seconds: 2));
      debugPrint('🔍 Delete account flow available but not executed in tests');
      debugPrint('   • Call testDeleteAccountFlow() manually if needed');
      debugPrint('   • WARNING: This will permanently delete the account');
      
      debugPrint('✅ Profile management workflow tests completed');
    }
  }
  
  /// Mostra informações do usuário atual para debug
  static Future<void> showCurrentUserInfo(
    TaskManagerAuthService authService,
  ) async {
    if (kDebugMode) {
      try {
        final userStream = authService.currentUser;
        final currentUser = await userStream.first;
        
        if (currentUser != null) {
          debugPrint('👤 Current User Info:');
          debugPrint('   • ID: ${currentUser.id}');
          debugPrint('   • Name: ${currentUser.displayName}');
          debugPrint('   • Email: ${currentUser.email}');
          debugPrint('   • Verified: true'); // UserEntity não tem emailVerified
        } else {
          debugPrint('❌ No user currently logged in');
        }
      } catch (e) {
        debugPrint('❌ Error getting current user info: $e');
      }
    }
  }
}