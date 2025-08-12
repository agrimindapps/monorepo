// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/23_abastecimento_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../controller/abastecimento_form_controller.dart';
import '../views/abastecimento_form_view.dart';

Future<bool?> showAbastecimentoCadastroDialog(
  BuildContext context,
  AbastecimentoCar? abastecimento,
) async {
  final controller = Get.put(AbastecimentoFormController());
  await controller.initializeForm(abastecimento);

  final result = await DialogCadastro.show(
    context: context,
    title: 'Abastecimento',
    formKey: controller.formKey,
    maxHeight: 570,
    onSubmit: () async {
      debugPrint('🚗 [ABASTECIMENTO] onSubmit chamado');
      if (!controller.formModel.isLoading) {
        try {
          debugPrint('🚗 [ABASTECIMENTO] Chamando submitForm...');
          final success = await controller.submitForm(abastecimento);
          debugPrint('🚗 [ABASTECIMENTO] submitForm retornou: $success');
          // O DialogCadastro.show é responsável por fechar o dialog.
          // Não há necessidade de chamar Navigator.pop() aqui.
        } catch (e) {
          debugPrint('🚗 [ABASTECIMENTO] Erro capturado: $e');
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Erro'),
                content: Text('Erro ao salvar: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    },
    disableSubmitWhen: () => controller.formModel.isLoading,
    formWidget: (key) => const AbastecimentoFormView(),
  );

  Get.delete<AbastecimentoFormController>();
  return result;
}
