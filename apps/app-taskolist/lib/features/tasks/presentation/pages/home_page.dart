import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/enums/task_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/sample_data.dart';
import '../../../../shared/widgets/bottom_input_bar.dart';
import '../../../../shared/widgets/filter_side_panel.dart';
import '../../../../shared/widgets/modern_drawer.dart';
import '../../../../shared/widgets/premium_banner.dart';
import '../../../../shared/widgets/task_detail_drawer.dart';
import '../../../../shared/widgets/task_list_widget.dart';
import '../../domain/task_entity.dart';
import '../providers/task_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  TaskStatus _selectedFilter = TaskStatus.pending;
  TaskFilter _taskFilter = TaskFilter.all;
  String? _selectedTag;
  TaskEntity? _selectedTask;
  late AnimationController _drawerAnimationController;
  late Animation<Offset> _drawerSlideAnimation;
  late AnimationController _filterDrawerAnimationController;
  late Animation<Offset> _filterDrawerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _filterDrawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterDrawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _filterDrawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTasks();
        _loadSampleDataIfEmpty();
      }
    });
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _filterDrawerAnimationController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    ref.read(taskProvider.notifier).getTasks(status: _selectedFilter);
  }

  Future<void> _loadSampleDataIfEmpty() async {
    if (!mounted) return;
    
    try {
      const tasksRequest = GetTasksRequest();
      final tasks = await ref.read<Future<List<TaskEntity>>>(getTasksFutureProvider(tasksRequest).future);
      if (!mounted) return;
      
      if (tasks.isEmpty) {
        final sampleTasks = SampleData.getSampleTasks();
        for (final task in sampleTasks) {
          if (!mounted) return;
          await ref.read<TaskNotifier>(taskProvider.notifier).createTask(task);
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      final sampleTasks = SampleData.getSampleTasks();
      for (final task in sampleTasks) {
        if (!mounted) return;
        await ref.read<TaskNotifier>(taskProvider.notifier).createTask(task);
      }
    }
  }

  void _openTaskDrawer(TaskEntity task) {
    setState(() {
      _selectedTask = task;
    });
    _drawerAnimationController.forward();
  }

  void _closeTaskDrawer() {
    _drawerAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedTask = null;
        });
      }
    });
  }

  void _openFilterDrawer() {
    _filterDrawerAnimationController.forward();
  }

  void _closeFilterDrawer() {
    _filterDrawerAnimationController.reverse();
  }

  void _onFilterChanged(TaskFilter filter, String? selectedTag) {
    setState(() {
      _taskFilter = filter;
      _selectedTag = selectedTag;
    });
    _closeFilterDrawer();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            drawer: const ModernDrawer(),
            appBar: AppBar(
              title: const Text('Task Manager'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Filtros',
                  onPressed: _openFilterDrawer,
                ),
                PopupMenuButton<TaskStatus>(
                  icon: const Icon(Icons.filter_list_rounded),
                  tooltip: 'Status das Tarefas',
                  onSelected: (status) {
                    setState(() {
                      _selectedFilter = status;
                    });
                    _loadTasks();
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: TaskStatus.pending,
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                color: AppColors.pendingColor,
                              ),
                              SizedBox(width: 8),
                              Text('Pendentes'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: TaskStatus.inProgress,
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_rounded,
                                color: AppColors.inProgressColor,
                              ),
                              SizedBox(width: 8),
                              Text('Em Progresso'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: TaskStatus.completed,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.completedColor,
                              ),
                              SizedBox(width: 8),
                              Text('Concluídas'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            body: Column(
              children: [
                const PremiumBanner(),

                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tasks: ${_selectedFilter.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TaskListWidget(
                    onTaskTap: _openTaskDrawer,
                    taskFilter: _taskFilter,
                    selectedTag: _selectedTag,
                  ),
                ),
                const BottomInputBar(),
              ],
            ),
          ),
          if (_selectedTask != null)
            GestureDetector(
              onTap: _closeTaskDrawer,
              child: Container(
                color: AppColors.overlay,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          AnimatedBuilder(
            animation: _filterDrawerAnimationController,
            builder: (context, child) {
              if (_filterDrawerAnimationController.value == 0.0) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: _closeFilterDrawer,
                child: Container(
                  color: AppColors.overlay.withValues(
                    alpha: _filterDrawerAnimationController.value * 0.5,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SlideTransition(
              position: _filterDrawerSlideAnimation,
              child: FilterSidePanel(
                onFilterChanged: _onFilterChanged,
                currentFilter: _taskFilter,
                currentSelectedTag: _selectedTag,
              ),
            ),
          ),
          if (_selectedTask != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SlideTransition(
                position: _drawerSlideAnimation,
                child: TaskDetailDrawer(
                  task: _selectedTask!,
                  onClose: _closeTaskDrawer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
