/// Re-export field configurations from the factory interface
/// 
/// This module provides convenient access to all field configuration classes
/// and follows the Single Responsibility Principle by centralizing field
/// configuration types.
/// 
/// Usage:
/// ```dart
/// import 'field_config.dart';
/// 
/// final textConfig = TextFieldConfig(
///   key: 'name',
///   label: 'Nome',
///   isRequired: true,
/// );
/// ```
library;
import '../architecture/i_field_factory.dart';
export '../architecture/i_field_factory.dart'
    show
        FieldConfig,
        TextFieldConfig,
        DropdownFieldConfig,
        NumberFieldConfig,
        DateFieldConfig,
        TimeFieldConfig,
        SwitchFieldConfig,
        CheckboxFieldConfig,
        RadioGroupFieldConfig,
        MultiSelectFieldConfig,
        FileFieldConfig,
        CustomFieldConfig,
        DropdownOption,
        RadioOption;

/// Builder for creating text field configurations
class TextFieldConfigBuilder {
  String? _key;
  String? _label;
  String? _hint;
  bool _isRequired = false;
  bool _isEnabled = true;
  dynamic _initialValue;
  String? _validationPattern;
  int? _maxLength;
  int _maxLines = 1;
  bool _obscureText = false;
  
  /// Set field key
  TextFieldConfigBuilder key(String key) {
    _key = key;
    return this;
  }
  
  /// Set field label
  TextFieldConfigBuilder label(String label) {
    _label = label;
    return this;
  }
  
  /// Set field hint
  TextFieldConfigBuilder hint(String hint) {
    _hint = hint;
    return this;
  }
  
  /// Mark field as required
  TextFieldConfigBuilder required([bool isRequired = true]) {
    _isRequired = isRequired;
    return this;
  }
  
  /// Set field enabled state
  TextFieldConfigBuilder enabled([bool isEnabled = true]) {
    _isEnabled = isEnabled;
    return this;
  }
  
  /// Set initial value
  TextFieldConfigBuilder initialValue(dynamic value) {
    _initialValue = value;
    return this;
  }
  
  /// Set validation pattern (regex)
  TextFieldConfigBuilder validationPattern(String pattern) {
    _validationPattern = pattern;
    return this;
  }
  
  /// Set maximum length
  TextFieldConfigBuilder maxLength(int length) {
    _maxLength = length;
    return this;
  }
  
  /// Set maximum lines
  TextFieldConfigBuilder maxLines(int lines) {
    _maxLines = lines;
    return this;
  }
  
  /// Mark field as password (obscured)
  TextFieldConfigBuilder password([bool isPassword = true]) {
    _obscureText = isPassword;
    return this;
  }
  
  /// Build the configuration
  TextFieldConfig build() {
    if (_key == null) {
      throw ArgumentError('Field key is required');
    }
    
    return TextFieldConfig(
      key: _key!,
      label: _label,
      hint: _hint,
      isRequired: _isRequired,
      isEnabled: _isEnabled,
      initialValue: _initialValue,
      validationPattern: _validationPattern,
      maxLength: _maxLength,
      maxLines: _maxLines,
      obscureText: _obscureText,
    );
  }
}

/// Builder for creating dropdown field configurations
class DropdownFieldConfigBuilder {
  String? _key;
  String? _label;
  String? _hint;
  bool _isRequired = false;
  bool _isEnabled = true;
  dynamic _initialValue;
  final List<DropdownOption> _options = [];
  bool _isSearchable = false;
  String? _searchHint;
  bool _allowMultiple = false;
  
  /// Set field key
  DropdownFieldConfigBuilder key(String key) {
    _key = key;
    return this;
  }
  
  /// Set field label
  DropdownFieldConfigBuilder label(String label) {
    _label = label;
    return this;
  }
  
  /// Set field hint
  DropdownFieldConfigBuilder hint(String hint) {
    _hint = hint;
    return this;
  }
  
  /// Mark field as required
  DropdownFieldConfigBuilder required([bool isRequired = true]) {
    _isRequired = isRequired;
    return this;
  }
  
  /// Set field enabled state
  DropdownFieldConfigBuilder enabled([bool isEnabled = true]) {
    _isEnabled = isEnabled;
    return this;
  }
  
  /// Set initial value
  DropdownFieldConfigBuilder initialValue(dynamic value) {
    _initialValue = value;
    return this;
  }
  
  /// Add dropdown option
  DropdownFieldConfigBuilder option(dynamic value, String label) {
    _options.add(DropdownOption(value: value, label: label));
    return this;
  }
  
  /// Add multiple options from map
  DropdownFieldConfigBuilder options(Map<dynamic, String> optionsMap) {
    _options.addAll(
      optionsMap.entries.map(
        (entry) => DropdownOption(value: entry.key, label: entry.value),
      ),
    );
    return this;
  }
  
  /// Add multiple options from list
  DropdownFieldConfigBuilder optionsList(List<DropdownOption> options) {
    _options.addAll(options);
    return this;
  }
  
  /// Enable search functionality
  DropdownFieldConfigBuilder searchable([bool isSearchable = true, String? hint]) {
    _isSearchable = isSearchable;
    _searchHint = hint;
    return this;
  }
  
  /// Allow multiple selections
  DropdownFieldConfigBuilder multiSelect([bool allowMultiple = true]) {
    _allowMultiple = allowMultiple;
    return this;
  }
  
  /// Build the configuration
  DropdownFieldConfig build() {
    if (_key == null) {
      throw ArgumentError('Field key is required');
    }
    
    return DropdownFieldConfig(
      key: _key!,
      options: _options,
      label: _label,
      hint: _hint,
      isRequired: _isRequired,
      isEnabled: _isEnabled,
      initialValue: _initialValue,
      isSearchable: _isSearchable,
      searchHint: _searchHint,
      allowMultiple: _allowMultiple,
    );
  }
}

/// Builder for creating number field configurations
class NumberFieldConfigBuilder {
  String? _key;
  String? _label;
  String? _hint;
  bool _isRequired = false;
  bool _isEnabled = true;
  dynamic _initialValue;
  num? _minValue;
  num? _maxValue;
  int? _decimalPlaces;
  bool _allowNegative = true;
  
  /// Set field key
  NumberFieldConfigBuilder key(String key) {
    _key = key;
    return this;
  }
  
  /// Set field label
  NumberFieldConfigBuilder label(String label) {
    _label = label;
    return this;
  }
  
  /// Set field hint
  NumberFieldConfigBuilder hint(String hint) {
    _hint = hint;
    return this;
  }
  
  /// Mark field as required
  NumberFieldConfigBuilder required([bool isRequired = true]) {
    _isRequired = isRequired;
    return this;
  }
  
  /// Set field enabled state
  NumberFieldConfigBuilder enabled([bool isEnabled = true]) {
    _isEnabled = isEnabled;
    return this;
  }
  
  /// Set initial value
  NumberFieldConfigBuilder initialValue(num value) {
    _initialValue = value;
    return this;
  }
  
  /// Set minimum value
  NumberFieldConfigBuilder min(num minValue) {
    _minValue = minValue;
    return this;
  }
  
  /// Set maximum value
  NumberFieldConfigBuilder max(num maxValue) {
    _maxValue = maxValue;
    return this;
  }
  
  /// Set value range
  NumberFieldConfigBuilder range(num minValue, num maxValue) {
    _minValue = minValue;
    _maxValue = maxValue;
    return this;
  }
  
  /// Set decimal places
  NumberFieldConfigBuilder decimals(int decimalPlaces) {
    _decimalPlaces = decimalPlaces;
    return this;
  }
  
  /// Set whether negative values are allowed
  NumberFieldConfigBuilder allowNegative([bool allowNegative = true]) {
    _allowNegative = allowNegative;
    return this;
  }
  
  /// Build the configuration
  NumberFieldConfig build() {
    if (_key == null) {
      throw ArgumentError('Field key is required');
    }
    
    return NumberFieldConfig(
      key: _key!,
      label: _label,
      hint: _hint,
      isRequired: _isRequired,
      isEnabled: _isEnabled,
      initialValue: _initialValue,
      minValue: _minValue,
      maxValue: _maxValue,
      decimalPlaces: _decimalPlaces,
      allowNegative: _allowNegative,
    );
  }
}

/// Predefined field configuration templates
class FieldTemplates {
  /// Create a name text field
  static TextFieldConfig name({
    String key = 'name',
    String label = 'Nome',
    bool isRequired = true,
  }) {
    return TextFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .maxLength(100)
        .build();
  }
  
  /// Create an email text field
  static TextFieldConfig email({
    String key = 'email',
    String label = 'Email',
    bool isRequired = true,
  }) {
    return TextFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .validationPattern(r'^[^@]+@[^@]+\.[^@]+$')
        .build();
  }
  
  /// Create a phone text field
  static TextFieldConfig phone({
    String key = 'phone',
    String label = 'Telefone',
    bool isRequired = false,
  }) {
    return TextFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .validationPattern(r'^\(\d{2}\)\s\d{4,5}-\d{4}$')
        .build();
  }
  
  /// Create a password field
  static TextFieldConfig password({
    String key = 'password',
    String label = 'Senha',
    bool isRequired = true,
  }) {
    return TextFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .password()
        .build();
  }
  
  /// Create a currency number field
  static NumberFieldConfig currency({
    String key = 'amount',
    String label = 'Valor',
    bool isRequired = true,
  }) {
    return NumberFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .decimals(2)
        .min(0)
        .build();
  }
  
  /// Create a percentage number field
  static NumberFieldConfig percentage({
    String key = 'percentage',
    String label = 'Porcentagem',
    bool isRequired = false,
  }) {
    return NumberFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .range(0, 100)
        .decimals(2)
        .build();
  }
  
  /// Create a yes/no dropdown
  static DropdownFieldConfig yesNo({
    String key = 'yesNo',
    String label = 'Sim/Não',
    bool isRequired = true,
  }) {
    return DropdownFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .option(true, 'Sim')
        .option(false, 'Não')
        .build();
  }
  
  /// Create a status dropdown
  static DropdownFieldConfig status({
    String key = 'status',
    String label = 'Status',
    bool isRequired = true,
    Map<String, String> statusOptions = const {
      'active': 'Ativo',
      'inactive': 'Inativo',
    },
  }) {
    return DropdownFieldConfigBuilder()
        .key(key)
        .label(label)
        .required(isRequired)
        .options(statusOptions)
        .build();
  }
}

/// Utility for field configuration validation
class FieldConfigValidator {
  /// Validate a field configuration
  static List<String> validate(FieldConfig config) {
    final errors = <String>[];
    if (config.key.isEmpty) {
      errors.add('Field key cannot be empty');
    }
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(config.key)) {
      errors.add('Field key must be a valid identifier');
    }
    if (config is NumberFieldConfig) {
      if (config.minValue != null && config.maxValue != null) {
        if (config.minValue! > config.maxValue!) {
          errors.add('Min value cannot be greater than max value');
        }
      }
      
      if (config.decimalPlaces != null && config.decimalPlaces! < 0) {
        errors.add('Decimal places cannot be negative');
      }
    }
    
    if (config is TextFieldConfig) {
      if (config.maxLength != null && config.maxLength! <= 0) {
        errors.add('Max length must be positive');
      }
      
      if (config.maxLines <= 0) {
        errors.add('Max lines must be positive');
      }
    }
    
    if (config is DropdownFieldConfig) {
      if (config.options.isEmpty) {
        errors.add('Dropdown must have at least one option');
      }
      final values = config.options.map((o) => o.value).toList();
      final uniqueValues = values.toSet();
      if (values.length != uniqueValues.length) {
        errors.add('Dropdown options must have unique values');
      }
    }
    
    return errors;
  }
  
  /// Validate a list of field configurations
  static Map<String, List<String>> validateFields(List<FieldConfig> configs) {
    final results = <String, List<String>>{};
    for (final config in configs) {
      final errors = validate(config);
      if (errors.isNotEmpty) {
        results[config.key] = errors;
      }
    }
    final keys = configs.map((c) => c.key).toList();
    final uniqueKeys = keys.toSet();
    if (keys.length != uniqueKeys.length) {
      results['_global'] = ['Duplicate field keys found'];
    }
    
    return results;
  }
}
