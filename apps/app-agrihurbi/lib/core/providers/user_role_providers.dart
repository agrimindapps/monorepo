import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/user_role.dart';
import '../auth/user_role_service.dart';

/// Provider do serviço de role
final userRoleServiceProvider = Provider<UserRoleService>((ref) {
  return UserRoleService(FirebaseAuth.instance);
});

/// Provider do role do usuário atual (Future)
final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final service = ref.watch(userRoleServiceProvider);
  return await service.getUserRole();
});

/// Provider que observa mudanças no role (Stream)
final userRoleStreamProvider = StreamProvider<UserRole>((ref) {
  final service = ref.watch(userRoleServiceProvider);
  return service.watchUserRole();
});

/// Provider derivado para verificar se é admin (mais conveniente)
final isAdminUserProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return role.isAdmin;
});
