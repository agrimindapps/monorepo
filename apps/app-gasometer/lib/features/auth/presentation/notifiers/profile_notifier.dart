import 'package:core/core.dart' as core;
import 'package:core/core.dart' hide AuthStatus, AuthState;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container_modular.dart';
import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/entities/user_entity.dart' as gasometer_auth;
import '../../domain/usecases/update_profile.dart';
import '../state/profile_state.dart';
import 'auth_notifier.dart';

part 'profile_notifier.g.dart';

/// ProfileNotifier - Gerenciamento de perfil do usuário
///
/// Responsabilidades:
/// - Update profile (displayName, photoUrl)
/// - Update avatar (base64)
/// - Remove avatar
/// - Local user data caching
///
/// Separado do AuthNotifier para aplicar SRP (Single Responsibility Principle)
@Riverpod(keepAlive: true)
class Profile extends _$Profile {
  late final UpdateProfile _updateProfile;
  late final GasometerAnalyticsService _analytics;
  late final AuthLocalDataSource _authLocalDataSource;

  @override
  ProfileState build() {
    _updateProfile = sl<UpdateProfile>();
    _analytics = sl<GasometerAnalyticsService>();
    _authLocalDataSource = sl<AuthLocalDataSource>();

    return const ProfileState.initial();
  }

  /// UPDATE PROFILE - displayName e/ou photoUrl
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    final result = await _updateProfile(
      UpdateProfileParams(displayName: displayName, photoUrl: photoUrl),
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          hasError: true,
        );
      },
      (updatedUser) async {
        final gasometerUser = _convertFromCoreUser(updatedUser);

        state = state.copyWith(
          currentUser: gasometerUser,
          isLoading: false,
          hasError: false,
        );

        // Atualiza também o AuthNotifier para manter consistência
        ref.read(authProvider.notifier).refreshUser(gasometerUser);

        await _analytics.logUserAction(
          'profile_updated',
          parameters: {
            'has_display_name': (displayName != null).toString(),
            'has_photo_url': (photoUrl != null).toString(),
          },
        );
      },
    );
  }

  /// UPDATE AVATAR - Base64 encoded image
  Future<bool> updateAvatar(String avatarBase64) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser == null) {
        state = state.copyWith(
          errorMessage: 'Nenhum usuário autenticado',
          hasError: true,
        );
        return false;
      }

      final updatedUser = authState.currentUser!.copyWith(
        avatarBase64: avatarBase64,
      );

      await _saveUserLocallyWithAvatar(updatedUser);

      state = state.copyWith(currentUser: updatedUser);

      // Atualiza AuthNotifier
      ref.read(authProvider.notifier).refreshUser(updatedUser);

      await _analytics.logUserAction(
        'avatar_updated',
        parameters: {
          'avatar_size_kb': (avatarBase64.length * 3 ~/ 4 / 1024).toString(),
          'user_type': authState.currentUser!.type.toString(),
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao salvar avatar: ${e.toString()}',
        hasError: true,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'avatar_update_error',
      );

      return false;
    }
  }

  /// REMOVE AVATAR
  Future<bool> removeAvatar() async {
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser == null) {
        state = state.copyWith(
          errorMessage: 'Nenhum usuário autenticado',
          hasError: true,
        );
        return false;
      }

      final updatedUser = authState.currentUser!.copyWith(avatarBase64: null);

      await _saveUserLocallyWithAvatar(updatedUser);

      state = state.copyWith(currentUser: updatedUser);

      // Atualiza AuthNotifier
      ref.read(authProvider.notifier).refreshUser(updatedUser);

      await _analytics.logUserAction(
        'avatar_removed',
        parameters: {'user_type': authState.currentUser!.type.toString()},
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover avatar: ${e.toString()}',
        hasError: true,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'avatar_remove_error',
      );

      return false;
    }
  }

  /// Helper method to save user data locally including avatar
  Future<void> _saveUserLocallyWithAvatar(
    gasometer_auth.UserEntity user,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 [Profile] Salvando dados do usuário localmente com avatar');
      }
      final coreUser = _convertToCore(user);
      await _authLocalDataSource.cacheUser(coreUser);
    } catch (e) {
      throw Exception('Falha ao salvar dados do usuário localmente: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ============================================================================
  // CONVERSION UTILITIES
  // ============================================================================

  String _mapFailureToMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  /// Convert core UserEntity to gasometer UserEntity
  gasometer_auth.UserEntity? _convertFromCoreUser(core.UserEntity? coreUser) {
    if (coreUser == null) return null;
    return gasometer_auth.UserEntity(
      id: coreUser.id,
      email: coreUser.email.isEmpty ? null : coreUser.email,
      displayName: coreUser.displayName.isEmpty ? null : coreUser.displayName,
      photoUrl: coreUser.photoUrl,
      avatarBase64: null, // Core doesn't have local avatar support
      type: _mapAuthProviderToUserType(coreUser.provider),
      isEmailVerified: coreUser.isEmailVerified,
      createdAt: coreUser.createdAt ?? DateTime.now(),
      lastSignInAt: coreUser.lastLoginAt,
      metadata: {
        'provider': coreUser.provider.name,
        'phone': coreUser.phone ?? '',
        'isActive': coreUser.isActive,
      },
    );
  }

  /// Map AuthProvider to UserType
  gasometer_auth.UserType _mapAuthProviderToUserType(
    core.AuthProvider provider,
  ) {
    switch (provider) {
      case core.AuthProvider.anonymous:
        return gasometer_auth.UserType.anonymous;
      case core.AuthProvider.email:
      case core.AuthProvider.google:
      case core.AuthProvider.apple:
      case core.AuthProvider.facebook:
        return gasometer_auth.UserType.registered;
    }
  }

  /// Convert gasometer UserEntity to core UserEntity
  core.UserEntity _convertToCore(gasometer_auth.UserEntity gasometerUser) {
    final metadata = gasometerUser.metadata;
    final phone = metadata['phone'];
    final isActive = metadata['isActive'];

    return core.UserEntity(
      id: gasometerUser.id,
      email: gasometerUser.email ?? '',
      displayName: gasometerUser.displayName ?? '',
      photoUrl: gasometerUser.photoUrl,
      isEmailVerified: gasometerUser.isEmailVerified,
      lastLoginAt: gasometerUser.lastSignInAt,
      provider: _mapUserTypeToAuthProvider(gasometerUser.type),
      phone: phone is String ? phone : null,
      isActive: isActive is bool ? isActive : true,
      createdAt: gasometerUser.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Map UserType to AuthProvider for reverse conversion
  core.AuthProvider _mapUserTypeToAuthProvider(
    gasometer_auth.UserType userType,
  ) {
    switch (userType) {
      case gasometer_auth.UserType.anonymous:
        return core.AuthProvider.anonymous;
      case gasometer_auth.UserType.registered:
      case gasometer_auth.UserType.premium:
        return core.AuthProvider.email; // Default to email for registered users
    }
  }
}
