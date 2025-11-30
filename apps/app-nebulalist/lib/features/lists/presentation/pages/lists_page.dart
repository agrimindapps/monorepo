import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../../core/providers/services_providers.dart';
import '../providers/lists_provider.dart';
import '../widgets/create_list_dialog.dart';
import '../widgets/list_card.dart';
import '../widgets/list_empty_state.dart';

/// Lists page - main view showing all user lists
/// Uses ConsumerWidget for Riverpod state management
class ListsPage extends ConsumerWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(listsProvider);
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const ListEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(listsProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return ListCard(
                  list: list,
                  onTap: () => _navigateToDetail(context, list.id),
                  onEdit: () => _showEditDialog(context, ref, list),
                  onDelete: () => _deleteList(context, ref, list.id),
                  onToggleFavorite: () => _toggleFavorite(ref, list),
                  onSetReminder: () => _showReminderDialog(context, ref, list),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar listas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(listsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String listId) {
    context.push('/list/$listId');
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => CreateListDialog(ref: ref),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic list,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => CreateListDialog(ref: ref, existingList: list),
    );
  }

  Future<void> _deleteList(
    BuildContext context,
    WidgetRef ref,
    String listId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar Lista'),
        content: const Text(
          'Tem certeza que deseja arquivar esta lista? '
          'Você poderá restaurá-la depois nas configurações.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(listsProvider.notifier).deleteList(listId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista arquivada com sucesso')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(WidgetRef ref, dynamic list) async {
    await ref.read(listsProvider.notifier).toggleFavorite(list);
  }

  Future<void> _showReminderDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic list,
  ) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data do lembrete',
    );

    if (selectedDate == null || !context.mounted) return;

    // Show time picker
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Selecione o horário do lembrete',
    );

    if (selectedTime == null || !context.mounted) return;

    // Combine date and time
    final reminderDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Check if the selected time is in the future
    if (reminderDateTime.isBefore(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O lembrete deve ser agendado para o futuro'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Schedule notification
      final notificationService = ref.read(appNotificationServiceProvider);
      await notificationService.scheduleListReminder(
        listId: list.id,
        listName: list.name,
        reminderTime: reminderDateTime,
      );

      // Track reminder event
      await ref
          .read(appAnalyticsServiceProvider)
          .logEvent(
            'list_reminder_set',
            parameters: {
              'list_id': list.id,
              'reminder_time': reminderDateTime.toIso8601String(),
            },
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lembrete agendado para ${_formatDateTime(reminderDateTime)}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar lembrete: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$minute';
  }
}
