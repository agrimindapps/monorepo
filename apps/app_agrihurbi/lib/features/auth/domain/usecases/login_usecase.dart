import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../entities/user_entity.dart' as local_user;
import '../repositories/auth_repository.dart';

/// Use case para login de usuário com validação e regras de negócio
/// 
/// Implementa UseCase que retorna a entidade do usuário em caso de sucesso
/// Inclui validações de email, senha e segurança
@lazySingleton
class LoginUseCase implements UseCase<local_user.UserEntity, LoginParams> {
  final AuthRepository repository;
  
  const LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, local_user.UserEntity>> call(LoginParams params) async {
    // Validação dos parâmetros de entrada
    final validation = _validateLoginData(params);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    
    // Normalizar email
    final normalizedEmail = params.email.trim().toLowerCase();
    
    // Executar login no repository
    return await repository.login(
      email: normalizedEmail,
      password: params.password,
    );
  }
  
  /// Valida os dados de login antes do processamento
  String? _validateLoginData(LoginParams params) {
    // Validar email
    if (params.email.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(params.email.trim())) {
      return 'Formato de email inválido';
    }
    
    // Validar senha
    if (params.password.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (params.password.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
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