import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// **Notes Field Component**
///
/// Componente reutilizável para campos de observações/notas em formulários.
/// Padroniza a interface e comportamento de campos de texto longo.
///
/// **Funcionalidades:**
/// - Interface consistente para observações
/// - Múltiplas linhas por padrão
/// - Contador de caracteres opcional
/// - Validação integrada
/// - Placeholder contextual
/// - Auto-resize baseado no conteúdo
///
/// **Uso:**
/// ```dart
/// NotesField(
///   controller: notesController,
///   label: 'Observações sobre o tratamento',
///   maxLength: 500,
/// )
/// ```
class NotesField extends StatelessWidget {
  /// Controller do campo de texto
  final TextEditingController? controller;

  /// Valor inicial do campo
  final String? initialValue;

  /// Callback para mudanças no texto
  final ValueChanged<String>? onChanged;

  /// Label do campo
  final String? label;

  /// Texto de placeholder
  final String? placeholder;

  /// Texto de ajuda
  final String? helperText;

  /// Função de validação
  final String? Function(String?)? validator;

  /// Número máximo de caracteres
  final int? maxLength;

  /// Número máximo de linhas (null = ilimitado)
  final int? maxLines;

  /// Número mínimo de linhas
  final int minLines;

  /// Se o campo está habilitado
  final bool enabled;

  /// Se o campo é obrigatório
  final bool isRequired;

  /// Ícone personalizado
  final IconData? icon;

  /// Tipo de capitalização
  final TextCapitalization textCapitalization;

  const NotesField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.placeholder,
    this.helperText,
    this.validator,
    this.maxLength,
    this.maxLines,
    this.minLines = 3,
    this.enabled = true,
    this.isRequired = false,
    this.icon,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com indicador de obrigatório
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Campo de texto
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          onChanged: onChanged,
          validator: _buildValidator(),
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: placeholder ?? _getDefaultPlaceholder(),
            helperText: helperText,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: enabled ? AppColors.primary : AppColors.textSecondary,
                  )
                : const Icon(
                    Icons.notes,
                    color: AppColors.primary,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            alignLabelWithHint: true,
            helperStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            // Remove contador padrão se maxLength for definido
            counterText: maxLength != null ? '' : null,
          ),
        ),

        // Contador customizado se maxLength for definido
        if (maxLength != null) _buildCharacterCounter(),
      ],
    );
  }

  String _getDefaultPlaceholder() {
    if (label?.toLowerCase().contains('observ') == true) {
      return 'Digite suas observações...';
    } else if (label?.toLowerCase().contains('descr') == true) {
      return 'Descreva os detalhes...';
    } else if (label?.toLowerCase().contains('nota') == true) {
      return 'Adicione suas notas...';
    } else if (label?.toLowerCase().contains('comentário') == true) {
      return 'Deixe seu comentário...';
    }
    return 'Digite informações adicionais...';
  }

  String? Function(String?)? _buildValidator() {
    if (validator != null) return validator;

    if (isRequired) {
      return (value) {
        if (value == null || value.trim().isEmpty) {
          return '${label ?? 'Este campo'} é obrigatório';
        }
        return null;
      };
    }

    return null;
  }

  Widget _buildCharacterCounter() {
    return StreamBuilder<String>(
      stream: controller?.selection != null
          ? Stream.periodic(const Duration(milliseconds: 100), (_) => controller!.text)
          : const Stream.empty(),
      builder: (context, snapshot) {
        final currentLength = controller?.text.length ?? 0;
        final isNearLimit = maxLength != null && currentLength > (maxLength! * 0.8);
        final isOverLimit = maxLength != null && currentLength > maxLength!;

        return Padding(
          padding: const EdgeInsets.only(top: 4, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$currentLength${maxLength != null ? '/$maxLength' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverLimit
                      ? AppColors.error
                      : isNearLimit
                          ? AppColors.warning
                          : AppColors.textSecondary,
                  fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// **Variações pré-configuradas do NotesField**
extension NotesFieldVariants on NotesField {
  /// Campo para observações gerais
  static Widget general({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return NotesField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: 'Observações${isRequired ? '' : ' (Opcional)'}',
      placeholder: 'Informações importantes, comportamentos observados, etc...',
      maxLength: 500,
      enabled: enabled,
      isRequired: isRequired,
      icon: Icons.note_alt,
    );
  }

  /// Campo para observações médicas/veterinárias
  static Widget medical({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return NotesField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: 'Observações Médicas${isRequired ? '' : ' (Opcional)'}',
      placeholder: 'Sintomas, reações, orientações veterinárias...',
      helperText: 'Registre informações importantes para o histórico médico',
      maxLength: 1000,
      enabled: enabled,
      isRequired: isRequired,
      icon: Icons.medical_information,
    );
  }

  /// Campo para descrição de tratamentos
  static Widget treatment({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return NotesField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: 'Detalhes do Tratamento${isRequired ? '' : ' (Opcional)'}',
      placeholder: 'Instruções especiais, cuidados adicionais...',
      maxLength: 750,
      enabled: enabled,
      isRequired: isRequired,
      icon: Icons.healing,
    );
  }

  /// Campo para observações sobre alimentação
  static Widget feeding({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return NotesField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: 'Observações Alimentares${isRequired ? '' : ' (Opcional)'}',
      placeholder: 'Preferências, restrições, horários de alimentação...',
      maxLength: 400,
      enabled: enabled,
      isRequired: isRequired,
      icon: Icons.restaurant,
    );
  }

  /// Campo para comportamento
  static Widget behavior({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return NotesField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: 'Observações Comportamentais${isRequired ? '' : ' (Opcional)'}',
      placeholder: 'Temperamento, hábitos, particularidades...',
      maxLength: 600,
      enabled: enabled,
      isRequired: isRequired,
      icon: Icons.psychology,
    );
  }

  /// Campo para emergências
  static Widget emergency({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool isRequired = true,
  }) {
    return NotesField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: 'Descrição da Emergência',
      placeholder: 'Descreva o problema, sintomas, horário de início...',
      helperText: 'Seja específico para ajudar no atendimento',
      maxLength: 1000,
      minLines: 4,
      enabled: enabled,
      isRequired: isRequired,
      icon: Icons.emergency,
    );
  }
}