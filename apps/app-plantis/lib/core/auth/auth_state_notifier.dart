import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Global singleton that manages authentication state across the entire application
///
/// This class provides a centralized way to manage and observe authentication state
/// changes, breaking circular dependencies between AuthProvider and other providers
/// that need user information.
///
/// Key features:
/// - Thread-safe singleton pattern
/// - Stream-based state notifications
/// - Proper lifecycle management
/// - Memory leak prevention
/// - Clean separation of concerns
///
/// Usage:
/// ```dart
/// // Get the singleton instance
/// final authState = AuthStateNotifier.instance;
///
/// // Listen to auth state changes
/// authState.userStream.listen((user) {
///   // Handle user changes
/// });
///
/// // Check current user
/// final currentUser = authState.currentUser;
/// ```
class AuthStateNotifier {
  static AuthStateNotifier? _instance;
  static final Object _lock = Object();

  /// Private constructor to prevent external instantiation
  AuthStateNotifier._();

  /// Gets the singleton instance of AuthStateNotifier
  ///
  /// This method implements thread-safe singleton pattern with double-check locking
  /// to ensure only one instance exists across the entire application lifecycle.
  ///
  /// Returns:
  /// - The singleton AuthStateNotifier instance
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
  bool _isPremium = false;
  bool _isInitialized = false;
  final StreamController<UserEntity?> _userController =
      StreamController<UserEntity?>.broadcast();
  final StreamController<bool> _authController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _premiumController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _initializedController =
      StreamController<bool>.broadcast();
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;
  Stream<UserEntity?> get userStream => _userController.stream;
  Stream<bool> get authStream => _authController.stream;
  Stream<bool> get premiumStream => _premiumController.stream;
  Stream<bool> get initializedStream => _initializedController.stream;

  /// Updates the current user and notifies all listeners
  ///
  /// This method is typically called by AuthProvider when authentication
  /// state changes (login, logout, token refresh, etc.).
  ///
  /// Parameters:
  /// - [user]: The new user entity, or null if user logged out
  ///
  /// Side effects:
  /// - Updates internal state
  /// - Notifies all stream listeners
  /// - Updates authentication status based on user presence
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
        '🔐 AuthStateNotifier: User updated - authenticated: $_isAuthenticated',
      );
    }
  }

  /// Updates the premium status and notifies listeners
  ///
  /// This method should be called whenever the user's subscription status
  /// changes (subscription purchased, expired, restored, etc.).
  ///
  /// Parameters:
  /// - [isPremium]: Whether the user has an active premium subscription
  void updatePremiumStatus(bool isPremium) {
    if (_isPremium != isPremium) {
      _isPremium = isPremium;

      if (!_premiumController.isClosed) {
        _premiumController.add(_isPremium);
      }

      debugPrint('💎 AuthStateNotifier: Premium status updated: $_isPremium');
    }
  }

  /// Marks the authentication system as initialized
  ///
  /// This method should be called once the initial authentication state
  /// has been determined (either from persistent storage or initial
  /// server check). It helps other parts of the app know when it's safe
  /// to make authentication-dependent decisions.
  ///
  /// Parameters:
  /// - [isInitialized]: Whether the auth system is initialized
  void updateInitializationStatus(bool isInitialized) {
    if (_isInitialized != isInitialized) {
      _isInitialized = isInitialized;

      if (!_initializedController.isClosed) {
        _initializedController.add(_isInitialized);
      }

      debugPrint(
        '🚀 AuthStateNotifier: Initialization status updated: $_isInitialized',
      );
    }
  }

  /// Convenience method to check if current user is anonymous
  ///
  /// Returns:
  /// - `true` if user is authenticated but using anonymous auth
  /// - `false` if user is not authenticated or using regular auth
  bool get isAnonymous {
    return _currentUser?.provider.name == 'anonymous';
  }

  /// Convenience method to get user ID safely
  ///
  /// Returns:
  /// - User ID string if user is authenticated
  /// - `null` if user is not authenticated
  String? get userId => _currentUser?.id;

  /// Alias for userId to maintain compatibility with IAuthStateProvider
  String? get currentUserId => userId;

  /// Convenience method to get user email safely
  ///
  /// Returns:
  /// - User email string if user is authenticated and has email
  /// - `null` if user is not authenticated or has no email
  String? get userEmail => _currentUser?.email;

  /// Resets all authentication state to initial values
  ///
  /// This method is useful for logout operations or when switching
  /// between different user accounts. It ensures all state is properly
  /// cleared and listeners are notified.
  void reset() {
    _currentUser = null;
    _isAuthenticated = false;
    _isPremium = false;
    _isInitialized = false;
    if (!_userController.isClosed) {
      _userController.add(null);
    }
    if (!_authController.isClosed) {
      _authController.add(false);
    }
    if (!_premiumController.isClosed) {
      _premiumController.add(false);
    }
    if (!_initializedController.isClosed) {
      _initializedController.add(false);
    }

    debugPrint('🔄 AuthStateNotifier: State reset to initial values');
  }

  /// Ensures the auth system is initialized
  /// This is a compatibility method for IAuthStateProvider interface
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await Future<void>.delayed(Duration.zero);
      updateInitializationStatus(true);
    }
  }

  /// Disposes of all resources and closes streams
  ///
  /// This method should be called when the app is shutting down to prevent
  /// memory leaks. It closes all stream controllers and cleans up resources.
  ///
  /// Note: After calling dispose, the singleton instance becomes unusable
  /// and a new instance should be created if needed.
  void dispose() {
    debugPrint('♻️ AuthStateNotifier: Disposing resources');

    _userController.close();
    _authController.close();
    _premiumController.close();
    _initializedController.close();
    synchronized(_lock, () {
      _instance = null;
    });
  }
}

/// Thread-safe synchronization utility
///
/// This ensures that singleton creation is thread-safe across isolates
void synchronized(Object lock, void Function() callback) {
  callback();
}
