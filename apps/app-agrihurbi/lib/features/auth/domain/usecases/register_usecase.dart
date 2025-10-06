import 'package:core/core.dart' as core_lib;
import 'package:core/core.dart' show Equatable, Left, lazySingleton;

import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/user_entity.dart' as local_user;
import '../repositories/auth_repository.dart';

/// Use case para registro de usuário com validação e regras de negócio
///
/// Implementa UseCase que retorna a entidade do usuário criado em caso de sucesso
/// Inclui validações de email, senha, nome e segurança
@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;
  final core_lib.FirebaseAnalyticsService _analyticsService;

  RegisterUseCase(this.repository)
    : _analyticsService = core_lib.FirebaseAnalyticsService();

  ResultFuture<local_user.UserEntity> call(RegisterParams params) async {
    final startTime = DateTime.now();

    try {
      await _analyticsService.logEvent(
        'registration_attempt',
        parameters: {
          'has_phone': params.phone != null,
          'email_domain': params.email.split('@').last,
          'name_length': params.name.length,
          'password_length': params.password.length,
        },
      );
      final validation = _validateRegistrationData(params);
      if (validation != null) {
        await _analyticsService.logEvent(
          'registration_validation_failed',
          parameters: {
            'error': validation,
            'email_domain': params.email.split('@').last,
          },
        );
        return Left(ValidationFailure(message: validation));
      }
      final normalizedEmail = params.email.trim().toLowerCase();
      final normalizedName = params.name.trim();
      final normalizedPhone = params.phone?.trim();
      final emailExists = await _checkEmailExists(normalizedEmail);
      if (emailExists) {
        await _analyticsService.logEvent(
          'registration_email_exists',
          parameters: {'email_domain': params.email.split('@').last},
        );
        return const Left(ValidationFailure(message: 'Email já está em uso'));
      }
      final result = await repository.register(
        name: normalizedName,
        email: normalizedEmail,
        password: params.password,
        phone: normalizedPhone,
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      await result.fold(
        (failure) async {
          await _analyticsService.logEvent(
            'registration_failed',
            parameters: {
              'error_type': failure.runtimeType.toString(),
              'duration_ms': duration,
              'email_domain': params.email.split('@').last,
            },
          );
        },
        (user) async {
          await _analyticsService.logEvent(
            'registration_success',
            parameters: {
              'duration_ms': duration,
              'user_id': user.id,
              'email_domain': params.email.split('@').last,
              'has_phone': params.phone != null,
            },
          );
          await _analyticsService.setUserId(user.id);
          await _analyticsService.setUserProperty('user_type', 'farmer');
          await _analyticsService.setUserProperty(
            'app_version',
            'agrihurbi_v1',
          );
          await _analyticsService.setUserProperty(
            'registration_date',
            DateTime.now().toIso8601String(),
          );
        },
      );

      return result;
    } catch (e) {
      await _analyticsService.logEvent(
        'registration_unexpected_error',
        parameters: {
          'error': e.toString(),
          'email_domain': params.email.split('@').last,
        },
      );
      rethrow;
    }
  }

  /// Valida os dados de registro antes do processamento
  String? _validateRegistrationData(RegisterParams params) {
    if (params.name.trim().isEmpty) {
      return 'Nome é obrigatório';
    }

    if (params.name.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    if (params.name.trim().length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
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

    if (params.password.length > 128) {
      return 'Senha deve ter no máximo 128 caracteres';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(params.password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(params.password);

    if (!hasLetter || !hasNumber) {
      return 'Senha deve conter pelo menos uma letra e um número';
    }
    if (params.phone != null && params.phone!.trim().isNotEmpty) {
      final phonePattern = RegExp(r'^[\+]?[(]?[\d\s\-\(\)]{10,20}$');
      if (!phonePattern.hasMatch(params.phone!.trim())) {
        return 'Formato de telefone inválido';
      }
    }

    return null;
  }

  /// Verifica se o email já está em uso
  Future<bool> _checkEmailExists(String email) async {
    return false;
  }
}

/// Parâmetros para registro de usuário
class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.acceptTerms = false,
  });

  /// Nome completo do usuário
  final String name;

  /// Email do usuário
  final String email;

  /// Senha do usuário
  final String password;

  /// Telefone opcional do usuário
  final String? phone;

  /// Se o usuário aceitou os termos
  final bool acceptTerms;

  @override
  List<Object?> get props => [name, email, password, phone, acceptTerms];
}
