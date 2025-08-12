// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/timeout_constants.dart';
import '../constants/todoist_colors.dart';
import '../controllers/auth_controller.dart';
import '../dependency_injection.dart';
import '../models/background_theme.dart';
import '../models/task_grouping.dart';
import '../models/task_menu_options.dart';
import '../models/task_model.dart';
import '../providers/theme_controller.dart';
import '../services/id_generation_service.dart';
import '../services/task_stream_service.dart';
import '../widgets/grouped_task_list.dart';
import '../widgets/reorderable_task_list.dart';
import '../widgets/task_detail_side_panel.dart';
import '../widgets/task_filter_side_panel.dart';
import '../widgets/task_grouping_side_panel.dart';
import '../widgets/theme_selector_panel.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //#region === PROPERTIES ===
  // Controllers
  final _addTaskController = TextEditingController();
  final _taskStreamService = TaskStreamService();
  
  // State variables
  TaskFilter _currentFilter = TaskFilter.all;
  String? _selectedTag;
  TaskGrouping _currentGrouping = TaskGrouping.none;
  bool _isReorderMode = false;

  // Keys para otimização
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _mainContentKey = GlobalKey();
  final GlobalKey _bottomBarKey = GlobalKey();
  //#endregion

  //#region === LIFECYCLE ===
  @override
  void initState() {
    super.initState();

    // RealtimeController gerencia automaticamente o carregamento
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(context),
        child: Column(
          children: [
            // Custom AppBar
            SizedBox(
              key: _appBarKey,
              height: 120 + MediaQuery.of(context).padding.top,
              child: _buildCustomAppBar(),
            ),
            // Expanded content
            Expanded(
              key: _mainContentKey,
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        key: _bottomBarKey,
        child: _buildBottomInputBar(),
      ),
    );
  }

  @override
  void dispose() {
    _addTaskController.dispose();
    _taskStreamService.dispose();
    super.dispose();
  }
  //#endregion

  //#region === UTILITY METHODS ===
  String _getFilterKey() {
    switch (_currentFilter) {
      case TaskFilter.today:
        return 'today';
      case TaskFilter.overdue:
        return 'overdue';
      case TaskFilter.starred:
        return 'starred';
      case TaskFilter.week:
        return 'week';
      case TaskFilter.all:
      default:
        return 'all';
    }
  }

  //#endregion

  //#region === WIDGET BUILDERS ===
  Widget _buildOptimizedTaskList(AsyncSnapshot<ProcessedTaskData> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(
        key: const ValueKey('error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar tarefas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: TodoistColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: TodoistColors.subtitleColor),
            ),
          ],
        ),
      );
    }

    final data = snapshot.data;
    if (data == null || data.isEmpty) {
      String emptyMessage = 'Nenhuma tarefa encontrada';
      String emptySubMessage =
          'Tente ajustar os filtros ou adicionar uma nova tarefa.';

      if (_currentFilter == TaskFilter.all && _selectedTag == null) {
        emptyMessage = 'Nenhuma tarefa ainda';
        emptySubMessage = 'Adicione sua primeira tarefa acima!';
      }

      return Center(
        key: const ValueKey('empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: TodoistColors.dividerColor,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: TodoistColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubMessage,
              style: TextStyle(color: TodoistColors.subtitleColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Se agrupamento estiver ativo, usar a lista agrupada
    if (_currentGrouping != TaskGrouping.none && data.groups != null) {
      final taskGroups = data.groups!.entries
          .map((entry) => TaskGroup(
                id: entry.key,
                title: entry.key,
                subtitle:
                    '${entry.value.length} tarefa${entry.value.length != 1 ? 's' : ''}',
                tasks: entry.value,
              ))
          .toList();

      return GroupedTaskList(
        key: ValueKey('grouped_${_currentGrouping.name}'),
        groups: taskGroups,
        onTaskTap: (task) => _openTaskSidePanel(context, task),
        onCompletedChanged: (taskId, completed) {
          DependencyContainer.instance.taskController
              .toggleTaskComplete(taskId);
        },
        onStarToggle: (taskId, starred) {
          DependencyContainer.instance.taskController.toggleTaskStar(taskId);
        },
      );
    }

    // Lista normal ou com reordenação
    return ReorderableTaskList(
      key: ValueKey('list_${data.tasks.length}'),
      tasks: data.tasks,
      isReorderMode: _isReorderMode,
      onTaskTap: (task) => _openTaskSidePanel(context, task),
      onCompletedChanged: (taskId, completed) {
        DependencyContainer.instance.taskController.toggleTaskComplete(taskId);
      },
      onStarToggle: (taskId, starred) {
        DependencyContainer.instance.taskController.toggleTaskStar(taskId);
      },
      onReorder: (oldIndex, newIndex) {
        // TODO: Implementar reordenação
      },
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    final themeController = Get.find<TodoistThemeController>();
    return themeController.currentTheme.decoration;
  }

  Widget _buildMainContent() {
    // Use o novo service para stream otimizada
    return StreamBuilder<ProcessedTaskData>(
      stream: _taskStreamService.getProcessedTaskStream(
        filterKey: _getFilterKey(),
        selectedTag: _selectedTag,
        grouping: _currentGrouping,
        limit: _currentFilter == TaskFilter.all &&
                _selectedTag == null &&
                _currentGrouping == TaskGrouping.none
            ? 10
            : null,
      ),
      builder: (context, snapshot) {
        return _buildOptimizedTaskList(snapshot);
      },
    );
  }

  Widget _buildCustomAppBar() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: TodoistColors.backgroundColor,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(() {
                final authController = Get.find<TodoistAuthController>();
                  return Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: TodoistColors.appBarColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Botão de menu lateral (lado esquerdo)
                          GestureDetector(
                            onTap: () => _openFilterSidePanel(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          // Conteúdo central
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getFilterTitle(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                StreamBuilder<int>(
                                  stream: _taskStreamService
                                      .getTaskCountStream(_getFilterKey()),
                                  builder: (context, snapshot) {
                                    final totalTasks = snapshot.data ?? 0;
                                    return Text(
                                      '$totalTasks tarefas',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Menu de opções
                          _buildOptionsMenu(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<TaskMenuOption>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 20,
        ),
      ),
      onSelected: _onMenuOptionSelected,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, 50),
      itemBuilder: (BuildContext context) {
        return TaskMenuOption.values.map((option) {
          final isActive = option.isActive(_isReorderMode);
          final isToggleable = option.isToggleable(_isReorderMode);

          return PopupMenuItem<TaskMenuOption>(
            value: option,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? TodoistColors.primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isToggleable && isActive ? Icons.check : option.icon,
                    color: isActive
                        ? TodoistColors.primaryColor
                        : TodoistColors.subtitleColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? TodoistColors.primaryColor
                              : TodoistColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive
                              ? TodoistColors.primaryColor
                                  .withValues(alpha: 0.7)
                              : TodoistColors.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToggleable && isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: TodoistColors.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'ATIVO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: () {
            // Focar no campo de texto quando tocar no container
            FocusScope.of(context).requestFocus(FocusNode());
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Ícone de + mais destacado
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: TodoistColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 14,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                // Campo de input
                Expanded(
                  child: TextField(
                    controller: _addTaskController,
                    decoration: InputDecoration(
                      hintText: 'Adicionar uma tarefa',
                      hintStyle: TextStyle(
                        color: TodoistColors.hintColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: TodoistColors.textColor,
                      fontWeight: FontWeight.w400,
                    ),
                    onSubmitted: (value) => _addQuickTask(value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addQuickTask(String title) {
    if (title.trim().isEmpty) return;

    final authController = Get.find<TodoistAuthController>();
    final now = DateTime.now();

    // Obter a próxima posição na lista
    int nextPosition = 0; // Simplificado por enquanto

    // Usar IDGenerationService para geração segura de ID
    final idService = IDGenerationService();
    final secureTaskId = idService.generateTaskId();

    final task = Task(
      id: secureTaskId,
      title: title.trim(),
      listId: 'default', // Lista padrão para tarefas da home
      createdById: authController.currentUser?.id ?? 'anonymous',
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
      dueDate:
          DateTime(now.year, now.month, now.day), // Marcar como tarefa de hoje
      position: nextPosition,
    );

    // Criar tarefa usando o provider apropriado
    _createTaskQuick(task);

    // Limpar o campo
    _addTaskController.clear();
  }

  void _createTaskQuick(Task task) async {
    await DependencyContainer.instance.taskController.createTask(task);
  }

  void _openTaskSidePanel(BuildContext context, Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Permite transparência
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: TimeoutConstants.mediumAnimation,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height,
                child: TaskDetailSidePanel(task: task),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Vem da direita
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _openFilterSidePanel() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: TimeoutConstants.mediumAnimation,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Material(
              type: MaterialType.transparency,
              child: TaskFilterSidePanel(
                onFilterChanged: _onFilterChanged,
                currentFilter: _currentFilter,
                currentSelectedTag: _selectedTag,
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0), // Vem da esquerda
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _openGroupingSidePanel() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: TimeoutConstants.mediumAnimation,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              type: MaterialType.transparency,
              child: TaskGroupingSidePanel(
                onGroupingChanged: _onGroupingChanged,
                currentGrouping: _currentGrouping,
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Vem da direita
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _onFilterChanged(TaskFilter filter, String? selectedTag) {
    setState(() {
      _currentFilter = filter;
      _selectedTag = selectedTag;
    });

    // Aplicar o filtro
    _applyFilter(filter, selectedTag);

    // Fechar o painel de filtros
    Navigator.of(context).pop();
  }

  void _onMenuOptionSelected(TaskMenuOption option) {
    switch (option) {
      case TaskMenuOption.reorder:
        _toggleReorderMode();
        break;
      case TaskMenuOption.grouping:
        _openGroupingSidePanel();
        break;
      case TaskMenuOption.customize:
        _openThemeSelector();
        break;
      case TaskMenuOption.settings:
        _openSettingsScreen();
        break;
    }
  }

  void _onGroupingChanged(TaskGrouping grouping) {
    setState(() {
      _currentGrouping = grouping;
    });

    // Fechar o painel de agrupamento
    Navigator.of(context).pop();
  }

  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
    });

    // Mostrar feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isReorderMode
              ? 'Modo reordenação ativado - arraste para reorganizar'
              : 'Modo reordenação desativado',
        ),
        duration: TimeoutConstants.mediumDelay,
        backgroundColor:
            _isReorderMode ? const Color(0xFF4CAF50) : const Color(0xFF666666),
      ),
    );
  }

  void _onTaskReorder(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    // Ajustar newIndex se necessário
    if (newIndex > oldIndex) newIndex--;

    // Implementar reordenação via controller
    try {
      // Funcionalidade de reordenação será implementada no controller
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao reordenar tarefas'),
            backgroundColor: Colors.red,
            duration: TimeoutConstants.mediumDelay,
          ),
        );
      }
    }
  }

  void _applyFilter(TaskFilter filter, String? selectedTag) {
    // O filtro é aplicado no _getFilteredTasksStream()
    // Nenhuma ação adicional necessária aqui
  }

  String _getFilterTitle() {
    if (_selectedTag != null) {
      return 'Tag: $_selectedTag';
    }

    switch (_currentFilter) {
      case TaskFilter.today:
        return 'Hoje';
      case TaskFilter.overdue:
        return 'Vencidas';
      case TaskFilter.starred:
        return 'Favoritas';
      case TaskFilter.week:
        return 'Esta Semana';
      case TaskFilter.all:
        return 'Minhas Tarefas';
    }
  }

  void _openThemeSelector() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Center(
              child: ThemeSelectorPanel(),
            ),
          ),
        ),
        opaque: false,
        transitionDuration: TimeoutConstants.mediumAnimation,
        reverseTransitionDuration: TimeoutConstants.mediumAnimation,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  //#region === EVENT HANDLERS ===
  void _openSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
  //#endregion
}
