import 'dart:async';
import 'package:core/core.dart';
import '../../core/di/injection_container.dart' as di;

/// Wrapper para o serviço de autenticação Firebase Auth do core
/// Adiciona funcionalidades específicas do Task Manager
class TaskManagerAuthService {
  final IAuthRepository _authRepository;
  late final TaskManagerAnalyticsService _analyticsService;
  late final TaskManagerCrashlyticsService _crashlyticsService;

  TaskManagerAuthService({
    required IAuthRepository authRepository,
  }) : _authRepository = authRepository {
    _analyticsService = di.sl<TaskManagerAnalyticsService>();
    _crashlyticsService = di.sl<TaskManagerCrashlyticsService>();
  }

  /// Stream do usuário atual
  Stream<UserEntity?> get currentUser => _authRepository.currentUser;

  /// Verifica se o usuário está logado
  Future<bool> get isLoggedIn => _authRepository.isLoggedIn;

  /// Login com email e senha
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
          failure,
          null,
          reason: 'Login failed with email/password',
        );

        return Left(failure);
      },
      (user) {
        // Log de sucesso
        _logAuthEvent('login_success', {
          'method': 'email',
          'user_id': user.id,
          'has_display_name': user.name?.isNotEmpty == true,
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
          failure,
          null,
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
          failure,
          null,
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
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      // TODO: Implementar updateProfile no core repository se necessário
      // Por enquanto, vamos retornar erro não implementado
      return const Left(AuthFailure('Atualização de perfil não implementada'));
    } catch (e) {
      _crashlyticsService.recordError(
        e,
        null,
        reason: 'Profile update failed',
      );
      return Left(AuthFailure('Erro ao atualizar perfil: $e'));
    }
  }

  /// Deletar conta do usuário
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final currentUserData = await _getCurrentUserForAnalytics();
      
      // TODO: Implementar deleteAccount no core repository se necessário
      // Por enquanto, vamos retornar erro não implementado
      
      _logAuthEvent('account_deletion_requested', currentUserData);
      
      return const Left(AuthFailure('Exclusão de conta não implementada'));
    } catch (e) {
      _crashlyticsService.recordError(
        e,
        null,
        reason: 'Account deletion failed',
      );
      return Left(AuthFailure('Erro ao deletar conta: $e'));
    }
  }

  /// Helper para log de eventos de autenticação
  void _logAuthEvent(String eventName, Map<String, dynamic> parameters) {
    _analyticsService.logEvent(eventName, parameters: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'app_section': 'auth',
      ...parameters,
    });
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
        'has_display_name': user.name?.isNotEmpty == true,
        'has_email': user.email?.isNotEmpty == true,
        'is_anonymous': user.isAnonymous,
        'email_verified': user.emailVerified,
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