import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Factory interface for creating form fields following Abstract Factory pattern
/// 
/// This interface allows different implementations for various field types
/// while maintaining consistent creation patterns. It follows Open/Closed
/// Principle by being open for extension but closed for modification.
/// 
/// Example usage:
/// ```dart
/// final factory = MaterialFieldFactory();
/// final textField = factory.createTextField(TextFieldConfig(...));
/// final dropdown = factory.createDropdownField(DropdownFieldConfig(...));
/// ```
abstract class IFieldFactory {
  /// Create a text input field
  Widget createTextField(TextFieldConfig config);
  
  /// Create a dropdown/select field
  Widget createDropdownField(DropdownFieldConfig config);
  
  /// Create a number input field
  Widget createNumberField(NumberFieldConfig config);
  
  /// Create a date picker field
  Widget createDateField(DateFieldConfig config);
  
  /// Create a time picker field
  Widget createTimeField(TimeFieldConfig config);
  
  /// Create a switch/toggle field
  Widget createSwitchField(SwitchFieldConfig config);
  
  /// Create a checkbox field
  Widget createCheckboxField(CheckboxFieldConfig config);
  
  /// Create a radio button group field
  Widget createRadioGroupField(RadioGroupFieldConfig config);
  
  /// Create a multi-select field
  Widget createMultiSelectField(MultiSelectFieldConfig config);
  
  /// Create a file picker field
  Widget createFileField(FileFieldConfig config);
  
  /// Create a custom field from a configuration
  Widget createCustomField(CustomFieldConfig config);
  
  /// Register a custom field creator
  void registerCustomFieldCreator(String fieldType, FieldCreator creator);
  
  /// Check if a field type is supported
  bool supportsFieldType(String fieldType);
  
  /// Get all supported field types
  List<String> getSupportedFieldTypes();
}

/// Function type for creating custom fields
typedef FieldCreator = Widget Function(FieldConfig config);

/// Base configuration for all field types
abstract class FieldConfig {
  final String key;
  final String? label;
  final String? hint;
  final bool isRequired;
  final bool isEnabled;
  final dynamic initialValue;
  final ValueChanged<dynamic>? onChanged;
  final VoidCallback? onTap;
  final String? errorMessage;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? padding;
  final Map<String, dynamic> metadata;
  
  const FieldConfig({
    required this.key,
    this.label,
    this.hint,
    this.isRequired = false,
    this.isEnabled = true,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.errorMessage,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.metadata = const {},
  });
  
  /// Get field type identifier
  String get fieldType;
  
  /// Check if field has error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  
  /// Create copy with modifications
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  });
}

/// Configuration for text input fields
class TextFieldConfig extends FieldConfig {
  final TextInputType keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? validationPattern;
  
  const TextFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validationPattern,
  });
  
  @override
  String get fieldType => 'text';
  
  @override
  TextFieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
    TextInputType? keyboardType,
    int? maxLength,
    int? maxLines,
    bool? obscureText,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    String? validationPattern,
  }) {
    return TextFieldConfig(
      key: key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
      keyboardType: keyboardType ?? this.keyboardType,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      obscureText: obscureText ?? this.obscureText,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      validationPattern: validationPattern ?? this.validationPattern,
    );
  }
}

/// Configuration for dropdown fields
class DropdownFieldConfig extends FieldConfig {
  final List<DropdownOption> options;
  final bool isSearchable;
  final String? searchHint;
  final bool allowMultiple;
  
  const DropdownFieldConfig({
    required super.key,
    required this.options,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.isSearchable = false,
    this.searchHint,
    this.allowMultiple = false,
  });
  
  @override
  String get fieldType => 'dropdown';
  
  @override
  DropdownFieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
    List<DropdownOption>? options,
    bool? isSearchable,
    String? searchHint,
    bool? allowMultiple,
  }) {
    return DropdownFieldConfig(
      key: key,
      options: options ?? this.options,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
      isSearchable: isSearchable ?? this.isSearchable,
      searchHint: searchHint ?? this.searchHint,
      allowMultiple: allowMultiple ?? this.allowMultiple,
    );
  }
}

/// Option for dropdown fields
class DropdownOption {
  final dynamic value;
  final String label;
  final Widget? icon;
  final bool isEnabled;
  final Map<String, dynamic> metadata;
  
  const DropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.isEnabled = true,
    this.metadata = const {},
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownOption && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'DropdownOption(value: $value, label: $label)';
}

/// Configuration for number fields
class NumberFieldConfig extends TextFieldConfig {
  final num? minValue;
  final num? maxValue;
  final int? decimalPlaces;
  final bool allowNegative;
  
  const NumberFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.minValue,
    this.maxValue,
    this.decimalPlaces,
    this.allowNegative = true,
  }) : super(keyboardType: TextInputType.number);
  
  @override
  String get fieldType => 'number';
}

/// Configuration for date fields
class DateFieldConfig extends FieldConfig {
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? dateFormat;
  final bool showTime;
  
  const DateFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.minDate,
    this.maxDate,
    this.dateFormat,
    this.showTime = false,
  });
  
  @override
  String get fieldType => 'date';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return DateFieldConfig(
      key: key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
      minDate: minDate,
      maxDate: maxDate,
      dateFormat: dateFormat,
      showTime: showTime,
    );
  }
}

/// Configuration for time fields
class TimeFieldConfig extends FieldConfig {
  final bool use24HourFormat;
  final String? timeFormat;
  
  const TimeFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.use24HourFormat = true,
    this.timeFormat,
  });
  
  @override
  String get fieldType => 'time';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return TimeFieldConfig(
      key: key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
      use24HourFormat: use24HourFormat,
      timeFormat: timeFormat,
    );
  }
}

/// Configuration for switch fields
class SwitchFieldConfig extends FieldConfig {
  final String? trueLabel;
  final String? falseLabel;
  
  const SwitchFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.trueLabel,
    this.falseLabel,
  });
  
  @override
  String get fieldType => 'switch';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return SwitchFieldConfig(
      key: key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
      trueLabel: trueLabel,
      falseLabel: falseLabel,
    );
  }
}

/// Configuration for checkbox fields
class CheckboxFieldConfig extends FieldConfig {
  const CheckboxFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
  });
  
  @override
  String get fieldType => 'checkbox';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return CheckboxFieldConfig(
      key: key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Configuration for radio group fields
class RadioGroupFieldConfig extends FieldConfig {
  final List<RadioOption> options;
  final Axis direction;
  
  const RadioGroupFieldConfig({
    required super.key,
    required this.options,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.direction = Axis.vertical,
  });
  
  @override
  String get fieldType => 'radio_group';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return RadioGroupFieldConfig(
      key: key,
      options: options,
      direction: direction,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Option for radio group fields
class RadioOption {
  final dynamic value;
  final String label;
  final Widget? icon;
  final bool isEnabled;
  
  const RadioOption({
    required this.value,
    required this.label,
    this.icon,
    this.isEnabled = true,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadioOption && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
}

/// Configuration for multi-select fields
class MultiSelectFieldConfig extends FieldConfig {
  final List<DropdownOption> options;
  final int? maxSelections;
  final String? allSelectedText;
  final String? noneSelectedText;
  
  const MultiSelectFieldConfig({
    required super.key,
    required this.options,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.maxSelections,
    this.allSelectedText,
    this.noneSelectedText,
  });
  
  @override
  String get fieldType => 'multi_select';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return MultiSelectFieldConfig(
      key: key,
      options: options,
      maxSelections: maxSelections,
      allSelectedText: allSelectedText,
      noneSelectedText: noneSelectedText,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Configuration for file picker fields
class FileFieldConfig extends FieldConfig {
  final List<String> allowedExtensions;
  final int? maxFileSizeMB;
  final bool allowMultiple;
  final String? acceptButtonText;
  
  const FileFieldConfig({
    required super.key,
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
    this.allowedExtensions = const [],
    this.maxFileSizeMB,
    this.allowMultiple = false,
    this.acceptButtonText,
  });
  
  @override
  String get fieldType => 'file';
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return FileFieldConfig(
      key: key,
      allowedExtensions: allowedExtensions,
      maxFileSizeMB: maxFileSizeMB,
      allowMultiple: allowMultiple,
      acceptButtonText: acceptButtonText,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Configuration for custom fields
class CustomFieldConfig extends FieldConfig {
  final String customType;
  final Map<String, dynamic> customProperties;
  
  const CustomFieldConfig({
    required super.key,
    required this.customType,
    this.customProperties = const {},
    super.label,
    super.hint,
    super.isRequired,
    super.isEnabled,
    super.initialValue,
    super.onChanged,
    super.onTap,
    super.errorMessage,
    super.prefixIcon,
    super.suffixIcon,
    super.padding,
    super.metadata,
  });
  
  @override
  String get fieldType => customType;
  
  @override
  FieldConfig copyWith({
    String? label,
    String? hint,
    bool? isRequired,
    bool? isEnabled,
    dynamic initialValue,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onTap,
    String? errorMessage,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
    Map<String, dynamic>? metadata,
  }) {
    return CustomFieldConfig(
      key: key,
      customType: customType,
      customProperties: customProperties,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isRequired: isRequired ?? this.isRequired,
      isEnabled: isEnabled ?? this.isEnabled,
      initialValue: initialValue ?? this.initialValue,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      errorMessage: errorMessage,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      padding: padding ?? this.padding,
      metadata: metadata ?? this.metadata,
    );
  }
}