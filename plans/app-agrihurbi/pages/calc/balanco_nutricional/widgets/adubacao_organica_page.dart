// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants.dart';
import '../controllers/adubacao_organica_controller.dart';
import 'adubacao_organica_form.dart';
import 'adubacao_organica_result.dart';

class AdubacaoOrganicaPage extends StatelessWidget {
  const AdubacaoOrganicaPage({super.key});

  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError
                  ? BalancoNutricionalIcons.errorOutline
                  : BalancoNutricionalIcons.checkCircleOutline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? BalancoNutricionalColors.red900
            : BalancoNutricionalColors.green700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AdubacaoOrganicaController());
    final controller = Get.find<AdubacaoOrganicaController>();
    return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdubacaoOrganicaForm(controller: controller),
              const SizedBox(height: 16),
              AdubacaoOrganicaResult(),
              const SizedBox(height: 16),
            ],
    );
  }
}
