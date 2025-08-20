// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/form_constants.dart';
import '../styles/form_styles.dart';

/// Action buttons for vaccine form
class FormButtons extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool isEnabled;
  final String? saveButtonText;
  final String? cancelButtonText;

  const FormButtons({
    super.key,
    this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.isEnabled = true,
    this.saveButtonText,
    this.cancelButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: FormConstants.spacingLarge),
      child: Row(
        children: [
          // Cancel button
          if (onCancel != null)
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onCancel,
                style: FormStyles.getSecondaryButtonStyle(
                  enabled: !isLoading,
                ),
                child: Text(cancelButtonText ?? 'Cancelar'),
              ),
            ),
          
          if (onCancel != null && onSave != null)
            const SizedBox(width: FormConstants.buttonSpacing),
          
          // Save button
          if (onSave != null)
            Expanded(
              child: ElevatedButton(
                onPressed: (isLoading || !isEnabled) ? null : onSave,
                style: FormStyles.getPrimaryButtonStyle(
                  enabled: !isLoading && isEnabled,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: FormConstants.spacingSmall),
                    ],
                    Text(
                      isLoading 
                          ? 'Salvando...' 
                          : (saveButtonText ?? 'Salvar'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Floating action button for save action
class SaveFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? tooltip;

  const SaveFloatingActionButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip ?? 'Salvar vacina',
      backgroundColor: isLoading 
          ? FormStyles.getPrimaryButtonStyle(enabled: false).backgroundColor?.resolve({})
          : null,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save),
    );
  }
}

/// Simple submit button with customizable appearance
class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final bool isPrimary;

  const SubmitButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = !isLoading && isEnabled;
    
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: FormStyles.getPrimaryButtonStyle(enabled: enabled),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon ?? Icons.check),
        label: Text(isLoading ? 'Processando...' : text),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: FormStyles.getSecondaryButtonStyle(enabled: enabled),
        icon: Icon(icon ?? Icons.check),
        label: Text(text),
      );
    }
  }
}
