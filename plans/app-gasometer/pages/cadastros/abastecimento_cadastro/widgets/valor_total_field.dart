// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/abastecimento_form_controller.dart';

class ValorTotalField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const ValorTotalField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.valorTotalNotifier,
      builder: (context, value, child) {
        return InputDecorator(
          decoration: ShadcnStyle.inputDecoration(
            label: 'Valor Total',
            prefixIcon: const Icon(Icons.attach_money),
          ),
          child: Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
              decimalDigits: 2,
            ).format(value),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}
