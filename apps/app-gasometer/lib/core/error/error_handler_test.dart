import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/base_provider.dart';
import 'app_error.dart';
import 'error_handler.dart';
import 'error_logger.dart';

/// Test utility class for error handling system
/// Use this to validate error handling scenarios during development
class ErrorHandlerTestSuite {
  final ErrorHandler _errorHandler;
  final ErrorLogger _logger;

  ErrorHandlerTestSuite()
      : _errorHandler = ErrorHandler(ErrorLogger()),
        _logger = ErrorLogger();

  /// Test all error scenarios
  Future<void> runAllTests() async {
    debugPrint('🧪 Starting Error Handler Test Suite...');
    
    await _testNetworkErrors();
    await _testServerErrors();
    await _testValidationErrors();
    await _testRetryMechanisms();
    await _testResultPattern();
    await _testLoggingSystem();
    
    debugPrint('✅ Error Handler Test Suite completed');
  }

  /// Test network error scenarios
  Future<void> _testNetworkErrors() async {
    debugPrint('Testing Network Errors...');

    // Test timeout error
    final timeoutResult = await _errorHandler.execute(
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        throw TimeoutException('Operation timed out');
      },
      operationName: 'test_timeout',
      policy: RetryPolicy.noRetry,
    );

    assert(!timeoutResult.isSuccess);
    assert(timeoutResult.error is TimeoutError);
    debugPrint('✅ Timeout error test passed');

    // Test network error with retry
    int attemptCount = 0;
    final networkResult = await _errorHandler.execute(
      () async {
        attemptCount++;
        if (attemptCount < 3) {
          throw Exception('Network connection failed');
        }
        return 'Success after $attemptCount attempts';
      },
      operationName: 'test_network_retry',
      policy: RetryPolicy.network,
    );

    assert(networkResult.isSuccess);
    assert(attemptCount == 3);
    debugPrint('✅ Network retry test passed');
  }

  /// Test server error scenarios
  Future<void> _testServerErrors() async {
    debugPrint('Testing Server Errors...');

    // Test 500 server error
    final serverResult = await _errorHandler.execute(
      () async {
        throw Exception('Internal server error (500)');
      },
      operationName: 'test_server_error',
      policy: RetryPolicy.noRetry,
    );

    assert(!serverResult.isSuccess);
    assert(serverResult.error is UnexpectedError);
    debugPrint('✅ Server error test passed');

    // Test unauthorized error
    const authError = UnauthorizedError(
      message: 'Session expired',
      technicalDetails: 'JWT token invalid',
    );

    _logger.logError(authError);
    assert(authError.severity == ErrorSeverity.error);
    assert(authError.displayMessage.contains('Sessão expirada'));
    debugPrint('✅ Unauthorized error test passed');
  }

  /// Test validation error scenarios
  Future<void> _testValidationErrors() async {
    debugPrint('Testing Validation Errors...');

    const validationError = ValidationError(
      message: 'Form validation failed',
      fieldErrors: {
        'email': ['Email is required', 'Email format is invalid'],
        'password': ['Password must be at least 8 characters'],
      },
      userFriendlyMessage: 'Please fix the form errors',
    );

    _logger.logError(validationError);

    assert(validationError.fieldErrors.length == 2);
    assert(validationError.fieldErrors['email']?.length == 2);
    assert(validationError.severity == ErrorSeverity.warning);
    debugPrint('✅ Validation error test passed');
  }

  /// Test retry mechanisms
  Future<void> _testRetryMechanisms() async {
    debugPrint('Testing Retry Mechanisms...');

    // Test exponential backoff
    const policy = RetryPolicy(
      maxAttempts: 4,
      initialDelay: Duration(milliseconds: 100),
      backoffMultiplier: 2.0,
    );

    final delay1 = policy.getDelay(1);
    final delay2 = policy.getDelay(2);
    final delay3 = policy.getDelay(3);

    assert(delay1.inMilliseconds == 100);
    assert(delay2.inMilliseconds == 200);
    assert(delay3.inMilliseconds == 400);
    debugPrint('✅ Exponential backoff test passed');

    // Test retry condition
    const networkError = NetworkError(message: 'Connection failed');
    const authError = InvalidCredentialsError();

    assert(policy.shouldRetry(networkError) == true);
    assert(policy.shouldRetry(authError) == false);
    debugPrint('✅ Retry condition test passed');
  }

  /// Test Result pattern
  Future<void> _testResultPattern() async {
    debugPrint('Testing Result Pattern...');

    // Test successful result
    const successResult = Result.success('Test data');
    assert(successResult.isSuccess == true);
    assert(successResult.data == 'Test data');
    assert(successResult.getOrThrow() == 'Test data');
    assert(successResult.getOrElse('fallback') == 'Test data');

    // Test failure result
    const failureResult = Result<String>.failure(
      NetworkError(message: 'Network failed'),
    );
    assert(failureResult.isSuccess == false);
    assert(failureResult.error is NetworkError);
    assert(failureResult.getOrElse('fallback') == 'fallback');

    // Test mapping
    final mappedResult = successResult.map((data) => data.length);
    assert(mappedResult.isSuccess == true);
    assert(mappedResult.data == 'Test data'.length);

    // Test fold
    final foldedValue = failureResult.fold(
      (error) => 'Error: ${error.message}',
      (data) => 'Success: $data',
    );
    assert(foldedValue == 'Error: Network failed');

    debugPrint('✅ Result pattern test passed');
  }

  /// Test logging system
  Future<void> _testLoggingSystem() async {
    debugPrint('Testing Logging System...');

    // Test error logging
    const testError = BusinessLogicError(
      message: 'Invalid vehicle state',
      userFriendlyMessage: 'Veículo não pode ser removido',
      metadata: {
        'vehicleId': 'test-123',
        'state': 'in_use',
      },
    );

    _logger.logError(testError, additionalContext: {
      'testContext': 'error_handler_test',
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Test info logging
    _logger.logInfo('Test info message', metadata: {
      'testType': 'logging_test',
    });

    // Test warning logging
    _logger.logWarning('Test warning message', context: 'test_suite');

    // Test provider state logging
    _logger.logProviderStateChange(
      'TestProvider',
      'loaded',
      {'itemCount': 5, 'hasError': false},
    );

    // Test network request logging
    _logger.logNetworkRequest(
      'POST',
      '/api/test',
      200,
      const Duration(milliseconds: 150),
      requestData: {'test': true},
      responseData: {'success': true},
    );

    debugPrint('✅ Logging system test passed');
  }

  /// Test provider integration
  Future<void> testProviderIntegration() async {
    debugPrint('Testing Provider Integration...');

    final testProvider = TestProvider();
    
    // Test successful operation
    await testProvider.testSuccessfulOperation();
    assert(testProvider.state == ProviderState.loaded);
    assert(testProvider.error == null);

    // Test failed operation
    await testProvider.testFailedOperation();
    assert(testProvider.state == ProviderState.error);
    assert(testProvider.error != null);
    assert(testProvider.error is BusinessLogicError);

    // Test retry
    testProvider.retry();
    // Should call onRetry method

    debugPrint('✅ Provider integration test passed');
  }

  /// Test UI error scenarios
  void testUIErrorScenarios() {
    debugPrint('Testing UI Error Scenarios...');

    // Test different error types for UI display
    final errors = [
      const NetworkError(message: 'Network error'),
      const ValidationError(message: 'Validation error'),
      const ServerError(message: 'Server error', statusCode: 500),
      const AuthenticationError(message: 'Auth error'),
      const BusinessLogicError(message: 'Business error'),
      const UnexpectedError(message: 'Unexpected error'),
    ];

    for (final error in errors) {
      final displayMessage = error.displayMessage;
      final isRecoverable = error.isRecoverable;
      final severity = error.severity;

      assert(displayMessage.isNotEmpty);
      // severity is never null since it has a default value

      debugPrint('Error: ${error.runtimeType}');
      debugPrint('  Message: $displayMessage');
      debugPrint('  Recoverable: $isRecoverable');
      debugPrint('  Severity: ${severity.name}');
    }

    debugPrint('✅ UI error scenarios test passed');
  }
}

/// Test provider implementation
class TestProvider extends BaseProvider {
  Future<void> testSuccessfulOperation() async {
    await executeOperation(
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Simulate success
      },
      operationName: 'testSuccessfulOperation',
    );
  }

  Future<void> testFailedOperation() async {
    await executeOperation(
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        throw const BusinessLogicError(
          message: 'Test business logic error',
          userFriendlyMessage: 'Operação de teste falhou',
        );
      },
      operationName: 'testFailedOperation',
    );
  }

  @override
  void onRetry() {
    debugPrint('TestProvider: onRetry called');
  }
}

/// Utility function to run error handler tests in debug mode
void runErrorHandlerTests() {
  if (!kDebugMode) return;

  final testSuite = ErrorHandlerTestSuite();
  
  // Run tests asynchronously
  Future.microtask(() async {
    try {
      await testSuite.runAllTests();
      await testSuite.testProviderIntegration();
      testSuite.testUIErrorScenarios();
      debugPrint('🎉 All error handling tests completed successfully!');
    } catch (e, stackTrace) {
      debugPrint('❌ Error handler tests failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  });
}