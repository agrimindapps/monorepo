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
      final authResult = await super.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _recordAuthResult(email, authResult);

      return authResult;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'L EnhancedFirebaseAuthService: signInWithEmailAndPassword error: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }
      await _securityService.recordFailedLoginAttempt(email);
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
      final sanitizedDisplayName = _securityService.sanitizeInput(displayName);
      final sanitizedEmail = _securityService.sanitizeInput(email);
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
      if (!_securityService.isInputSafe(currentPassword) ||
          !_securityService.isInputSafe(newPassword)) {
        return const Left(AuthFailure('Invalid input detected'));
      }
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
      final currentUserResult = await getCurrentUser();
      String? userEmail;

      currentUserResult.fold(
        (failure) => userEmail = null,
        (user) => userEmail = user?.email,
      );
      final result = await super.signOut();
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

  Future<Either<Failure, void>> _performSecurityChecks(
    String email,
    String password, {
    required bool isSignIn,
  }) async {
    try {
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
  FirebaseAuth get firebaseAuth => _firebaseAuth;
  SecurityService get securityService => _securityService;
}
