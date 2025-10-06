import 'package:flutter/material.dart';

import 'validated_form_field.dart';

/// Tipos de campo de texto pré-configurados
enum NotesFieldType {
  /// Campo de observações gerais
  notes,
  /// Campo de descrição detalhada
  description,
  /// Campo de localização/endereço
  location,
  /// Campo de comentários
  comments,
  /// Campo genérico de texto
  generic,
}

/// Campo unificado para entrada de textos longos (observações, descrições, etc)
///
/// Centraliza toda a lógica de formatação, validação e apresentação
/// de campos de texto que estavam duplicados em múltiplos formulários.
///
/// Características:
/// - Tipos pré-configurados com labels e hints apropriados
/// - Validação específica para cada tipo de campo
/// - Múltiplas linhas e limite de caracteres
/// - Interface consistente em todos os formulários
/// - Ícones apropriados para cada tipo
///
/// Exemplo de uso:
/// ```dart
/// NotesFormField(
///   controller: _notesController,
///   type: NotesFieldType.notes,
///   onChanged: (value) => provider.updateNotes(value),
/// )
/// ```
class NotesFormField extends StatelessWidget {

  const NotesFormField({
    super.key,
    required this.controller,
    required this.type,
    this.customLabel,
    this.customHint,
    this.required = false,
    this.onChanged,
    this.additionalValidator,
    this.customMaxLength,
    this.customMaxLines,
    this.showCharacterCount = true,
    this.customHelperText,
  });
  /// Controller do campo de texto
  final TextEditingController controller;

  /// Tipo do campo de texto (define configurações padrão)
  final NotesFieldType type;

  /// Label customizado (sobrescreve o padrão do tipo)
  final String? customLabel;

  /// Hint customizado (sobrescreve o padrão do tipo)
  final String? customHint;

  /// Se o campo é obrigatório
  final bool required;

  /// Callback quando o valor muda
  final void Function(String?)? onChanged;

  /// Callback para validação customizada adicional
  final String? Function(String?)? additionalValidator;

  /// Número máximo de caracteres (sobrescreve o padrão do tipo)
  final int? customMaxLength;

  /// Número de linhas visíveis (sobrescreve o padrão do tipo)
  final int? customMaxLines;

  /// Se deve mostrar contador de caracteres
  final bool showCharacterCount;

  /// Helper text customizado
  final String? customHelperText;

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfiguration();

    return ValidatedFormField(
      controller: controller,
      label: customLabel ?? config.label,
      hint: customHint ?? config.hint,
      prefixIcon: config.icon,
      required: required,
      validationType: ValidationType.length,
      maxLength: customMaxLength ?? config.maxLength,
      maxLengthValidation: customMaxLength ?? config.maxLength,
      maxLines: customMaxLines ?? config.maxLines,
      showCharacterCount: showCharacterCount,
      helperText: customHelperText ?? config.helperText,
      customValidator: (value) => _validateText(value, config),
      onChanged: onChanged,
      debounceDuration: const Duration(milliseconds: 500),
    );
  }

  /// Configuração específica para cada tipo de campo
  _NotesFieldConfig _getTypeConfiguration() {
    switch (type) {
      case NotesFieldType.notes:
        return _NotesFieldConfig(
          label: required ? 'Observações *' : 'Observações',
          hint: 'Digite observações adicionais...',
          icon: Icons.note_alt,
          maxLength: 500,
          maxLines: 3,
          helperText: 'Informações extras sobre o registro',
        );
      case NotesFieldType.description:
        return _NotesFieldConfig(
          label: required ? 'Descrição *' : 'Descrição',
          hint: 'Descreva detalhadamente...',
          icon: Icons.description,
          maxLength: 255,
          maxLines: 2,
          helperText: 'Descrição detalhada do item',
        );
      case NotesFieldType.location:
        return _NotesFieldConfig(
          label: required ? 'Local *' : 'Local',
          hint: 'Ex: Posto Shell, Rua ABC...',
          icon: Icons.location_on,
          maxLength: 150,
          maxLines: 2,
          helperText: 'Endereço ou nome do estabelecimento',
        );
      case NotesFieldType.comments:
        return _NotesFieldConfig(
          label: required ? 'Comentários *' : 'Comentários',
          hint: 'Adicione seus comentários...',
          icon: Icons.comment,
          maxLength: 300,
          maxLines: 3,
          helperText: 'Comentários pessoais sobre o registro',
        );
      case NotesFieldType.generic:
        return _NotesFieldConfig(
          label: required ? 'Texto *' : 'Texto',
          hint: 'Digite o texto...',
          icon: Icons.text_fields,
          maxLength: 255,
          maxLines: 2,
          helperText: null,
        );
    }
  }

  /// Validação específica para campos de texto
  String? _validateText(String? value, _NotesFieldConfig config) {
    if (required && (value == null || value.isEmpty)) {
      return '${config.label.replaceAll(' *', '')} é obrigatório';
    }

    if (value != null && value.isNotEmpty) {
      if (value.length > config.maxLength) {
        return 'Máximo ${config.maxLength} caracteres';
      }
      switch (type) {
        case NotesFieldType.location:
          if (value.length < 3) {
            return 'Local deve ter pelo menos 3 caracteres';
          }
          break;
        case NotesFieldType.description:
          if (required && value.length < 10) {
            return 'Descrição deve ter pelo menos 10 caracteres';
          }
          break;
        default:
          break;
      }
    }
    if (additionalValidator != null) {
      return additionalValidator!(value);
    }

    return null;
  }
}

/// Configuração interna para tipos de campo
class _NotesFieldConfig {

  const _NotesFieldConfig({
    required this.label,
    required this.hint,
    required this.icon,
    required this.maxLength,
    required this.maxLines,
    this.helperText,
  });
  final String label;
  final String hint;
  final IconData icon;
  final int maxLength;
  final int maxLines;
  final String? helperText;
}

/// Variações pré-configuradas para casos específicos
class ObservationsField extends StatelessWidget {

  const ObservationsField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.required = false,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool required;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return NotesFormField(
      controller: controller,
      type: NotesFieldType.notes,
      customLabel: label,
      customHint: hint,
      required: required,
      onChanged: onChanged,
    );
  }
}

class DescriptionField extends StatelessWidget {

  const DescriptionField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.required = false,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool required;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return NotesFormField(
      controller: controller,
      type: NotesFieldType.description,
      customLabel: label,
      customHint: hint,
      required: required,
      onChanged: onChanged,
    );
  }
}

class LocationField extends StatelessWidget {

  const LocationField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.required = false,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool required;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return NotesFormField(
      controller: controller,
      type: NotesFieldType.location,
      customLabel: label,
      customHint: hint,
      required: required,
      onChanged: onChanged,
    );
  }
}

class CommentsField extends StatelessWidget {

  const CommentsField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.required = false,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool required;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return NotesFormField(
      controller: controller,
      type: NotesFieldType.comments,
      customLabel: label,
      customHint: hint,
      required: required,
      onChanged: onChanged,
    );
  }
}
