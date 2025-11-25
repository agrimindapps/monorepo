// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/meditacao_provider.dart';

class MeditacaoNotificationWidget extends ConsumerWidget {
  const MeditacaoNotificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificacoesHabilitadas = ref.watch(
      meditacaoProvider.select((state) => state.notificacoesHabilitadas),
    );
    final horarioNotificacao = ref.watch(
      meditacaoProvider.select((state) => state.horarioNotificacao),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active),
                const SizedBox(width: 8),
                const Text(
                  'Lembrete Diário de Meditação',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: notificacoesHabilitadas,
                  onChanged: (value) {
                    ref
                        .read(meditacaoProvider.notifier)
                        .alternarNotificacoes(value);
                  },
                ),
              ],
            ),
            if (notificacoesHabilitadas)
              Row(
                children: [
                  const Text('Horário: '),
                  TextButton(
                    onPressed: () => _selecionarHorario(context, ref),
                    child: Text(_formatTimeOfDay(horarioNotificacao)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Format TimeOfDay
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Open time picker
  Future<void> _selecionarHorario(BuildContext context, WidgetRef ref) async {
    final horarioAtual = ref.read(
      meditacaoProvider.select((state) => state.horarioNotificacao),
    );

    final horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: horarioAtual,
    );

    if (horarioSelecionado != null) {
      ref
          .read(meditacaoProvider.notifier)
          .definirHorarioNotificacao(horarioSelecionado);
    }
  }
}
