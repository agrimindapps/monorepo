import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_state_notifier.dart';

/// Provider for the AuthStateNotifier singleton
final authStateNotifierProvider = Provider<AuthStateNotifier>((ref) {
  return AuthStateNotifier.instance;
});
