// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controllers/gasto_energetico_controller.dart';

class AtividadesWidget extends StatelessWidget {
  final GastoEnergeticoController controller;

  final _tempoMask = MaskTextInputFormatter(
    mask: '#0.0',
    filter: {'#': RegExp(r'[0-9]'), '0': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  AtividadesWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 0,
      color: isDark ? Colors.black.withAlpha(51) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isDark ? Colors.amber.shade300 : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tempo em cada atividade (horas/dia)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTempoAtividadeField(
              'Dormindo',
              controller.dormirController,
              Icons.hotel,
              isDark ? Colors.indigo.shade300 : Colors.indigo,
            ),
            _buildTempoAtividadeField(
              'Deitado Acordado',
              controller.deitadoController,
              Icons.airline_seat_flat,
              isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            _buildTempoAtividadeField(
              'Sentado',
              controller.sentadoController,
              Icons.event_seat,
              isDark ? Colors.teal.shade300 : Colors.teal,
            ),
            _buildTempoAtividadeField(
              'Em Pé / Atividades Leves',
              controller.emPeController,
              Icons.accessibility_new,
              isDark ? Colors.green.shade300 : Colors.green,
            ),
            _buildTempoAtividadeField(
              'Caminhando',
              controller.caminhandoController,
              Icons.directions_walk,
              isDark ? Colors.amber.shade300 : Colors.amber,
            ),
            _buildTempoAtividadeField(
              'Exercício Intenso',
              controller.exercicioController,
              Icons.fitness_center,
              isDark ? Colors.red.shade300 : Colors.red,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: (controller.calcularTotalHoras() < 22 ||
                            controller.calcularTotalHoras() > 26)
                        ? (isDark ? Colors.red.shade300 : Colors.red)
                        : (isDark ? Colors.green.shade300 : Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total de horas: ${controller.calcularTotalHoras().toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (controller.calcularTotalHoras() < 22 ||
                              controller.calcularTotalHoras() > 26)
                          ? (isDark ? Colors.red.shade300 : Colors.red)
                          : (isDark ? Colors.green.shade300 : Colors.green),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '(ideal: 24h)',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempoAtividadeField(String label,
      TextEditingController controller, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ShadcnStyle.borderColor),
                color: ThemeManager().isDark.value
                    ? ShadcnStyle.backgroundColor
                    : Colors.white,
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'h',
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: ShadcnStyle.mutedTextColor,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_tempoMask],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
