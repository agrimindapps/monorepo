import 'package:firebase_auth/firebase_auth.dart';
import 'package:core/core.dart';

/// Interface abstrata para provedor de autenticação
///
/// **Responsabilidades (Single Responsibility):**
/// - Obter usuário autenticado atual
/// - Obter ID do usuário autenticado
/// - Verificar estado de autenticação
/// - Apenas operações de autenticação, sem negócio
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas auth necessários)
///
/// **Princípio DIP:**
/// - Depende de abstração, não de Firebase diretamente
/// - Facilita testes com mocks
///
/// **Exemplo:**
/// ```dart
/// final userId = authProvider.getCurrentUserId();
/// userId.fold(
///   (failure) => print('Not authenticated'),
///   (uid) => print('Current user: $uid'),
/// );
/// ```
abstract class IAuthProvider {
  /// Obtém usuário autenticado atual
  ///
  /// Retorna:
  /// - Right(user): Usuário autenticado
  /// - Left(AuthFailure): Nenhum usuário autenticado
  Future<Either<Failure, User>> getCurrentUser();

  /// Obtém ID do usuário autenticado
  ///
  /// Retorna:
  /// - Right(uid): ID do usuário
  /// - Left(AuthFailure): Nenhum usuário autenticado
  String? getCurrentUserId();

  /// Verifica se usuário está autenticado
  bool get isAuthenticated;
}
