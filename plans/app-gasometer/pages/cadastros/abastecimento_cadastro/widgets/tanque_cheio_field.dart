// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/abastecimento_form_controller.dart';

class TanqueCheioField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const TanqueCheioField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.tanqueCheioNotifier,
      builder: (context, tanqueCheio, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tanque Cheio',
                style: TextStyle(fontSize: 14),
              ),
              Switch(
                value: tanqueCheio,
                onChanged: controller.updateTanqueCheio,
                activeColor: ShadcnStyle.focusColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
