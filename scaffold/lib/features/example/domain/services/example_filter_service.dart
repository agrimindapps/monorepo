import 'package:injectable/injectable.dart';
import '../entities/example_entity.dart';

/// Filtering service for examples
/// Single Responsibility: Only handles filtering operations
@injectable
class ExampleFilterService {
  const ExampleFilterService();

  /// Filter examples by name (case-insensitive)
  List<ExampleEntity> filterByName(
    List<ExampleEntity> examples,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return examples;
    }

    final lowercaseQuery = query.toLowerCase();
    return examples.where((example) {
      return example.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Filter examples by description (case-insensitive)
  List<ExampleEntity> filterByDescription(
    List<ExampleEntity> examples,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return examples;
    }

    final lowercaseQuery = query.toLowerCase();
    return examples.where((example) {
      final description = example.description ?? '';
      return description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Filter examples by user ID
  List<ExampleEntity> filterByUser(
    List<ExampleEntity> examples,
    String userId,
  ) {
    return examples.where((example) {
      return example.userId == userId;
    }).toList();
  }

  /// Filter examples that need sync (isDirty)
  List<ExampleEntity> filterDirty(List<ExampleEntity> examples) {
    return examples.where((example) => example.isDirty).toList();
  }

  /// Filter examples created after a specific date
  List<ExampleEntity> filterCreatedAfter(
    List<ExampleEntity> examples,
    DateTime date,
  ) {
    return examples.where((example) {
      final createdAt = example.createdAt;
      return createdAt != null && createdAt.isAfter(date);
    }).toList();
  }

  /// Generic filter by predicate
  List<ExampleEntity> filterBy(
    List<ExampleEntity> examples,
    bool Function(ExampleEntity) predicate,
  ) {
    return examples.where(predicate).toList();
  }
}
