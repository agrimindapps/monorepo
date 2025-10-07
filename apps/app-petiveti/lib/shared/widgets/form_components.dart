import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// **Enhanced Form Components Library**
///
/// A comprehensive collection of form-related components that provide
/// consistent styling, validation feedback, and accessibility support
/// across the entire PetiVeti application.
///
/// ## Components Included:
/// - **Enhanced Text Fields**: With validation states and feedback
/// - **Validation Indicators**: Visual feedback for form validation
/// - **Form Sections**: Structured form organization
/// - **Input Hints**: Helpful guidance for users
/// - **Error States**: Clear error messaging and recovery
///
/// ## Features:
/// - **Material Design 3 Compliance**: Latest design standards
/// - **Accessibility Support**: Screen reader and keyboard navigation
/// - **Validation Feedback**: Real-time visual and semantic feedback
/// - **Consistent Styling**: Unified appearance across all forms
/// - **Performance Optimized**: Efficient rendering and state management
///
/// @author PetiVeti UX/UI Team
/// @since 1.0.0
class FormComponents {
  FormComponents._();

  /// **Enhanced Text Form Field**
  ///
  /// A text form field with enhanced validation feedback, accessibility support,
  /// and consistent styling across the application.
  ///
  /// **Parameters:**
  /// - [controller]: Text editing controller
  /// - [label]: Field label text
  /// - [hint]: Optional hint text
  /// - [helperText]: Optional helper text shown below field
  /// - [validator]: Validation function
  /// - [keyboardType]: Input type for optimized keyboard
  /// - [prefixIcon]: Optional leading icon
  /// - [suffixIcon]: Optional trailing icon
  /// - [obscureText]: Whether to obscure text (for passwords)
  /// - [enabled]: Whether the field is interactive
  /// - [maxLines]: Maximum number of lines (null for unlimited)
  /// - [maxLength]: Maximum character count
  /// - [autofocus]: Whether to focus automatically
  /// - [textCapitalization]: Text capitalization behavior
  /// - [validationState]: Current validation state for visual feedback
  ///
  /// **Usage Example:**
  /// ```dart
  /// FormComponents.enhancedTextField(
  ///   controller: nameController,
  ///   label: 'Nome do Pet',
  ///   hint: 'Digite o nome do seu pet',
  ///   helperText: 'Use apenas letras e espaços',
  ///   prefixIcon: Icons.pets,
  ///   validator: (value) => value?.isEmpty == true ? 'Nome é obrigatório' : null,
  ///   validationState: ValidationState.valid,
  /// )
  /// ```
  static Widget enhancedTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    bool enabled = true,
    int? maxLines = 1,
    int? maxLength,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValidationState validationState = ValidationState.none,
    VoidCallback? onEditingComplete,
    void Function(String)? onChanged,
  }) {
    final borderColor = _getValidationColor(validationState);
    final prefixIconColor = _getValidationColor(validationState, isIcon: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: label,
          hint: hint,
          textField: true,
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: maxLines,
            maxLength: maxLength,
            autofocus: autofocus,
            textCapitalization: textCapitalization,
            onEditingComplete: onEditingComplete,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              helperText: helperText,
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, color: prefixIconColor)
                      : null,
              suffixIcon: _buildSuffixIcon(suffixIcon, validationState),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.error),
              ),
              helperStyle: TextStyle(
                color: _getValidationColor(validationState, isHelper: true),
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (validationState != ValidationState.none)
          _buildValidationFeedback(validationState),
      ],
    );
  }

  /// **Password Text Field**
  ///
  /// Specialized text field for password input with visibility toggle.
  ///
  /// **Parameters:**
  /// - [controller]: Text editing controller
  /// - [label]: Field label (defaults to 'Senha')
  /// - [hint]: Optional hint text
  /// - [validator]: Password validation function
  /// - [helperText]: Optional helper text with password requirements
  /// - [showStrengthIndicator]: Whether to show password strength
  ///
  /// **Features:**
  /// - Password visibility toggle
  /// - Strength indicator (optional)
  /// - Secure text entry
  /// - Accessibility optimized
  static Widget passwordTextField({
    required TextEditingController controller,
    String label = 'Senha',
    String? hint,
    String? Function(String?)? validator,
    String? helperText,
    bool showStrengthIndicator = false,
    ValidationState validationState = ValidationState.none,
    void Function(String)? onChanged,
  }) {
    return _PasswordTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      helperText: helperText,
      showStrengthIndicator: showStrengthIndicator,
      validationState: validationState,
      onChanged: onChanged,
    );
  }

  /// **Dropdown Field**
  ///
  /// Enhanced dropdown field with consistent styling and validation support.
  ///
  /// **Parameters:**
  /// - [value]: Currently selected value
  /// - [items]: List of dropdown items
  /// - [onChanged]: Callback when selection changes
  /// - [label]: Field label
  /// - [hint]: Optional hint text
  /// - [prefixIcon]: Optional leading icon
  /// - [validator]: Validation function
  /// - [enabled]: Whether the field is interactive
  ///
  /// **Usage Example:**
  /// ```dart
  /// FormComponents.dropdownField<AnimalType>(
  ///   value: selectedType,
  ///   items: AnimalType.values.map((type) =>
  ///     DropdownMenuItem(value: type, child: Text(type.name))
  ///   ).toList(),
  ///   onChanged: (value) => setState(() => selectedType = value),
  ///   label: 'Tipo de Animal',
  ///   prefixIcon: Icons.pets,
  /// )
  /// ```
  static Widget dropdownField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String label,
    String? hint,
    IconData? prefixIcon,
    String? Function(T?)? validator,
    bool enabled = true,
    ValidationState validationState = ValidationState.none,
  }) {
    final borderColor = _getValidationColor(validationState);

    return Semantics(
      label: label,
      hint: hint,
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              prefixIcon != null
                  ? Icon(
                    prefixIcon,
                    color: _getValidationColor(validationState, isIcon: true),
                  )
                  : null,
          suffixIcon: _buildSuffixIcon(null, validationState),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
        ),
      ),
    );
  }

  /// **Form Section**
  ///
  /// Groups related form fields with consistent styling and spacing.
  ///
  /// **Parameters:**
  /// - [title]: Section title
  /// - [children]: List of form widgets in this section
  /// - [icon]: Optional section icon
  /// - [description]: Optional section description
  /// - [isRequired]: Whether this section is required
  /// - [isCollapsible]: Whether the section can be collapsed
  ///
  /// **Features:**
  /// - Consistent spacing
  /// - Optional collapsible behavior
  /// - Required field indication
  /// - Accessibility support
  static Widget formSection({
    required String title,
    required List<Widget> children,
    IconData? icon,
    String? description,
    bool isRequired = false,
    bool isCollapsible = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = true;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap:
                      isCollapsible
                          ? () => setState(() => isExpanded = !isExpanded)
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Obrigatório',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        if (isCollapsible)
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                  ),
                ),
                if (description != null && isExpanded) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  ...children.map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: child,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _getValidationColor(
    ValidationState state, {
    bool isIcon = false,
    bool isHelper = false,
  }) {
    switch (state) {
      case ValidationState.valid:
        return AppColors.success;
      case ValidationState.error:
        return AppColors.error;
      case ValidationState.warning:
        return AppColors.warning;
      case ValidationState.loading:
        return AppColors.primary;
      case ValidationState.none:
        if (isIcon) return AppColors.textSecondary;
        if (isHelper) return AppColors.textSecondary;
        return AppColors.border;
    }
  }

  static Widget? _buildSuffixIcon(
    Widget? customSuffix,
    ValidationState validationState,
  ) {
    if (customSuffix != null) return customSuffix;

    switch (validationState) {
      case ValidationState.valid:
        return const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 20,
        );
      case ValidationState.error:
        return const Icon(Icons.error, color: AppColors.error, size: 20);
      case ValidationState.warning:
        return const Icon(
          Icons.warning_amber,
          color: AppColors.warning,
          size: 20,
        );
      case ValidationState.loading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        );
      case ValidationState.none:
        return null;
    }
  }

  static Widget _buildValidationFeedback(ValidationState state) {
    IconData icon;
    Color color;
    String message;

    switch (state) {
      case ValidationState.valid:
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        message = 'Campo válido';
        break;
      case ValidationState.error:
        icon = Icons.error_outline;
        color = AppColors.error;
        message = 'Verifique este campo';
        break;
      case ValidationState.warning:
        icon = Icons.warning_amber_outlined;
        color = AppColors.warning;
        message = 'Atenção necessária';
        break;
      case ValidationState.loading:
        icon = Icons.hourglass_empty;
        color = AppColors.primary;
        message = 'Validando...';
        break;
      case ValidationState.none:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPasswordStrengthIndicator(String password) {
    final strength = _calculatePasswordStrength(password);
    final strengthLabel = _getStrengthLabel(strength);
    final strengthColor = _getStrengthColor(strength);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Força da senha: ', style: TextStyle(fontSize: 12)),
              Text(
                strengthLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: strength / 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(strengthColor),
          ),
        ],
      ),
    );
  }

  static int _calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  static String _getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Muito Fraca';
      case 2:
        return 'Fraca';
      case 3:
        return 'Média';
      case 4:
        return 'Forte';
      default:
        return 'Muito Fraca';
    }
  }

  static Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }
}

/// Private stateful widget for password text field
class _PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final String? helperText;
  final bool showStrengthIndicator;
  final ValidationState validationState;
  final void Function(String)? onChanged;

  const _PasswordTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.helperText,
    required this.showStrengthIndicator,
    required this.validationState,
    this.onChanged,
  });

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormComponents.enhancedTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint ?? 'Digite sua senha',
          helperText: widget.helperText,
          validator: widget.validator,
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            onPressed: () => setState(() => _isObscured = !_isObscured),
            icon: Icon(
              _isObscured ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: _isObscured ? 'Mostrar senha' : 'Ocultar senha',
          ),
          obscureText: _isObscured,
          validationState: widget.validationState,
          onChanged: widget.onChanged,
        ),
        if (widget.showStrengthIndicator)
          FormComponents._buildPasswordStrengthIndicator(
            widget.controller.text,
          ),
      ],
    );
  }
}

/// **Validation State Enumeration**
///
/// Represents the current validation state of a form field
/// for appropriate visual feedback and user guidance.
enum ValidationState {
  /// No validation state
  none,

  /// Field is valid
  valid,

  /// Field has an error
  error,

  /// Field has a warning
  warning,

  /// Field is being validated
  loading,
}
