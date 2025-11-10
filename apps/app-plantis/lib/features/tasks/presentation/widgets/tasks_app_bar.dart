import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/tasks_providers.dart';
import '../../core/constants/tasks_constants.dart';
import '../../core/utils/task_display_utils.dart';
import '../../domain/entities/task.dart' as task_entity;

/// Enhanced app bar for tasks with search, filtering, and quick actions
///
/// This app bar provides comprehensive task management functionality including:
/// - **Search Capabilities**: Real-time search with debounced input
/// - **Advanced Filtering**: Multiple filter types with visual indicators
/// - **Quick Actions**: Fast access to common task filters
/// - **Visual Feedback**: Active filter chips and counters
/// - **Responsive Design**: Adapts to different screen sizes and themes
///
/// Key Features:
/// - Search functionality with 300ms debounce for performance
/// - Filter bottom sheet with multiple selection categories
/// - Active filter chips that can be individually removed
/// - Quick filter buttons for "Today" and "Upcoming" tasks
/// - Visual badges showing filter counts and task statistics
///
/// The app bar automatically manages its state and communicates changes
/// to the TasksProvider for data filtering and the parent widget through
/// the onFilterChanged callback.
class TasksAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final ValueChanged<TasksFilterType>? onFilterChanged;

  const TasksAppBar({super.key, this.onFilterChanged});

  @override
  ConsumerState<TasksAppBar> createState() => _TasksAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 140);
}

class _TasksAppBarState extends ConsumerState<TasksAppBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _showSearchBar = false;
  final List<TasksFilterType> _activeFilters = [];
  final List<task_entity.TaskType> _activeTaskTypes = [];
  final List<task_entity.TaskPriority> _activePriorities = [];
  String? _selectedPlantFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handles search input changes with debouncing to optimize performance
  ///
  /// This method implements a debounce mechanism to prevent excessive search
  /// operations while the user is typing. It waits for a pause in typing before
  /// executing the actual search operation.
  ///
  /// The debounce delay is configured in TasksConstants.searchDebounceDelay
  /// to maintain consistency across the application.
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TasksConstants.searchDebounceDelay, () {
      if (mounted) {
        ref.read(tasksNotifierProvider.notifier).searchTasks(_searchController.text);
      }
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        ref.read(tasksNotifierProvider.notifier).searchTasks('');
      }
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _FilterBottomSheet(
            activeFilters: _activeFilters,
            activeTaskTypes: _activeTaskTypes,
            activePriorities: _activePriorities,
            selectedPlantFilter: _selectedPlantFilter,
            onFiltersChanged: _onFiltersChanged,
          ),
    );
  }

  void _onFiltersChanged({
    List<TasksFilterType>? filters,
    List<task_entity.TaskType>? taskTypes,
    List<task_entity.TaskPriority>? priorities,
    String? plantFilter,
  }) {
    setState(() {
      if (filters != null) _activeFilters.clear();
      if (filters != null) _activeFilters.addAll(filters);
      if (taskTypes != null) _activeTaskTypes.clear();
      if (taskTypes != null) _activeTaskTypes.addAll(taskTypes);
      if (priorities != null) _activePriorities.clear();
      if (priorities != null) _activePriorities.addAll(priorities);
      if (plantFilter != null) _selectedPlantFilter = plantFilter;
    });
    _applyAllFilters();
  }

  void _applyAllFilters() {
    final primaryFilter =
        _activeFilters.isNotEmpty ? _activeFilters.first : TasksFilterType.all;

    ref.read(tasksNotifierProvider.notifier).setAdvancedFilters(
      filter: primaryFilter,
      plantId: _selectedPlantFilter,
      taskTypes: _activeTaskTypes,
      priorities: _activePriorities,
    );
    widget.onFilterChanged?.call(primaryFilter);
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _activeTaskTypes.clear();
      _activePriorities.clear();
      _selectedPlantFilter = null;
    });
    ref.read(tasksNotifierProvider.notifier).setAdvancedFilters(
      filter: TasksFilterType.all,
      plantId: null,
      taskTypes: const [],
      priorities: const [],
    );
    widget.onFilterChanged?.call(TasksFilterType.all);
  }

  int get _totalActiveFilters {
    return _activeFilters.length +
        _activeTaskTypes.length +
        _activePriorities.length +
        (_selectedPlantFilter != null ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor:
          isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
      elevation: 0,
      title: _showSearchBar ? _buildSearchBar(theme) : _buildTitleRow(theme),
      actions: [
        IconButton(
          icon: Icon(_showSearchBar ? Icons.close : Icons.search),
          onPressed: _toggleSearchBar,
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            if (_totalActiveFilters > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_totalActiveFilters',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: ColoredBox(
          color: isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  if (_totalActiveFilters > 0) _buildActiveFilterChips(theme),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      bottom: 16,
                      top: 8,
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final tasksAsync = ref.watch(tasksNotifierProvider);
                            return tasksAsync.maybeWhen(
                              data: (tasksState) {
                                return Row(
                                  children: [
                                    _FilterButton(
                                      text: AppStrings.todayQuickFilter,
                                      isSelected:
                                          tasksState.currentFilter ==
                                          TasksFilterType.today,
                                      onTap:
                                          () => _handleFilterChange(
                                            TasksFilterType.today,
                                          ),
                                    ),
                                    const SizedBox(width: 16),
                                    _FilterButton(
                                      text: AppStrings.upcomingQuickFilterFormat
                                          .replaceAll(
                                            '%d',
                                            '${tasksState.upcomingTasksCount}',
                                          ),
                                      isSelected:
                                          tasksState.currentFilter ==
                                          TasksFilterType.upcoming,
                                      onTap:
                                          () => _handleFilterChange(
                                            TasksFilterType.upcoming,
                                          ),
                                    ),
                                  ],
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(ThemeData theme) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    return tasksAsync.maybeWhen(
      data: (tasksState) {
        return Row(
          children: [
            Icon(Icons.task_alt, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              AppStrings.tasksTitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.secondary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppStrings.totalTasksFormat.replaceAll(
                  '%d',
                  '${tasksState.totalTasks}',
                ),
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
      orElse: () => Row(
        children: [
          Icon(Icons.task_alt, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 8),
          Text(
            AppStrings.tasksTitle,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppStrings.searchTasksHint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
    );
  }

  Widget _buildActiveFilterChips(ThemeData theme) {
    final allChips = <Widget>[];
    for (final filter in _activeFilters) {
      allChips.add(
        _buildFilterChip(
          filter.displayName,
          () => _removeFilter(filter),
          theme,
        ),
      );
    }
    for (final taskType in _activeTaskTypes) {
      allChips.add(
        _buildFilterChip(
          TaskDisplayUtils.getTaskTypeName(taskType),
          () => _removeTaskType(taskType),
          theme,
        ),
      );
    }
    for (final priority in _activePriorities) {
      allChips.add(
        _buildFilterChip(
          TaskDisplayUtils.getPriorityName(priority),
          () => _removePriority(priority),
          theme,
        ),
      );
    }
    if (_selectedPlantFilter != null) {
      allChips.add(
        _buildFilterChip(
          'Planta: $_selectedPlantFilter',
          () => _removePlantFilter(),
          theme,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Wrap(spacing: 8, runSpacing: 4, children: allChips)),
          if (_totalActiveFilters > 0)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Limpar'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    VoidCallback onRemove,
    ThemeData theme,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4,
                right: 8,
                top: 6,
                bottom: 6,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFilter(TasksFilterType filter) {
    setState(() {
      _activeFilters.remove(filter);
    });
    _applyAllFilters();
  }

  void _removeTaskType(task_entity.TaskType taskType) {
    setState(() {
      _activeTaskTypes.remove(taskType);
    });
    _applyAllFilters();
  }

  void _removePriority(task_entity.TaskPriority priority) {
    setState(() {
      _activePriorities.remove(priority);
    });
    _applyAllFilters();
  }

  void _removePlantFilter() {
    setState(() {
      _selectedPlantFilter = null;
    });
    _applyAllFilters();
  }

  void _handleFilterChange(TasksFilterType filter) {
    ref.read(tasksNotifierProvider.notifier).setFilter(filter);
    widget.onFilterChanged?.call(filter);
  }
}

class _FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<TasksFilterType> activeFilters;
  final List<task_entity.TaskType> activeTaskTypes;
  final List<task_entity.TaskPriority> activePriorities;
  final String? selectedPlantFilter;
  final void Function({
    List<TasksFilterType>? filters,
    List<task_entity.TaskType>? taskTypes,
    List<task_entity.TaskPriority>? priorities,
    String? plantFilter,
  })
  onFiltersChanged;

  const _FilterBottomSheet({
    required this.activeFilters,
    required this.activeTaskTypes,
    required this.activePriorities,
    required this.selectedPlantFilter,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late List<TasksFilterType> _tempFilters;
  late List<task_entity.TaskType> _tempTaskTypes;
  late List<task_entity.TaskPriority> _tempPriorities;
  String? _tempPlantFilter;
  final TextEditingController _plantFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempFilters = List.from(widget.activeFilters);
    _tempTaskTypes = List.from(widget.activeTaskTypes);
    _tempPriorities = List.from(widget.activePriorities);
    _tempPlantFilter = widget.selectedPlantFilter;
    _plantFilterController.text = _tempPlantFilter ?? '';
  }

  @override
  void dispose() {
    _plantFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      AppStrings.filtersTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: const Text(AppStrings.clearAllFilters),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterSection(
                      AppStrings.taskStatusSection,
                      TasksFilterType.values.where(
                        (f) => f != TasksFilterType.byPlant,
                      ),
                      _tempFilters,
                      (filter) => _toggleFilter(filter),
                      (filter) => filter.displayName,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      AppStrings.taskTypeSection,
                      task_entity.TaskType.values,
                      _tempTaskTypes,
                      (type) => _toggleTaskType(type),
                      TaskDisplayUtils.getTaskTypeName,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      AppStrings.prioritySection,
                      task_entity.TaskPriority.values,
                      _tempPriorities,
                      (priority) => _togglePriority(priority),
                      TaskDisplayUtils.getPriorityName,
                    ),
                    const SizedBox(height: 24),
                    _buildPlantFilterSection(),
                    const SizedBox(height: 100), // Space for apply button
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(AppStrings.applyFilters),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection<T>(
    String title,
    Iterable<T> options,
    List<T> selectedItems,
    void Function(T) onToggle,
    String Function(T) getName,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedItems.contains(option);
                return _buildFilterChipButton(
                  getName(option),
                  isSelected,
                  () => onToggle(option),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlantFilterSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.filterByPlantSection,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _plantFilterController,
          decoration: InputDecoration(
            hintText: AppStrings.plantNameHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon:
                _tempPlantFilter != null
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _tempPlantFilter = null;
                          _plantFilterController.clear();
                        });
                      },
                    )
                    : null,
          ),
          onChanged: (value) {
            setState(() {
              _tempPlantFilter = value.isNotEmpty ? value : null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterChipButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _toggleFilter(TasksFilterType filter) {
    setState(() {
      if (_tempFilters.contains(filter)) {
        _tempFilters.remove(filter);
      } else {
        _tempFilters.clear(); // Only one status filter at a time
        _tempFilters.add(filter);
      }
    });
  }

  void _toggleTaskType(task_entity.TaskType taskType) {
    setState(() {
      if (_tempTaskTypes.contains(taskType)) {
        _tempTaskTypes.remove(taskType);
      } else {
        _tempTaskTypes.add(taskType);
      }
    });
  }

  void _togglePriority(task_entity.TaskPriority priority) {
    setState(() {
      if (_tempPriorities.contains(priority)) {
        _tempPriorities.remove(priority);
      } else {
        _tempPriorities.add(priority);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _tempFilters.clear();
      _tempTaskTypes.clear();
      _tempPriorities.clear();
      _tempPlantFilter = null;
      _plantFilterController.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      filters: _tempFilters,
      taskTypes: _tempTaskTypes,
      priorities: _tempPriorities,
      plantFilter: _tempPlantFilter,
    );
    Navigator.pop(context);
  }
}
