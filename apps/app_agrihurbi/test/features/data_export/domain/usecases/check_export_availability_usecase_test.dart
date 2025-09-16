import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:app_agrihurbi/features/data_export/domain/repositories/data_export_repository.dart';
import 'package:app_agrihurbi/features/data_export/domain/usecases/check_export_availability_usecase.dart';

@GenerateMocks([DataExportRepository])
import 'check_export_availability_usecase_test.mocks.dart';

void main() {
  group('CheckExportAvailabilityUsecase', () {
    late CheckExportAvailabilityUsecase usecase;
    late MockDataExportRepository mockRepository;

    setUp(() {
      mockRepository = MockDataExportRepository();
      usecase = CheckExportAvailabilityUsecase(mockRepository);
    });

    test('should return available when export is allowed', () async {
      // Arrange
      when(mockRepository.canExport()).thenAnswer((_) async => true);

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result.isAvailable, true);
      expect(result.hasError, false);
      verify(mockRepository.canExport()).called(1);
    });

    test('should return rate limited when export is not allowed', () async {
      // Arrange
      final lastExportDate = DateTime.now().subtract(Duration(hours: 12));
      when(mockRepository.canExport()).thenAnswer((_) async => false);
      when(mockRepository.getLastExportDate())
          .thenAnswer((_) async => lastExportDate);

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result.isAvailable, false);
      expect(result.hasError, false);
      expect(result.lastExportDate, equals(lastExportDate));
      expect(result.nextAvailableDate, isNotNull);
      verify(mockRepository.canExport()).called(1);
      verify(mockRepository.getLastExportDate()).called(1);
    });

    test('should return error when repository throws exception', () async {
      // Arrange
      when(mockRepository.canExport()).thenThrow(Exception('Database error'));

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result.isAvailable, false);
      expect(result.hasError, true);
      expect(result.error, contains('Database error'));
      verify(mockRepository.canExport()).called(1);
    });

    test('should calculate time until next export correctly', () async {
      // Arrange
      final lastExportDate = DateTime.now().subtract(Duration(hours: 20));
      when(mockRepository.canExport()).thenAnswer((_) async => false);
      when(mockRepository.getLastExportDate())
          .thenAnswer((_) async => lastExportDate);

      // Act
      final result = await usecase.execute();

      // Assert
      expect(result.isAvailable, false);
      expect(result.timeUntilNextExport, isNotNull);
      expect(result.timeUntilNextExport!.inHours, lessThan(5));
      expect(result.timeUntilNextExport!.inHours, greaterThan(3));
    });
  });
}