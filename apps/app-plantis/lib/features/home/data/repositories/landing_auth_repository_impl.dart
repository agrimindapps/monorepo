import 'package:core/core.dart' hide Column;

import '../../domain/entities/auth_status.dart';
import '../../domain/repositories/auth_status_repository.dart';

/// Implementation of [LandingAuthRepository]
///
/// Acts as a bridge between the Home/Landing feature and the core authentication system.
/// This abstraction allows the landing page to remain independent of core implementation details.
class LandingAuthRepositoryImpl implements LandingAuthRepository {
  final IAuthRepository _coreAuthRepository;

  const LandingAuthRepositoryImpl({required IAuthRepository coreAuthRepository})
    : _coreAuthRepository = coreAuthRepository;

  @override
  Future<Either<Failure, LandingAuthStatus>> checkAuthStatus() async {
    try {
      // Check if user is logged in
      final isLogged = await _coreAuthRepository.isLoggedIn;

      if (!isLogged) {
        return const Right(LandingAuthStatus.unauthenticated());
      }

      // Get current user stream - take first value
      final user = await _coreAuthRepository.currentUser.first;

      if (user == null) {
        return const Right(LandingAuthStatus.unauthenticated());
      }

      return Right(LandingAuthStatus.authenticated(user.id));
    } catch (e) {
      return Left(
        AuthenticationFailure(
          'Erro ao verificar status de autenticação: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<LandingAuthStatus> watchAuthStatus() {
    try {
      // Watch auth state changes from core
      return _coreAuthRepository.currentUser.map((user) {
        if (user == null) {
          return const LandingAuthStatus.unauthenticated();
        }
        return LandingAuthStatus.authenticated(user.id);
      });
    } catch (e) {
      // Return error stream as unauthenticated
      return Stream.value(const LandingAuthStatus.unauthenticated());
    }
  }
}
