// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/lembrete_form_controller.dart';
import '../styles/form_colors.dart';

class FormActions extends StatelessWidget {
  final LembreteFormController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const FormActions({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: LembreteFormColors.cardColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: LembreteFormColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCancelButton(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: controller.isLoading ? null : onCancel,
      style: OutlinedButton.styleFrom(
        foregroundColor: LembreteFormColors.textSecondary,
        side: const BorderSide(color: LembreteFormColors.borderColor),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Cancelar',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: controller.canSubmit() ? onSubmit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: LembreteFormColors.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: LembreteFormColors.textDisabled,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: controller.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              controller.getSubmitButtonText(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
