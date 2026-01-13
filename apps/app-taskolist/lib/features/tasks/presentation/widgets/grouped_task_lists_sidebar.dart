import 'package:flutter/material.dart';
import '../../domain/task_list_entity.dart';
import '../../domain/task_list_group_entity.dart';

/// Widget para exibir listas agrupadas em sidebar/drawer
class GroupedTaskListsSidebar extends StatelessWidget {
  final List<TaskListGroupEntity> groups;
  final List<TaskListEntity> lists;
  final String? selectedListId;
  final String? selectedGroupId;
  final Function(String listId) onListTap;
  final Function(String groupId) onGroupTap;
  final Function(String groupId, bool isCollapsed) onGroupToggle;
  final VoidCallback onCreateList;
  final VoidCallback onCreateGroup;

  const GroupedTaskListsSidebar({
    super.key,
    required this.groups,
    required this.lists,
    this.selectedListId,
    this.selectedGroupId,
    required this.onListTap,
    required this.onGroupTap,
    required this.onGroupToggle,
    required this.onCreateList,
    required this.onCreateGroup,
  });

  @override
  Widget build(BuildContext context) {
    // Organizar listas por grupo
    final Map<String?, List<TaskListEntity>> listsByGroup = {};
    
    for (final list in lists) {
      if (list.isArchived) continue; // Skip archived
      final groupId = list.groupId;
      if (!listsByGroup.containsKey(groupId)) {
        listsByGroup[groupId] = [];
      }
      listsByGroup[groupId]!.add(list);
    }

    // Ordenar grupos por position
    final sortedGroups = [...groups]..sort((a, b) => a.position.compareTo(b.position));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas Listas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: onCreateList,
                tooltip: 'Nova lista',
              ),
            ],
          ),
        ),

        const Divider(),

        // Grupos
        ...sortedGroups.map((group) {
          final groupLists = listsByGroup[group.id] ?? [];
          return _GroupSection(
            group: group,
            lists: groupLists,
            isCollapsed: group.isCollapsed,
            isSelected: selectedGroupId == group.id,
            selectedListId: selectedListId,
            onGroupTap: () => onGroupTap(group.id),
            onGroupToggle: (isCollapsed) => onGroupToggle(group.id, isCollapsed),
            onListTap: onListTap,
          );
        }),

        // Listas sem grupo
        if (listsByGroup[null]?.isNotEmpty ?? false) ...[
          const Divider(),
          _UngroupedSection(
            lists: listsByGroup[null]!,
            selectedListId: selectedListId,
            onListTap: onListTap,
          ),
        ],

        // Botão criar grupo
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: onCreateGroup,
            icon: const Icon(Icons.create_new_folder, size: 18),
            label: const Text('Novo Grupo'),
          ),
        ),
      ],
    );
  }
}

/// Seção de grupo com listas
class _GroupSection extends StatelessWidget {
  final TaskListGroupEntity group;
  final List<TaskListEntity> lists;
  final bool isCollapsed;
  final bool isSelected;
  final String? selectedListId;
  final VoidCallback onGroupTap;
  final Function(bool isCollapsed) onGroupToggle;
  final Function(String listId) onListTap;

  const _GroupSection({
    required this.group,
    required this.lists,
    required this.isCollapsed,
    required this.isSelected,
    required this.selectedListId,
    required this.onGroupTap,
    required this.onGroupToggle,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Material(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) 
              : Colors.transparent,
          child: InkWell(
            onTap: onGroupTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isCollapsed ? Icons.chevron_right : Icons.expand_more,
                      size: 20,
                    ),
                    onPressed: () => onGroupToggle(!isCollapsed),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  if (group.icon != null)
                    Text(group.icon!, style: const TextStyle(fontSize: 20)),
                  if (group.icon != null) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${lists.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Lists (quando expandido)
        if (!isCollapsed)
          ...lists.map((list) => _ListTile(
                list: list,
                isSelected: selectedListId == list.id,
                onTap: () => onListTap(list.id),
              )),
      ],
    );
  }
}

/// Seção de listas sem grupo
class _UngroupedSection extends StatelessWidget {
  final List<TaskListEntity> lists;
  final String? selectedListId;
  final Function(String listId) onListTap;

  const _UngroupedSection({
    required this.lists,
    required this.selectedListId,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Sem Grupo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...lists.map((list) => _ListTile(
              list: list,
              isSelected: selectedListId == list.id,
              onTap: () => onListTap(list.id),
            )),
      ],
    );
  }
}

/// List tile individual
class _ListTile extends StatelessWidget {
  final TaskListEntity list;
  final bool isSelected;
  final VoidCallback onTap;

  const _ListTile({
    required this.list,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) 
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _parseColor(list.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  list.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Shared indicator
              if (list.isShared)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.people, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
