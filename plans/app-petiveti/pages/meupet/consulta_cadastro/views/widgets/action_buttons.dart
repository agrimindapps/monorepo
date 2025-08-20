// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_form_controller.dart';
import '../consulta_form_view.dart';
import '../styles/consulta_form_styles.dart';

class ActionButtons extends StatelessWidget {
  final ConsultaFormController controller;
  final ConsultaFormMode mode;

  const ActionButtons({
    super.key,
    required this.controller,
    this.mode = ConsultaFormMode.fullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.state.isLoading;
      final hasErrors = controller.state.hasFieldErrors;
      final canSave = controller.canSave();
      final isEditMode = controller.isEditing;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              offset: const Offset(0, -2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasErrors) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ConsultaFormStyles.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          ConsultaFormStyles.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: ConsultaFormStyles.errorColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Corrija os erros antes de continuar',
                          style: TextStyle(
                            color: ConsultaFormStyles.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  if (isEditMode) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            isLoading ? null : () => _showDeleteDialog(context),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ConsultaFormStyles.errorColor,
                          side:
                              const BorderSide(color: ConsultaFormStyles.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => controller.duplicateConsulta(),
                        icon: const Icon(Icons.content_copy),
                        label: const Text('Duplicar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ConsultaFormStyles.primaryColor,
                          side: const BorderSide(
                              color: ConsultaFormStyles.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: isEditMode ? 2 : 1,
                    child: ElevatedButton.icon(
                      onPressed: (isLoading || !canSave)
                          ? null
                          : () => _saveConsulta(),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(isEditMode ? Icons.save : Icons.add),
                      label: Text(isEditMode ? 'Salvar' : 'Criar Consulta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConsultaFormStyles.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor:
                            ConsultaFormStyles.dividerColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (isEditMode) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed:
                            isLoading ? null : () => controller.resetForm(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restaurar'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              ConsultaFormStyles.textSecondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: isLoading ? null : () => Get.back(),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              ConsultaFormStyles.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Future<void> _saveConsulta() async {
    try {
      await controller.saveConsulta();
    } catch (e) {
      // Error handling is already done in the controller
      debugPrint('Error in action buttons: $e');
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text(
            'Tem certeza que deseja excluir esta consulta? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await controller.deleteConsulta();
                } catch (e) {
                  // Error handling is already done in the controller
                  debugPrint('Error deleting consulta: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ConsultaFormStyles.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
