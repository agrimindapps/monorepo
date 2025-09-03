import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/user_entity.dart' as local_entities;
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/update_profile.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';
import 'subscription_service.dart';
import 'sync_service.dart';

/// Wrapper para o serviço de autenticação Firebase Auth do core
/// Adiciona funcionalidades específicas do Task Manager
class TaskManagerAuthService {
  final IAuthRepository _authRepository;
  late final TaskManagerAnalyticsService _analyticsService;
  late final TaskManagerCrashlyticsService _crashlyticsService;
  late final TaskManagerSubscriptionService _subscriptionService;
  late final TaskManagerSyncService _syncService;
  late final UpdateProfile _updateProfile;
  late final DeleteAccount _deleteAccount;

  TaskManagerAuthService({
    required IAuthRepository authRepository,
  }) : _authRepository = authRepository {
    _analyticsService = di.sl<TaskManagerAnalyticsService>();
    _crashlyticsService = di.sl<TaskManagerCrashlyticsService>();
    _subscriptionService = di.sl<TaskManagerSubscriptionService>();
    _syncService = di.sl<TaskManagerSyncService>();
    _updateProfile = di.sl<UpdateProfile>();
    _deleteAccount = di.sl<DeleteAccount>();
  }

  /// Stream do usuário atual
  Stream<UserEntity?> get currentUser => _authRepository.currentUser;

  /// Verifica se o usuário está logado
  Future<bool> get isLoggedIn => _authRepository.isLoggedIn;

  /// Verifica se o usuário tem assinatura Premium ativa
  Future<bool> get hasPremiumSubscription => _subscriptionService.hasPremiumSubscription();

  /// Stream do status da assinatura
  Stream<SubscriptionEntity?> get subscriptionStatus => _subscriptionService.subscriptionStatus;

  /// Login com email e senha (sem sincronização automática)
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        // Log do erro para analytics
        _logAuthEvent('login_failed', {
          'method': 'email',
          'error_type': failure.runtimeType.toString(),
          'error_message': failure.message,
        });

        // Registrar erro no Crashlytics
        _crashlyticsService.recordError(
          exception: failure,
          stackTrace: StackTrace.current,
          reason: 'Login failed with email/password',
        );

        return Left(failure);
      },
      (user) {
        // Log de sucesso
        _logAuthEvent('login_success', {
          'method': 'email',
          'user_id': user.id,
          'has_display_name': user.displayName.isNotEmpty,
        });

        // Configurar contexto do usuário no Crashlytics
        _crashlyticsService.setTaskManagerContext(
          userId: user.id,
          version: '1.0.0',
          environment: 'production',
        );

        return Right(user);
      },
    );
  }

  /// Login com email e senha + sincronização automática
  Future<Either<Failure, UserEntity>> loginAndSync({
    required String email,
    required String password,
  }) async {
    // 1. Realizar login
    final loginResult = await signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return loginResult.fold(
      (failure) => Left(failure),
      (user) async {
        // 2. Iniciar sincronização automática pós-login
        await _startPostLoginSync(user);
        return Right(user);
      },
    );
  }

  /// Inicia sincronização após login (não-bloqueante)
  Future<void> _startPostLoginSync(UserEntity user) async {
    try {
      // Verificar se usuário é Premium via RevenueCat
      final bool isUserPremium = await _subscriptionService.hasPremiumSubscription();
      
      // Iniciar sync em background (não bloqueia o login)
      unawaited(_syncService.syncAll(
        userId: user.id,
        isUserPremium: isUserPremium,
      ));

      if (kDebugMode) {
        debugPrint('🔄 TaskManagerAuthService: Sync pós-login iniciado');
      }
    } catch (e) {
      // Falha silenciosa - não deve interromper o login
      if (kDebugMode) {
        debugPrint('❌ TaskManagerAuthService: Erro ao iniciar sync pós-login: $e');
      }
    }
  }

  /// Registro com email, senha e nome
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.fold(
      (failure) {
        // Log do erro
        _logAuthEvent('registration_failed', {
          'method': 'email',
          'error_type': failure.runtimeType.toString(),
          'error_message': failure.message,
        });

        _crashlyticsService.recordError(
          exception: failure,
          stackTrace: StackTrace.current,
          reason: 'Registration failed with email/password',
        );

        return Left(failure);
      },
      (user) {
        // Log de sucesso do registro
        _logAuthEvent('registration_success', {
          'method': 'email',
          'user_id': user.id,
          'display_name_length': displayName.length,
        });

        // Log do primeiro login após registro
        _logAuthEvent('first_login', {
          'method': 'email',
          'user_id': user.id,
        });

        // Configurar contexto do usuário
        _crashlyticsService.setTaskManagerContext(
          userId: user.id,
          version: '1.0.0',
          environment: 'production',
        );

        return Right(user);
      },
    );
  }

  /// Login com Google
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    final result = await _authRepository.signInWithGoogle();

    return result.fold(
      (failure) {
        _logAuthEvent('login_failed', {
          'method': 'google',
          'error_message': failure.message,
        });
        return Left(failure);
      },
      (user) {
        _logAuthEvent('login_success', {
          'method': 'google',
          'user_id': user.id,
        });
        return Right(user);
      },
    );
  }

  /// Login com Apple
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    final result = await _authRepository.signInWithApple();

    return result.fold(
      (failure) {
        _logAuthEvent('login_failed', {
          'method': 'apple',
          'error_message': failure.message,
        });
        return Left(failure);
      },
      (user) {
        _logAuthEvent('login_success', {
          'method': 'apple',
          'user_id': user.id,
        });
        return Right(user);
      },
    );
  }

  /// Login anônimo (modo demo)
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    final result = await _authRepository.signInAnonymously();

    return result.fold(
      (failure) {
        _logAuthEvent('anonymous_login_failed', {
          'error_message': failure.message,
        });
        return Left(failure);
      },
      (user) {
        _logAuthEvent('anonymous_login_success', {
          'user_id': user.id,
        });
        return Right(user);
      },
    );
  }

  /// Logout
  Future<Either<Failure, void>> signOut() async {
    // Capturar dados do usuário antes do logout para analytics
    final currentUserData = await _getCurrentUserForAnalytics();

    final result = await _authRepository.signOut();

    return result.fold(
      (failure) {
        _crashlyticsService.recordError(
          exception: failure,
          stackTrace: StackTrace.current,
          reason: 'Logout failed',
        );
        return Left(failure);
      },
      (_) {
        // Log de logout bem-sucedido
        _logAuthEvent('logout_success', currentUserData);

        // Limpar contexto do usuário no Crashlytics
        _crashlyticsService.setTaskManagerContext(
          userId: 'anonymous',
          version: '1.0.0',
          environment: 'production',
        );

        return const Right(null);
      },
    );
  }

  /// Enviar email de redefinição de senha
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    final result = await _authRepository.sendPasswordResetEmail(email: email);

    return result.fold(
      (failure) {
        _logAuthEvent('password_reset_failed', {
          'error_message': failure.message,
        });
        return Left(failure);
      },
      (_) {
        _logAuthEvent('password_reset_requested', {
          'email_domain': _getEmailDomain(email),
        });
        return const Right(null);
      },
    );
  }

  /// Atualizar perfil do usuário
  Future<Either<Failure, local_entities.UserEntity>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      // Obter usuário atual
      final currentUserResult = await _authRepository.currentUser.first;
      if (currentUserResult == null) {
        return const Left(AuthFailure('Usuário não logado'));
      }

      // Converter para entidade local e aplicar mudanças
      final updatedUser = local_entities.UserEntity(
        id: currentUserResult.id,
        name: displayName ?? currentUserResult.displayName,
        email: currentUserResult.email,
        avatarUrl: photoURL,
        createdAt: DateTime.now(), // Ajustar conforme necessário
        updatedAt: DateTime.now(),
      );

      // Usar o use case local para atualizar
      final result = await _updateProfile(UpdateProfileParams(user: updatedUser));
      
      return result.fold(
        (failure) {
          _logAuthEvent('profile_update_failed', {
            'error_type': failure.runtimeType.toString(),
            'error_message': failure.message,
          });

          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Profile update failed',
          );
          
          return Left(AuthFailure(failure.message));
        },
        (_) {
          _logAuthEvent('profile_updated', {
            'user_id': updatedUser.id,
            'has_display_name': displayName != null,
            'has_photo_url': photoURL != null,
          });

          return Right(updatedUser);
        },
      );
    } catch (e) {
      _crashlyticsService.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Profile update failed',
      );
      return Left(AuthFailure('Erro ao atualizar perfil: $e'));
    }
  }

  /// Deletar conta do usuário
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final currentUserData = await _getCurrentUserForAnalytics();
      
      _logAuthEvent('account_deletion_requested', currentUserData);
      
      // Usar o use case local para deletar conta
      final result = await _deleteAccount();
      
      return result.fold(
        (failure) {
          _logAuthEvent('account_deletion_failed', {
            'error_type': failure.runtimeType.toString(),
            'error_message': failure.message,
            ...currentUserData,
          });

          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Account deletion failed',
          );
          
          return Left(AuthFailure(failure.message));
        },
        (_) {
          _logAuthEvent('account_deleted', currentUserData);
          
          // Limpar contexto do Crashlytics
          _crashlyticsService.setTaskManagerContext(
            userId: 'anonymous',
            version: '1.0.0',
            environment: 'production',
          );
          
          return const Right(null);
        },
      );
    } catch (e) {
      _crashlyticsService.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Account deletion failed',
      );
      return Left(AuthFailure('Erro ao deletar conta: $e'));
    }
  }

  /// Helper para log de eventos de autenticação
  void _logAuthEvent(String eventName, Map<String, dynamic> parameters) {
    // Use analytics methods from TaskManagerAnalyticsService
    // For now, just log to console or use basic analytics
    // TODO: Implement custom event logging in analytics service
    switch (eventName) {
      case 'login_success':
        _analyticsService.logLogin(parameters['method'] as String);
        break;
      case 'registration_success':
        _analyticsService.logSignUp(parameters['method'] as String);
        break;
      case 'logout_success':
        _analyticsService.logLogout();
        break;
      default:
        // For other events, we can add them to the analytics service later
        break;
    }
  }

  /// Helper para obter dados do usuário atual para analytics
  Future<Map<String, dynamic>> _getCurrentUserForAnalytics() async {
    try {
      final isLoggedIn = await this.isLoggedIn;
      if (!isLoggedIn) {
        return {'user_status': 'not_logged_in'};
      }

      // Obter usuário atual do stream (primeira emissão)
      final user = await currentUser.first;
      if (user == null) {
        return {'user_status': 'no_user_data'};
      }

      return {
        'user_id': user.id,
        'has_display_name': user.displayName.isNotEmpty,
        'has_email': user.email.isNotEmpty,
        'is_anonymous': false, // Simplified since core UserEntity doesn't have isAnonymous
        'email_verified': user.isEmailVerified,
      };
    } catch (e) {
      return {'user_status': 'error_getting_data'};
    }
  }

  /// Helper para extrair domínio do email
  String _getEmailDomain(String email) {
    try {
      return email.split('@').last.toLowerCase();
    } catch (e) {
      return 'unknown';
    }
  }
}