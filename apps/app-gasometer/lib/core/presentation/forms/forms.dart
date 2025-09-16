/// Barrel file for SOLID form architecture components
/// 
/// This file provides a convenient way to import all form-related components
/// for the new SOLID form architecture, including interfaces, configurations,
/// state management, validation, and field factories.
/// 
/// Usage:
/// ```dart
/// import '../../../../core/presentation/forms/forms.dart';
/// ```

// Legacy form components (maintained for backward compatibility)
export 'base_form_dialog.dart';
export 'base_form_page.dart';
export 'form_mixins.dart';
export 'form_widgets.dart';

// SOLID Architecture - Core Interfaces
export 'architecture/i_form_builder.dart';
export 'architecture/i_form_validator.dart';
export 'architecture/i_form_state_manager.dart';
export 'architecture/i_field_factory.dart';

// Configuration
export 'config/form_config.dart';
export 'config/field_config.dart';
export 'config/validation_config.dart';

// State Management
export 'state/form_state.dart';
export 'state/form_state_manager.dart';

// Validation System
export 'validation/validation_result.dart';
export 'validation/validators/base_validator.dart';
export 'validation/validators/required_validator.dart';
export 'validation/validators/length_validator.dart';
export 'validation/validators/email_validator.dart';

// Field System
export 'fields/base_form_field.dart';
export 'fields/field_factory.dart';