// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../utils/responsive_layout.dart';
import '../validators/numeric_input_validator.dart';

/// Componentes reutilizáveis para campos de formulário
class FormFieldComponents {
  /// Campo de texto padrão
  static Widget textField({
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    TextEditingController? controller,
    int? maxLength,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    TextAlign textAlign = TextAlign.start,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      style: ShadcnStyle.inputStyle,
      maxLength: maxLength,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      enabled: enabled,
      decoration: ShadcnStyle.inputDecoration(
        label: label,
        hint: hint,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
      ).copyWith(
        counterText: maxLength != null ? '' : null,
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }

  /// Campo de descrição específico
  static Widget descricaoField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return textField(
      label: 'Descrição',
      hint: 'Digite a descrição do pluviômetro',
      icon: Icons.description,
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      maxLength: 80,
      onChanged: onChanged,
    );
  }

  /// Campo de quantidade específico com validação avançada
  static Widget quantidadeField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextEditingController? controller,
    void Function(String)? onChanged,
  }) {
    return textField(
      label: 'Quantidade',
      hint: 'Digite a quantidade',
      icon: Icons.water_drop,
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        NumericInputValidator.createNumericFormatter(
          maxDecimalPlaces: 2,
          maxValue: 1000.0,
          allowNegative: false,
        ),
      ],
      suffixText: 'mm',
      textAlign: TextAlign.end,
      onChanged: onChanged,
    );
  }

  /// Campo de latitude específico com validação avançada
  static Widget latitudeField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return textField(
      label: 'Latitude',
      hint: 'Ex: -23.550520',
      icon: Icons.location_on,
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        NumericInputValidator.createNumericFormatter(
          maxDecimalPlaces: 6,
          allowNegative: true,
        ),
      ],
      textAlign: TextAlign.end,
      onChanged: onChanged,
    );
  }

  /// Campo de longitude específico com validação avançada
  static Widget longitudeField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return textField(
      label: 'Longitude',
      hint: 'Ex: -46.633309',
      icon: Icons.location_on,
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        NumericInputValidator.createNumericFormatter(
          maxDecimalPlaces: 6,
          allowNegative: true,
        ),
      ],
      textAlign: TextAlign.end,
      onChanged: onChanged,
    );
  }

  /// Campo de grupo específico
  static Widget grupoField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return textField(
      label: 'Grupo',
      hint: 'Digite o grupo do pluviômetro',
      icon: Icons.group,
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      maxLength: 50,
      onChanged: onChanged,
    );
  }

  /// Seção de formulário com título responsivo
  static Widget section({
    required String title,
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return Builder(
      builder: (context) {
        final responsivePadding =
            padding ?? ResponsiveLayout.getResponsivePadding(context);
        final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);

        return Padding(
          padding: responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ShadcnStyle.subtitleStyle,
              ),
              SizedBox(height: sectionSpacing),
              ...children,
            ],
          ),
        );
      },
    );
  }

  /// Botão de ação com GPS responsivo
  static Widget gpsButton({
    required String label,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Builder(
      builder: (context) {
        final buttonHeight = ResponsiveLayout.getButtonHeight(context);
        final buttonWidth = ResponsiveLayout.getButtonWidth(context);

        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: const Icon(Icons.gps_fixed),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Indicador de validação
  static Widget validationIndicator({
    required bool isValid,
    required bool isValidating,
    String? message,
  }) {
    if (isValidating) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Validando...', style: TextStyle(fontSize: 12)),
        ],
      );
    }

    if (message != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            size: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// Espaçador responsivo entre campos
  static Widget spacer({double? height}) {
    return Builder(
      builder: (context) {
        final responsiveHeight =
            height ?? ResponsiveLayout.getFieldSpacing(context);
        return SizedBox(height: responsiveHeight);
      },
    );
  }
}

/// Builder para construção de formulários dinâmicos
class FormBuilder {
  final List<Widget> _fields = [];
  final GlobalKey<FormState> _formKey;

  FormBuilder({GlobalKey<FormState>? formKey})
      : _formKey = formKey ?? GlobalKey<FormState>();

  /// Adiciona um campo ao formulário
  FormBuilder addField(Widget field) {
    _fields.add(field);
    return this;
  }

  /// Adiciona um espaçador
  FormBuilder addSpacer({double height = 16}) {
    _fields.add(FormFieldComponents.spacer(height: height));
    return this;
  }

  /// Adiciona uma seção
  FormBuilder addSection({
    required String title,
    required List<Widget> children,
  }) {
    _fields.add(FormFieldComponents.section(
      title: title,
      children: children,
    ));
    return this;
  }

  /// Constrói o formulário
  Widget build() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _fields,
      ),
    );
  }

  /// Adiciona campo de quantidade com validação avançada
  FormBuilder addQuantidadeField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextEditingController? controller,
    void Function(String)? onChanged,
  }) {
    return addField(FormFieldComponents.quantidadeField(
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      onChanged: onChanged,
    ));
  }

  /// Adiciona campo de latitude com validação avançada
  FormBuilder addLatitudeField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return addField(FormFieldComponents.latitudeField(
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      onChanged: onChanged,
    ));
  }

  /// Adiciona campo de longitude com validação avançada
  FormBuilder addLongitudeField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return addField(FormFieldComponents.longitudeField(
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      onChanged: onChanged,
    ));
  }

  /// Adiciona campo de descrição
  FormBuilder addDescricaoField({
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return addField(FormFieldComponents.descricaoField(
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      onChanged: onChanged,
    ));
  }

  /// Obtém a chave do formulário
  GlobalKey<FormState> get formKey => _formKey;
}
