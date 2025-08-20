// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/despesa_form_controller.dart';
import '../styles/despesa_form_styles.dart';

class ActionButtons extends StatelessWidget {
  final DespesaFormController controller;

  const ActionButtons({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final formState = controller.formState.value;
      final isSubmitting = formState.isSubmitting;
      final canSubmit = formState.canSubmit && controller.formModel.value.isValid;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : _handleCancel,
                  style: DespesaFormStyles.outlineButtonStyle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, size: 20),
                      SizedBox(width: 8),
                      Text('Cancelar'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (canSubmit && !isSubmitting) ? _handleSave : null,
                  style: DespesaFormStyles.primaryButtonStyle,
                  child: isSubmitting 
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Salvando...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.getFormTitle().contains('Editar') ? Icons.save : Icons.add,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(controller.getSubmitButtonText()),
                          ],
                        ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (controller.getFormTitle().contains('Editar')) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : _handleDuplicate,
                    style: DespesaFormStyles.outlineButtonStyle.copyWith(
                      foregroundColor: WidgetStateProperty.all(DespesaFormStyles.secondaryColor),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: DespesaFormStyles.secondaryColor, width: 1.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 8),
                        Text('Duplicar'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : _handleDelete,
                    style: DespesaFormStyles.outlineButtonStyle.copyWith(
                      foregroundColor: WidgetStateProperty.all(DespesaFormStyles.errorColor),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: DespesaFormStyles.errorColor, width: 1.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Excluir'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  void _handleCancel() {
    if (controller.formModel.value.isValid && controller.formState.value.hasChanges) {
      Get.dialog(
        AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text(
            'Você possui alterações não salvas. Deseja realmente sair sem salvar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Continuar editando'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: DespesaFormStyles.dangerButtonStyle,
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }

  void _handleSave() {
    if (controller.formKey.currentState?.validate() ?? false) {
      controller.submitForm();
    } else {
      Get.snackbar(
        'Erro de validação',
        'Por favor, corrija os erros antes de salvar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DespesaFormStyles.errorColor,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handleDuplicate() {
    Get.dialog(
      AlertDialog(
        title: const Text('Duplicar despesa'),
        content: const Text(
          'Deseja criar uma nova despesa com os mesmos dados desta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement duplicate functionality
              Get.snackbar('Info', 'Funcionalidade de duplicar ainda não implementada');
            },
            style: DespesaFormStyles.secondaryButtonStyle,
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir despesa'),
        content: const Text(
          'Tem certeza que deseja excluir esta despesa? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Delete current despesa (only available in edit mode)
              final success = await controller.deleteCurrentDespesa();
              if (success) {
                Get.back(); // Return to previous screen
                Get.snackbar(
                  'Sucesso',
                  'Despesa excluída com sucesso!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            style: DespesaFormStyles.dangerButtonStyle,
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
