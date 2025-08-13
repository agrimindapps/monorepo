// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/abastecimento_form_controller.dart';

class TanqueCheioField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const TanqueCheioField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.tanqueCheioNotifier,
      builder: (context, tanqueCheio, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: tanqueCheio
                  ? [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.orange.withValues(alpha: 0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: tanqueCheio
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tanqueCheio
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tanqueCheio
                      ? Icons.local_gas_station
                      : Icons.local_gas_station_outlined,
                  size: 20,
                  color: tanqueCheio ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanque Cheio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeManager().isDark.value
                            ? Colors.white
                            : ShadcnStyle.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tanqueCheio
                          ? 'Abastecimento completo'
                          : 'Abastecimento parcial',
                      style: TextStyle(
                        fontSize: 12,
                        color: tanqueCheio
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.1,
                child: Switch(
                  value: tanqueCheio,
                  onChanged: controller.updateTanqueCheio,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.orange,
                  inactiveTrackColor: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
