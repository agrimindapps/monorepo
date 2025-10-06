import 'package:core/core.dart';

import '../entities/user_entity.dart' as local_user;
import '../repositories/auth_repository.dart';

/// Use case para login de usuário com validação e regras de negócio
/// 
/// Implementa UseCase que retorna a entidade do usuário em caso de sucesso
/// Inclui validações de email, senha e segurança
@lazySingleton
class LoginUseCase implements UseCase<local_user.UserEntity, LoginParams> {
  final AuthRepository repository;
  final FirebaseAnalyticsService _analyticsService;
  
  LoginUseCase(
    this.repository,
  ) : _analyticsService = FirebaseAnalyticsService();
  
  @override
  Future<Either<Failure, local_user.UserEntity>> call(LoginParams params) async {
    final startTime = DateTime.now();
    
    try {
      await _analyticsService.logEvent(
        'login_attempt',
        parameters: {
          'remember_me': params.rememberMe,
          'email_domain': params.email.split('@').last,
        },
      );
      final validation = _validateLoginData(params);
      if (validation != null) {
        await _analyticsService.logEvent(
          'login_validation_failed',
          parameters: {
            'error': validation,
            'email_domain': params.email.split('@').last,
          },
        );
        return Left(ValidationFailure(validation));
      }
      final normalizedEmail = params.email.trim().toLowerCase();
      final result = await repository.login(
        email: normalizedEmail,
        password: params.password,
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logAnalyticsAsync(result, duration, params.email);
      
      return result;
    } catch (e) {
      await _analyticsService.logEvent(
        'login_unexpected_error',
        parameters: {
          'error': e.toString(),
          'email_domain': params.email.split('@').last,
        },
      );
      rethrow;
    }
  }
  
  /// Valida os dados de login antes do processamento
  String? _validateLoginData(LoginParams params) {
    if (params.email.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(params.email.trim())) {
      return 'Formato de email inválido';
    }
    if (params.password.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (params.password.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }
  
  /// Log analytics async (fire and forget)
  void _logAnalyticsAsync(Either<Failure, local_user.UserEntity> result, int duration, String email) {
    result.fold(
      (failure) => _analyticsService.logEvent(
        'login_failed',
        parameters: {
          'error_type': failure.runtimeType.toString(),
          'duration_ms': duration,
          'email_domain': email.split('@').last,
        },
      ),
      (user) async {
        await _analyticsService.logEvent(
          'login_success',
          parameters: {
            'duration_ms': duration,
            'user_id': user.id,
            'email_domain': email.split('@').last,
          },
        );
        await _analyticsService.setUserId(user.id);
        await _analyticsService.setUserProperty('user_type', 'farmer');
        await _analyticsService.setUserProperty('app_version', 'agrihurbi_v1');
      },
    );
  }
}

/// Parâmetros para login de usuário
class LoginParams extends Equatable {
  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  /// Email do usuário
  final String email;
  
  /// Senha do usuário
  final String password;
  
  /// Se deve manter o usuário logado
  final bool rememberMe;
  
  @override
  List<Object> get props => [email, password, rememberMe];
}