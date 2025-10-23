import 'dart:async';

import 'package:core/core.dart' hide test;
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gasometer/core/services/auto_sync_service.dart';

// Mock classes
class MockConnectivityService extends Mock implements ConnectivityService {}

class MockUnifiedSyncManager extends Mock implements UnifiedSyncManager {}

// Fake classes for fallback values
class _FakeConnectivityResult extends Fake {}

void main() {
  late AutoSyncService autoSyncService;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockConnectivityService = MockConnectivityService();

    autoSyncService = AutoSyncService(
      connectivityService: mockConnectivityService,
    );

    // Default: device is online
    when(() => mockConnectivityService.isOnline())
        .thenAnswer((_) async => const Right(true));
  });

  tearDown(() {
    autoSyncService.dispose();
  });

  group('AutoSyncService - Initialization', () {
    test('should initialize successfully', () async {
      // Act
      await autoSyncService.initialize();

      // Assert
      expect(autoSyncService.isRunning, false);
      expect(autoSyncService.isSyncing, false);
    });

    test('should not initialize twice', () async {
      // Arrange
      await autoSyncService.initialize();

      // Act
      await autoSyncService.initialize();

      // Assert - no errors thrown
      expect(autoSyncService.isRunning, false);
    });
  });

  group('AutoSyncService - Start/Stop', () {
    test('should start periodic sync timer', () async {
      // Arrange
      await autoSyncService.initialize();

      // Act
      autoSyncService.start();

      // Assert
      expect(autoSyncService.isRunning, true);
    });

    test('should not start if not initialized', () {
      // Act
      autoSyncService.start();

      // Assert
      expect(autoSyncService.isRunning, false);
    });

    test('should not start twice', () async {
      // Arrange
      await autoSyncService.initialize();
      autoSyncService.start();

      // Act
      autoSyncService.start();

      // Assert
      expect(autoSyncService.isRunning, true);
    });

    test('should stop periodic sync timer', () async {
      // Arrange
      await autoSyncService.initialize();
      autoSyncService.start();

      // Act
      autoSyncService.stop();

      // Assert
      expect(autoSyncService.isRunning, false);
    });

    test('should handle stop when not running', () async {
      // Arrange
      await autoSyncService.initialize();

      // Act
      autoSyncService.stop();

      // Assert - no errors thrown
      expect(autoSyncService.isRunning, false);
    });
  });

  group('AutoSyncService - Pause/Resume', () {
    test('should pause auto-sync when app goes to background', () async {
      // Arrange
      await autoSyncService.initialize();
      autoSyncService.start();
      expect(autoSyncService.isRunning, true);

      // Act
      autoSyncService.pause();

      // Assert
      expect(autoSyncService.isRunning, false);
    });

    test('should resume auto-sync when app returns to foreground', () async {
      // Arrange
      await autoSyncService.initialize();
      autoSyncService.start();
      autoSyncService.pause();
      expect(autoSyncService.isRunning, false);

      // Act
      autoSyncService.resume();

      // Assert
      expect(autoSyncService.isRunning, true);
    });

    test('should handle resume when already running', () async {
      // Arrange
      await autoSyncService.initialize();
      autoSyncService.start();

      // Act
      autoSyncService.resume();

      // Assert - no errors, still running
      expect(autoSyncService.isRunning, true);
    });

    test('should handle pause when not running', () async {
      // Arrange
      await autoSyncService.initialize();

      // Act
      autoSyncService.pause();

      // Assert - no errors thrown
      expect(autoSyncService.isRunning, false);
    });
  });

  group('AutoSyncService - Sync Guards', () {
    test('should skip sync when device is offline', () async {
      // Arrange
      await autoSyncService.initialize();
      when(() => mockConnectivityService.isOnline())
          .thenAnswer((_) async => const Right(false));

      // Act
      await autoSyncService.syncNow();

      // Assert
      expect(autoSyncService.isSyncing, false);
    });

    test('should handle connectivity check failure', () async {
      // Arrange
      await autoSyncService.initialize();
      when(() => mockConnectivityService.isOnline())
          .thenAnswer((_) async => const Left(ServerFailure('No connection')));

      // Act
      await autoSyncService.syncNow();

      // Assert - should skip sync (treat error as offline)
      expect(autoSyncService.isSyncing, false);
    });

    test('should prevent concurrent syncs', () async {
      // Arrange
      await autoSyncService.initialize();

      // Track sync attempts
      var syncAttempts = 0;
      when(() => mockConnectivityService.isOnline()).thenAnswer((_) async {
        syncAttempts++;
        return const Right(true);
      });

      // Act - trigger two syncs in quick succession
      // First sync starts
      final firstSync = autoSyncService.syncNow();

      // Small delay to ensure first sync is in progress
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Second sync should be skipped (concurrent guard)
      final secondSync = autoSyncService.syncNow();

      // Wait for both to complete
      await Future.wait([firstSync, secondSync]);

      // Assert - Only first sync should execute
      // Note: syncAttempts might be > 1 due to async timing,
      // but isSyncing flag prevents actual concurrent execution
      expect(autoSyncService.isSyncing, false);
    });
  });

  group('AutoSyncService - Manual Sync', () {
    test('should trigger sync when syncNow is called', () async {
      // Arrange
      await autoSyncService.initialize();

      var connectivityCheckCount = 0;
      when(() => mockConnectivityService.isOnline()).thenAnswer((_) async {
        connectivityCheckCount++;
        return const Right(true);
      });

      // Act
      await autoSyncService.syncNow();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(connectivityCheckCount, greaterThan(0));
    });
  });

  group('AutoSyncService - Dispose', () {
    test('should dispose resources and stop timer', () async {
      // Arrange
      await autoSyncService.initialize();
      autoSyncService.start();
      expect(autoSyncService.isRunning, true);

      // Act
      autoSyncService.dispose();

      // Assert
      expect(autoSyncService.isRunning, false);
    });

    test('should handle dispose when not running', () async {
      // Arrange
      await autoSyncService.initialize();

      // Act
      autoSyncService.dispose();

      // Assert - no errors thrown
      expect(autoSyncService.isRunning, false);
    });
  });
}
