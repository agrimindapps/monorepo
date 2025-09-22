import 'package:flutter/material.dart';
import '../architecture/i_field_factory.dart';
import '../architecture/i_form_validator.dart';

/// Abstract base widget for all form fields
/// 
/// This class provides common functionality for form fields while allowing
/// subclasses to implement specific field types. Follows Template Method
/// pattern and Single Responsibility Principle.
abstract class BaseFormField extends StatefulWidget {
  final FieldConfig config;
  final IFieldValidator? validator;
  final void Function(String key, dynamic value)? onChanged;
  final FocusNode? focusNode;
  final bool autovalidate;
  
  const BaseFormField({
    super.key,
    required this.config,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.autovalidate = false,
  });
  
  @override
  BaseFormFieldState createState();
  
  /// Create the specific field widget
  Widget buildField(BuildContext context, BaseFormFieldState state);
  
  /// Get the current field value
  dynamic getCurrentValue(BaseFormFieldState state);
  
  /// Set the field value
  void setFieldValue(BaseFormFieldState state, dynamic value);
  
  /// Validate the current field value
  String? validateField(dynamic value) {
    if (validator == null) return null;
    
    final result = validator!.validate(value);
    return result.isValid ? null : result.errorMessage;
  }
}

/// Base state for form fields
abstract class BaseFormFieldState<T extends BaseFormField> extends State<T> {
  late FocusNode _focusNode;
  String? _errorText;
  bool _hasInteracted = false;
  
  /// Get the focus node for this field
  FocusNode get focusNode => widget.focusNode ?? _focusNode;
  
  /// Get current error text
  String? get errorText => _errorText;
  
  /// Check if field has been interacted with
  bool get hasInteracted => _hasInteracted;
  
  /// Check if field should show error
  bool get shouldShowError {
    return _errorText != null && 
           (_hasInteracted || widget.autovalidate);
  }
  
  @override
  void initState() {
    super.initState();
    
    // Create focus node if not provided
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    }
    
    // Listen to focus changes
    focusNode.addListener(_onFocusChanged);
    
    // Initial validation if autovalidate is enabled
    if (widget.autovalidate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _validateField();
      });
    }
  }
  
  @override
  void dispose() {
    focusNode.removeListener(_onFocusChanged);
    
    // Dispose focus node if we created it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        if (widget.config.label != null) ...[
          _buildLabel(context),
          const SizedBox(height: 8),
        ],
        
        // Main field widget
        _buildFieldWithDecoration(context),
        
        // Error text
        if (shouldShowError) ...[
          const SizedBox(height: 4),
          _buildErrorText(context),
        ],
        
        // Hint text
        if (widget.config.hint != null && !shouldShowError) ...[
          const SizedBox(height: 4),
          _buildHintText(context),
        ],
      ],
    );
  }
  
  /// Build field label
  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    
    return RichText(
      text: TextSpan(
        text: widget.config.label!,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
        children: [
          if (widget.config.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
  
  /// Build field with decoration
  Widget _buildFieldWithDecoration(BuildContext context) {
    final field = widget.buildField(context, this);
    
    // Apply padding if specified
    if (widget.config.padding != null) {
      return Padding(
        padding: widget.config.padding!,
        child: field,
      );
    }
    
    return field;
  }
  
  /// Build error text
  Widget _buildErrorText(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      _errorText!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
  
  /// Build hint text
  Widget _buildHintText(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      widget.config.hint!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
  
  /// Handle value changes
  void onValueChanged(dynamic value) {
    _hasInteracted = true;
    
    // Validate the new value
    _validateField(value);
    
    // Notify parent of change
    widget.onChanged?.call(widget.config.key, value);
  }
  
  /// Handle focus changes
  void _onFocusChanged() {
    if (!focusNode.hasFocus && _hasInteracted) {
      // Validate on focus lost
      _validateField();
    }
  }
  
  /// Validate the field
  void _validateField([dynamic value]) {
    final currentValue = value ?? widget.getCurrentValue(this);
    final errorMessage = widget.validateField(currentValue);
    
    if (mounted) {
      setState(() {
        _errorText = errorMessage;
      });
    }
  }
  
  /// Force validation (public method)
  void validate() {
    _hasInteracted = true;
    _validateField();
  }
  
  /// Clear validation error
  void clearError() {
    if (mounted) {
      setState(() {
        _errorText = null;
      });
    }
  }
  
  /// Set validation error
  void setError(String error) {
    if (mounted) {
      setState(() {
        _errorText = error;
      });
    }
  }
  
  /// Check if field is valid
  bool get isValid => _errorText == null;
  
  /// Get decoration for input fields
  InputDecoration getInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    
    return InputDecoration(
      hintText: hintText ?? widget.config.hint,
      prefixIcon: prefixIcon ?? widget.config.prefixIcon,
      suffixIcon: suffixIcon ?? widget.config.suffixIcon,
      errorText: shouldShowError ? _errorText : null,
      enabled: widget.config.isEnabled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: widget.config.isEnabled
          ? Colors.white
          : Colors.grey.shade100,
    );
  }
}

/// Mixin for form fields that handle text input
mixin TextInputMixin<T extends BaseFormField> on BaseFormFieldState<T> {
  late TextEditingController _textController;
  
  /// Get the text editing controller
  TextEditingController get textController => _textController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize text controller with initial value
    final initialValue = widget.config.initialValue;
    _textController = TextEditingController(
      text: initialValue?.toString() ?? '',
    );
    
    // Listen to text changes
    _textController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }
  
  /// Handle text changes
  void _onTextChanged() {
    onValueChanged(_textController.text);
  }
  
  /// Get current text value
  String get currentText => _textController.text;
  
  /// Set text value
  void setText(String text) {
    if (_textController.text != text) {
      _textController.text = text;
    }
  }
}

/// Mixin for form fields that handle selection
mixin SelectionMixin<T extends BaseFormField> on BaseFormFieldState<T> {
  dynamic _selectedValue;
  
  /// Get selected value
  dynamic get selectedValue => _selectedValue;
  
  @override
  void initState() {
    super.initState();
    _selectedValue = widget.config.initialValue;
  }
  
  /// Set selected value
  void setSelectedValue(dynamic value) {
    if (_selectedValue != value) {
      setState(() {
        _selectedValue = value;
      });
      onValueChanged(value);
    }
  }
  
  /// Clear selection
  void clearSelection() {
    setSelectedValue(null);
  }
}

/// Mixin for form fields that handle boolean values
mixin BooleanMixin<T extends BaseFormField> on BaseFormFieldState<T> {
  bool _booleanValue = false;
  
  /// Get boolean value
  bool get booleanValue => _booleanValue;
  
  @override
  void initState() {
    super.initState();
    _booleanValue = widget.config.initialValue == true;
  }
  
  /// Set boolean value
  void setBooleanValue(bool value) {
    if (_booleanValue != value) {
      setState(() {
        _booleanValue = value;
      });
      onValueChanged(value);
    }
  }
  
  /// Toggle boolean value
  void toggleBooleanValue() {
    setBooleanValue(!_booleanValue);
  }
}