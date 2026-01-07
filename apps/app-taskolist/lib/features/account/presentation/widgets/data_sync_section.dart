import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_providers.dart';
import '../../../../shared/providers/subscription_providers.dart';
import '../../../tasks/domain/get_tasks.dart';
import '../../../tasks/domain/task_entity.dart';
import '../../../tasks/providers/task_providers.dart';

/// Seção de sincronização e exportação de dados
/// Combina sync cloud + exportação JSON/CSV
class DataSyncSection extends ConsumerStatefulWidget {
  const DataSyncSection({super.key});

  @override
  ConsumerState<DataSyncSection> createState() => _DataSyncSectionState();
}

class _DataSyncSectionState extends ConsumerState<DataSyncSection> {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  @override
  Widget build(BuildContext context) {
    final syncService = ref.watch(taskManagerSyncServiceProvider);
    final isSyncing = _isSyncing || syncService.isSyncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Dados e Sincronização',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Sync Status
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSyncing ? Icons.sync : Icons.cloud_done,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                title: Text(
                  isSyncing ? 'Sincronizando...' : 'Dados Sincronizados',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _getSyncStatusMessage(isSyncing),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _syncNow,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Sincronizar agora',
                      ),
              ),
              const Divider(height: 1, indent: 72),
              // Export JSON
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.file_download,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Exportar JSON',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Backup completo em formato JSON'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _exportAsJson(context, ref),
              ),
              const Divider(height: 1, indent: 72),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.table_chart,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Exportar CSV',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Planilha para análise de dados'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _exportAsCsv(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportAsJson(BuildContext context, WidgetRef ref) async {
    try {
      // Mostra loading
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Preparando exportação...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: AppColors.info,
        ),
      );

      // Busca todas as tarefas usando o use case
      final getTasks = ref.read(getTasksProvider);
      final result = await getTasks(const GetTasksParams());

      await result.fold(
        (failure) async {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao buscar tarefas: ${failure.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        },
        (tasks) async {
          // Converte para JSON
          final jsonData = {
            'export_date': DateTime.now().toIso8601String(),
            'version': '1.0',
            'app': 'Task Manager',
            'total_tasks': tasks.length,
            'tasks': tasks
                .map(
                  (task) => {
                    'id': task.id,
                    'title': task.title,
                    'description': task.description ?? '',
                    'status': task.status.name,
                    'priority': task.priority.name,
                    'list_id': task.listId,
                    'due_date': task.dueDate?.toIso8601String(),
                    'reminder_date': task.reminderDate?.toIso8601String(),
                    'created_at': task.createdAt.toIso8601String(),
                    'updated_at': task.updatedAt.toIso8601String(),
                    'is_starred': task.isStarred,
                    'position': task.position,
                    'tags': task.tags,
                    'notes': task.notes ?? '',
                  },
                )
                .toList(),
          };

          final jsonString = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonData);

          // Salva arquivo temporário
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${directory.path}/tasks_export_$timestamp.json');
          await file.writeAsString(jsonString);

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Compartilha arquivo
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              subject: 'Exportação de Tarefas - Task Manager',
              text: 'Backup de ${tasks.length} tarefas em formato JSON',
            ),
          );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${tasks.length} tarefas exportadas com sucesso!',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro inesperado: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _exportAsCsv(BuildContext context, WidgetRef ref) async {
    try {
      // Mostra loading
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Preparando exportação...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: AppColors.info,
        ),
      );

      // Busca todas as tarefas usando o use case
      final getTasks = ref.read(getTasksProvider);
      final result = await getTasks(const GetTasksParams());

      await result.fold(
        (failure) async {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao buscar tarefas: ${failure.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        },
        (tasks) async {
          // Converte para CSV
          final csvBuffer = StringBuffer();

          // Header
          csvBuffer.writeln(
            'ID,Título,Descrição,Status,Prioridade,Lista,Data de Vencimento,'
            'Data de Lembrete,Data de Criação,Data de Atualização,Favorito,Posição,Tags,Notas',
          );

          // Dados
          for (final task in tasks) {
            csvBuffer.writeln(
              '"${_escapeCsv(task.id)}",'
              '"${_escapeCsv(task.title)}",'
              '"${_escapeCsv(task.description ?? '')}",'
              '"${_getStatusLabel(task.status)}",'
              '"${_getPriorityLabel(task.priority)}",'
              '"${_escapeCsv(task.listId)}",'
              '"${task.dueDate != null ? _formatDate(task.dueDate!) : ''}",'
              '"${task.reminderDate != null ? _formatDate(task.reminderDate!) : ''}",'
              '"${_formatDate(task.createdAt)}",'
              '"${_formatDate(task.updatedAt)}",'
              '"${task.isStarred ? 'Sim' : 'Não'}",'
              '"${task.position}",'
              '"${task.tags.join(', ')}",'
              '"${_escapeCsv(task.notes ?? '')}"',
            );
          }

          // Salva arquivo temporário
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${directory.path}/tasks_export_$timestamp.csv');
          await file.writeAsString(csvBuffer.toString());

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Compartilha arquivo
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              subject: 'Exportação de Tarefas - Task Manager',
              text: 'Planilha com ${tasks.length} tarefas em formato CSV',
            ),
          );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${tasks.length} tarefas exportadas com sucesso!',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro inesperado: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _escapeCsv(String value) {
    // Escapa aspas duplas e remove quebras de linha
    return value
        .replaceAll('"', '""')
        .replaceAll('\n', ' ')
        .replaceAll('\r', '');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendente';
      case TaskStatus.inProgress:
        return 'Em Progresso';
      case TaskStatus.completed:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }

  // Sync methods
  Future<void> _syncNow() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final subscriptionStatus = ref.read(subscriptionStatusProvider).value;
      final isPremium = subscriptionStatus == SubscriptionStatus.active;

      // Chamada real ao serviço de sincronização
      final syncService = ref.read(taskManagerSyncServiceProvider);
      final result = await syncService.syncAll(
        userId: user.id,
        isUserPremium: isPremium,
      );

      setState(() {
        _isSyncing = false;
        _lastSyncTime = DateTime.now();
      });

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erro na sincronização: ${failure.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Dados sincronizados com sucesso!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      }
    } catch (e) {
      setState(() => _isSyncing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro na sincronização: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getSyncStatusMessage(bool isSyncing) {
    if (isSyncing) {
      return 'Atualizando dados na nuvem...';
    }
    if (_lastSyncTime != null) {
      return 'Última sincronização: ${_formatSyncTime(_lastSyncTime!)}';
    }
    return 'Todos os dados estão atualizados';
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) return 'Agora mesmo';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m atrás';
    if (difference.inHours < 24) return '${difference.inHours}h atrás';

    return '${time.day}/${time.month} às ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
