import 'package:injectable/injectable.dart';
import '../entities/example_entity.dart';

/// Sorting service for examples
/// Single Responsibility: Only handles sorting operations
@injectable
class ExampleSortService {
  const ExampleSortService();

  /// Sort examples by name (ascending)
  List<ExampleEntity> sortByNameAsc(List<ExampleEntity> examples) {
    final sorted = List<ExampleEntity>.from(examples);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Sort examples by name (descending)
  List<ExampleEntity> sortByNameDesc(List<ExampleEntity> examples) {
    final sorted = List<ExampleEntity>.from(examples);
    sorted.sort((a, b) => b.name.compareTo(a.name));
    return sorted;
  }

  /// Sort examples by creation date (newest first)
  List<ExampleEntity> sortByCreatedDateDesc(List<ExampleEntity> examples) {
    final sorted = List<ExampleEntity>.from(examples);
    sorted.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return sorted;
  }

  /// Sort examples by creation date (oldest first)
  List<ExampleEntity> sortByCreatedDateAsc(List<ExampleEntity> examples) {
    final sorted = List<ExampleEntity>.from(examples);
    sorted.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  /// Sort examples by update date (most recently updated first)
  List<ExampleEntity> sortByUpdatedDateDesc(List<ExampleEntity> examples) {
    final sorted = List<ExampleEntity>.from(examples);
    sorted.sort((a, b) {
      if (a.updatedAt == null && b.updatedAt == null) return 0;
      if (a.updatedAt == null) return 1;
      if (b.updatedAt == null) return -1;
      return b.updatedAt!.compareTo(a.updatedAt!);
    });
    return sorted;
  }

  /// Generic sort by comparator
  List<ExampleEntity> sortBy(
    List<ExampleEntity> examples,
    int Function(ExampleEntity a, ExampleEntity b) comparator,
  ) {
    final sorted = List<ExampleEntity>.from(examples);
    sorted.sort(comparator);
    return sorted;
  }
}
