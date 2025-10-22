import 'package:app_plantis/core/services/rate_limiter_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RateLimiterService rateLimiter;

  setUp(() {
    rateLimiter = RateLimiterService();
  });

  group('RateLimiterService - Throttling', () {
    test('should allow first request immediately', () async {
      // Act
      final start = DateTime.now();
      await rateLimiter.checkLimit('test.endpoint');
      final elapsed = DateTime.now().difference(start);

      // Assert
      expect(elapsed.inMilliseconds, lessThan(100)); // Should be immediate
    });

    test('should throttle rapid consecutive requests', () async {
      // Arrange
      const throttleMs = 500;

      // Act - Make 3 rapid requests
      final start = DateTime.now();
      await rateLimiter.checkLimit('test.endpoint'); // Request 1: immediate
      await rateLimiter.checkLimit('test.endpoint'); // Request 2: waits ~500ms
      await rateLimiter.checkLimit('test.endpoint'); // Request 3: waits ~500ms
      final elapsed = DateTime.now().difference(start);

      // Assert - Should wait at least 1000ms (2 throttle intervals)
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(throttleMs * 2));
      expect(elapsed.inMilliseconds, lessThan(throttleMs * 2 + 200)); // With tolerance
    });

    test('should apply throttling independently per endpoint', () async {
      // Act
      final start = DateTime.now();
      await rateLimiter.checkLimit('endpoint1');
      await rateLimiter.checkLimit('endpoint2'); // Different endpoint
      final elapsed = DateTime.now().difference(start);

      // Assert - Second request should NOT throttle (different endpoint)
      expect(elapsed.inMilliseconds, lessThan(100));
    });

    test('should use custom throttle config when set', () async {
      // Arrange
      const customThrottleMs = 200;
      rateLimiter.setConfig(
        'custom.endpoint',
        const RateLimitConfig(throttleInterval: Duration(milliseconds: customThrottleMs)),
      );

      // Act
      final start = DateTime.now();
      await rateLimiter.checkLimit('custom.endpoint'); // Request 1
      await rateLimiter.checkLimit('custom.endpoint'); // Request 2: waits custom duration
      final elapsed = DateTime.now().difference(start);

      // Assert
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(customThrottleMs));
      expect(elapsed.inMilliseconds, lessThan(customThrottleMs + 100));
    });
  });

  group('RateLimiterService - Window Limiting', () {
    test('should allow requests within window limit', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero, // Disable throttle for this test
          maxRequestsPerWindow: 5,
          windowDuration: Duration(minutes: 1),
        ),
      );

      // Act & Assert - Should allow 5 requests
      for (var i = 0; i < 5; i++) {
        await expectLater(
          rateLimiter.checkLimit('test.endpoint'),
          completes,
        );
      }
    });

    test('should throw RateLimitException when window limit exceeded', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero, // Disable throttle
          maxRequestsPerWindow: 3,
          windowDuration: Duration(seconds: 10),
        ),
      );

      // Act - Make 3 requests (should succeed)
      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');

      // Assert - 4th request should throw
      expect(
        () => rateLimiter.checkLimit('test.endpoint'),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('RateLimitException should include retry duration', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 1,
          windowDuration: Duration(seconds: 5),
        ),
      );

      // Act
      await rateLimiter.checkLimit('test.endpoint');

      // Assert
      try {
        await rateLimiter.checkLimit('test.endpoint');
        fail('Should have thrown RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter.inSeconds, greaterThan(0));
        expect(e.retryAfter.inSeconds, lessThanOrEqualTo(5));
      }
    });

    test('should allow requests after window expires', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 2,
          windowDuration: Duration(milliseconds: 500), // Short window for test
        ),
      );

      // Act - Exhaust limit
      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');

      // Assert - Should throw immediately
      expect(
        () => rateLimiter.checkLimit('test.endpoint'),
        throwsA(isA<RateLimitException>()),
      );

      // Wait for window to expire
      await Future.delayed(const Duration(milliseconds: 600));

      // Assert - Should allow new requests
      await expectLater(
        rateLimiter.checkLimit('test.endpoint'),
        completes,
      );
    });
  });

  group('RateLimiterService - Stats & Management', () {
    test('should provide accurate stats for endpoint', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 10,
        ),
      );

      // Act - Make 3 requests
      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');

      final stats = rateLimiter.getStats('test.endpoint');

      // Assert
      expect(stats.endpoint, 'test.endpoint');
      expect(stats.requestsInWindow, 3);
      expect(stats.maxRequestsPerWindow, 10);
      expect(stats.canRequest, true);
      expect(stats.usagePercentage, 30.0);
    });

    test('should reset endpoint limits', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 2,
        ),
      );

      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');

      // Should throw before reset
      expect(
        () => rateLimiter.checkLimit('test.endpoint'),
        throwsA(isA<RateLimitException>()),
      );

      // Act
      rateLimiter.reset('test.endpoint');

      // Assert - Should allow requests after reset
      await expectLater(
        rateLimiter.checkLimit('test.endpoint'),
        completes,
      );
    });

    test('should reset all limits', () async {
      // Arrange
      rateLimiter.setConfig(
        'endpoint1',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 1,
        ),
      );
      rateLimiter.setConfig(
        'endpoint2',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 1,
        ),
      );

      await rateLimiter.checkLimit('endpoint1');
      await rateLimiter.checkLimit('endpoint2');

      // Act
      rateLimiter.resetAll();

      // Assert - Both should allow requests
      await expectLater(
        rateLimiter.checkLimit('endpoint1'),
        completes,
      );
      await expectLater(
        rateLimiter.checkLimit('endpoint2'),
        completes,
      );
    });

    test('stats should show canRequest=false when limit reached', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration.zero,
          maxRequestsPerWindow: 2,
        ),
      );

      // Act
      await rateLimiter.checkLimit('test.endpoint');
      await rateLimiter.checkLimit('test.endpoint');

      final stats = rateLimiter.getStats('test.endpoint');

      // Assert
      expect(stats.canRequest, false);
      expect(stats.usagePercentage, 100.0);
    });
  });

  group('RateLimiterService - Presets', () {
    test('aggressive config should have stricter limits', () async {
      // Arrange
      const aggressive = RateLimitConfig.aggressive();

      // Assert
      expect(aggressive.throttleInterval.inMilliseconds, 1000);
      expect(aggressive.maxRequestsPerWindow, 15);
    });

    test('relaxed config should have looser limits', () async {
      // Arrange
      const relaxed = RateLimitConfig.relaxed();

      // Assert
      expect(relaxed.throttleInterval.inMilliseconds, 200);
      expect(relaxed.maxRequestsPerWindow, 60);
    });
  });

  group('RateLimiterService - Edge Cases', () {
    test('should handle stats for endpoint with no requests', () async {
      // Act
      final stats = rateLimiter.getStats('never-used');

      // Assert
      expect(stats.requestsInWindow, 0);
      expect(stats.canRequest, true);
      expect(stats.lastRequestAt, null);
    });

    test('should handle concurrent requests to same endpoint', () async {
      // Arrange
      rateLimiter.setConfig(
        'test.endpoint',
        const RateLimitConfig(
          throttleInterval: Duration(milliseconds: 200),
          maxRequestsPerWindow: 10,
        ),
      );

      // Act - Fire 3 concurrent requests (sequentially, because throttle is synchronous)
      final start = DateTime.now();
      await rateLimiter.checkLimit('test.endpoint'); // 1st: immediate
      await rateLimiter.checkLimit('test.endpoint'); // 2nd: waits 200ms
      await rateLimiter.checkLimit('test.endpoint'); // 3rd: waits 200ms
      final elapsed = DateTime.now().difference(start);

      // Assert - Should wait at least 400ms (2 throttle intervals)
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(400));
    });
  });
}
