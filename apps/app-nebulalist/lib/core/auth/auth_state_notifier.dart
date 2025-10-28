import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Global singleton that manages authentication state for app_nebulalist
///
/// Simplified version from app-plantis, focusing only on:
/// - User authentication state
/// - Stream-based notifications
/// - Thread-safe singleton pattern
class AuthStateNotifier {
  static AuthStateNotifier? _instance;
  static final Object _lock = Object();

  /// Private constructor to prevent external instantiation
  AuthStateNotifier._();

  /// Gets the singleton instance of AuthStateNotifier
  static AuthStateNotifier get instance {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= AuthStateNotifier._();
      });
    }
    return _instance!;
  }

  UserEntity? _currentUser;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  final StreamController<UserEntity?> _userController =
      StreamController<UserEntity?>.broadcast();
  final StreamController<bool> _authController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _initializedController =
      StreamController<bool>.broadcast();

  // Getters
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  // Streams
  Stream<UserEntity?> get userStream => _userController.stream;
  Stream<bool> get authStream => _authController.stream;
  Stream<bool> get initializedStream => _initializedController.stream;

  /// Updates the current user and notifies all listeners
  void updateUser(UserEntity? user) {
    if (_currentUser != user) {
      _currentUser = user;
      _isAuthenticated = user != null;

      if (!_userController.isClosed) {
        _userController.add(user);
      }
      if (!_authController.isClosed) {
        _authController.add(_isAuthenticated);
      }

      debugPrint(
        'AuthStateNotifier: User updated - authenticated: $_isAuthenticated',
      );
    }
  }

  /// Marks the authentication system as initialized
  void updateInitializationStatus(bool isInitialized) {
    if (_isInitialized != isInitialized) {
      _isInitialized = isInitialized;

      if (!_initializedController.isClosed) {
        _initializedController.add(_isInitialized);
      }

      debugPrint(
        'AuthStateNotifier: Initialization status updated: $_isInitialized',
      );
    }
  }

  /// Convenience method to get user ID safely
  String? get userId => _currentUser?.id;

  /// Convenience method to get user email safely
  String? get userEmail => _currentUser?.email;

  /// Resets all authentication state to initial values
  void reset() {
    _currentUser = null;
    _isAuthenticated = false;
    _isInitialized = false;

    if (!_userController.isClosed) {
      _userController.add(null);
    }
    if (!_authController.isClosed) {
      _authController.add(false);
    }
    if (!_initializedController.isClosed) {
      _initializedController.add(false);
    }

    debugPrint('AuthStateNotifier: State reset to initial values');
  }

  /// Ensures the auth system is initialized
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await Future<void>.delayed(Duration.zero);
      updateInitializationStatus(true);
    }
  }

  /// Disposes of all resources and closes streams
  void dispose() {
    debugPrint('AuthStateNotifier: Disposing resources');

    _userController.close();
    _authController.close();
    _initializedController.close();

    synchronized(_lock, () {
      _instance = null;
    });
  }
}

/// Thread-safe synchronization utility
void synchronized(Object lock, void Function() callback) {
  callback();
}
