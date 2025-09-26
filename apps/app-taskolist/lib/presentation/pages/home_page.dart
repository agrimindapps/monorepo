import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../core/enums/task_filter.dart';
import '../../core/utils/sample_data.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import '../widgets/bottom_input_bar.dart';
import '../widgets/filter_side_panel.dart';
import '../widgets/modern_drawer.dart';
import '../widgets/premium_banner.dart';
import '../widgets/task_detail_drawer.dart';
import '../widgets/task_list_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
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
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _filterDrawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterDrawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterDrawerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
      _loadSampleDataIfEmpty();
    });
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _filterDrawerAnimationController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    ref.read(taskNotifierProvider.notifier).getTasks(
      status: _selectedFilter,
    );
  }

  Future<void> _loadSampleDataIfEmpty() async {
    try {
      // Buscar tasks existentes usando o provider
      const tasksRequest = GetTasksRequest();
      final tasks = await ref.read(getTasksProvider(tasksRequest).future);
      
      // Se não há tasks, carregar dados de exemplo
      if (tasks.isEmpty) {
        final sampleTasks = SampleData.getSampleTasks();
        for (final task in sampleTasks) {
          await ref.read(taskNotifierProvider.notifier).createTask(task);
        }
      }
    } catch (e) {
      // Se houve erro ao buscar tasks, ainda assim carregar dados de exemplo
      final sampleTasks = SampleData.getSampleTasks();
      for (final task in sampleTasks) {
        await ref.read(taskNotifierProvider.notifier).createTask(task);
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
    // Reload tasks com o novo filtro
    _loadTasks();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // Main content
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
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: TaskStatus.pending,
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Pendentes'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: TaskStatus.inProgress,
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_rounded, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Em Progresso'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: TaskStatus.completed,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green),
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
                // Premium Banner
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

          // Overlay quando drawer está aberto
          if (_selectedTask != null)
            GestureDetector(
              onTap: _closeTaskDrawer,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Filter Side Panel Overlay
          AnimatedBuilder(
            animation: _filterDrawerAnimationController,
            builder: (context, child) {
              if (_filterDrawerAnimationController.value == 0.0) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: _closeFilterDrawer,
                child: Container(
                  color: Colors.black54.withValues(
                    alpha: _filterDrawerAnimationController.value * 0.5,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),

          // Filter Side Panel
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

          // Task Detail Drawer
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