import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../entities/user_entity.dart' hide UserEntity;
import '../entities/user_entity.dart' as local_user;
import '../repositories/auth_repository.dart';

/// Use case para registro de usuário com validação e regras de negócio
/// 
/// Implementa UseCase que retorna a entidade do usuário criado em caso de sucesso
/// Inclui validações de email, senha, nome e segurança
@lazySingleton
class RegisterUseCase implements UseCase<local_user.UserEntity, RegisterParams> {
  final AuthRepository repository;
  
  const RegisterUseCase(this.repository);
  
  @override
  Future<Either<Failure, local_user.UserEntity>> call(RegisterParams params) async {
    // Validação dos parâmetros de entrada
    final validation = _validateRegistrationData(params);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    
    // Normalizar dados
    final normalizedEmail = params.email.trim().toLowerCase();
    final normalizedName = params.name.trim();
    final normalizedPhone = params.phone?.trim();
    
    // Validar se email já existe
    final emailExists = await _checkEmailExists(normalizedEmail);
    if (emailExists) {
      return Left(ValidationFailure('Email já está em uso'));
    }
    
    // Executar registro no repository
    return await repository.register(
      name: normalizedName,
      email: normalizedEmail,
      password: params.password,
      phone: normalizedPhone,
    );
  }
  
  /// Valida os dados de registro antes do processamento
  String? _validateRegistrationData(RegisterParams params) {
    // Validar nome
    if (params.name.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (params.name.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (params.name.trim().length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
    
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
    
    if (params.password.length > 128) {
      return 'Senha deve ter no máximo 128 caracteres';
    }
    
    // Validar senha complexidade
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(params.password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(params.password);
    
    if (!hasLetter || !hasNumber) {
      return 'Senha deve conter pelo menos uma letra e um número';
    }
    
    // Validar telefone se fornecido
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
    // Esta verificação será implementada quando o repository estiver completo
    // Por ora, retornamos false (email não existe)
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