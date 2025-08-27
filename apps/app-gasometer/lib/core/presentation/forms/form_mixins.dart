import 'package:flutter/material.dart';

import '../../providers/base_provider.dart';

/// Mixin for handling loading states in forms
mixin FormLoadingMixin<T extends StatefulWidget> on State<T> {
  
  /// Check if the provider is in loading state
  bool isLoading(dynamic provider) {
    // Try to access common loading property names
    try {
      final isLoadingProperty = (provider as dynamic).isLoading;
      if (isLoadingProperty is bool) {
        return isLoadingProperty;
      }
    } catch (e) {
      // Try alternative property names
      try {
        final loadingState = (provider as dynamic).loading;
        if (loadingState is bool) {
          return loadingState;
        }
      } catch (e2) {
        // Try state-based loading check
        try {
          if (provider is BaseProvider) {
            return provider.isLoading;
          }
        } catch (e3) {
          // Ignore and fall through
        }
      }
    }
    return false;
  }
}

/// Mixin for handling form errors with standardized dialogs
mixin FormErrorMixin<T extends StatefulWidget> on State<T> {
  
  /// Get the last error from provider
  String? getLastError(dynamic provider) {
    // Try to access common error property names
    try {
      final lastErrorProperty = (provider as dynamic).lastError;
      if (lastErrorProperty is String) {
        return lastErrorProperty;
      }
    } catch (e) {
      // Try alternative property names
      try {
        final errorMessage = (provider as dynamic).errorMessage;
        if (errorMessage is String) {
          return errorMessage;
        }
      } catch (e2) {
        // Try accessing error object
        try {
          if (provider is BaseProvider) {
            return provider.error?.message;
          }
        } catch (e3) {
          // Try form model error
          try {
            final formModel = (provider as dynamic).formModel;
            final lastError = formModel?.lastError;
            if (lastError is String) {
              return lastError;
            }
          } catch (e4) {
            // Ignore and fall through
          }
        }
      }
    }
    return null;
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Mixin for form validation logic
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  
  /// Get the form key from provider
  GlobalKey<FormState>? getFormKey(dynamic provider) {
    // Try to access common form key property names
    try {
      final formKeyProperty = (provider as dynamic).formKey;
      if (formKeyProperty is GlobalKey<FormState>) {
        return formKeyProperty;
      }
    } catch (e) {
      // Try alternative property names
      try {
        final formStateKey = (provider as dynamic).formStateKey;
        if (formStateKey is GlobalKey<FormState>) {
          return formStateKey;
        }
      } catch (e2) {
        // Try accessing from form model
        try {
          final formModel = (provider as dynamic).formModel;
          final formKey = formModel?.formKey;
          if (formKey is GlobalKey<FormState>) {
            return formKey;
          }
        } catch (e3) {
          // Ignore and fall through
        }
      }
    }
    return null;
  }
  
  /// Validate the form using provider's validation logic
  bool validateForm(dynamic provider) {
    // First try provider's own validation method
    try {
      return (provider as dynamic).validateForm() as bool;
    } catch (e) {
      // Provider doesn't have validateForm method, fall back to form key validation
    }
    
    // Fallback to form key validation
    final formKey = getFormKey(provider);
    if (formKey?.currentState != null) {
      return formKey!.currentState!.validate();
    }
    
    return true; // Default to valid if no validation available
  }
  
  /// Check if form can be submitted
  bool canSubmit(dynamic provider) {
    // First try provider's canSubmit property
    try {
      final canSubmitProperty = (provider as dynamic).canSubmit;
      if (canSubmitProperty is bool) {
        return canSubmitProperty;
      }
    } catch (e) {
      // Provider doesn't have canSubmit property
    }
    
    // Fallback: check if form is valid and not loading
    final isValid = validateForm(provider);
    final loading = (this as FormLoadingMixin).isLoading(provider);
    
    return isValid && !loading;
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
  bool hasUnsavedChanges(dynamic provider) {
    try {
      final hasChangesProperty = (provider as dynamic).hasChanges;
      if (hasChangesProperty is bool) {
        return hasChangesProperty;
      }
    } catch (e) {
      // Provider doesn't have hasChanges property
    }
    
    return false; // Default to no changes
  }
}