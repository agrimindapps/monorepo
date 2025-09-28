import 'dart:async';

import 'package:flutter/material.dart';

import 'animated_feedback.dart';
import 'haptic_service.dart';

/// Sistema de confirmação com feedback visual e háptico
/// Para ações críticas que precisam de confirmação do usuário
class ConfirmationSystem {
  /// Mostra dialog de confirmação simples
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    IconData? icon,
    ConfirmationType type = ConfirmationType.warning,
    bool includeHaptic = true,
  }) async {
    if (includeHaptic) {
      await HapticService.medium();
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ConfirmationDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            type: type,
          ),
    );

    return result ?? false;
  }

  /// Mostra dialog de confirmação destrutiva (deletar, etc.)
  static Future<bool> showDestructiveConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Deletar',
    String cancelLabel = 'Cancelar',
    IconData icon = Icons.warning,
    bool requiresDoubleConfirmation = false,
    bool includeHaptic = true,
  }) async {
    if (includeHaptic) {
      await HapticService.heavy();
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => DestructiveConfirmationDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            requiresDoubleConfirmation: requiresDoubleConfirmation,
          ),
    );

    return result ?? false;
  }

  /// Mostra dialog de confirmação com input
  static Future<String?> showInputConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? initialValue,
    String? hintText,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool includeHaptic = true,
  }) async {
    if (includeHaptic) {
      await HapticService.medium();
    }

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => InputConfirmationDialog(
            title: title,
            message: message,
            initialValue: initialValue,
            hintText: hintText,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            keyboardType: keyboardType,
            validator: validator,
          ),
    );

    return result;
  }

  /// Mostra dialog de confirmação com checklist
  static Future<List<String>?> showChecklistConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required List<ChecklistItem> items,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    IconData? icon,
    bool requireAllChecked = false,
    bool includeHaptic = true,
  }) async {
    if (includeHaptic) {
      await HapticService.medium();
    }

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ChecklistConfirmationDialog(
            title: title,
            message: message,
            items: items,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            requireAllChecked: requireAllChecked,
          ),
    );

    return result;
  }

  /// Mostra bottom sheet de confirmação
  static Future<bool> showBottomSheetConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    IconData? icon,
    ConfirmationType type = ConfirmationType.info,
    bool includeHaptic = true,
  }) async {
    if (includeHaptic) {
      await HapticService.light();
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ConfirmationBottomSheet(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            type: type,
          ),
    );

    return result ?? false;
  }
}

/// Dialog de confirmação básico
class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final ConfirmationType type;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.icon,
    required this.type,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getTypeColors(theme);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.7 + (_animationController.value * 0.3),
          child: Opacity(
            opacity: _animationController.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.backgroundColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: colors.iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(widget.message, style: theme.textTheme.bodyMedium),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticService.light();
                    Navigator.of(context).pop(false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.outline,
                  ),
                  child: Text(widget.cancelLabel),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.backgroundColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.confirmLabel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ConfirmationColors _getTypeColors(ThemeData theme) {
    switch (widget.type) {
      case ConfirmationType.info:
        return ConfirmationColors(
          backgroundColor: theme.colorScheme.primary,
          iconColor: theme.colorScheme.primary,
        );
      case ConfirmationType.success:
        return const ConfirmationColors(
          backgroundColor: Colors.green,
          iconColor: Colors.green,
        );
      case ConfirmationType.warning:
        return const ConfirmationColors(
          backgroundColor: Colors.orange,
          iconColor: Colors.orange,
        );
      case ConfirmationType.error:
        return const ConfirmationColors(
          backgroundColor: Colors.red,
          iconColor: Colors.red,
        );
    }
  }
}

/// Dialog de confirmação destrutiva
class DestructiveConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final bool requiresDoubleConfirmation;

  const DestructiveConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.requiresDoubleConfirmation,
  });

  @override
  State<DestructiveConfirmationDialog> createState() =>
      _DestructiveConfirmationDialogState();
}

class _DestructiveConfirmationDialogState
    extends State<DestructiveConfirmationDialog>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  bool _firstConfirmation = false;
  int _countdown = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (widget.requiresDoubleConfirmation) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleConfirm() {
    if (widget.requiresDoubleConfirmation && !_firstConfirmation) {
      setState(() {
        _firstConfirmation = true;
      });
      HapticService.warning();
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
      return;
    }

    HapticService.heavy();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedFeedback.shakeAnimation(
      controller: _shakeController,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message, style: theme.textTheme.bodyMedium),
            if (_firstConfirmation) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tem certeza? Esta ação não pode ser desfeita.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.outline,
            ),
            child: Text(widget.cancelLabel),
          ),
          ElevatedButton(
            onPressed:
                (_countdown <= 0 || !widget.requiresDoubleConfirmation)
                    ? _handleConfirm
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _firstConfirmation ? Colors.red.shade700 : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              _firstConfirmation
                  ? 'CONFIRMAR EXCLUSÃO'
                  : (_countdown > 0 && widget.requiresDoubleConfirmation
                      ? '${widget.confirmLabel} ($_countdown)'
                      : widget.confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog de confirmação com input
class InputConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? initialValue;
  final String? hintText;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const InputConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.initialValue,
    this.hintText,
    required this.confirmLabel,
    required this.cancelLabel,
    this.icon,
    required this.keyboardType,
    this.validator,
  });

  @override
  State<InputConfirmationDialog> createState() =>
      _InputConfirmationDialogState();
}

class _InputConfirmationDialogState extends State<InputConfirmationDialog> {
  late TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticService.selection();
      Navigator.of(context).pop(_controller.text.trim());
    } else {
      HapticService.warning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          if (widget.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              autofocus: true,
              onFieldSubmitted: (_) => _handleConfirm(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticService.light();
            Navigator.of(context).pop(null);
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.outline,
          ),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Dialog de confirmação com checklist
class ChecklistConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final List<ChecklistItem> items;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final bool requireAllChecked;

  const ChecklistConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.items,
    required this.confirmLabel,
    required this.cancelLabel,
    this.icon,
    required this.requireAllChecked,
  });

  @override
  State<ChecklistConfirmationDialog> createState() =>
      _ChecklistConfirmationDialogState();
}

class _ChecklistConfirmationDialogState
    extends State<ChecklistConfirmationDialog> {
  late List<bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = widget.items.map((item) => item.isChecked).toList();
  }

  bool get _canConfirm {
    if (widget.requireAllChecked) {
      return _checkedItems.every((checked) => checked);
    }
    return _checkedItems.any((checked) => checked);
  }

  void _handleConfirm() {
    if (_canConfirm) {
      HapticService.selection();
      final selectedItems = <String>[];
      for (int i = 0; i < widget.items.length; i++) {
        if (_checkedItems[i]) {
          selectedItems.add(widget.items[i].id);
        }
      }
      Navigator.of(context).pop(selectedItems);
    } else {
      HapticService.warning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          if (widget.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ...List.generate(widget.items.length, (index) {
              final item = widget.items[index];
              return CheckboxListTile(
                value: _checkedItems[index],
                onChanged: (value) {
                  setState(() {
                    _checkedItems[index] = value ?? false;
                  });
                  HapticService.selection();
                },
                title: Text(item.title),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticService.light();
            Navigator.of(context).pop(null);
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.outline,
          ),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: _canConfirm ? _handleConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Bottom sheet de confirmação
class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final ConfirmationType type;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.icon,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final colors = _getTypeColors(theme);

    return Container(
      margin: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.backgroundColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.iconColor, size: 32),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticService.light();
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.outline,
                      side: BorderSide(color: theme.colorScheme.outline),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticService.selection();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.backgroundColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),

            // Bottom padding for safe area
            SizedBox(height: mediaQuery.padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  ConfirmationColors _getTypeColors(ThemeData theme) {
    switch (type) {
      case ConfirmationType.info:
        return ConfirmationColors(
          backgroundColor: theme.colorScheme.primary,
          iconColor: theme.colorScheme.primary,
        );
      case ConfirmationType.success:
        return const ConfirmationColors(
          backgroundColor: Colors.green,
          iconColor: Colors.green,
        );
      case ConfirmationType.warning:
        return const ConfirmationColors(
          backgroundColor: Colors.orange,
          iconColor: Colors.orange,
        );
      case ConfirmationType.error:
        return const ConfirmationColors(
          backgroundColor: Colors.red,
          iconColor: Colors.red,
        );
    }
  }
}

/// Tipos de confirmação
enum ConfirmationType { info, success, warning, error }

/// Item de checklist para confirmação
class ChecklistItem {
  final String id;
  final String title;
  final String? subtitle;
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.isChecked = false,
  });
}

/// Cores para confirmação
class ConfirmationColors {
  final Color backgroundColor;
  final Color iconColor;

  const ConfirmationColors({
    required this.backgroundColor,
    required this.iconColor,
  });
}

/// Contextos pré-definidos para confirmações
class ConfirmationContexts {
  // Deletar planta
  static Future<bool> deletePlant(BuildContext context, String plantName) {
    return ConfirmationSystem.showDestructiveConfirmation(
      context: context,
      title: 'Deletar planta',
      message:
          'Tem certeza que deseja remover "$plantName"? '
          'Todas as tarefas e históricos relacionados serão perdidos.',
      confirmLabel: 'Deletar',
      icon: Icons.delete_forever,
      requiresDoubleConfirmation: true,
    );
  }

  // Deletar tarefa
  static Future<bool> deleteTask(BuildContext context, String taskName) {
    return ConfirmationSystem.showConfirmation(
      context: context,
      title: 'Deletar tarefa',
      message: 'Deseja remover a tarefa "$taskName"?',
      confirmLabel: 'Deletar',
      icon: Icons.delete,
      type: ConfirmationType.warning,
    );
  }

  // Logout
  static Future<bool> logout(BuildContext context) {
    return ConfirmationSystem.showBottomSheetConfirmation(
      context: context,
      title: 'Fazer logout',
      message:
          'Você será desconectado da sua conta. '
          'Dados não sincronizados podem ser perdidos.',
      confirmLabel: 'Sair',
      icon: Icons.logout,
      type: ConfirmationType.warning,
    );
  }

  // Reset de dados
  static Future<bool> resetData(BuildContext context) {
    return ConfirmationSystem.showDestructiveConfirmation(
      context: context,
      title: 'Resetar dados',
      message:
          'ATENÇÃO: Todos os seus dados (plantas, tarefas, configurações) '
          'serão permanentemente removidos. Esta ação não pode ser desfeita.',
      confirmLabel: 'RESETAR TUDO',
      icon: Icons.warning,
      requiresDoubleConfirmation: true,
    );
  }

  // Cancelar premium
  static Future<bool> cancelPremium(BuildContext context) {
    return ConfirmationSystem.showConfirmation(
      context: context,
      title: 'Cancelar Premium',
      message:
          'Você perderá acesso aos recursos premium. '
          'O plano continuará ativo até o fim do período pago.',
      confirmLabel: 'Cancelar Premium',
      icon: Icons.cancel,
      type: ConfirmationType.warning,
    );
  }

  // Restaurar backup
  static Future<bool> restoreBackup(BuildContext context) {
    return ConfirmationSystem.showConfirmation(
      context: context,
      title: 'Restaurar backup',
      message:
          'Os dados atuais serão substituídos pelo backup. '
          'Deseja continuar?',
      confirmLabel: 'Restaurar',
      icon: Icons.restore,
      type: ConfirmationType.info,
    );
  }

  // Criar backup
  static Future<bool> createBackup(BuildContext context) {
    return ConfirmationSystem.showConfirmation(
      context: context,
      title: 'Criar backup',
      message: 'Salvar uma cópia de segurança dos seus dados na nuvem?',
      confirmLabel: 'Criar backup',
      icon: Icons.backup,
      type: ConfirmationType.info,
    );
  }

  // Nome da planta
  static Future<String?> plantName(BuildContext context, {String? current}) {
    return ConfirmationSystem.showInputConfirmation(
      context: context,
      title: 'Nome da planta',
      message: 'Como você gostaria de chamar sua planta?',
      initialValue: current,
      hintText: 'Ex: Rosinha, Suculenta da sala...',
      confirmLabel: 'Salvar',
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Nome é obrigatório';
        }
        return null;
      },
    );
  }

  // Configurações de backup
  static Future<List<String>?> backupOptions(BuildContext context) {
    return ConfirmationSystem.showChecklistConfirmation(
      context: context,
      title: 'Opções de backup',
      message: 'Selecione os dados que deseja incluir no backup:',
      items: const [
        ChecklistItem(
          id: 'plants',
          title: 'Plantas',
          subtitle: 'Lista de plantas e informações',
          isChecked: true,
        ),
        ChecklistItem(
          id: 'tasks',
          title: 'Tarefas',
          subtitle: 'Histórico de tarefas e lembretes',
          isChecked: true,
        ),
        ChecklistItem(
          id: 'settings',
          title: 'Configurações',
          subtitle: 'Preferências do aplicativo',
          isChecked: false,
        ),
        ChecklistItem(
          id: 'images',
          title: 'Imagens',
          subtitle: 'Fotos das plantas',
          isChecked: false,
        ),
      ],
      confirmLabel: 'Criar backup',
      requireAllChecked: false,
    );
  }
}
