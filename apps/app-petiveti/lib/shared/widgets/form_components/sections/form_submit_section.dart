import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// **Form Submit Section Component**
///
/// Componente reutilizável para seções de envio de formulários.
/// Padroniza botões de submit, cancel e loading states.
///
/// **Funcionalidades:**
/// - Estados de loading consistentes
/// - Botão primário e secundário
/// - Layout responsivo
/// - Validação automática
/// - Feedback visual
/// - Ações customizáveis
///
/// **Uso:**
/// ```dart
/// FormSubmitSection(
///   onSubmit: _handleSubmit,
///   isLoading: _isSubmitting,
///   submitText: 'Salvar Animal',
/// )
/// ```
class FormSubmitSection extends StatelessWidget {
  /// Função executada no submit
  final VoidCallback? onSubmit;

  /// Função executada no cancelar
  final VoidCallback? onCancel;

  /// Se está em estado de carregamento
  final bool isLoading;

  /// Texto do botão de submit
  final String? submitText;

  /// Texto do botão de cancelar
  final String? cancelText;

  /// Ícone do botão de submit
  final IconData? submitIcon;

  /// Se deve mostrar botão de cancelar
  final bool showCancel;

  /// Estilo do botão (elevated, filled, outlined)
  final SubmitButtonStyle style;

  /// Largura total (full width)
  final bool fullWidth;

  /// Espaçamento entre botões
  final double spacing;

  /// Padding da seção
  final EdgeInsets? padding;

  /// Se o botão está habilitado
  final bool enabled;

  /// Cor customizada do botão
  final Color? buttonColor;

  /// Cor customizada do texto
  final Color? textColor;

  /// Altura customizada dos botões
  final double? buttonHeight;

  const FormSubmitSection({
    super.key,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.submitText,
    this.cancelText,
    this.submitIcon,
    this.showCancel = true,
    this.style = SubmitButtonStyle.filled,
    this.fullWidth = true,
    this.spacing = 12,
    this.padding,
    this.enabled = true,
    this.buttonColor,
    this.textColor,
    this.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        children: [
          // Divisor opcional
          if (padding == null) const Divider(),

          const SizedBox(height: 16),

          // Botões
          if (fullWidth && showCancel)
            _buildFullWidthButtons(context)
          else if (fullWidth)
            _buildSingleFullWidthButton(context)
          else
            _buildInlineButtons(context),
        ],
      ),
    );
  }

  Widget _buildFullWidthButtons(BuildContext context) {
    return Column(
      children: [
        // Botão principal
        SizedBox(
          width: double.infinity,
          height: buttonHeight ?? 48,
          child: _buildSubmitButton(context),
        ),

        SizedBox(height: spacing),

        // Botão de cancelar
        SizedBox(
          width: double.infinity,
          height: buttonHeight ?? 48,
          child: _buildCancelButton(context),
        ),
      ],
    );
  }

  Widget _buildSingleFullWidthButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight ?? 48,
      child: _buildSubmitButton(context),
    );
  }

  Widget _buildInlineButtons(BuildContext context) {
    if (!showCancel) {
      return _buildSubmitButton(context);
    }

    return Row(
      children: [
        if (onCancel != null) ...[
          Expanded(child: _buildCancelButton(context)),
          SizedBox(width: spacing),
        ],
        Expanded(
          flex: 2,
          child: _buildSubmitButton(context),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isDisabled = !enabled || isLoading || onSubmit == null;
    final text = submitText ?? _getDefaultSubmitText();

    switch (style) {
      case SubmitButtonStyle.elevated:
        return ElevatedButton.icon(
          onPressed: isDisabled ? null : onSubmit,
          icon: _buildSubmitIcon(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

      case SubmitButtonStyle.filled:
        return FilledButton.icon(
          onPressed: isDisabled ? null : onSubmit,
          icon: _buildSubmitIcon(),
          label: Text(text),
          style: FilledButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

      case SubmitButtonStyle.outlined:
        return OutlinedButton.icon(
          onPressed: isDisabled ? null : onSubmit,
          icon: _buildSubmitIcon(),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor ?? AppColors.primary,
            side: BorderSide(
              color: buttonColor ?? AppColors.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
    }
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : (onCancel ?? () => Navigator.of(context).pop()),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(cancelText ?? 'Cancelar'),
    );
  }

  Widget _buildSubmitIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (submitIcon != null) {
      return Icon(submitIcon, size: 18);
    }

    return const SizedBox.shrink();
  }

  String _getDefaultSubmitText() {
    if (isLoading) return 'Salvando...';
    return 'Salvar';
  }
}

/// **Estilos de botão disponíveis**
enum SubmitButtonStyle {
  elevated,
  filled,
  outlined,
}

/// **Variações pré-configuradas**
extension FormSubmitSectionVariants on FormSubmitSection {
  /// Seção para criar/adicionar
  static Widget create({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
    String? itemName,
    bool enabled = true,
  }) {
    return FormSubmitSection(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
      submitText: isLoading
          ? 'Criando...'
          : 'Criar ${itemName ?? ''}',
      submitIcon: Icons.add,
      enabled: enabled,
      style: SubmitButtonStyle.filled,
    );
  }

  /// Seção para editar/atualizar
  static Widget update({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
    String? itemName,
    bool enabled = true,
  }) {
    return FormSubmitSection(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
      submitText: isLoading
          ? 'Salvando...'
          : 'Salvar Alterações',
      submitIcon: Icons.save,
      enabled: enabled,
      style: SubmitButtonStyle.filled,
    );
  }

  /// Seção para deletar
  static Widget delete({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
    String? itemName,
    bool enabled = true,
  }) {
    return FormSubmitSection(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
      submitText: isLoading
          ? 'Removendo...'
          : 'Remover ${itemName ?? ''}',
      submitIcon: Icons.delete,
      buttonColor: AppColors.error,
      enabled: enabled,
      style: SubmitButtonStyle.filled,
    );
  }

  /// Seção para enviar/submit genérico
  static Widget submit({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
    String? actionName,
    bool enabled = true,
  }) {
    return FormSubmitSection(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
      submitText: isLoading
          ? 'Enviando...'
          : actionName ?? 'Enviar',
      submitIcon: Icons.send,
      enabled: enabled,
      style: SubmitButtonStyle.filled,
    );
  }

  /// Seção simples apenas com botão principal
  static Widget simple({
    required VoidCallback? onSubmit,
    bool isLoading = false,
    String? text,
    IconData? icon,
    bool enabled = true,
    Color? color,
  }) {
    return FormSubmitSection(
      onSubmit: onSubmit,
      isLoading: isLoading,
      submitText: text,
      submitIcon: icon,
      showCancel: false,
      enabled: enabled,
      buttonColor: color,
      style: SubmitButtonStyle.filled,
    );
  }

  /// Seção para ações emergenciais
  static Widget emergency({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
    String? actionName,
    bool enabled = true,
  }) {
    return FormSubmitSection(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
      submitText: isLoading
          ? 'Processando...'
          : actionName ?? 'Solicitar Emergência',
      submitIcon: Icons.emergency,
      buttonColor: AppColors.error,
      enabled: enabled,
      style: SubmitButtonStyle.filled,
    );
  }
}