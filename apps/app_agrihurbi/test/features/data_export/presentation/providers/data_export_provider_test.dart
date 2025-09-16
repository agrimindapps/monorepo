import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:app_agrihurbi/features/data_export/domain/entities/export_request.dart';
import 'package:app_agrihurbi/features/data_export/domain/usecases/check_export_availability_usecase.dart';
import 'package:app_agrihurbi/features/data_export/domain/usecases/export_user_data_usecase.dart';
import 'package:app_agrihurbi/features/data_export/presentation/providers/data_export_provider.dart';

@GenerateMocks([
  CheckExportAvailabilityUsecase,
  ExportUserDataUsecase,
])
import 'data_export_provider_test.mocks.dart';

void main() {
  group('DataExportProvider', () {
    late DataExportProvider provider;
    late MockCheckExportAvailabilityUsecase mockCheckAvailabilityUsecase;
    late MockExportUserDataUsecase mockExportDataUsecase;

    setUp(() {
      mockCheckAvailabilityUsecase = MockCheckExportAvailabilityUsecase();
      mockExportDataUsecase = MockExportUserDataUsecase();
      provider = DataExportProvider(
        mockCheckAvailabilityUsecase,
        mockExportDataUsecase,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    group('checkExportAvailability', () {
      test('should update availability result when check succeeds', () async {
        // Arrange
        final availabilityResult = ExportAvailabilityResult.available();
        when(mockCheckAvailabilityUsecase.execute())
            .thenAnswer((_) async => availabilityResult);

        // Act
        await provider.checkExportAvailability();

        // Assert
        expect(provider.availabilityResult, equals(availabilityResult));
        expect(provider.isCheckingAvailability, false);
        expect(provider.canExport, true);
        verify(mockCheckAvailabilityUsecase.execute()).called(1);
      });

      test('should update availability result when check fails', () async {
        // Arrange
        when(mockCheckAvailabilityUsecase.execute())
            .thenThrow(Exception('Network error'));

        // Act
        await provider.checkExportAvailability();

        // Assert
        expect(provider.availabilityResult?.hasError, true);
        expect(provider.availabilityResult?.error, contains('Network error'));
        expect(provider.isCheckingAvailability, false);
        expect(provider.canExport, false);
      });

      test('should set loading state correctly during check', () async {
        // Arrange
        final completer = Completer<ExportAvailabilityResult>();
        when(mockCheckAvailabilityUsecase.execute())
            .thenAnswer((_) => completer.future);

        // Act
        final future = provider.checkExportAvailability();

        // Assert (during loading)
        expect(provider.isCheckingAvailability, true);
        expect(provider.availabilityResult, isNull);

        // Complete the operation
        completer.complete(ExportAvailabilityResult.available());
        await future;

        expect(provider.isCheckingAvailability, false);
        expect(provider.availabilityResult, isNotNull);
      });

      test('should not start new check when already checking', () async {
        // Arrange
        final completer = Completer<ExportAvailabilityResult>();
        when(mockCheckAvailabilityUsecase.execute())
            .thenAnswer((_) => completer.future);

        // Act
        final future1 = provider.checkExportAvailability();
        final future2 = provider.checkExportAvailability(); // Should be ignored

        // Assert
        expect(provider.isCheckingAvailability, true);

        completer.complete(ExportAvailabilityResult.available());
        await future1;
        await future2;

        verify(mockCheckAvailabilityUsecase.execute()).called(1);
      });
    });

    group('startExport', () {
      test('should handle successful export flow', () async {
        // Arrange
        final request = ExportRequest(
          format: ExportFormat.json,
          dataTypes: {DataType.userProfile},
        );

        final progressEvents = [
          ExportProgress(current: 0, total: 3, currentTask: 'Starting...'),
          ExportProgress(current: 1, total: 3, currentTask: 'Processing...'),
          ExportProgress(current: 2, total: 3, currentTask: 'Saving...'),
          ExportProgress(current: 3, total: 3, currentTask: 'Completed!', isCompleted: true),
        ];

        when(mockExportDataUsecase.execute(request))
            .thenAnswer((_) => Stream.fromIterable(progressEvents));

        // Act
        await provider.startExport(request);

        // Wait for all progress events
        await Future.delayed(Duration(milliseconds: 100));

        // Assert
        expect(provider.exportProgress?.isCompleted, true);
        expect(provider.exportProgress?.currentTask, 'Completed!');
        expect(provider.isExporting, false);
        verify(mockExportDataUsecase.execute(request)).called(1);
      });

      test('should handle export error', () async {
        // Arrange
        final request = ExportRequest(
          format: ExportFormat.json,
          dataTypes: {DataType.userProfile},
        );

        final progressEvents = [
          ExportProgress(current: 0, total: 3, currentTask: 'Starting...'),
          ExportProgress(current: 1, total: 3, currentTask: 'Error occurred', error: 'File write failed'),
        ];

        when(mockExportDataUsecase.execute(request))
            .thenAnswer((_) => Stream.fromIterable(progressEvents));

        // Act
        await provider.startExport(request);

        // Wait for all progress events
        await Future.delayed(Duration(milliseconds: 100));

        // Assert
        expect(provider.exportProgress?.hasError, true);
        expect(provider.exportProgress?.error, 'File write failed');
        expect(provider.isExporting, false);
      });

      test('should not start new export when already exporting', () async {
        // Arrange
        final request = ExportRequest(
          format: ExportFormat.json,
          dataTypes: {DataType.userProfile},
        );

        final controller = StreamController<ExportProgress>();
        when(mockExportDataUsecase.execute(request))
            .thenAnswer((_) => controller.stream);

        // Act
        provider.startExport(request);
        expect(provider.isExporting, true);

        // Try to start another export
        provider.startExport(request);

        // Assert
        verify(mockExportDataUsecase.execute(request)).called(1);

        // Clean up
        controller.close();
      });
    });

    group('cancelExport', () {
      test('should cancel ongoing export', () async {
        // Arrange
        final request = ExportRequest(
          format: ExportFormat.json,
          dataTypes: {DataType.userProfile},
        );

        final controller = StreamController<ExportProgress>();
        when(mockExportDataUsecase.execute(request))
            .thenAnswer((_) => controller.stream);

        // Act
        provider.startExport(request);
        expect(provider.isExporting, true);

        provider.cancelExport();

        // Assert
        expect(provider.isExporting, false);
        expect(provider.exportProgress, isNull);

        // Clean up
        controller.close();
      });
    });

    group('state management', () {
      test('should reset all state correctly', () async {
        // Arrange
        provider.checkExportAvailability();
        await Future.delayed(Duration(milliseconds: 10));

        // Act
        provider.reset();

        // Assert
        expect(provider.isCheckingAvailability, false);
        expect(provider.isExporting, false);
        expect(provider.availabilityResult, isNull);
        expect(provider.exportProgress, isNull);
      });

      test('should clear results correctly', () {
        // Arrange
        // Simulate some export progress
        final request = ExportRequest(
          format: ExportFormat.json,
          dataTypes: {DataType.userProfile},
        );

        when(mockExportDataUsecase.execute(request))
            .thenAnswer((_) => Stream.value(
              ExportProgress(current: 1, total: 3, currentTask: 'Test'),
            ));

        provider.startExport(request);

        // Act
        provider.clearResults();

        // Assert
        expect(provider.exportProgress, isNull);
      });
    });

    group('computed properties', () {
      test('canExport should return correct values', () {
        // Test when availability not checked yet
        expect(provider.canExport, false);

        // Test when export is available and not exporting
        provider.checkExportAvailability();
        when(mockCheckAvailabilityUsecase.execute())
            .thenAnswer((_) async => ExportAvailabilityResult.available());
        expect(provider.canExport, false); // Still false until result is set

        // TODO: Add more specific tests when provider state is accessible
      });

      test('error properties should return correct values', () {
        expect(provider.hasAvailabilityError, false);
        expect(provider.hasExportError, false);
        expect(provider.availabilityError, isNull);
        expect(provider.exportError, isNull);
      });
    });
  });
}