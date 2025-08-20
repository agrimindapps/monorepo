// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';
import 'shared_error_display.dart';

/// Configuração para botões de ação
class ActionButtonConfig {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final bool isPrimary;
  final bool isDestructive;

  const ActionButtonConfig({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.isPrimary = false,
    this.isDestructive = false,
  });
}

/// Widget de botões de ação unificado para todos os formulários de cadastro
class SharedActionButtons extends StatelessWidget {
  final bool isLoading;
  final bool hasErrors;
  final bool canSave;
  final bool isEditMode;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onReset;
  final String? errorMessage;
  final bool showDeleteButton;
  final bool showDuplicateButton;
  final bool showResetButton;
  final String? saveLabel;
  final String? createLabel;
  final bool compactMode;
  final EdgeInsets? padding;
  final List<ActionButtonConfig>? customButtons;

  const SharedActionButtons({
    super.key,
    this.isLoading = false,
    this.hasErrors = false,
    this.canSave = true,
    this.isEditMode = false,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.onDuplicate,
    this.onReset,
    this.errorMessage,
    this.showDeleteButton = true,
    this.showDuplicateButton = true,
    this.showResetButton = true,
    this.saveLabel,
    this.createLabel,
    this.compactMode = false,
    this.padding,
    this.customButtons,
  });

  /// Factory para consulta
  factory SharedActionButtons.consulta({
    required bool isLoading,
    required bool hasErrors,
    required bool canSave,
    required bool isEditMode,
    VoidCallback? onSave,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    VoidCallback? onDuplicate,
    VoidCallback? onReset,
    String? errorMessage,
  }) {
    return SharedActionButtons(
      isLoading: isLoading,
      hasErrors: hasErrors,
      canSave: canSave,
      isEditMode: isEditMode,
      onSave: onSave,
      onCancel: onCancel,
      onDelete: onDelete,
      onDuplicate: onDuplicate,
      onReset: onReset,
      errorMessage: errorMessage,
      saveLabel: 'Salvar',
      createLabel: 'Criar Consulta',
    );
  }

  /// Factory para despesa
  factory SharedActionButtons.despesa({
    required bool isLoading,
    required bool hasErrors,
    required bool canSave,
    required bool isEditMode,
    VoidCallback? onSave,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    VoidCallback? onDuplicate,
    VoidCallback? onReset,
    String? errorMessage,
  }) {
    return SharedActionButtons(
      isLoading: isLoading,
      hasErrors: hasErrors,
      canSave: canSave,
      isEditMode: isEditMode,
      onSave: onSave,
      onCancel: onCancel,
      onDelete: onDelete,
      onDuplicate: onDuplicate,
      onReset: onReset,
      errorMessage: errorMessage,
      saveLabel: 'Salvar',
      createLabel: 'Criar Despesa',
    );
  }

  /// Factory para lembrete
  factory SharedActionButtons.lembrete({
    required bool isLoading,
    required bool hasErrors,
    required bool canSave,
    required bool isEditMode,
    VoidCallback? onSave,
    VoidCallback? onCancel,
    VoidCallback? onDelete,
    VoidCallback? onReset,
    String? errorMessage,
  }) {
    return SharedActionButtons(
      isLoading: isLoading,
      hasErrors: hasErrors,
      canSave: canSave,
      isEditMode: isEditMode,
      onSave: onSave,
      onCancel: onCancel,
      onDelete: onDelete,
      onReset: onReset,
      errorMessage: errorMessage,
      saveLabel: 'Salvar',
      createLabel: 'Criar Lembrete',
      showDuplicateButton: false, // Lembretes não precisam de duplicar
    );
  }

  /// Factory compacto para modais
  factory SharedActionButtons.compact({
    required bool isLoading,
    required bool canSave,
    VoidCallback? onSave,
    VoidCallback? onCancel,
    String? saveLabel,
  }) {
    return SharedActionButtons(
      isLoading: isLoading,
      canSave: canSave,
      onSave: onSave,
      onCancel: onCancel,
      compactMode: true,
      showDeleteButton: false,
      showDuplicateButton: false,
      showResetButton: false,
      saveLabel: saveLabel ?? FormConstants.saveLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? FormStyles.defaultPadding,
      decoration: _getContainerDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasErrors && !compactMode) ...[
              _buildErrorBanner(),
              const SizedBox(height: FormStyles.mediumSpacing),
            ],
            if (compactMode)
              _buildCompactButtons()
            else
              _buildFullButtons(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getContainerDecoration() {
    if (compactMode) return const BoxDecoration();
    
    return BoxDecoration(
      color: FormStyles.surfaceColor,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          offset: const Offset(0, -2),
          blurRadius: FormStyles.mediumElevation,
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return SharedErrorDisplay.error(
      message: errorMessage ?? 'Corrija os erros antes de continuar',
      dismissible: false,
    );
  }

  Widget _buildCompactButtons() {
    return Row(
      children: [
        if (onCancel != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: FormStyles.getSecondaryButtonStyle(),
              child: const Text(FormConstants.cancelLabel),
            ),
          ),
          const SizedBox(width: FormStyles.mediumSpacing),
        ],
        Expanded(
          flex: onCancel != null ? 1 : 2,
          child: ElevatedButton(
            onPressed: (isLoading || !canSave) ? null : onSave,
            style: FormStyles.getPrimaryButtonStyle(),
            child: isLoading
                ? _buildLoadingIndicator()
                : Text(saveLabel ?? FormConstants.saveLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildFullButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (isEditMode && showDeleteButton && onDelete != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : () => _showDeleteDialog(),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(FormConstants.deleteLabel),
                  style: FormStyles.getSecondaryButtonStyle(
                    borderColor: FormStyles.errorColor,
                  ).copyWith(
                    foregroundColor: WidgetStateProperty.all(FormStyles.errorColor),
                  ),
                ),
              ),
              const SizedBox(width: FormStyles.smallSpacing),
            ],
            if (isEditMode && showDuplicateButton && onDuplicate != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onDuplicate,
                  icon: const Icon(Icons.content_copy),
                  label: const Text(FormConstants.duplicateLabel),
                  style: FormStyles.getSecondaryButtonStyle(),
                ),
              ),
              const SizedBox(width: FormStyles.smallSpacing),
            ],
            if (customButtons != null) ...[
              for (final button in customButtons!) ...[
                Expanded(
                  child: _buildCustomButton(button),
                ),
                const SizedBox(width: FormStyles.smallSpacing),
              ],
            ],
            Expanded(
              flex: _getMainButtonFlex(),
              child: ElevatedButton.icon(
                onPressed: (isLoading || !canSave) ? null : onSave,
                icon: isLoading
                    ? _buildLoadingIndicator()
                    : Icon(isEditMode ? Icons.save : Icons.add),
                label: Text(_getSaveButtonLabel()),
                style: FormStyles.getPrimaryButtonStyle(),
              ),
            ),
          ],
        ),
        if (isEditMode && (showResetButton || onCancel != null)) ...[
          const SizedBox(height: FormStyles.smallSpacing),
          Row(
            children: [
              if (showResetButton && onReset != null) ...[
                Expanded(
                  child: TextButton.icon(
                    onPressed: isLoading ? null : onReset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restaurar'),
                    style: TextButton.styleFrom(
                      foregroundColor: FormStyles.disabledColor,
                    ),
                  ),
                ),
                const SizedBox(width: FormStyles.smallSpacing),
              ],
              if (onCancel != null) ...[
                Expanded(
                  child: TextButton.icon(
                    onPressed: isLoading ? null : onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text(FormConstants.cancelLabel),
                    style: TextButton.styleFrom(
                      foregroundColor: FormStyles.disabledColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCustomButton(ActionButtonConfig config) {
    if (config.isPrimary) {
      return ElevatedButton.icon(
        onPressed: config.isLoading ? null : config.onPressed,
        icon: config.isLoading ? _buildLoadingIndicator() : Icon(config.icon),
        label: Text(config.label),
        style: FormStyles.getPrimaryButtonStyle(
          backgroundColor: config.color,
        ),
      );
    } else if (config.isDestructive) {
      return OutlinedButton.icon(
        onPressed: config.isLoading ? null : config.onPressed,
        icon: Icon(config.icon),
        label: Text(config.label),
        style: FormStyles.getSecondaryButtonStyle(
          borderColor: FormStyles.errorColor,
        ).copyWith(
          foregroundColor: WidgetStateProperty.all(FormStyles.errorColor),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: config.isLoading ? null : config.onPressed,
        icon: Icon(config.icon),
        label: Text(config.label),
        style: FormStyles.getSecondaryButtonStyle(
          borderColor: config.color,
        ).copyWith(
          foregroundColor: WidgetStateProperty.all(config.color ?? FormStyles.primaryColor),
        ),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  int _getMainButtonFlex() {
    int totalButtons = 1; // Save button
    if (isEditMode && showDeleteButton && onDelete != null) totalButtons++;
    if (isEditMode && showDuplicateButton && onDuplicate != null) totalButtons++;
    if (customButtons != null) totalButtons += customButtons!.length;
    
    return totalButtons > 2 ? 2 : 1;
  }

  String _getSaveButtonLabel() {
    if (isEditMode) {
      return saveLabel ?? FormConstants.saveLabel;
    } else {
      return createLabel ?? 'Criar';
    }
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(FormConstants.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(FormConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onDelete?.call();
            },
            style: FormStyles.getDangerButtonStyle(),
            child: const Text(FormConstants.deleteLabel),
          ),
        ],
      ),
    );
  }

  /// Método estático para confirmar mudanças não salvas
  static Future<bool> showUnsavedChangesDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Alterações Não Salvas'),
        content: const Text(FormConstants.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Continuar Editando'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: FormStyles.getDangerButtonStyle(),
            child: const Text('Descartar Alterações'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
