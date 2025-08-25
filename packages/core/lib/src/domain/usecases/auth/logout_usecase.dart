import 'package:dartz/dartz.dart';

import '../../../shared/utils/failure.dart';
import '../../repositories/i_analytics_repository.dart';
import '../../repositories/i_auth_repository.dart';
import '../base_usecase.dart';

/// Use case para fazer logout do usuário atual
class LogoutUseCase implements NoParamsUseCase<void> {
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analyticsRepository;

  LogoutUseCase(this._authRepository, this._analyticsRepository);

  @override
  Future<Either<Failure, void>> call() async {
    // Fazer logout
    final logoutResult = await _authRepository.signOut();

    // Log analytics independentemente do resultado
    await _analyticsRepository.logLogout();

    return logoutResult;
  }
}