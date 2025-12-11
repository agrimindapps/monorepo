import 'package:app_plantis/features/plants/domain/entities/plant.dart';
import 'package:app_plantis/features/tasks/domain/entities/task.dart'
    as task_entity;
import 'package:core/core.dart' hide Task;

/// Test fixtures for common entities used in tests
class TestFixtures {
  // Plant test data
  static Plant createTestPlant({
    String id = 'test-plant-1',
    String name = 'Test Plant',
    String? species = 'Monstera Deliciosa',
    String? spaceId,
    String? imageBase64,
    List<String>? imageUrls,
    DateTime? plantingDate,
    String? notes,
    PlantConfig? config,
    bool isFavorited = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    String userId = 'test-user-1',
  }) {
    return Plant(
      id: id,
      name: name,
      species: species,
      spaceId: spaceId,
      imageBase64: imageBase64,
      imageUrls: imageUrls ?? [],
      plantingDate: plantingDate ?? DateTime.now(),
      notes: notes,
      config: config,
      isFavorited: isFavorited,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      userId: userId,
      moduleName: 'plantis',
      isDirty: false,
    );
  }

  static List<Plant> createTestPlants({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestPlant(id: 'plant-$index', name: 'Test Plant $index'),
    );
  }

  // Task test data
  static task_entity.Task createTestTask({
    String id = 'test-task-1',
    String title = 'Water Plant',
    String? description,
    DateTime? dueDate,
    bool completed = false,
    String? plantId,
    String userId = 'test-user-1',
    task_entity.TaskType? type,
    task_entity.TaskStatus? status,
    task_entity.TaskPriority? priority,
  }) {
    return task_entity.Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
      plantId: plantId ?? 'plant-1',
      type: type ?? task_entity.TaskType.watering,
      status: completed
          ? task_entity.TaskStatus.completed
          : (status ?? task_entity.TaskStatus.pending),
      priority: priority ?? task_entity.TaskPriority.medium,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: false,
    );
  }

  static List<task_entity.Task> createTestTasks({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestTask(id: 'task-$index', title: 'Task $index'),
    );
  }

  // Failure test data
  static const serverFailure = ServerFailure('Server error');
  static const networkFailure = NetworkFailure('Network error');
  static const validationFailure = ValidationFailure('Validation error');
  static const notFoundFailure = NotFoundFailure('Not found');
}
