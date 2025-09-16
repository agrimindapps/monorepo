import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_agrihurbi/features/data_export/data/services/export_formatter_service.dart';
import 'package:app_agrihurbi/features/data_export/domain/entities/export_data.dart';
import 'package:app_agrihurbi/features/data_export/domain/entities/export_request.dart';

void main() {
  group('ExportFormatterService', () {
    late ExportFormatterService service;
    late ExportData testData;

    setUp(() {
      service = ExportFormatterServiceImpl();
      testData = ExportData(
        userProfile: UserProfileData(
          name: 'João Silva',
          email: 'joao@email.com',
          createdAt: DateTime(2023, 1, 15),
          lastLoginAt: DateTime(2024, 6, 10),
        ),
        favorites: [
          FavoriteData(
            productId: 'prod_001',
            productName: 'Herbicida XYZ',
            category: 'Herbicidas',
            createdAt: DateTime(2024, 3, 20),
          ),
          FavoriteData(
            productId: 'prod_002',
            productName: 'Fungicida ABC',
            category: 'Fungicidas',
            createdAt: DateTime(2024, 4, 15),
          ),
        ],
        comments: [
          CommentData(
            id: 'comment_001',
            productId: 'prod_001',
            content: 'Produto muito eficaz!',
            rating: 4.5,
            createdAt: DateTime(2024, 5, 1),
          ),
        ],
        preferences: UserPreferencesData(
          settings: {'theme': 'dark', 'notifications': true},
          language: 'pt-BR',
          theme: 'dark',
          notificationsEnabled: true,
        ),
        metadata: ExportMetadata(
          exportDate: DateTime(2024, 6, 15),
          userId: 'user_123',
          appVersion: '1.0.0',
          dataVersion: '1.0',
          format: 'complete',
          totalRecords: 4,
        ),
      );
    });

    group('JSON formatting', () {
      test('should format export data as valid JSON', () {
        // Act
        final result = service.formatExportData(testData, ExportFormat.json);

        // Assert
        expect(() => json.decode(result), returnsNormally);

        final parsed = json.decode(result) as Map<String, dynamic>;
        expect(parsed['metadata'], isNotNull);
        expect(parsed['user_profile'], isNotNull);
        expect(parsed['favorites'], isA<List>());
        expect(parsed['comments'], isA<List>());
        expect(parsed['preferences'], isNotNull);
      });

      test('should include all user profile data in JSON', () {
        // Act
        final result = service.formatExportData(testData, ExportFormat.json);
        final parsed = json.decode(result) as Map<String, dynamic>;

        // Assert
        final userProfile = parsed['user_profile'] as Map<String, dynamic>;
        expect(userProfile['name'], equals('João Silva'));
        expect(userProfile['email'], equals('joao@email.com'));
        expect(userProfile['created_at'], equals('2023-01-15T00:00:00.000'));
      });

      test('should include all favorites data in JSON', () {
        // Act
        final result = service.formatExportData(testData, ExportFormat.json);
        final parsed = json.decode(result) as Map<String, dynamic>;

        // Assert
        final favorites = parsed['favorites'] as List;
        expect(favorites.length, equals(2));
        expect(favorites[0]['product_name'], equals('Herbicida XYZ'));
        expect(favorites[1]['product_name'], equals('Fungicida ABC'));
      });
    });

    group('CSV formatting', () {
      test('should format export data as CSV with headers', () {
        // Act
        final result = service.formatExportData(testData, ExportFormat.csv);

        // Assert
        expect(result, contains('# LGPD Data Export'));
        expect(result, contains('# Export Date:'));
        expect(result, contains('# App Version:'));
        expect(result, contains('## User Profile'));
        expect(result, contains('## Favorites'));
        expect(result, contains('## Comments'));
        expect(result, contains('## Preferences'));
      });

      test('should include user profile section in CSV', () {
        // Act
        final result = service.formatExportData(testData, ExportFormat.csv);

        // Assert
        expect(result, contains('Field,Value'));
        expect(result, contains('Name,"João Silva"'));
        expect(result, contains('Email,"joao@email.com"'));
      });

      test('should include favorites section in CSV', () {
        // Act
        final result = service.formatExportData(testData, ExportFormat.csv);

        // Assert
        expect(result, contains('Product ID,Product Name,Category,Created At'));
        expect(result, contains('prod_001,"Herbicida XYZ","Herbicidas"'));
        expect(result, contains('prod_002,"Fungicida ABC","Fungicidas"'));
      });

      test('should handle special characters in CSV', () {
        // Arrange
        final dataWithSpecialChars = ExportData(
          favorites: [
            FavoriteData(
              productId: 'prod_001',
              productName: 'Produto "Especial" com, vírgula',
              category: 'Categoria, com vírgula',
              createdAt: DateTime(2024, 3, 20),
            ),
          ],
          comments: [],
          metadata: testData.metadata,
        );

        // Act
        final result = service.formatExportData(dataWithSpecialChars, ExportFormat.csv);

        // Assert
        expect(result, contains('"Produto ""Especial"" com, vírgula"'));
        expect(result, contains('"Categoria, com vírgula"'));
      });
    });

    group('Edge cases', () {
      test('should handle empty data collections', () {
        // Arrange
        final emptyData = ExportData(
          favorites: [],
          comments: [],
          metadata: testData.metadata,
        );

        // Act
        final jsonResult = service.formatExportData(emptyData, ExportFormat.json);
        final csvResult = service.formatExportData(emptyData, ExportFormat.csv);

        // Assert
        expect(() => json.decode(jsonResult), returnsNormally);
        expect(csvResult, contains('# LGPD Data Export'));

        final parsed = json.decode(jsonResult) as Map<String, dynamic>;
        expect(parsed['favorites'], isEmpty);
        expect(parsed['comments'], isEmpty);
      });

      test('should handle null optional fields', () {
        // Arrange
        final dataWithNulls = ExportData(
          favorites: [],
          comments: [],
          metadata: testData.metadata,
        );

        // Act
        final result = service.formatExportData(dataWithNulls, ExportFormat.json);

        // Assert
        expect(() => json.decode(result), returnsNormally);

        final parsed = json.decode(result) as Map<String, dynamic>;
        expect(parsed['user_profile'], isNull);
        expect(parsed['preferences'], isNull);
      });
    });
  });
}