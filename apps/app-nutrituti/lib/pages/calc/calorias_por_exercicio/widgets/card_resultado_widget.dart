// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../controller/calorias_exercicio_controller.dart';

class CardResultadoWidget extends StatelessWidget {
  const CardResultadoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CaloriasExercicioController>();
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text(
              'Resultado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.share_rounded,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              onPressed: controller.compartilhar,
              tooltip: 'Compartilhar resultados',
            ),
          ),
          const Divider(
            thickness: 1,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: isDark ? Colors.orange.shade300 : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calorias Consumidas: ${controller.resultado} kCal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${controller.atividadeSelecionada.text} consome ${controller.atividadeSelecionada.value} kCal por minuto',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
