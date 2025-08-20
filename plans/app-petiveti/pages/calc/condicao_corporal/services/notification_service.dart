// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../controller/condicao_corporal_controller.dart';

enum ReminderInterval {
  weekly(7, 'Semanal'),
  biweekly(14, 'Quinzenal'),
  monthly(30, 'Mensal'),
  quarterly(90, 'Trimestral');

  const ReminderInterval(this.days, this.label);
  final int days;
  final String label;
}

class NotificationService {
  static const String _remindersKey = 'condition_reminders';
  static const String _permissionKey = 'notification_permission';

  static Future<void> scheduleReminder({
    required BuildContext context,
    required CondicaoCorporalController controller,
    required ReminderInterval interval,
    String? customNote,
  }) async {
    try {
      // Verificar se há resultado para criar lembrete
      if (controller.resultado == null) {
        _showErrorSnackBar(context, 'Nenhum resultado disponível para criar lembrete.');
        return;
      }

      // Verificar permissão (simulado - em produção usaria flutter_local_notifications)
      final hasPermission = await _checkNotificationPermission();
      if (!hasPermission) {
        final granted = await _requestNotificationPermission(context);
        if (!granted) return;
      }

      // Criar dados do lembrete
      final reminder = ReminderData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        species: controller.especieSelecionada!,
        score: controller.indiceSelecionado!,
        classification: _extractClassification(controller.resultado!),
        interval: interval,
        nextDate: DateTime.now().add(Duration(days: interval.days)),
        customNote: customNote,
        createdAt: DateTime.now(),
      );

      // Salvar lembrete
      await _saveReminder(reminder);

      // Mostrar confirmação
      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          'Lembrete agendado para ${_formatDate(reminder.nextDate)}',
        );
      }
    } catch (e) {
      debugPrint('Erro ao agendar lembrete: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erro ao agendar lembrete. Tente novamente.');
      }
    }
  }

  static Future<List<ReminderData>> getActiveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList(_remindersKey) ?? [];
      
      return remindersJson
          .map((json) => ReminderData.fromJson(json))
          .where((reminder) => reminder.nextDate.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.nextDate.compareTo(b.nextDate));
    } catch (e) {
      debugPrint('Erro ao carregar lembretes: $e');
      return [];
    }
  }

  static Future<void> cancelReminder(String reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList(_remindersKey) ?? [];
      
      final updatedReminders = remindersJson
          .map((json) => ReminderData.fromJson(json))
          .where((reminder) => reminder.id != reminderId)
          .map((reminder) => reminder.toJson())
          .toList();
      
      await prefs.setStringList(_remindersKey, updatedReminders);
    } catch (e) {
      debugPrint('Erro ao cancelar lembrete: $e');
    }
  }

  static Future<void> _saveReminder(ReminderData reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey) ?? [];
    
    remindersJson.add(reminder.toJson());
    await prefs.setStringList(_remindersKey, remindersJson);
  }

  static Future<bool> _checkNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionKey) ?? false;
  }

  static Future<bool> _requestNotificationPermission(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão de Notificações'),
        content: const Text(
          'Para receber lembretes de reavaliação, é necessário permitir notificações. '
          'Deseja ativar as notificações?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionKey, true);
    }

    return result ?? false;
  }

  static String _extractClassification(String resultado) {
    final lines = resultado.split('\n');
    if (lines.isNotEmpty) {
      final classificationLine = lines[0];
      return classificationLine.replaceAll('Classificação: ', '');
    }
    return 'Classificação não encontrada';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showReminderDialog(
    BuildContext context,
    CondicaoCorporalController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ReminderDialog(controller: controller),
    );
  }

  static void showRemindersListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _RemindersListDialog(),
    );
  }
}

class ReminderData {
  final String id;
  final String species;
  final int score;
  final String classification;
  final ReminderInterval interval;
  final DateTime nextDate;
  final String? customNote;
  final DateTime createdAt;

  ReminderData({
    required this.id,
    required this.species,
    required this.score,
    required this.classification,
    required this.interval,
    required this.nextDate,
    this.customNote,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species': species,
      'score': score,
      'classification': classification,
      'interval': interval.name,
      'nextDate': nextDate.millisecondsSinceEpoch,
      'customNote': customNote,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ReminderData.fromMap(Map<String, dynamic> map) {
    return ReminderData(
      id: map['id'],
      species: map['species'],
      score: map['score'],
      classification: map['classification'],
      interval: ReminderInterval.values.firstWhere(
        (e) => e.name == map['interval'],
        orElse: () => ReminderInterval.monthly,
      ),
      nextDate: DateTime.fromMillisecondsSinceEpoch(map['nextDate']),
      customNote: map['customNote'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() {
    final map = toMap();
    return '${map['id']}|${map['species']}|${map['score']}|${map['classification']}|${map['interval']}|${map['nextDate']}|${map['customNote'] ?? ''}|${map['createdAt']}';
  }

  factory ReminderData.fromJson(String json) {
    final parts = json.split('|');
    return ReminderData(
      id: parts[0],
      species: parts[1],
      score: int.parse(parts[2]),
      classification: parts[3],
      interval: ReminderInterval.values.firstWhere(
        (e) => e.name == parts[4],
        orElse: () => ReminderInterval.monthly,
      ),
      nextDate: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[5])),
      customNote: parts[6].isEmpty ? null : parts[6],
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[7])),
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  final CondicaoCorporalController controller;

  const _ReminderDialog({required this.controller});

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  ReminderInterval _selectedInterval = ReminderInterval.monthly;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agendar Lembrete'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agende um lembrete para reavaliar a condição corporal do seu ${widget.controller.especieSelecionada?.toLowerCase()}.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Intervalo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ...ReminderInterval.values.map((interval) {
              return RadioListTile<ReminderInterval>(
                title: Text(interval.label),
                subtitle: Text('A cada ${interval.days} dias'),
                value: interval,
                groupValue: _selectedInterval,
                onChanged: (value) {
                  setState(() {
                    _selectedInterval = value!;
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
            
            const SizedBox(height: 16),
            
            const Text(
              'Nota personalizada (opcional):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Ex: Verificar peso após dieta',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            NotificationService.scheduleReminder(
              context: context,
              controller: widget.controller,
              interval: _selectedInterval,
              customNote: _noteController.text.isEmpty ? null : _noteController.text,
            );
          },
          child: const Text('Agendar'),
        ),
      ],
    );
  }
}

class _RemindersListDialog extends StatefulWidget {
  const _RemindersListDialog();

  @override
  State<_RemindersListDialog> createState() => _RemindersListDialogState();
}

class _RemindersListDialogState extends State<_RemindersListDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lembretes Ativos'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<ReminderData>>(
          future: NotificationService.getActiveReminders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reminders = snapshot.data ?? [];

            if (reminders.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum lembrete ativo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(reminder.score.toString()),
                    ),
                    title: Text('${reminder.species} - ${reminder.classification}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Próxima avaliação: ${NotificationService._formatDate(reminder.nextDate)}'),
                        if (reminder.customNote != null)
                          Text(
                            reminder.customNote!,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await NotificationService.cancelReminder(reminder.id);
                        setState(() {});
                      },
                    ),
                    isThreeLine: reminder.customNote != null,
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
