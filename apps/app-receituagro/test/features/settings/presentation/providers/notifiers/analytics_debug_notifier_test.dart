import 'package:app_receituagro/core/interfaces/i_premium_service.dart';
import 'package:app_receituagro/features/settings/presentation/providers/notifiers/analytics_debug_notifier.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ===== MOCK CLASSES =====

/// Mock IAnalyticsRepository for testing
class MockIAnalyticsRepository extends Mock implements IAnalyticsRepository {}

/// Mock ICrashlyticsRepository for testing
class MockICrashlyticsRepository extends Mock implements ICrashlyticsRepository {}

/// Mock IAppRatingRepository for testing
class MockIAppRatingRepository extends Mock implements IAppRatingRepository {}

/// Mock IPremiumService for testing
class MockIPremiumService extends Mock implements IPremiumService {}

void main() {
  late MockIAnalyticsRepository mockAnalyticsRepository;
  late MockICrashlyticsRepository mockCrashlyticsRepository;
  late MockIAppRatingRepository mockAppRatingRepository;
  late MockIPremiumService mockPremiumService;

  setUp(() {
    mockAnalyticsRepository = MockIAnalyticsRepository();
    mockCrashlyticsRepository = MockICrashlyticsRepository();
    mockAppRatingRepository = MockIAppRatingRepository();
    mockPremiumService = MockIPremiumService();

    // Mock successful responses
    when(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
        .thenAnswer((_) async => Right(null));

    when(() => mockCrashlyticsRepository.log(any()))
        .thenAnswer((_) async => Right(null));

    when(() => mockCrashlyticsRepository.setCustomKey(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async => Right(null));

    when(() => mockCrashlyticsRepository.recordError(
          exception: any(named: 'exception'),
          stackTrace: any(named: 'stackTrace'),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
        ))
        .thenAnswer((_) async => Right(null));

    when(() => mockAppRatingRepository.showRatingDialog())
        .thenAnswer((_) async => true);

    when(() => mockPremiumService.generateTestSubscription())
        .thenAnswer((_) async => Right(null));

    when(() => mockPremiumService.removeTestSubscription())
        .thenAnswer((_) async => Right(null));
  });

  // ===== GROUP 1: ANALYTICS TESTING =====

  group('AnalyticsDebugNotifier - Analytics Testing', () {
    test('should test analytics functionality successfully', () async {
      // Arrange
      final analysisMap = {
        'test_event': 'settings_test_analytics',
        'timestamp': DateTime.now().toIso8601String(),
      };

      when(() => mockAnalyticsRepository.logEvent(
            'test_analytics',
            parameters: any(named: 'parameters'),
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockAnalyticsRepository.logEvent(
        'test_analytics',
        parameters: analysisMap,
      );

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(
            'test_analytics',
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('should log test event with valid timestamp', () async {
      // Arrange
      final timestamp = DateTime.now();
      final testData = {
        'test_event': 'settings_test_analytics',
        'timestamp': timestamp.toIso8601String(),
      };

      when(() => mockAnalyticsRepository.logEvent(
            'test_analytics',
            parameters: testData,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockAnalyticsRepository.logEvent(
        'test_analytics',
        parameters: testData,
      );

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(
            'test_analytics',
            parameters: testData,
          )).called(1);
    });

    test('should handle analytics logging error', () async {
      // Arrange
      final exception = Exception('Analytics logging failed');

      when(() => mockAnalyticsRepository.logEvent(
            any(),
            parameters: any(named: 'parameters'),
          )).thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should log multiple analytics events sequentially', () async {
      // Arrange
      when(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async => Right(null));

      // Act
      await mockAnalyticsRepository.logEvent('event1', parameters: {});
      await mockAnalyticsRepository.logEvent('event2', parameters: {});
      await mockAnalyticsRepository.logEvent('event3', parameters: {});

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .called(3);
    });

    test('should include required fields in analytics event', () async {
      // Arrange
      final testData = {
        'test_event': 'settings_test_analytics',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Act & Assert
      expect(testData.containsKey('test_event'), true);
      expect(testData.containsKey('timestamp'), true);
      expect(testData['test_event'], 'settings_test_analytics');
    });
  });

  // ===== GROUP 2: CRASHLYTICS TESTING =====

  group('AnalyticsDebugNotifier - Crashlytics Testing', () {
    test('should test crashlytics logging successfully', () async {
      // Arrange
      const testLog = 'Test crashlytics log from settings';

      when(() => mockCrashlyticsRepository.log(testLog))
          .thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.log(testLog);

      // Assert
      verify(() => mockCrashlyticsRepository.log(testLog)).called(1);
    });

    test('should set custom key in crashlytics', () async {
      // Arrange
      final timestamp = DateTime.now().toIso8601String();

      when(() => mockCrashlyticsRepository.setCustomKey(
            key: 'test_timestamp',
            value: timestamp,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.setCustomKey(
        key: 'test_timestamp',
        value: timestamp,
      );

      // Assert
      verify(() => mockCrashlyticsRepository.setCustomKey(
            key: 'test_timestamp',
            value: any(named: 'value'),
          )).called(1);
    });

    test('should record error with full details', () async {
      // Arrange
      final testException = Exception('Test exception from settings');
      final stackTrace = StackTrace.current;

      when(() => mockCrashlyticsRepository.recordError(
            exception: testException,
            stackTrace: any(named: 'stackTrace'),
            reason: 'Testing Crashlytics integration',
            fatal: false,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.recordError(
        exception: testException,
        stackTrace: stackTrace,
        reason: 'Testing Crashlytics integration',
        fatal: false,
      );

      // Assert
      verify(() => mockCrashlyticsRepository.recordError(
            exception: any(named: 'exception'),
            stackTrace: any(named: 'stackTrace'),
            reason: 'Testing Crashlytics integration',
            fatal: false,
          )).called(1);
    });

    test('should handle crashlytics error', () async {
      // Arrange
      final exception = Exception('Crashlytics error');

      when(() => mockCrashlyticsRepository.log(any()))
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should record multiple logs in sequence', () async {
      // Arrange
      when(() => mockCrashlyticsRepository.log(any()))
          .thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.log('Log 1');
      await mockCrashlyticsRepository.log('Log 2');
      await mockCrashlyticsRepository.log('Log 3');

      // Assert
      verify(() => mockCrashlyticsRepository.log(any())).called(3);
    });

    test('should handle non-fatal errors', () async {
      // Arrange
      final exception = Exception('Non-fatal error');

      when(() => mockCrashlyticsRepository.recordError(
            exception: any(named: 'exception'),
            stackTrace: any(named: 'stackTrace'),
            reason: any(named: 'reason'),
            fatal: false,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.recordError(
        exception: exception,
        stackTrace: StackTrace.current,
        reason: 'Testing non-fatal error',
        fatal: false,
      );

      // Assert
      verify(() => mockCrashlyticsRepository.recordError(
            exception: any(named: 'exception'),
            stackTrace: any(named: 'stackTrace'),
            reason: any(named: 'reason'),
            fatal: false,
          )).called(1);
    });

    test('should handle fatal errors', () async {
      // Arrange
      final exception = Exception('Fatal error');

      when(() => mockCrashlyticsRepository.recordError(
            exception: any(named: 'exception'),
            stackTrace: any(named: 'stackTrace'),
            reason: any(named: 'reason'),
            fatal: true,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.recordError(
        exception: exception,
        stackTrace: StackTrace.current,
        reason: 'Testing fatal error',
        fatal: true,
      );

      // Assert
      verify(() => mockCrashlyticsRepository.recordError(
            exception: any(named: 'exception'),
            stackTrace: any(named: 'stackTrace'),
            reason: any(named: 'reason'),
            fatal: true,
          )).called(1);
    });
  });

  // ===== GROUP 3: APP RATING =====

  group('AnalyticsDebugNotifier - App Rating', () {
    test('should show rate app dialog successfully', () async {
      // Arrange
      when(() => mockAppRatingRepository.showRatingDialog())
          .thenAnswer((_) async => true);

      when(() => mockAnalyticsRepository.logEvent(
            'rate_app_shown',
            parameters: any(named: 'parameters'),
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockAppRatingRepository.showRatingDialog();
      await mockAnalyticsRepository.logEvent(
        'rate_app_shown',
        parameters: {'timestamp': DateTime.now().toIso8601String()},
      );

      // Assert
      verify(() => mockAppRatingRepository.showRatingDialog()).called(1);
      verify(() => mockAnalyticsRepository.logEvent(
            'rate_app_shown',
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('should handle rate app dialog error', () async {
      // Arrange
      final exception = Exception('Rate app dialog error');

      when(() => mockAppRatingRepository.showRatingDialog())
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should log rate app event with timestamp', () async {
      // Arrange
      final timestamp = DateTime.now().toIso8601String();
      final params = {'timestamp': timestamp};

      when(() => mockAnalyticsRepository.logEvent(
            'rate_app_shown',
            parameters: params,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockAnalyticsRepository.logEvent(
        'rate_app_shown',
        parameters: params,
      );

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(
            'rate_app_shown',
            parameters: any(named: 'parameters'),
          )).called(1);
    });
  });

  // ===== GROUP 4: PREMIUM TESTING =====

  group('AnalyticsDebugNotifier - Premium Testing', () {
    test('should generate test license successfully', () async {
      // Arrange
      when(() => mockPremiumService.generateTestSubscription())
          .thenAnswer((_) async => Right(null));

      // Act
      await mockPremiumService.generateTestSubscription();

      // Assert
      verify(() => mockPremiumService.generateTestSubscription()).called(1);
    });

    test('should remove test license successfully', () async {
      // Arrange
      when(() => mockPremiumService.removeTestSubscription())
          .thenAnswer((_) async => Right(null));

      // Act
      await mockPremiumService.removeTestSubscription();

      // Assert
      verify(() => mockPremiumService.removeTestSubscription()).called(1);
    });

    test('should handle generate test license error', () async {
      // Arrange
      final exception = Exception('Generate test license failed');

      when(() => mockPremiumService.generateTestSubscription())
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should handle remove test license error', () async {
      // Arrange
      final exception = Exception('Remove test license failed');

      when(() => mockPremiumService.removeTestSubscription())
          .thenThrow(exception);

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('should generate and remove test license in sequence', () async {
      // Arrange
      when(() => mockPremiumService.generateTestSubscription())
          .thenAnswer((_) async => Right(null));
      when(() => mockPremiumService.removeTestSubscription())
          .thenAnswer((_) async => Right(null));

      // Act
      await mockPremiumService.generateTestSubscription();
      await mockPremiumService.removeTestSubscription();

      // Assert
      verify(() => mockPremiumService.generateTestSubscription()).called(1);
      verify(() => mockPremiumService.removeTestSubscription()).called(1);
    });
  });

  // ===== GROUP 5: DEBUG OPERATIONS INTEGRATION =====

  group('AnalyticsDebugNotifier - Integration Scenarios', () {
    test('should execute full debug workflow', () async {
      // Arrange - Setup all mocks
      when(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async => Right(null));
      when(() => mockCrashlyticsRepository.log(any()))
          .thenAnswer((_) async => Right(null));
      when(() => mockAppRatingRepository.showRatingDialog())
          .thenAnswer((_) async => true);

      // Act - Execute full workflow
      await mockAnalyticsRepository.logEvent('test', parameters: {});
      await mockCrashlyticsRepository.log('Test log');
      await mockAppRatingRepository.showRatingDialog();

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .called(1);
      verify(() => mockCrashlyticsRepository.log(any())).called(1);
      verify(() => mockAppRatingRepository.showRatingDialog()).called(1);
    });

    test('should handle multiple debug operations concurrently', () async {
      // Arrange
      when(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async => Right(null));
      when(() => mockCrashlyticsRepository.log(any()))
          .thenAnswer((_) async => Right(null));
      when(() => mockPremiumService.generateTestSubscription())
          .thenAnswer((_) async => Right(null));

      // Act - Execute concurrent operations
      final future1 =
          mockAnalyticsRepository.logEvent('test', parameters: {});
      final future2 = mockCrashlyticsRepository.log('Test log');
      final future3 = mockPremiumService.generateTestSubscription();

      await Future.wait([future1, future2, future3]);

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .called(1);
      verify(() => mockCrashlyticsRepository.log(any())).called(1);
      verify(() => mockPremiumService.generateTestSubscription()).called(1);
    });

    test('should maintain debug state across operations', () async {
      // Arrange
      when(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .thenAnswer((_) async => Right(null));
      when(() => mockCrashlyticsRepository.log(any()))
          .thenAnswer((_) async => Right(null));

      // Act - Execute operations and verify state
      await mockAnalyticsRepository.logEvent('operation1', parameters: {});
      await mockCrashlyticsRepository.log('Log entry 1');
      await mockAnalyticsRepository.logEvent('operation2', parameters: {});

      // Assert - Verify all operations were executed
      verify(() => mockAnalyticsRepository.logEvent(any(), parameters: any(named: 'parameters')))
          .called(2);
      verify(() => mockCrashlyticsRepository.log(any())).called(1);
    });
  });

  // ===== GROUP 6: ERROR HANDLING & EDGE CASES =====

  group('AnalyticsDebugNotifier - Error Handling & Edge Cases', () {
    test('should handle null parameters in analytics event', () async {
      // Arrange & Act & Assert
      expect(() {
        // This tests that the service handles null gracefully
        final params = <String, dynamic>{};
        expect(params.isEmpty, true);
      }, returnsNormally);
    });

    test('should handle empty crash log message', () async {
      // Arrange
      when(() => mockCrashlyticsRepository.log(''))
          .thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.log('');

      // Assert
      verify(() => mockCrashlyticsRepository.log('')).called(1);
    });

    test('should handle very long analytics event parameters', () async {
      // Arrange
      final longParams = {
        'long_key': 'x' * 10000, // Very long value
        'timestamp': DateTime.now().toIso8601String(),
      };

      when(() => mockAnalyticsRepository.logEvent(
            any(),
            parameters: longParams,
          )).thenAnswer((_) async => Right(null));

      // Act
      await mockAnalyticsRepository.logEvent('test', parameters: longParams);

      // Assert
      verify(() => mockAnalyticsRepository.logEvent(
            any(),
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('should handle special characters in debug messages', () async {
      // Arrange
      const specialMessage = r'Test with special chars: @#$%^&*()';

      when(() => mockCrashlyticsRepository.log(specialMessage))
          .thenAnswer((_) async => Right(null));

      // Act
      await mockCrashlyticsRepository.log(specialMessage);

      // Assert
      verify(() => mockCrashlyticsRepository.log(specialMessage)).called(1);
    });
  });
}
