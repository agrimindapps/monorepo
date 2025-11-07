import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../architecture/i_field_factory.dart';
import 'base_form_field.dart';

/// Concrete implementation of field factory for Material Design
///
/// This factory creates Material Design form fields following the
/// Abstract Factory pattern. It's easily extensible for custom field types.
class MaterialFieldFactory implements IFieldFactory {
  final Map<String, FieldCreator> _customCreators = {};

  @override
  Widget createTextField(TextFieldConfig config) {
    return _MaterialTextField(config: config);
  }

  @override
  Widget createDropdownField(DropdownFieldConfig config) {
    return _MaterialDropdownField(config: config);
  }

  @override
  Widget createNumberField(NumberFieldConfig config) {
    return _MaterialNumberField(config: config);
  }

  @override
  Widget createDateField(DateFieldConfig config) {
    return _MaterialDateField(config: config);
  }

  @override
  Widget createTimeField(TimeFieldConfig config) {
    return _MaterialTimeField(config: config);
  }

  @override
  Widget createSwitchField(SwitchFieldConfig config) {
    return _MaterialSwitchField(config: config);
  }

  @override
  Widget createCheckboxField(CheckboxFieldConfig config) {
    return _MaterialCheckboxField(config: config);
  }

  @override
  Widget createRadioGroupField(RadioGroupFieldConfig config) {
    return _MaterialRadioGroupField(config: config);
  }

  @override
  Widget createMultiSelectField(MultiSelectFieldConfig config) {
    return _MaterialMultiSelectField(config: config);
  }

  @override
  Widget createFileField(FileFieldConfig config) {
    return _MaterialFileField(config: config);
  }

  @override
  Widget createCustomField(CustomFieldConfig config) {
    final creator = _customCreators[config.customType];
    if (creator == null) {
      throw UnsupportedError(
        'Custom field type ${config.customType} not registered',
      );
    }
    return creator(config);
  }

  @override
  void registerCustomFieldCreator(String fieldType, FieldCreator creator) {
    _customCreators[fieldType] = creator;
  }

  @override
  bool supportsFieldType(String fieldType) {
    const supportedTypes = {
      'text',
      'dropdown',
      'number',
      'date',
      'time',
      'switch',
      'checkbox',
      'radio_group',
      'multi_select',
      'file',
    };

    return supportedTypes.contains(fieldType) ||
        _customCreators.containsKey(fieldType);
  }

  @override
  List<String> getSupportedFieldTypes() {
    const builtInTypes = [
      'text',
      'dropdown',
      'number',
      'date',
      'time',
      'switch',
      'checkbox',
      'radio_group',
      'multi_select',
      'file',
    ];

    return [...builtInTypes, ..._customCreators.keys];
  }
}

/// Material Design text field implementation
class _MaterialTextField extends BaseFormField {
  const _MaterialTextField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialTextFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final textState = state as _MaterialTextFieldState;
    final config = this.config as TextFieldConfig;

    return TextField(
      controller: textState.textController,
      focusNode: textState.focusNode,
      decoration: textState.getInputDecoration(),
      keyboardType: config.keyboardType,
      maxLength: config.maxLength,
      maxLines: config.maxLines,
      obscureText: config.obscureText,
      inputFormatters: config.inputFormatters,
      textCapitalization: config.textCapitalization,
      enabled: config.isEnabled,
      onTap: config.onTap,
    );
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final textState = state as _MaterialTextFieldState;
    return textState.currentText;
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final textState = state as _MaterialTextFieldState;
    textState.setText(value?.toString() ?? '');
  }
}

class _MaterialTextFieldState extends BaseFormFieldState<_MaterialTextField>
    with TextInputMixin<_MaterialTextField> {}

/// Material Design dropdown field implementation
class _MaterialDropdownField extends BaseFormField {
  const _MaterialDropdownField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialDropdownFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final dropdownState = state as _MaterialDropdownFieldState;
    final config = this.config as DropdownFieldConfig;

    return DropdownButtonFormField<dynamic>(
      initialValue: dropdownState.selectedValue,
      decoration: dropdownState.getInputDecoration(),
      items: config.options.map((option) {
        return DropdownMenuItem<dynamic>(
          value: option.value,
          enabled: option.isEnabled,
          child: Row(
            children: [
              if (option.icon != null) ...[
                option.icon!,
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(option.label)),
            ],
          ),
        );
      }).toList(),
      onChanged: config.isEnabled ? dropdownState.setSelectedValue : null,
      focusNode: dropdownState.focusNode,
    );
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final dropdownState = state as _MaterialDropdownFieldState;
    return dropdownState.selectedValue;
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final dropdownState = state as _MaterialDropdownFieldState;
    dropdownState.setSelectedValue(value);
  }
}

class _MaterialDropdownFieldState
    extends BaseFormFieldState<_MaterialDropdownField>
    with SelectionMixin<_MaterialDropdownField> {}

/// Material Design number field implementation
class _MaterialNumberField extends BaseFormField {
  const _MaterialNumberField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialNumberFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final numberState = state as _MaterialNumberFieldState;
    final config = this.config as NumberFieldConfig;

    return TextField(
      controller: numberState.textController,
      focusNode: numberState.focusNode,
      decoration: numberState.getInputDecoration(),
      keyboardType: TextInputType.numberWithOptions(
        decimal: config.decimalPlaces != null && config.decimalPlaces! > 0,
        signed: config.allowNegative,
      ),
      inputFormatters: _buildNumberFormatters(config),
      enabled: config.isEnabled,
      onTap: config.onTap,
    );
  }

  List<TextInputFormatter> _buildNumberFormatters(NumberFieldConfig config) {
    final formatters = <TextInputFormatter>[];
    if (config.allowNegative) {
      formatters.add(
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      );
    } else {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')));
    }
    if (config.decimalPlaces != null) {
      formatters.add(_DecimalTextInputFormatter(config.decimalPlaces!));
    }

    return formatters;
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final numberState = state as _MaterialNumberFieldState;
    final text = numberState.currentText;
    if (text.isEmpty) return null;
    return num.tryParse(text);
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final numberState = state as _MaterialNumberFieldState;
    numberState.setText(value?.toString() ?? '');
  }
}

class _MaterialNumberFieldState extends BaseFormFieldState<_MaterialNumberField>
    with TextInputMixin<_MaterialNumberField> {}

/// Material Design date field implementation
class _MaterialDateField extends BaseFormField {
  const _MaterialDateField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialDateFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final dateState = state as _MaterialDateFieldState;
    final config = this.config as DateFieldConfig;

    return TextField(
      controller: dateState.textController,
      focusNode: dateState.focusNode,
      decoration: dateState.getInputDecoration(
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      enabled: config.isEnabled,
      onTap: config.isEnabled
          ? () => _selectDate(context, dateState, config)
          : null,
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    _MaterialDateFieldState state,
    DateFieldConfig config,
  ) async {
    final initialDate = state.selectedValue as DateTime? ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: config.minDate ?? DateTime(1900),
      lastDate: config.maxDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      state.setSelectedValue(date);
      state.setText(_formatDate(date, config.dateFormat));
    }
  }

  String _formatDate(DateTime date, String? format) {
    if (format != null) {
      return format
          .replaceAll('dd', date.day.toString().padLeft(2, '0'))
          .replaceAll('MM', date.month.toString().padLeft(2, '0'))
          .replaceAll('yyyy', date.year.toString());
    }

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final dateState = state as _MaterialDateFieldState;
    return dateState.selectedValue;
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final dateState = state as _MaterialDateFieldState;
    if (value is DateTime) {
      dateState.setSelectedValue(value);
      final config = this.config as DateFieldConfig;
      dateState.setText(_formatDate(value, config.dateFormat));
    } else {
      dateState.setSelectedValue(null);
      dateState.setText('');
    }
  }
}

class _MaterialDateFieldState extends BaseFormFieldState<_MaterialDateField>
    with
        TextInputMixin<_MaterialDateField>,
        SelectionMixin<_MaterialDateField> {}

/// Material Design time field implementation
class _MaterialTimeField extends BaseFormField {
  const _MaterialTimeField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialTimeFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final timeState = state as _MaterialTimeFieldState;
    final config = this.config as TimeFieldConfig;

    return TextField(
      controller: timeState.textController,
      focusNode: timeState.focusNode,
      decoration: timeState.getInputDecoration(
        suffixIcon: const Icon(Icons.access_time),
      ),
      readOnly: true,
      enabled: config.isEnabled,
      onTap: config.isEnabled
          ? () => _selectTime(context, timeState, config)
          : null,
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    _MaterialTimeFieldState state,
    TimeFieldConfig config,
  ) async {
    final initialTime = state.selectedValue as TimeOfDay? ?? TimeOfDay.now();

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(alwaysUse24HourFormat: config.use24HourFormat),
            child: child!,
          ),
        );
      },
    );

    if (time != null) {
      state.setSelectedValue(time);
      state.setText(_formatTime(time, config));
    }
  }

  String _formatTime(TimeOfDay time, TimeFieldConfig config) {
    if (config.use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final timeState = state as _MaterialTimeFieldState;
    return timeState.selectedValue;
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final timeState = state as _MaterialTimeFieldState;
    if (value is TimeOfDay) {
      timeState.setSelectedValue(value);
      final config = this.config as TimeFieldConfig;
      timeState.setText(_formatTime(value, config));
    } else {
      timeState.setSelectedValue(null);
      timeState.setText('');
    }
  }
}

class _MaterialTimeFieldState extends BaseFormFieldState<_MaterialTimeField>
    with
        TextInputMixin<_MaterialTimeField>,
        SelectionMixin<_MaterialTimeField> {}

/// Material Design switch field implementation
class _MaterialSwitchField extends BaseFormField {
  const _MaterialSwitchField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialSwitchFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final switchState = state as _MaterialSwitchFieldState;
    final config = this.config as SwitchFieldConfig;

    return SwitchListTile(
      title: config.label != null ? Text(config.label!) : null,
      subtitle: config.hint != null ? Text(config.hint!) : null,
      value: switchState.booleanValue,
      onChanged: config.isEnabled
          ? (bool? value) => switchState.setBooleanValue(value ?? false)
          : null,
      secondary: config.prefixIcon,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final switchState = state as _MaterialSwitchFieldState;
    return switchState.booleanValue;
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final switchState = state as _MaterialSwitchFieldState;
    switchState.setBooleanValue(value == true);
  }
}

class _MaterialSwitchFieldState extends BaseFormFieldState<_MaterialSwitchField>
    with BooleanMixin<_MaterialSwitchField> {}

/// Material Design checkbox field implementation
class _MaterialCheckboxField extends BaseFormField {
  const _MaterialCheckboxField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialCheckboxFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    final checkboxState = state as _MaterialCheckboxFieldState;
    final config = this.config as CheckboxFieldConfig;

    return CheckboxListTile(
      title: config.label != null ? Text(config.label!) : null,
      subtitle: config.hint != null ? Text(config.hint!) : null,
      value: checkboxState.booleanValue,
      onChanged: config.isEnabled
          ? (bool? value) => checkboxState.setBooleanValue(value ?? false)
          : null,
      secondary: config.prefixIcon,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) {
    final checkboxState = state as _MaterialCheckboxFieldState;
    return checkboxState.booleanValue;
  }

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {
    final checkboxState = state as _MaterialCheckboxFieldState;
    checkboxState.setBooleanValue(value == true);
  }
}

class _MaterialCheckboxFieldState
    extends BaseFormFieldState<_MaterialCheckboxField>
    with BooleanMixin<_MaterialCheckboxField> {}

/// Placeholder implementations for remaining field types
class _MaterialRadioGroupField extends BaseFormField {
  const _MaterialRadioGroupField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialRadioGroupFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    return const Placeholder();
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) => null;

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {}
}

class _MaterialRadioGroupFieldState
    extends BaseFormFieldState<_MaterialRadioGroupField> {}

class _MaterialMultiSelectField extends BaseFormField {
  const _MaterialMultiSelectField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialMultiSelectFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    return const Placeholder();
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) => null;

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {}
}

class _MaterialMultiSelectFieldState
    extends BaseFormFieldState<_MaterialMultiSelectField> {}

class _MaterialFileField extends BaseFormField {
  const _MaterialFileField({required super.config});

  @override
  BaseFormFieldState createState() => _MaterialFileFieldState();

  @override
  Widget buildField(BuildContext context, BaseFormFieldState state) {
    return const Placeholder();
  }

  @override
  dynamic getCurrentValue(BaseFormFieldState state) => null;

  @override
  void setFieldValue(BaseFormFieldState state, dynamic value) {}
}

class _MaterialFileFieldState extends BaseFormFieldState<_MaterialFileField> {}

/// Custom text input formatter for decimal places
class _DecimalTextInputFormatter extends TextInputFormatter {
  _DecimalTextInputFormatter(this.decimalPlaces);
  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final dotIndex = text.indexOf('.');
    if (dotIndex != -1) {
      final afterDot = text.substring(dotIndex + 1);
      if (afterDot.length > decimalPlaces) {
        final truncated = text.substring(0, dotIndex + 1 + decimalPlaces);
        return TextEditingValue(
          text: truncated,
          selection: TextSelection.collapsed(offset: truncated.length),
        );
      }
    }

    return newValue;
  }
}
