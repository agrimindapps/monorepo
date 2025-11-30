// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controller/calorias_exercicio_controller.dart';

class CaloriasExercicioResultWidget extends StatelessWidget {
  final CaloriasExercicioController controller;

  const CaloriasExercicioResultWidget({
    super.key,
    required this.controller,
  });

  void _compartilhar() {
    final texto = controller.gerarTextoCompartilhamento();
    if (texto.isNotEmpty) {
      SharePlus.instance.share(ShareParams(text: texto));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.calculado) return const SizedBox.shrink();

        return Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  onPressed: _compartilhar,
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
                          color:
                              isDark ? Colors.orange.shade300 : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Calorias Consumidas: ${controller.resultado.toStringAsFixed(1)} kCal',
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
                          color:
                              isDark ? Colors.indigo.shade300 : Colors.indigo,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${controller.atividadeSelecionada?.nome ?? ''} consome ${controller.atividadeSelecionada?.caloriasMinuto ?? 0} kCal por minuto',
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
      },
    );
  }
}
