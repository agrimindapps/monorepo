import 'package:core/core.dart' hide Column;

/// Interface para abstrair o AuthStateNotifier
/// Resolve violação DIP - dependência de implementação concreta
abstract class IAuthStateProvider {
  /// Usuário atualmente autenticado
  UserEntity? get currentUser;

  /// Stream de mudanças no usuário
  Stream<UserEntity?> get userStream;

  /// Se o usuário está autenticado
  bool get isAuthenticated;

  /// Se o usuário é anônimo
  bool get isAnonymous;

  /// Se o sistema de auth está inicializado
  bool get isInitialized;

  /// ID do usuário atual (null se não autenticado)
  String? get currentUserId;

  /// Aguarda a inicialização do sistema de auth
  Future<void> ensureInitialized();
}
