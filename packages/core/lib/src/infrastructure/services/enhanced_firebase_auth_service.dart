import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart' as core_entities;
import '../../shared/utils/failure.dart';
import 'firebase_auth_service.dart';
import 'security_service.dart';

/// Enhanced Firebase Auth Service with integrated security features
/// Extends the basic FirebaseAuthService with OWASP security protections
class EnhancedFirebaseAuthService extends FirebaseAuthService {
  final SecurityService _securityService;
  final FirebaseAuth _firebaseAuth;

  EnhancedFirebaseAuthService({
    SecurityService? securityService,
    super.firebaseAuth,
  }) : _securityService = securityService ?? SecurityService.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Pre-authentication security checks
      final securityResult = await _performSecurityChecks(
        email,
        password,
        isSignIn: true,
      );
      if (securityResult.isLeft()) {
        return Left(
          securityResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }

      // Proceed with authentication using parent implementation
      final authResult = await super.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Post-authentication security recording
      await _recordAuthResult(email, authResult);

      return authResult;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'L EnhancedFirebaseAuthService: signInWithEmailAndPassword error: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }

      // Record failed attempt for any exception
      await _securityService.recordFailedLoginAttempt(email);

      // Return appropriate failure
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Pre-registration security checks
      final securityResult = await _performSecurityChecks(
        email,
        password,
        isSignIn: false,
      );
      if (securityResult.isLeft()) {
        return Left(
          securityResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }

      // Enhanced password validation for registration
      final passwordValidation = _securityService.validatePasswordStrength(
        password,
      );
      if (!passwordValidation.isValid) {
        return Left(
          AuthFailure(
            'Password security requirements not met: ${passwordValidation.issues.join(', ')}',
          ),
        );
      }

      // Input sanitization for display name
      final sanitizedDisplayName = _securityService.sanitizeInput(displayName);
      final sanitizedEmail = _securityService.sanitizeInput(email);

      // Proceed with registration using parent implementation
      return super.signUpWithEmailAndPassword(
        email: sanitizedEmail,
        password: password, // Don't sanitize password
        displayName: sanitizedDisplayName,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'L EnhancedFirebaseAuthService: signUpWithEmailAndPassword error: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }

      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validate new password strength
      final passwordValidation = _securityService.validatePasswordStrength(
        newPassword,
      );
      if (!passwordValidation.isValid) {
        return Left(
          AuthFailure(
            'New password security requirements not met: ${passwordValidation.issues.join(', ')}',
          ),
        );
      }

      // Input safety check
      if (!_securityService.isInputSafe(currentPassword) ||
          !_securityService.isInputSafe(newPassword)) {
        return const Left(AuthFailure('Invalid input detected'));
      }

      // Proceed with password update using parent implementation
      return super.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('L EnhancedFirebaseAuthService: updatePassword error: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Get current user email before signing out for security cleanup
      final currentUserResult = await getCurrentUser();
      String? userEmail;

      currentUserResult.fold(
        (failure) => userEmail = null,
        (user) => userEmail = user?.email,
      );

      // Proceed with sign out using parent implementation
      final result = await super.signOut();

      // Clear security data for user
      if (userEmail != null) {
        await _securityService.clearUserSecurityData(userEmail!);
      }

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('L EnhancedFirebaseAuthService: signOut error: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      return Left(AuthFailure(e.toString()));
    }
  }

  // Security-specific methods

  /// Get security status report for a user
  Future<Either<Failure, SecurityStatusReport>> getSecurityStatus(
    String userIdentifier,
  ) async {
    try {
      final report = await _securityService.getSecurityStatus(userIdentifier);
      return Right(report);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('L Error getting security status: $e');
      }
      return Left(AuthFailure('Error getting security status: $e'));
    }
  }

  /// Check if account is locked for a user
  Future<Either<Failure, bool>> isAccountLocked(String userIdentifier) async {
    try {
      final isLocked = await _securityService.isAccountLockedOut(
        userIdentifier,
      );
      return Right(isLocked);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('L Error checking account lock status: $e');
      }
      return Left(AuthFailure('Error checking account lock status: $e'));
    }
  }

  /// Get remaining lockout time
  Future<Either<Failure, Duration?>> getRemainingLockoutTime(
    String userIdentifier,
  ) async {
    try {
      final remainingTime = await _securityService.getRemainingLockoutTime(
        userIdentifier,
      );
      return Right(remainingTime);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('L Error getting lockout time: $e');
      }
      return Left(AuthFailure('Error getting lockout time: $e'));
    }
  }

  /// Validate password strength
  SecurityValidationResult validatePassword(String password) {
    return _securityService.validatePasswordStrength(password);
  }

  /// Check if input is safe
  bool isInputSafe(String input) {
    return _securityService.isInputSafe(input);
  }

  /// Sanitize input
  String sanitizeInput(String input) {
    return _securityService.sanitizeInput(input);
  }

  // Private security methods

  Future<Either<Failure, void>> _performSecurityChecks(
    String email,
    String password, {
    required bool isSignIn,
  }) async {
    try {
      // Account lockout check
      final isLocked = await _securityService.isAccountLockedOut(email);
      if (isLocked) {
        final remainingTime = await _securityService.getRemainingLockoutTime(
          email,
        );
        final minutes = remainingTime?.inMinutes ?? 0;
        return Left(
          AuthFailure(
            'Account temporarily locked due to too many failed attempts. '
            'Try again in $minutes minutes.',
          ),
        );
      }

      // Rate limiting check
      final endpoint = isSignIn ? 'login' : 'register';
      final isRateLimited = await _securityService.isRateLimited(
        endpoint,
        email,
      );
      if (isRateLimited) {
        return const Left(
          AuthFailure(
            'Too many requests. Please wait before trying again.',
          ),
        );
      }

      // Input validation
      if (!_securityService.isInputSafe(email) ||
          !_securityService.isInputSafe(password)) {
        return const Left(AuthFailure('Invalid input detected'));
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('L Error performing security checks: $e');
      }
      return Left(AuthFailure('Security check failed: $e'));
    }
  }

  Future<void> _recordAuthResult(
    String email,
    Either<Failure, core_entities.UserEntity> result,
  ) async {
    try {
      result.fold(
        (failure) => _securityService.recordFailedLoginAttempt(email),
        (user) => _securityService.recordSuccessfulLogin(email),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('L Error recording auth result: $e');
      }
    }
  }

  // Utility method to get current user safely
  Future<Either<Failure, core_entities.UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Right(null);
      }

      return Right(
        core_entities.UserEntity(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          isEmailVerified: user.emailVerified,
        ),
      );
    } catch (e) {
      return Left(AuthFailure('Error getting current user: $e'));
    }
  }

  // Getter for access to firebase instance (for compatibility)
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  // Getter for access to security service
  SecurityService get securityService => _securityService;
}
