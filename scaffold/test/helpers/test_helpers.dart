/// Test helpers and utilities
/// Provides common test utilities and mock builders
library;

import 'package:{{APP_NAME}}/features/example/domain/entities/example_entity.dart';

/// Build a test ExampleEntity with default values
ExampleEntity buildTestExample({
  String? id,
  String? name,
  String? description,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isDirty,
  String? userId,
}) {
  return ExampleEntity(
    id: id ?? 'test-id-123',
    name: name ?? 'Test Example',
    description: description,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    updatedAt: updatedAt ?? DateTime(2024, 1, 1),
    isDirty: isDirty ?? false,
    userId: userId ?? 'user-123',
  );
}

/// Build a list of test ExampleEntities
List<ExampleEntity> buildTestExampleList(int count) {
  return List.generate(
    count,
    (index) => buildTestExample(
      id: 'test-id-$index',
      name: 'Test Example $index',
    ),
  );
}
