// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/meditacao_controller.dart';

class MeditacaoNotificationWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoNotificationWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
                Obx(() => Switch(
                      value: controller.notificacoesHabilitadas.value,
                      onChanged: (value) =>
                          controller.alternarNotificacoes(value),
                    )),
              ],
            ),
            Obx(() {
              if (!controller.notificacoesHabilitadas.value) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  const Text('Horário: '),
                  TextButton(
                    onPressed: () => _selecionarHorario(context),
                    child: Text(
                      _formatTimeOfDay(controller.horarioNotificacao.value),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Formatar TimeOfDay
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Abrir seletor de horário
  Future<void> _selecionarHorario(BuildContext context) async {
    final horarioAtual = controller.horarioNotificacao.value;

    final horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: horarioAtual,
    );

    if (horarioSelecionado != null) {
      controller.definirHorarioNotificacao(horarioSelecionado);
    }
  }
}
