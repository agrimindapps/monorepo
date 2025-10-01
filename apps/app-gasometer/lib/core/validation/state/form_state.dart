/// Re-export form state from architecture
/// 
/// This module provides convenient access to form state classes
/// following the Single Responsibility Principle.
library;

import '../architecture/i_form_state_manager.dart';

// Re-export core state classes
export '../architecture/i_form_state_manager.dart'
    show
        FormState,
        FormStateChangeListener;

// Additional utilities and extensions for form state

/// Form state extensions for convenience methods
extension FormStateExtensions<T> on FormState<T> {
  /// Check if the form is in a valid state to submit
  bool get isReadyToSubmit {
    return canSubmit && !isLoading && error == null;
  }
  
  /// Check if the form has any data
  bool get hasData {
    return data != null || fieldValues.isNotEmpty;
  }
  
  /// Check if the form is in initial state
  bool get isInitial {
    return !isDirty && !isLoading && error == null && 
           fieldValues.isEmpty && validationResult == null;
  }
  
  /// Get a field value with type casting
  T? getFieldValueAs<T>(String fieldName) {
    final value = fieldValues[fieldName];
    return value is T ? value : null;
  }
  
  /// Get field value with default
  T getFieldValueOr<T>(String fieldName, T defaultValue) {
    final value = fieldValues[fieldName];
    return value is T ? value : defaultValue;
  }
  
  /// Check if all required fields have values
  bool areRequiredFieldsFilled(List<String> requiredFields) {
    for (final field in requiredFields) {
      if (!hasFieldValue(field)) {
        return false;
      }
    }
    return true;
  }
  
  /// Get validation errors for specific fields
  Map<String, String> getFieldErrors(List<String> fieldNames) {
    final errors = <String, String>{};
    
    for (final fieldName in fieldNames) {
      final error = getFieldError(fieldName);
      if (error != null) {
        errors[fieldName] = error;
      }
    }
    
    return errors;
  }
  
  /// Check if any of the specified fields have errors
  bool hasErrorsIn(List<String> fieldNames) {
    return fieldNames.any((field) => !isFieldValid(field));
  }
  
  /// Get summary of form state
  FormStateSummary get summary {
    return FormStateSummary(
      isValid: isValid,
      isDirty: isDirty,
      isLoading: isLoading,
      hasError: error != null,
      errorMessage: error,
      fieldCount: fieldValues.length,
      invalidFieldCount: validationResult?.invalidFields.length ?? 0,
      lastModified: lastModified,
    );
  }
  
  /// Create a debugging string
  String toDebugString() {
    final buffer = StringBuffer();
    buffer.writeln('FormState<$T> {');
    buffer.writeln('  isValid: $isValid');
    buffer.writeln('  isDirty: $isDirty');
    buffer.writeln('  isLoading: $isLoading');
    buffer.writeln('  error: $error');
    buffer.writeln('  canSubmit: $canSubmit');
    buffer.writeln('  fieldCount: ${fieldValues.length}');
    buffer.writeln('  lastModified: $lastModified');
    
    if (fieldValues.isNotEmpty) {
      buffer.writeln('  fieldValues: {');
      fieldValues.forEach((key, value) {
        buffer.writeln('    $key: $value');
      });
      buffer.writeln('  }');
    }
    
    if (validationResult != null) {
      buffer.writeln('  validation: {');
      buffer.writeln('    isValid: ${validationResult!.isValid}');
      buffer.writeln('    errors: ${validationResult!.invalidFields.length}');
      buffer.writeln('    warnings: ${validationResult!.fieldsWithWarnings.length}');
      buffer.writeln('  }');
    }
    
    buffer.writeln('}');
    return buffer.toString();
  }
}

/// Summary of form state for quick overview
class FormStateSummary {
  
  const FormStateSummary({
    required this.isValid,
    required this.isDirty,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.fieldCount,
    required this.invalidFieldCount,
    required this.lastModified,
  });
  final bool isValid;
  final bool isDirty;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final int fieldCount;
  final int invalidFieldCount;
  final DateTime lastModified;
  
  /// Check if form is ready for submission
  bool get canSubmit {
    return isValid && !isLoading && !hasError && fieldCount > 0;
  }
  
  /// Get form status description
  String get statusDescription {
    if (isLoading) return 'Carregando...';
    if (hasError) return 'Erro: $errorMessage';
    if (!isValid) return 'Formulário inválido ($invalidFieldCount erro(s))';
    if (isDirty) return 'Formulário modificado';
    return 'Formulário válido';
  }
  
  @override
  String toString() {
    return 'FormStateSummary(valid: $isValid, dirty: $isDirty, '
           'loading: $isLoading, fields: $fieldCount)';
  }
}

/// Form state change tracker for debugging and analytics
class FormStateTracker<T> {
  
  FormStateTracker({this.maxHistorySize = 100});
  final List<FormStateChange<T>> _changes = [];
  final int maxHistorySize;
  
  /// Track a state change
  void trackChange(FormState<T> oldState, FormState<T> newState, String action) {
    final change = FormStateChange(
      oldState: oldState,
      newState: newState,
      action: action,
      timestamp: DateTime.now(),
    );
    
    _changes.add(change);
    
    // Limit history size
    if (_changes.length > maxHistorySize) {
      _changes.removeAt(0);
    }
  }
  
  /// Get all changes
  List<FormStateChange<T>> get changes => List.unmodifiable(_changes);
  
  /// Get recent changes
  List<FormStateChange<T>> getRecentChanges(int count) {
    final startIndex = (_changes.length - count).clamp(0, _changes.length);
    return _changes.sublist(startIndex);
  }
  
  /// Get changes for a specific field
  List<FormStateChange<T>> getFieldChanges(String fieldName) {
    return _changes.where((change) {
      final oldValue = change.oldState.getFieldValue(fieldName);
      final newValue = change.newState.getFieldValue(fieldName);
      return oldValue != newValue;
    }).toList();
  }
  
  /// Clear tracking history
  void clear() {
    _changes.clear();
  }
  
  /// Get change statistics
  FormChangeStatistics get statistics {
    if (_changes.isEmpty) {
      return FormChangeStatistics.empty();
    }
    
    final actions = <String, int>{};
    final fieldChanges = <String, int>{};
    
    for (final change in _changes) {
      actions[change.action] = (actions[change.action] ?? 0) + 1;
      
      // Track field changes
      for (final fieldName in change.newState.fieldValues.keys) {
        final oldValue = change.oldState.getFieldValue(fieldName);
        final newValue = change.newState.getFieldValue(fieldName);
        if (oldValue != newValue) {
          fieldChanges[fieldName] = (fieldChanges[fieldName] ?? 0) + 1;
        }
      }
    }
    
    return FormChangeStatistics(
      totalChanges: _changes.length,
      actionCounts: actions,
      fieldChangeCounts: fieldChanges,
      firstChange: _changes.first.timestamp,
      lastChange: _changes.last.timestamp,
    );
  }
}

/// Individual form state change record
class FormStateChange<T> {
  
  const FormStateChange({
    required this.oldState,
    required this.newState,
    required this.action,
    required this.timestamp,
  });
  final FormState<T> oldState;
  final FormState<T> newState;
  final String action;
  final DateTime timestamp;
  
  /// Get the duration since this change
  Duration get timeSinceChange => DateTime.now().difference(timestamp);
  
  /// Check if this was a field value change
  bool get isFieldChange => action.startsWith('field_');
  
  /// Check if this was a validation change
  bool get isValidationChange => action.contains('validation');
  
  /// Get changed field names
  List<String> get changedFields {
    final changed = <String>[];
    
    // Check all fields from both states
    final allFields = {...oldState.fieldValues.keys, ...newState.fieldValues.keys};
    
    for (final field in allFields) {
      final oldValue = oldState.getFieldValue(field);
      final newValue = newState.getFieldValue(field);
      if (oldValue != newValue) {
        changed.add(field);
      }
    }
    
    return changed;
  }
  
  @override
  String toString() {
    return 'FormStateChange(action: $action, time: $timestamp, '
           'changedFields: ${changedFields.length})';
  }
}

/// Statistics about form state changes
class FormChangeStatistics {
  
  const FormChangeStatistics({
    required this.totalChanges,
    required this.actionCounts,
    required this.fieldChangeCounts,
    this.firstChange,
    this.lastChange,
  });
  
  /// Create empty statistics
  factory FormChangeStatistics.empty() {
    return const FormChangeStatistics(
      totalChanges: 0,
      actionCounts: {},
      fieldChangeCounts: {},
    );
  }
  final int totalChanges;
  final Map<String, int> actionCounts;
  final Map<String, int> fieldChangeCounts;
  final DateTime? firstChange;
  final DateTime? lastChange;
  
  /// Get total session duration
  Duration? get sessionDuration {
    if (firstChange == null || lastChange == null) return null;
    return lastChange!.difference(firstChange!);
  }
  
  /// Get most changed field
  String? get mostChangedField {
    if (fieldChangeCounts.isEmpty) return null;
    
    String? mostChanged;
    int maxChanges = 0;
    
    fieldChangeCounts.forEach((field, count) {
      if (count > maxChanges) {
        maxChanges = count;
        mostChanged = field;
      }
    });
    
    return mostChanged;
  }
  
  /// Get most common action
  String? get mostCommonAction {
    if (actionCounts.isEmpty) return null;
    
    String? mostCommon;
    int maxCount = 0;
    
    actionCounts.forEach((action, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = action;
      }
    });
    
    return mostCommon;
  }
  
  @override
  String toString() {
    return 'FormChangeStatistics(total: $totalChanges, '
           'duration: $sessionDuration, '
           'mostChanged: $mostChangedField)';
  }
}