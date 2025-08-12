// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../constants/timeout_constants.dart';
import '../controllers/auth_controller.dart';
import '../dependency_injection.dart';
import '../models/74_75_task_attachment.dart';
import '../models/76_task_comment.dart';
import '../models/task_model.dart';
import '../services/id_generation_service.dart';
import '../widgets/create_task_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateTask();
                  break;
                case 'delete':
                  _deleteTask();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 8),
                    Text('Duplicar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskHeader(),
                  const SizedBox(height: 24),
                  _buildTaskDetails(),
                  const SizedBox(height: 24),
                  if (widget.task.tags.isNotEmpty) ...[
                    _buildTagsSection(),
                    const SizedBox(height: 24),
                  ],
                  if (widget.task.attachments.isNotEmpty) ...[
                    _buildAttachmentsSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildCommentsHeader(),
                ],
              ),
            ),
          ),
          _buildCommentsList(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // Espaço para o campo de comentário
          ),
        ],
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildTaskHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StreamBuilder<Task?>(
                  stream: DependencyContainer.instance.taskRepository.tasksStream
                      .map((tasks) => tasks.firstWhere(
                            (t) => t.id == widget.task.id,
                            orElse: () => widget.task,
                          )),
                  builder: (context, snapshot) {
                    final task = snapshot.data ?? widget.task;
                    return Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        DependencyContainer.instance.taskController
                            .toggleTaskComplete(
                          task.id,
                        );
                      },
                      shape: const CircleBorder(),
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                  ),
                ),
                StreamBuilder<Task?>(
                  stream: DependencyContainer.instance.taskRepository.tasksStream
                      .map((tasks) => tasks.firstWhere(
                            (t) => t.id == widget.task.id,
                            orElse: () => widget.task,
                          )),
                  builder: (context, snapshot) {
                    final task = snapshot.data ?? widget.task;
                    return IconButton(
                      icon: Icon(
                        task.isStarred ? Icons.star : Icons.star_border,
                        color: task.isStarred ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        DependencyContainer.instance.taskController
                            .toggleTaskStar(
                          task.id,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            if (widget.task.description != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.task.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.priority_high,
              'Prioridade',
              _getPriorityText(widget.task.priority),
              _getPriorityColor(widget.task.priority),
            ),
            if (widget.task.dueDate != null)
              _buildDetailRow(
                Icons.calendar_today,
                'Vencimento',
                DateFormat('dd/MM/yyyy').format(widget.task.dueDate!),
                widget.task.isOverdue ? Colors.red : null,
              ),
            if (widget.task.reminderDate != null)
              _buildDetailRow(
                Icons.alarm,
                'Lembrete',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(widget.task.reminderDate!),
                null,
              ),
            _buildDetailRow(
              Icons.access_time,
              'Criado em',
              DateFormat('dd/MM/yyyy HH:mm').format(
                  DateTime.fromMillisecondsSinceEpoch(widget.task.createdAt)),
              null,
            ),
            if (widget.task.updatedAt != widget.task.createdAt)
              _buildDetailRow(
                Icons.update,
                'Atualizado em',
                DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(widget.task.updatedAt)),
                null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.task.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anexos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.task.attachments.length,
              itemBuilder: (context, index) {
                final attachment = widget.task.attachments[index];
                return ListTile(
                  leading: Icon(_getFileIcon(attachment.type.name)),
                  title: Text(attachment.name),
                  subtitle: Text(_formatFileSize(attachment.size)),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadAttachment(attachment),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Row(
      children: [
        Text(
          'Comentários',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.task.comments.length}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (widget.task.comments.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Nenhum comentário ainda',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final comment = widget.task.comments[index];
          return _buildCommentItem(comment);
        },
        childCount: widget.task.comments.length,
      ),
    );
  }

  Widget _buildCommentItem(TaskComment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(comment.userId.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Adicionar comentário...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addComment,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(BuildContext context) async {
    final authController = Get.find<TodoistAuthController>();
    final taskController = DependencyContainer.instance.taskController;

    final editedTask = await showDialog<Task>(
      context: context,
      builder: (context) => CreateTaskDialog(
        listId: widget.task.listId,
        userId: authController.currentUser?.id ?? 'anonymous',
        editingTask: widget.task,
      ),
    );

    if (editedTask != null) {
      try {
        await taskController.updateTask(editedTask.id, editedTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar tarefa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _duplicateTask() async {
    final taskController = DependencyContainer.instance.taskController;

    // Usar IDGenerationService para geração segura de ID
    final idService = IDGenerationService();
    final secureTaskId = idService.generateTaskId();

    final duplicatedTask = widget.task.copyWith(
      id: secureTaskId,
      title: '${widget.task.title} (Cópia)',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isCompleted: false,
      comments: [],
      attachments: [],
    );

    try {
      await taskController.createTask(duplicatedTask);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa duplicada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao duplicar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a tarefa "${widget.task.title}"?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final taskController = DependencyContainer.instance.taskController;
      try {
        await taskController.deleteTask(widget.task.id);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa excluída com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir tarefa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final content = _commentController.text.trim();
    final authController = Get.find<TodoistAuthController>();
    final taskController = DependencyContainer.instance.taskController;

    final comment = TaskComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task.id,
      userId: authController.currentUser?.id ?? 'anonymous',
      content: content,
      createdAt: DateTime.now(),
    );

    // Adicionar comentário à tarefa
    final updatedTask = widget.task.copyWith(
      comments: [...widget.task.comments, comment],
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await taskController.updateTask(updatedTask.id, updatedTask);
      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentário adicionado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar comentário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadAttachment(TaskAttachment attachment) async {
    try {
      // Simular download - em produção seria integrado com StorageService
      await Future.delayed(TimeoutConstants.shortDelay);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Download de "${attachment.name}" simulado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar anexo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgente';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.low:
        return 'Baixa';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.yellow[700]!;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.attach_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
