import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../infrastructure/services/firebase_auth_service.dart';
import '../../common_notifiers.dart';
import '../../common_providers.dart';

/// Providers de domínio unificados para autenticação
/// Consolidam lógica de auth comum entre todos os apps do monorepo

/// Provider principal para estado de autenticação
/// Unifica auth state entre gasometer, plantis, receituagro, etc.
final unifiedAuthProvider =
    StateNotifierProvider<UnifiedAuthNotifier, AuthState>((ref) {
      return UnifiedAuthNotifier();
    });

/// Provider para usuário atual unificado
final domainCurrentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(unifiedAuthProvider);

  return authState.maybeWhen(
    authenticated: (user) => UserEntity.fromJson(user),
    orElse: () => null,
  );
});

/// Provider para status de autenticação simplificado
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(unifiedAuthProvider);

  return authState.when(
    loading: () => AuthStatus.loading,
    authenticated: (_) => AuthStatus.authenticated,
    unauthenticated: () => AuthStatus.unauthenticated,
    error: (_) => AuthStatus.error,
  );
});

/// Provider para verificar se usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final status = ref.watch(authStatusProvider);
  return status == AuthStatus.authenticated;
});

/// Provider para verificar se é usuário anônimo
final isAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  return user?.isAnonymous ?? false;
});

/// Provider para stream de mudanças de auth (Firebase)
final firebaseAuthStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider para configurações específicas de auth por app
final authConfigProvider = Provider.family<AuthConfig, String>((ref, appId) {
  return AuthConfig.forApp(appId);
});

/// Provider para recursos específicos de auth por app
final authFeaturesProvider = Provider.family<AuthFeatures, String>((
  ref,
  appId,
) {
  final config = ref.watch(authConfigProvider(appId));
  return AuthFeatures.fromConfig(config);
});

/// Provider para informações do perfil do usuário
final userProfileProvider = Provider<UserProfile?>((ref) {
  final currentUser = ref.watch(domainCurrentUserProvider);
  if (currentUser == null) return null;

  return UserProfile(
    id: currentUser.id,
    name: currentUser.displayName,
    email: currentUser.email,
    photoUrl: currentUser.photoUrl,
    isEmailVerified: currentUser.isEmailVerified,
    createdAt: currentUser.createdAt,
    lastSignIn: currentUser.lastLoginAt,
  );
});

/// Provider para permissões do usuário
final userPermissionsProvider = Provider<Set<String>>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  if (user == null) return <String>{};
  return <String>{'basic_access'};
});

/// Provider para limitações do usuário (premium vs free)
final userLimitationsProvider = Provider<UserLimitations>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  // Determine premium status from user attributes (fallback to false).
  // This should be replaced/integrated with actual subscription providers later.
  final bool isPremium = user?.email.contains('premium') ?? false;

  return UserLimitations(
    isPremium: isPremium,
    maxDevices: isPremium ? 10 : 2,
    maxSyncItems: isPremium ? -1 : 100, // -1 = unlimited
    hasCloudBackup: isPremium,
    hasAdvancedFeatures: isPremium,
  );
});

/// Provider para ações de autenticação
final authActionsProvider = Provider<AuthActions>((ref) {
  final notifier = ref.read(unifiedAuthProvider.notifier);

  return AuthActions(
    login: notifier.login,
    loginWithGoogle: notifier.loginWithGoogle,
    loginWithApple: notifier.loginWithApple,
    loginAnonymously: notifier.loginAnonymously,
    logout: notifier.logout,
    register: notifier.register,
    resetPassword: notifier.resetPassword,
    deleteAccount: notifier.deleteAccount,
    updateProfile: notifier.updateProfile,
  );
});

/// Provider para token de autenticação atual
final authTokenProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(domainCurrentUserProvider);
  if (user == null) return null;

  try {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return await firebaseUser?.getIdToken();
  } catch (e) {
    return null;
  }
});

/// Provider para informações da sessão atual
final sessionInfoProvider = Provider<SessionInfo?>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  final isConnected = ref.watch(isConnectedProvider);

  if (user == null) return null;

  return SessionInfo(
    userId: user.id,
    deviceId: null,
    sessionStart: DateTime.now(), // Será persistido
    isOnline: isConnected,
    lastActivity: DateTime.now(),
  );
});

/// Status simplificado de autenticação
enum AuthStatus { loading, authenticated, unauthenticated, error }

/// Configurações de auth específicas por app
class AuthConfig {
  final String appId;
  final bool allowAnonymous;
  final bool allowSocialLogin;
  final Set<String> enabledProviders;
  final bool requireEmailVerification;
  final Duration sessionTimeout;

  const AuthConfig({
    required this.appId,
    this.allowAnonymous = true,
    this.allowSocialLogin = true,
    this.enabledProviders = const {'email', 'google', 'apple'},
    this.requireEmailVerification = false,
    this.sessionTimeout = const Duration(hours: 24),
  });

  factory AuthConfig.forApp(String appId) {
    switch (appId) {
      case 'gasometer':
        return const AuthConfig(
          appId: 'gasometer',
          allowAnonymous: true,
          enabledProviders: {'email', 'google'},
        );
      case 'plantis':
        return const AuthConfig(
          appId: 'plantis',
          allowAnonymous: true,
          enabledProviders: {'email', 'google', 'apple'},
        );
      case 'receituagro':
        return const AuthConfig(
          appId: 'receituagro',
          allowAnonymous: false,
          requireEmailVerification: true,
          enabledProviders: {'email'},
        );
      default:
        return AuthConfig(appId: appId);
    }
  }
}

/// Features de auth específicas por app
class AuthFeatures {
  final bool hasDeviceManagement;
  final bool hasMultipleProfiles;
  final bool hasOfflineSupport;
  final bool hasDataExport;

  const AuthFeatures({
    this.hasDeviceManagement = false,
    this.hasMultipleProfiles = false,
    this.hasOfflineSupport = true,
    this.hasDataExport = false,
  });

  factory AuthFeatures.fromConfig(AuthConfig config) {
    return AuthFeatures(
      hasDeviceManagement: config.appId != 'receituagro',
      hasMultipleProfiles: config.appId == 'plantis',
      hasOfflineSupport: true,
      hasDataExport: config.appId != 'receituagro',
    );
  }
}

/// Perfil do usuário unificado
class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignIn;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    this.isEmailVerified = false,
    this.createdAt,
    this.lastSignIn,
  });

  String get displayName => name ?? email?.split('@').first ?? 'Usuário';
  String get initials =>
      displayName
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0] : '')
          .take(2)
          .join()
          .toUpperCase();
}

/// Limitações do usuário
class UserLimitations {
  final bool isPremium;
  final int maxDevices;
  final int maxSyncItems; // -1 = unlimited
  final bool hasCloudBackup;
  final bool hasAdvancedFeatures;

  const UserLimitations({
    this.isPremium = false,
    this.maxDevices = 2,
    this.maxSyncItems = 100,
    this.hasCloudBackup = false,
    this.hasAdvancedFeatures = false,
  });

  bool canAddDevice(int currentDevices) => currentDevices < maxDevices;
  bool canSyncMore(int currentItems) =>
      maxSyncItems == -1 || currentItems < maxSyncItems;
}

/// Informações da sessão
class SessionInfo {
  final String userId;
  final String? deviceId;
  final DateTime sessionStart;
  final bool isOnline;
  final DateTime lastActivity;

  const SessionInfo({
    required this.userId,
    this.deviceId,
    required this.sessionStart,
    this.isOnline = false,
    required this.lastActivity,
  });

  Duration get sessionDuration => DateTime.now().difference(sessionStart);
  bool get isActive => DateTime.now().difference(lastActivity).inMinutes < 30;
}

/// Ações de autenticação disponíveis
class AuthActions {
  final Future<void> Function(String email, String password) login;
  final Future<void> Function() loginWithGoogle;
  final Future<void> Function() loginWithApple;
  final Future<void> Function() loginAnonymously;
  final Future<void> Function() logout;
  final Future<void> Function(
    String email,
    String password,
    Map<String, dynamic> userData,
  )
  register;
  final Future<void> Function(String email) resetPassword;
  final Future<void> Function() deleteAccount;
  final Future<void> Function(Map<String, dynamic> updates) updateProfile;

  const AuthActions({
    required this.login,
    required this.loginWithGoogle,
    required this.loginWithApple,
    required this.loginAnonymously,
    required this.logout,
    required this.register,
    required this.resetPassword,
    required this.deleteAccount,
    required this.updateProfile,
  });
}

/// Notifier unificado para autenticação
class UnifiedAuthNotifier extends BaseAuthNotifier {
  @override
  Future<void> login(String email, String password) async {
    setLoading();
    try {
      final authService = FirebaseAuthService();
      final result = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      result.fold(
        (failure) => setError(failure.message),
        (user) => setAuthenticated(user.toMap()),
      );
    } catch (e) {
      setError('Erro inesperado: $e');
    }
  }

  @override
  Future<void> logout() async {
    setLoading();
    try {
      await FirebaseAuth.instance.signOut();
      setUnauthenticated();
    } catch (e) {
      setError('Erro ao fazer logout: $e');
    }
  }

  @override
  Future<void> register(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    setLoading();
    try {
      final authService = FirebaseAuthService();
      final result = await authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName:
            (userData['displayName'] as String?) ?? email.split('@').first,
      );

      result.fold((failure) => setError(failure.message), (user) {
        setAuthenticated(user.toJson());
      });
    } catch (e) {
      setError('Erro no registro: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      setError('Erro ao enviar email: $e');
    }
  }

  @override
  Future<void> checkAuthStatus() async {
    setLoading();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setAuthenticated({
        'id': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'isAnonymous': user.isAnonymous,
      });
    } else {
      setUnauthenticated();
    }
  }

  Future<void> loginWithGoogle() async {
    setLoading();
    try {
      setError('Google Sign-In não implementado ainda');
    } catch (e) {
      setError('Erro no login com Google: $e');
    }
  }

  Future<void> loginWithApple() async {
    setLoading();
    try {
      setError('Apple Sign-In não implementado ainda');
    } catch (e) {
      setError('Erro no login com Apple: $e');
    }
  }

  Future<void> loginAnonymously() async {
    setLoading();
    try {
      final result = await FirebaseAuth.instance.signInAnonymously();
      final user = result.user;

      if (user != null) {
        setAuthenticated({'id': user.uid, 'isAnonymous': true});
      } else {
        setError('Falha no login anônimo');
      }
    } catch (e) {
      setError('Erro no login anônimo: $e');
    }
  }

  Future<void> deleteAccount() async {
    setLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        setUnauthenticated();
      }
    } catch (e) {
      setError('Erro ao deletar conta: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (updates['displayName'] != null) {
          await user.updateDisplayName(updates['displayName'] as String?);
        }
        if (updates['photoURL'] != null) {
          await user.updatePhotoURL(updates['photoURL'] as String?);
        }
        state.when(
          loading: () {},
          authenticated: (user) => setAuthenticated({...user, ...updates}),
          unauthenticated: () {},
          error: (_) {},
        );
      }
    } catch (e) {
      setError('Erro ao atualizar perfil: $e');
    }
  }
}
