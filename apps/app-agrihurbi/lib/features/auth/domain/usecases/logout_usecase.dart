import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Use case para logout de usuário com limpeza de sessão e segurança
/// 
/// Implementa UseCase que não retorna dados, apenas confirmação de sucesso
/// Inclui limpeza de cache, sessões e dados sensíveis
@lazySingleton
class LogoutUseCase implements UseCase<void, LogoutParams> {
  final AuthRepository repository;
  
  const LogoutUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(LogoutParams params) async {
    // Executar logout no repository
    final result = await repository.logout();
    
    return result.fold(
      (failure) => Left(failure),
      (success) {
        // Log adicional se necessário
        if (params.logAnalytics) {
          _logLogoutEvent();
        }
        
        return const Right(null);
      },
    );
  }
  
  /// Log do evento de logout para analytics
  void _logLogoutEvent() {
    // Implementar integração com Firebase Analytics ou similar
    // Por ora, apenas um placeholder
  }
}

/// Parâmetros para logout de usuário
class LogoutParams extends Equatable {
  const LogoutParams({
    this.clearAllData = true,
    this.logAnalytics = true,
  });

  /// Se deve limpar todos os dados locais
  final bool clearAllData;
  
  /// Se deve registrar o evento nos analytics
  final bool logAnalytics;
  
  @override
  List<Object> get props => [clearAllData, logAnalytics];
}