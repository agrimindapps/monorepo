import 'package:core/core.dart' hide Column;

import '../../auth/auth_state_notifier.dart';
import '../../interfaces/i_auth_state_provider.dart';

/// Adapter para o AuthStateNotifier implementar IAuthStateProvider
/// Resolve violação DIP mantendo compatibilidade com código existente
class AuthStateProviderAdapter implements IAuthStateProvider {
  final AuthStateNotifier _authStateNotifier;

  AuthStateProviderAdapter(this._authStateNotifier);

  /// Factory para usar o singleton existente
  factory AuthStateProviderAdapter.instance() {
    return AuthStateProviderAdapter(AuthStateNotifier.instance);
  }

  @override
  UserEntity? get currentUser => _authStateNotifier.currentUser;

  @override
  Stream<UserEntity?> get userStream => _authStateNotifier.userStream;

  @override
  bool get isAuthenticated => _authStateNotifier.isAuthenticated;

  @override
  bool get isAnonymous => _authStateNotifier.isAnonymous;

  @override
  bool get isInitialized => _authStateNotifier.isInitialized;

  @override
  String? get currentUserId => _authStateNotifier.currentUserId;

  @override
  Future<void> ensureInitialized() async {
    return _authStateNotifier.ensureInitialized();
  }
}
