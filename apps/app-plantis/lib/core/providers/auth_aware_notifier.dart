import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_state_notifier.dart';

/// Base class for notifiers that need to be aware of authentication state changes
/// Provides common authentication handling logic to avoid code duplication
abstract class AuthAwareNotifier<T> extends AsyncNotifier<T> {
  late final AuthStateNotifier _authStateNotifier;
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  FutureOr<T> build() {
    _authStateNotifier = AuthStateNotifier.instance;
    _initializeAuthListener();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return buildInitialState();
  }

  /// Subclasses must implement this to provide their initial state
  T buildInitialState();

  /// Called when user authentication state becomes stable (user logged in)
  void onUserAuthenticated(UserEntity user);

  /// Called when user logs out or authentication becomes invalid
  void onUserLoggedOut();

  /// Initializes the authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint(
        '🔐 ${runtimeType.toString()}: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}',
      );

      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint(
          '✅ ${runtimeType.toString()}: Auth is stable, user authenticated',
        );
        onUserAuthenticated(user);
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint(
          '🔄 ${runtimeType.toString()}: No user but auth initialized - user logged out',
        );
        onUserLoggedOut();
      }
    });
  }

  /// Validates if the current user has access to a resource
  bool validateUserAccess({String? resourceUserId}) {
    final currentUser = _authStateNotifier.currentUser;
    if (currentUser == null) {
      debugPrint(
        '🚫 ${runtimeType.toString()}: Access denied - No authenticated user',
      );
      return false;
    }

    if (resourceUserId != null && currentUser.id != resourceUserId) {
      debugPrint(
        '🚫 ${runtimeType.toString()}: Access denied - User does not own resource',
      );
      return false;
    }

    return true;
  }

  /// Gets the current authenticated user
  UserEntity? get currentUser => _authStateNotifier.currentUser;

  /// Checks if authentication is initialized
  bool get isAuthInitialized => _authStateNotifier.isInitialized;
}
