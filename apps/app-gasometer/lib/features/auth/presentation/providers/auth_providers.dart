import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/profile_notifier.dart';
import '../notifiers/sync_notifier.dart';
import '../state/auth_state.dart';

part 'auth_providers.g.dart';

/// Derived providers para facilitar acesso ao estado de autenticação
///
/// REFATORADO após separação SRP:
/// - Auth providers → authProvider (core auth)
/// - Profile providers → profileProvider (profile management)
/// - Sync providers → syncProvider (data sync)
///
/// Estes providers são automáticamente atualizados quando os notifiers mudam.
/// Use-os para acessar partes específicas do estado de forma otimizada.

/// Provider do usuário atual
@riverpod
UserEntity? currentUser(Ref ref) {
  return ref.watch(authProvider).currentUser;
}

/// Provider de autenticação
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider).isAuthenticated;
}

/// Provider de premium
@riverpod
bool isPremium(Ref ref) {
  return ref.watch(authProvider).isPremium;
}

/// Provider de usuário anônimo
@riverpod
bool isAnonymous(Ref ref) {
  return ref.watch(authProvider).isAnonymous;
}

/// Provider de status de autenticação
@riverpod
AuthStatus authStatus(Ref ref) {
  return ref.watch(authProvider).status;
}

/// Provider do nome de exibição do usuário
@riverpod
String? userDisplayName(Ref ref) {
  return ref.watch(authProvider).userDisplayName;
}

/// Provider do email do usuário
@riverpod
String? userEmail(Ref ref) {
  return ref.watch(authProvider).userEmail;
}

/// Provider do ID do usuário
@riverpod
String userId(Ref ref) {
  return ref.watch(authProvider).userId;
}

/// Provider de loading state
@riverpod
bool isAuthLoading(Ref ref) {
  return ref.watch(authProvider).isLoading;
}

/// Provider de erro de autenticação
@riverpod
String? authError(Ref ref) {
  return ref.watch(authProvider).errorMessage;
}

/// Provider de inicialização
@riverpod
bool isAuthInitialized(Ref ref) {
  return ref.watch(authProvider).isInitialized;
}

// ============================================================================
// SYNC PROVIDERS (delegated to SyncNotifier)
// ============================================================================

/// Provider de sincronização em andamento
@riverpod
bool isSyncing(Ref ref) {
  return ref.watch(syncProvider).isSyncing;
}

/// Provider de mensagem de sincronização
@riverpod
String? syncMessage(Ref ref) {
  return ref.watch(syncProvider).syncMessage;
}

/// Provider de erro de sincronização
@riverpod
bool hasSyncError(Ref ref) {
  return ref.watch(syncProvider).hasError;
}

// ============================================================================
// PROFILE PROVIDERS (delegated to ProfileNotifier)
// ============================================================================

/// Provider de loading do profile
@riverpod
bool isProfileLoading(Ref ref) {
  return ref.watch(profileProvider).isLoading;
}

/// Provider de erro do profile
@riverpod
String? profileError(Ref ref) {
  return ref.watch(profileProvider).errorMessage;
}
