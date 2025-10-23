import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/services/connectivity_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ConnectivityStateManager stateManager;

  setUp(() {
    stateManager = ConnectivityStateManager();
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('ConnectivityStateManager', () {
    test('should save connectivity state successfully', () async {
      // Act
      await stateManager.saveState(true);

      // Assert
      final loadedState = await stateManager.loadState();
      expect(loadedState, true);
    });

    test('should save offline state successfully', () async {
      // Act
      await stateManager.saveState(false);

      // Assert
      final loadedState = await stateManager.loadState();
      expect(loadedState, false);
    });

    test('should return true when no state is saved', () async {
      // Act
      final loadedState = await stateManager.loadState();

      // Assert
      expect(loadedState, true);
    });

    test('should return true when state is older than 24 hours', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Save state from 25 hours ago
      final oldTimestamp =
          DateTime.now().millisecondsSinceEpoch - (25 * 60 * 60 * 1000);
      await prefs.setBool('last_connectivity_state', false);
      await prefs.setInt('last_connectivity_check', oldTimestamp);

      // Act
      final loadedState = await stateManager.loadState();

      // Assert
      expect(loadedState, true); // Should default to online for old state
    });

    test('should load recent offline state correctly', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Save state from 1 hour ago
      final recentTimestamp =
          DateTime.now().millisecondsSinceEpoch - (1 * 60 * 60 * 1000);
      await prefs.setBool('last_connectivity_state', false);
      await prefs.setInt('last_connectivity_check', recentTimestamp);

      // Act
      final loadedState = await stateManager.loadState();

      // Assert
      expect(loadedState, false);
    });

    test('should clear state successfully', () async {
      // Arrange
      await stateManager.saveState(false);

      // Act
      await stateManager.clearState();

      // Assert
      final loadedState = await stateManager.loadState();
      expect(loadedState, true); // Should default to online after clear
    });

    test('should save and load last check time correctly', () async {
      // Arrange
      final beforeSave = DateTime.now();

      // Act
      await stateManager.saveState(true);
      await Future.delayed(const Duration(milliseconds: 100));

      final lastCheckTime = await stateManager.getLastCheckTime();
      final afterSave = DateTime.now();

      // Assert
      expect(lastCheckTime, isNotNull);
      expect(
        lastCheckTime!.isAfter(beforeSave.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        lastCheckTime.isBefore(afterSave.add(const Duration(seconds: 1))),
        true,
      );
    });

    test('should return null for last check time when no state saved',
        () async {
      // Act
      final lastCheckTime = await stateManager.getLastCheckTime();

      // Assert
      expect(lastCheckTime, isNull);
    });

    test('should update state when saving multiple times', () async {
      // Act
      await stateManager.saveState(true);
      await Future.delayed(const Duration(milliseconds: 50));

      await stateManager.saveState(false);
      await Future.delayed(const Duration(milliseconds: 50));

      await stateManager.saveState(true);

      // Assert
      final loadedState = await stateManager.loadState();
      expect(loadedState, true);
    });

    test('should handle state boundary at exactly 24 hours', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Save state from exactly 24 hours ago
      final exactTimestamp =
          DateTime.now().millisecondsSinceEpoch - (24 * 60 * 60 * 1000);
      await prefs.setBool('last_connectivity_state', false);
      await prefs.setInt('last_connectivity_check', exactTimestamp);

      // Act
      final loadedState = await stateManager.loadState();

      // Assert - should still accept at exactly 24h (not > 24h)
      expect(loadedState, false);
    });

    test('should update last check timestamp on each save', () async {
      // Arrange
      await stateManager.saveState(true);
      final firstCheckTime = await stateManager.getLastCheckTime();

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await stateManager.saveState(true);
      final secondCheckTime = await stateManager.getLastCheckTime();

      // Assert
      expect(secondCheckTime, isNotNull);
      expect(firstCheckTime, isNotNull);
      expect(
        secondCheckTime!.isAfter(firstCheckTime!),
        true,
      );
    });
  });
}
