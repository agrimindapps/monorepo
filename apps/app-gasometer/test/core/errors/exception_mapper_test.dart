import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/errors/exception_mapper.dart';
import 'package:gasometer/core/errors/failures.dart';

void main() {
  group('ExceptionMapper', () {
    group('Firebase Firestore exceptions', () {
      test('should map permission-denied to PermissionFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Insufficient permissions',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<PermissionFailure>());
        expect(failure.code, 'permission-denied');
        expect(failure.message, contains('permissão'));
      });

      test('should map unauthenticated to PermissionFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unauthenticated',
          message: 'User not authenticated',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<PermissionFailure>());
        expect(failure.code, 'unauthenticated');
      });

      test('should map unavailable to ConnectivityFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unavailable',
          message: 'Service unavailable',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
        expect(failure.code, 'unavailable');
        expect(failure.message, contains('indisponível'));
      });

      test('should map deadline-exceeded to ConnectivityFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'deadline-exceeded',
          message: 'Deadline exceeded',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
        expect(failure.code, 'deadline-exceeded');
      });

      test('should map not-found to NotFoundFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'not-found',
          message: 'Document not found',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<NotFoundFailure>());
        expect(failure.code, 'not-found');
        expect(failure.message, contains('não encontrados'));
      });

      test('should map already-exists to ValidationFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'already-exists',
          message: 'Document already exists',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'already-exists');
        expect(failure.message, contains('já existe'));
      });

      test('should map failed-precondition to FinancialConflictFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Transaction failed',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<FinancialConflictFailure>());
        expect(failure.code, 'failed-precondition');
        expect(failure.message, contains('Conflito'));
      });

      test('should map aborted to FinancialConflictFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'aborted',
          message: 'Transaction aborted',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<FinancialConflictFailure>());
        expect(failure.code, 'aborted');
      });

      test('should map resource-exhausted to StorageFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'resource-exhausted',
          message: 'Quota exceeded',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<StorageFailure>());
        expect(failure.code, 'resource-exhausted');
        expect((failure as StorageFailure).storageType, 'firebase');
        expect(failure.operation, 'write');
      });

      test('should map unknown Firebase code to FirebaseFailure', () {
        // Arrange
        final exception = FirebaseException(
          plugin: 'firestore',
          code: 'unknown-code',
          message: 'Unknown error',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<FirebaseFailure>());
        expect(failure.code, 'unknown-code');
      });
    });

    group('Firebase Auth exceptions', () {
      test('should map user-not-found to AuthFailure with user-friendly message', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<AuthFailure>());
        expect(failure.code, 'user-not-found');
        expect(failure.message, contains('Email ou senha incorretos'));
      });

      test('should map wrong-password to AuthFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<AuthFailure>());
        expect(failure.code, 'wrong-password');
        expect(failure.message, contains('Email ou senha incorretos'));
      });

      test('should map user-disabled to AuthFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'user-disabled',
          message: 'User account disabled',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<AuthFailure>());
        expect(failure.code, 'user-disabled');
        expect(failure.message, contains('Conta desabilitada'));
      });

      test('should map email-already-in-use to ValidationFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email is already in use',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'email-already-in-use');
        expect(failure.message, contains('já está em uso'));
      });

      test('should map weak-password to ValidationFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'weak-password',
          message: 'Password is too weak',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'weak-password');
        expect(failure.message, contains('muito fraca'));
      });

      test('should map invalid-email to ValidationFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email format',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'invalid-email');
        expect(failure.message, contains('Email inválido'));
      });

      test('should map network-request-failed to ConnectivityFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
        expect(failure.code, 'network-request-failed');
      });

      test('should map too-many-requests to ValidationFailure', () {
        // Arrange
        final exception = auth.FirebaseAuthException(
          code: 'too-many-requests',
          message: 'Too many attempts',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'too-many-requests');
        expect(failure.message, contains('Muitas tentativas'));
      });
    });

    group('Firebase Storage exceptions', () {
      test('should map object-not-found to NotFoundFailure', () {
        // Arrange
        final exception = storage.FirebaseException(
          plugin: 'storage',
          code: 'object-not-found',
          message: 'File not found',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<NotFoundFailure>());
        expect(failure.code, 'object-not-found');
        expect(failure.message, contains('não encontrada'));
      });

      test('should map unauthorized to PermissionFailure', () {
        // Arrange
        final exception = storage.FirebaseException(
          plugin: 'storage',
          code: 'unauthorized',
          message: 'Unauthorized access',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<PermissionFailure>());
        expect(failure.code, 'unauthorized');
      });

      test('should map retry-limit-exceeded to ConnectivityFailure', () {
        // Arrange
        final exception = storage.FirebaseException(
          plugin: 'storage',
          code: 'retry-limit-exceeded',
          message: 'Retry limit exceeded',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
        expect(failure.code, 'retry-limit-exceeded');
      });

      test('should map invalid-checksum to ImageOperationFailure', () {
        // Arrange
        final exception = storage.FirebaseException(
          plugin: 'storage',
          code: 'invalid-checksum',
          message: 'Checksum mismatch',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ImageOperationFailure>());
        expect(failure.code, 'invalid-checksum');
        expect((failure as ImageOperationFailure).operation, 'upload');
        expect(failure.message, contains('corrompida'));
      });

      test('should map canceled to ValidationFailure', () {
        // Arrange
        final exception = storage.FirebaseException(
          plugin: 'storage',
          code: 'canceled',
          message: 'Operation canceled',
        );

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'canceled');
      });
    });

    group('Network exceptions', () {
      test('should map SocketException string to ConnectivityFailure', () {
        // Arrange
        final exception = Exception('SocketException: Connection refused');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
        expect(failure.message, contains('internet'));
      });

      test('should map NetworkException string to ConnectivityFailure', () {
        // Arrange
        final exception = Exception('NetworkException: Failed host lookup');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
      });

      test('should map timeout error to ConnectivityFailure', () {
        // Arrange
        final exception = Exception('TimeoutException: Connection timeout');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ConnectivityFailure>());
      });
    });

    group('Parsing exceptions', () {
      test('should map FormatException to ParseFailure', () {
        // Arrange
        final exception = FormatException('Invalid format', 'test data');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ParseFailure>());
        expect(failure.code, 'PARSE_ERROR');
        expect(failure.message, contains('processar dados'));
      });
    });

    group('State and Argument exceptions', () {
      test('should map StateError to ValidationFailure', () {
        // Arrange
        final exception = StateError('Invalid state');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'STATE_ERROR');
        expect(failure.message, 'Invalid state');
      });

      test('should map ArgumentError to ValidationFailure', () {
        // Arrange
        final exception = ArgumentError('Invalid argument');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'ARGUMENT_ERROR');
        expect(failure.message, 'Invalid argument');
      });
    });

    group('Unknown exceptions', () {
      test('should map unknown exception to UnknownFailure', () {
        // Arrange
        final exception = Exception('Something went wrong');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<UnknownFailure>());
        expect(failure.code, 'UNKNOWN_ERROR');
        expect(failure.message, contains('Erro inesperado'));
      });

      test('should include exception type in UnknownFailure details', () {
        // Arrange
        final exception = Exception('Custom error');

        // Act
        final failure = ExceptionMapper.mapException(exception);

        // Assert
        expect(failure, isA<UnknownFailure>());
        expect(failure.details, isNotNull);
        expect(failure.details['exception_type'], contains('Exception'));
      });
    });

    group('Helper factory methods', () {
      test('createFinancialIntegrityFailure should create proper failure', () {
        // Act
        final failure = ExceptionMapper.createFinancialIntegrityFailure(
          message: 'Cost cannot be negative',
          fieldName: 'cost',
          invalidValue: -10.0,
          constraint: 'cost >= 0',
        );

        // Assert
        expect(failure, isA<FinancialIntegrityFailure>());
        expect(failure.message, 'Cost cannot be negative');
        expect(failure.fieldName, 'cost');
        expect(failure.invalidValue, -10.0);
        expect(failure.constraint, 'cost >= 0');
      });

      test('createFinancialConflictFailure should create proper failure', () {
        // Act
        final failure = ExceptionMapper.createFinancialConflictFailure(
          message: 'Data conflict detected',
          entityType: 'fuel_supply',
          entityId: 'fuel-123',
          localData: {'cost': 100.0},
          remoteData: {'cost': 120.0},
        );

        // Assert
        expect(failure, isA<FinancialConflictFailure>());
        expect(failure.message, 'Data conflict detected');
        expect(failure.entityType, 'fuel_supply');
        expect(failure.entityId, 'fuel-123');
        expect(failure.localData, isNotNull);
        expect(failure.remoteData, isNotNull);
      });

      test('createIdReconciliationFailure should create proper failure', () {
        // Act
        final failure = ExceptionMapper.createIdReconciliationFailure(
          message: 'Failed to reconcile ID',
          localId: 'local-123',
          entityType: 'vehicle',
          remoteId: 'remote-456',
        );

        // Assert
        expect(failure, isA<IdReconciliationFailure>());
        expect(failure.message, 'Failed to reconcile ID');
        expect(failure.localId, 'local-123');
        expect(failure.remoteId, 'remote-456');
        expect(failure.entityType, 'vehicle');
      });
    });

    group('Stack trace preservation', () {
      test('should preserve stack trace when provided', () {
        // Arrange
        final exception = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        final failure = ExceptionMapper.mapException(exception, stackTrace);

        // Assert
        expect(failure, isA<UnknownFailure>());
        expect(failure.details, isNotNull);
        expect(failure.details['stack_trace'], isNotNull);
      });
    });
  });
}
