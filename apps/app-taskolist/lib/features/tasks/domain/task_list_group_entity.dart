import 'package:core/core.dart';

/// Entity para agrupamento de listas de tarefas
/// Permite organizar listas em categorias (Work, Personal, Shopping, etc.)
class TaskListGroupEntity extends Equatable {
  final String id;
  final String name;
  final String userId;
  final String? icon; // emoji ou icon name
  final String color;
  final int position; // ordem de exibição
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCollapsed; // grupo expandido/recolhido na UI

  const TaskListGroupEntity({
    required this.id,
    required this.name,
    required this.userId,
    this.icon,
    this.color = '#2196F3', // blue default
    this.position = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isCollapsed = false,
  });

  TaskListGroupEntity copyWith({
    String? id,
    String? name,
    String? userId,
    String? icon,
    String? color,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCollapsed,
  }) {
    return TaskListGroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'icon': icon,
      'color': color,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_collapsed': isCollapsed,
    };
  }

  factory TaskListGroupEntity.fromMap(Map<String, dynamic> map) {
    return TaskListGroupEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      userId: map['user_id'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String? ?? '#2196F3',
      position: map['position'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isCollapsed: map['is_collapsed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        userId,
        icon,
        color,
        position,
        createdAt,
        updatedAt,
        isCollapsed,
      ];
}

/// Grupos padrão do sistema
class DefaultListGroups {
  static const String workId = 'default_work';
  static const String personalId = 'default_personal';
  static const String shoppingId = 'default_shopping';
  static const String ungroupedId = 'default_ungrouped';

  static TaskListGroupEntity work(String userId) {
    return TaskListGroupEntity(
      id: workId,
      name: 'Trabalho',
      userId: userId,
      icon: '💼',
      color: '#FF5722',
      position: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static TaskListGroupEntity personal(String userId) {
    return TaskListGroupEntity(
      id: personalId,
      name: 'Pessoal',
      userId: userId,
      icon: '🏠',
      color: '#4CAF50',
      position: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static TaskListGroupEntity shopping(String userId) {
    return TaskListGroupEntity(
      id: shoppingId,
      name: 'Compras',
      userId: userId,
      icon: '🛒',
      color: '#9C27B0',
      position: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static TaskListGroupEntity ungrouped(String userId) {
    return TaskListGroupEntity(
      id: ungroupedId,
      name: 'Sem Grupo',
      userId: userId,
      icon: '📋',
      color: '#607D8B',
      position: 999,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<TaskListGroupEntity> all(String userId) {
    return [
      work(userId),
      personal(userId),
      shopping(userId),
      ungrouped(userId),
    ];
  }
}
