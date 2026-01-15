import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/task_list_group_entity.dart';

part 'task_list_group_notifier.g.dart';

/// Provider for SharedPreferences
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// Notifier para gerenciar grupos de listas
/// Usa SharedPreferences para persistência (pode migrar para Drift futuramente)
@riverpod
class TaskListGroupNotifier extends _$TaskListGroupNotifier {
  static const String _storageKey = 'task_list_groups';

  @override
  Future<List<TaskListGroupEntity>> build(String userId) async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final groupsJson = prefs.getString('${_storageKey}_$userId');

    if (groupsJson == null || groupsJson.isEmpty) {
      // Retornar grupos padrão
      final defaultGroups = DefaultListGroups.all(userId);
      await _saveGroups(defaultGroups, prefs, userId);
      return defaultGroups;
    }

    try {
      final decoded = jsonDecode(groupsJson);
      if (decoded is List) {
        return decoded
            .map(
              (json) =>
                  TaskListGroupEntity.fromMap(json as Map<String, dynamic>),
            )
            .toList();
      }
      return DefaultListGroups.all(userId);
    } catch (e) {
      // Em caso de erro, retornar grupos padrão
      final defaultGroups = DefaultListGroups.all(userId);
      await _saveGroups(defaultGroups, prefs, userId);
      return defaultGroups;
    }
  }

  /// Criar novo grupo
  Future<void> createGroup(TaskListGroupEntity group) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<TaskListGroupEntity> current = state.value ?? [];
      final updated = [...current, group];

      final prefs = await ref.read(sharedPreferencesProvider.future);
      await _saveGroups(updated, prefs, group.userId);

      return updated;
    });
  }

  /// Atualizar grupo
  Future<void> updateGroup(TaskListGroupEntity group) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<TaskListGroupEntity> current = state.value ?? [];
      final updated = current
          .map((TaskListGroupEntity g) => g.id == group.id ? group : g)
          .toList();

      final prefs = await ref.read(sharedPreferencesProvider.future);
      await _saveGroups(updated, prefs, group.userId);

      return updated;
    });
  }

  /// Deletar grupo
  Future<void> deleteGroup(String groupId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<TaskListGroupEntity> current = state.value ?? [];
      final updated =
          current.where((TaskListGroupEntity g) => g.id != groupId).toList();

      final userId = current.firstOrNull?.userId ?? '';
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await _saveGroups(updated, prefs, userId);

      return updated;
    });
  }

  /// Toggle collapsed state
  Future<void> toggleCollapsed(String groupId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<TaskListGroupEntity> current = state.value ?? [];
      final updated = current.map((TaskListGroupEntity g) {
        if (g.id == groupId) {
          return g.copyWith(isCollapsed: !g.isCollapsed);
        }
        return g;
      }).toList();

      final userId = current.firstOrNull?.userId ?? '';
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await _saveGroups(updated, prefs, userId);

      return updated;
    });
  }

  /// Reordenar grupos
  Future<void> reorderGroups(List<String> groupIds) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final List<TaskListGroupEntity> current = state.value ?? [];
      final updated = <TaskListGroupEntity>[];

      for (int i = 0; i < groupIds.length; i++) {
        final group = current.firstWhere((TaskListGroupEntity g) => g.id == groupIds[i]);
        updated.add(group.copyWith(position: i));
      }

      final userId = current.firstOrNull?.userId ?? '';
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await _saveGroups(updated, prefs, userId);

      return updated;
    });
  }

  /// Salvar grupos no SharedPreferences
  Future<void> _saveGroups(
    List<TaskListGroupEntity> groups,
    SharedPreferences prefs,
    String userId,
  ) async {
    final groupsJson = jsonEncode(groups.map((g) => g.toMap()).toList());
    await prefs.setString('${_storageKey}_$userId', groupsJson);
  }
}
