import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/create_task_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  TaskStatus _selectedFilter = TaskStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    // ref.read(taskNotifierProvider.notifier).getTasks(
    //   status: _selectedFilter,
    // );
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final tasksState = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton<TaskStatus>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _selectedFilter = status;
              });
              _loadTasks();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskStatus.pending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: TaskStatus.inProgress,
                child: Text('In Progress'),
              ),
              const PopupMenuItem(
                value: TaskStatus.completed,
                child: Text('Completed'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
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
          const Expanded(
            child: TaskListWidget(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}