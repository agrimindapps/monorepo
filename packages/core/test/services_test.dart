import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LogRepositoryService', () {
    test('should create log entries correctly', () async {
      final logger = LogRepositoryService.instance;
      
      // Test basic logging
      logger.info('Test info message', context: 'Test');
      logger.warning('Test warning message', context: 'Test');
      logger.error('Test error message', context: 'Test');
      logger.debug('Test debug message', context: 'Test');
      
      // Get logs
      final logs = await logger.getLogs();
      
      expect(logs.length, 4);
      expect(logs.any((log) => log.level == LogLevel.info), true);
      expect(logs.any((log) => log.level == LogLevel.warning), true);
      expect(logs.any((log) => log.level == LogLevel.error), true);
      expect(logs.any((log) => log.level == LogLevel.debug), true);
    });

    test('should filter logs correctly', () async {
      final logger = LogRepositoryService.instance;
      
      // Clear existing logs
      await logger.clearLogs();
      
      // Add test logs
      logger.info('Info message');
      logger.error('Error message');
      
      // Filter by level
      final errorLogs = await logger.getLogs(filterLevel: LogLevel.error);
      final infoLogs = await logger.getLogs(filterLevel: LogLevel.info);
      
      expect(errorLogs.length, 1);
      expect(errorLogs.first.level, LogLevel.error);
      expect(infoLogs.length, 1);
      expect(infoLogs.first.level, LogLevel.info);
    });
  });

  group('DatabaseInspectorService', () {
    test('should manage custom boxes correctly', () {
      final inspector = DatabaseInspectorService.instance;
      
      // Register custom boxes
      inspector.registerCustomBoxes([
        CustomBoxType(
          key: 'test_box',
          displayName: 'Test Box',
          description: 'Test box for unit tests',
          module: 'Test Module',
        ),
      ]);
      
      expect(inspector.customBoxes.length, 1);
      expect(inspector.customBoxes.first.key, 'test_box');
      expect(inspector.getBoxDisplayName('test_box'), 'Test Box');
      expect(inspector.getBoxDescription('test_box'), 'Test box for unit tests');
    });

    test('should extract unique fields correctly', () {
      final inspector = DatabaseInspectorService.instance;
      
      final records = [
        DatabaseRecord(
          id: '1',
          data: {'name': 'Test 1', 'age': 25},
        ),
        DatabaseRecord(
          id: '2',
          data: {'name': 'Test 2', 'email': 'test@example.com'},
        ),
      ];
      
      final fields = inspector.extractUniqueFields(records);
      
      expect(fields.contains('name'), true);
      expect(fields.contains('age'), true);
      expect(fields.contains('email'), true);
      expect(fields.length, 3);
    });
  });

  group('LogLevel Extensions', () {
    test('should have correct properties', () {
      expect(LogLevel.error.isCritical, true);
      expect(LogLevel.info.isCritical, false);
      
      expect(LogLevel.debug.isDevelopmentLevel, true);
      expect(LogLevel.info.isProductionLevel, true);
      
      expect(LogLevel.error.priority > LogLevel.info.priority, true);
      expect(LogLevel.info.priority > LogLevel.debug.priority, true);
    });
  });
}