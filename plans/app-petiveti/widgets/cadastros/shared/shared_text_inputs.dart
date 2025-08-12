// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';

/// Tipos de entrada de texto
enum SharedTextInputType {
  text,
  multiline,
  name,
  description,
  observation,
  email,
  phone,
  veterinarian,
  medication,
  diagnosis,
}

/// Widget de entrada de texto unificado para todos os formulários de cadastro
class SharedTextInput extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isRequired;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? padding;
  final bool enabled;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final SharedTextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? helpText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;

  const SharedTextInput({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.errorText,
    this.isRequired = false,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputType = SharedTextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.helpText,
    this.onTap,
    this.readOnly = false,
    this.controller,
  });

  /// Factory para nome de veterinário
  factory SharedTextInput.veterinarian({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedTextInput(
      label: 'Veterinário',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Nome do veterinário',
      prefixIcon: const Icon(Icons.person),
      maxLength: FormConstants.maxNameLength,
      textCapitalization: TextCapitalization.words,
      inputType: SharedTextInputType.name,
      helpText: 'Nome do profissional que realizou o atendimento',
    );
  }

  /// Factory para motivo/razão
  factory SharedTextInput.motivo({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
    String label = 'Motivo',
  }) {
    return SharedTextInput(
      label: label,
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Descreva o motivo',
      prefixIcon: const Icon(Icons.description),
      maxLength: FormConstants.mediumTextLimit,
      textCapitalization: TextCapitalization.sentences,
      inputType: SharedTextInputType.description,
      helpText: 'Motivo principal do atendimento ou despesa',
    );
  }

  /// Factory para diagnóstico
  factory SharedTextInput.diagnostico({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedTextInput(
      label: 'Diagnóstico',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Diagnóstico médico',
      prefixIcon: const Icon(Icons.medical_services),
      maxLength: FormConstants.longTextLimit,
      textCapitalization: TextCapitalization.sentences,
      inputType: SharedTextInputType.diagnosis,
      helpText: 'Diagnóstico dado pelo veterinário',
    );
  }

  /// Factory para observações
  factory SharedTextInput.observacoes({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = false,
  }) {
    return SharedTextInput(
      label: 'Observações',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Observações adicionais (opcional)',
      prefixIcon: const Icon(Icons.note_add),
      maxLength: FormConstants.observationsLimit,
      maxLines: 4,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      inputType: SharedTextInputType.observation,
      helpText: 'Informações extras que considere importantes',
    );
  }

  /// Factory para descrição
  factory SharedTextInput.descricao({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
    String label = 'Descrição',
  }) {
    return SharedTextInput(
      label: label,
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Digite uma descrição',
      prefixIcon: const Icon(Icons.edit_note),
      maxLength: FormConstants.longTextLimit,
      textCapitalization: TextCapitalization.sentences,
      inputType: SharedTextInputType.description,
    );
  }

  /// Factory para nome de medicamento
  factory SharedTextInput.medicamento({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedTextInput(
      label: 'Nome do Medicamento',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Nome do medicamento',
      prefixIcon: const Icon(Icons.medication),
      maxLength: FormConstants.mediumTextLimit,
      textCapitalization: TextCapitalization.words,
      inputType: SharedTextInputType.medication,
      helpText: 'Nome comercial ou princípio ativo',
    );
  }

  /// Factory para nome de vacina
  factory SharedTextInput.vacina({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedTextInput(
      label: 'Nome da Vacina',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Nome da vacina',
      prefixIcon: const Icon(Icons.vaccines),
      maxLength: FormConstants.mediumTextLimit,
      textCapitalization: TextCapitalization.words,
      helpText: 'Nome da vacina aplicada',
    );
  }

  /// Factory para título de lembrete
  factory SharedTextInput.lembrete({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedTextInput(
      label: 'Título do Lembrete',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'Título do lembrete',
      prefixIcon: const Icon(Icons.notification_important),
      maxLength: FormConstants.mediumTextLimit,
      textCapitalization: TextCapitalization.sentences,
      helpText: 'Título descritivo para o lembrete',
    );
  }

  /// Factory para email
  factory SharedTextInput.email({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = false,
  }) {
    return SharedTextInput(
      label: 'E-mail',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'exemplo@email.com',
      prefixIcon: const Icon(Icons.email),
      inputType: SharedTextInputType.email,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Remove espaços
      ],
    );
  }

  /// Factory para telefone
  factory SharedTextInput.phone({
    String? value,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool isRequired = false,
  }) {
    return SharedTextInput(
      label: 'Telefone',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: '(11) 99999-9999',
      prefixIcon: const Icon(Icons.phone),
      inputType: SharedTextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneInputFormatter(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: FormStyles.smallSpacing),
          _buildTextField(),
          if (errorText != null) ...[
            const SizedBox(height: FormStyles.smallSpacing),
            _buildErrorText(),
          ],
          if (helpText != null) ...[
            const SizedBox(height: FormStyles.tinySpacing),
            _buildHelpText(),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      isRequired ? '$label *' : label,
      style: FormStyles.subtitleTextStyle.copyWith(
        fontSize: FormStyles.bodyFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField() {
    final keyboardType = _getKeyboardType();
    final formatters = _getInputFormatters();

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? value : null,
      onChanged: onChanged,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      inputFormatters: formatters,
      decoration: FormStyles.getInputDecoration(
        labelText: hintText ?? FormConstants.enterValuePlaceholder,
        errorText: null, // Handled separately
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabled: enabled,
      ),
      validator: isRequired ? _validateRequired : null,
      style: FormStyles.bodyTextStyle,
    );
  }

  Widget _buildErrorText() {
    return Text(
      errorText!,
      style: FormStyles.errorTextStyle,
    );
  }

  Widget _buildHelpText() {
    return Text(
      helpText!,
      style: FormStyles.captionTextStyle,
    );
  }

  TextInputType _getKeyboardType() {
    switch (inputType) {
      case SharedTextInputType.email:
        return TextInputType.emailAddress;
      case SharedTextInputType.phone:
        return TextInputType.phone;
      case SharedTextInputType.multiline:
      case SharedTextInputType.observation:
      case SharedTextInputType.description:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    // Add custom formatters if provided
    if (inputFormatters != null) {
      formatters.addAll(inputFormatters!);
    }

    // Add length formatter if maxLength is specified
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    // Add specific formatters based on input type
    switch (inputType) {
      case SharedTextInputType.name:
      case SharedTextInputType.veterinarian:
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')));
        break;
      case SharedTextInputType.email:
        formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
        break;
      case SharedTextInputType.phone:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      default:
        break;
    }

    return formatters.isNotEmpty ? formatters : null;
  }

  String? _validateRequired(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return FormConstants.requiredFieldMessage;
    }

    // Specific validations based on input type
    switch (inputType) {
      case SharedTextInputType.email:
        return _validateEmail(value!);
      case SharedTextInputType.name:
      case SharedTextInputType.veterinarian:
        if (value!.trim().length < FormConstants.minNameLength) {
          return 'Nome deve ter pelo menos ${FormConstants.minNameLength} caracteres';
        }
        break;
      case SharedTextInputType.description:
      case SharedTextInputType.diagnosis:
        if (value!.trim().length < FormConstants.minDescriptionLength) {
          return 'Descrição deve ter pelo menos ${FormConstants.minDescriptionLength} caracteres';
        }
        break;
      default:
        break;
    }

    return null;
  }

  String? _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'E-mail inválido';
    }
    return null;
  }

  /// Método estático para validação de texto
  static String? validateText(
    String? value, {
    bool required = false,
    int? minLength,
    int? maxLength,
    SharedTextInputType? type,
  }) {
    if (required && (value?.trim().isEmpty ?? true)) {
      return FormConstants.requiredFieldMessage;
    }

    if (value?.trim().isEmpty ?? true) return null;

    final trimmedValue = value!.trim();

    if (minLength != null && trimmedValue.length < minLength) {
      return 'Mínimo de $minLength caracteres';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return 'Máximo de $maxLength caracteres';
    }

    if (type == SharedTextInputType.email) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(trimmedValue)) {
        return 'E-mail inválido';
      }
    }

    return null;
  }
}

/// Formatador para números de telefone
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    
    if (digits.length <= 2) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    } else if (digits.length <= 10) {
      formatted = '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else {
      formatted = '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
