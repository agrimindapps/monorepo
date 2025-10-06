import 'package:flutter/material.dart';

import 'base_form_page.dart';

/// Mixin for handling loading states in forms
mixin FormLoadingMixin<T extends StatefulWidget> on State<T> {
  
  /// Check if the provider is in loading state
  /// ✅ TYPE SAFETY FIX: Use interface instead of dynamic casting
  bool isLoading(IFormProvider provider) {
    return provider.isLoading;
  }
}

/// Mixin for handling form errors with standardized dialogs
mixin FormErrorMixin<T extends StatefulWidget> on State<T> {
  
  /// Get the last error from provider
  /// ✅ TYPE SAFETY FIX: Use interface instead of dynamic casting
  String? getLastError(IFormProvider provider) {
    return provider.lastError;
  }
  
  /// Show standardized error dialog
  void showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show standardized error snackbar
  void showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Show standardized success snackbar
  void showSuccessSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Mixin for form validation logic
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  
  /// Get the form key from provider
  /// ✅ TYPE SAFETY FIX: Use interface instead of dynamic casting
  GlobalKey<FormState>? getFormKey(IFormProvider provider) {
    return provider.formKey;
  }
  
  /// Validate the form using provider's validation logic
  /// ✅ TYPE SAFETY FIX: Use interface instead of dynamic casting
  bool validateForm(IFormProvider provider) {
    return provider.validateForm();
  }
  
  /// Check if form can be submitted
  /// ✅ TYPE SAFETY FIX: Use interface instead of dynamic casting and this cast
  bool canSubmit(IFormProvider provider) {
    return provider.canSubmit;
  }
}

/// Mixin for input sanitization
mixin FormSanitizationMixin<T extends StatefulWidget> on State<T> {
  
  /// Sanitize text input by trimming and removing extra spaces
  String sanitizeTextInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Sanitize numeric input by removing invalid characters
  String sanitizeNumericInput(String input) {
    return input.replaceAll(RegExp(r'[^0-9.,]'), '');
  }
  
  /// Sanitize decimal input and normalize comma/dot
  String sanitizeDecimalInput(String input) {
    return input
        .replaceAll(RegExp(r'[^0-9.,]'), '')
        .replaceAll(',', '.');
  }
  
  /// Convert sanitized decimal string to double
  double? parseDecimal(String input) {
    final sanitized = sanitizeDecimalInput(input);
    if (sanitized.isEmpty) return null;
    
    return double.tryParse(sanitized);
  }
}

/// Mixin for navigation handling
mixin FormNavigationMixin<T extends StatefulWidget> on State<T> {
  
  /// Navigate back with result
  void navigateBack({bool success = false}) {
    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }
  
  /// Show unsaved changes dialog before navigation
  Future<bool> showUnsavedChangesDialog() async {
    if (!mounted) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text(
          'Você tem alterações não salvas. Deseja sair sem salvar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair sem salvar'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Check if provider has unsaved changes
  /// Note: This is optional functionality, not in IFormProvider interface
  bool hasUnsavedChanges(dynamic provider) {
    try {
      final hasChangesProperty = (provider as dynamic).hasChanges;
      if (hasChangesProperty is bool) {
        return hasChangesProperty;
      }
    } catch (e) {
    }
    
    return false; // Default to no changes
  }
}
