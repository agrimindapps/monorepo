import 'dart:async';
import 'package:flutter/foundation.dart';

import '../architecture/i_form_state_manager.dart';
import '../architecture/i_form_validator.dart';
import 'form_state.dart';

/// Concrete implementation of form state manager
/// 
/// This class manages form state using Provider pattern and follows
/// Single Responsibility Principle by focusing solely on state management.
/// It provides reactive state updates and validation integration.
class FormStateManager<T> implements IFormStateManager<T> {
  
  FormStateManager({
    T? initialData,
    this.validationDebounce = const Duration(milliseconds: 300),
    this.autoSaveEnabled = false,
    this.autoSaveInterval = const Duration(seconds: 30),
    this.onAutoSave,
  }) : _currentState = FormState<T>.initial(initialData: initialData),
       _stateController = StreamController<FormState<T>>.broadcast(),
       _tracker = FormStateTracker<T>() {
    if (autoSaveEnabled && onAutoSave != null) {
      _startAutoSave();
    }
  }
  FormState<T> _currentState;
  final StreamController<FormState<T>> _stateController;
  final Map<String, FormState<T>> _snapshots = {};
  final FormStateTracker<T> _tracker;
  
  /// Validation debounce timer
  Timer? _validationTimer;
  
  /// Debounce duration for validation
  final Duration validationDebounce;
  
  /// Auto-save timer
  Timer? _autoSaveTimer;
  
  /// Auto-save configuration
  final bool autoSaveEnabled;
  final Duration autoSaveInterval;
  final Future<void> Function(T data)? onAutoSave;
  
  @override
  FormState<T> get currentState => _currentState;
  
  @override
  Stream<FormState<T>> get stateStream => _stateController.stream;
  
  @override
  Future<void> updateField(String fieldName, dynamic value) async {
    final oldState = _currentState;
    
    _currentState = _currentState.withFieldUpdate(fieldName, value);
    
    _notifyStateChange(oldState, 'field_update_$fieldName');
    _scheduleValidation();
    if (autoSaveEnabled) {
      _resetAutoSave();
    }
  }
  
  @override
  Future<void> updateFields(Map<String, dynamic> fieldUpdates) async {
    final oldState = _currentState;
    
    _currentState = _currentState.withFieldUpdates(fieldUpdates);
    
    _notifyStateChange(oldState, 'fields_update');
    _scheduleValidation();
    if (autoSaveEnabled) {
      _resetAutoSave();
    }
  }
  
  @override
  Future<void> setFormData(T data) async {
    final oldState = _currentState;
    
    _currentState = _currentState.copyWith(
      data: data,
      lastModified: DateTime.now(),
    );
    
    _notifyStateChange(oldState, 'set_form_data');
    if (autoSaveEnabled) {
      _resetAutoSave();
    }
  }
  
  @override
  Future<void> reset() async {
    final oldState = _currentState;
    
    _currentState = FormState<T>.initial(initialData: oldState.data);
    
    _notifyStateChange(oldState, 'reset');
    _validationTimer?.cancel();
    _autoSaveTimer?.cancel();
    if (autoSaveEnabled && onAutoSave != null) {
      _startAutoSave();
    }
  }
  
  @override
  Future<void> markDirty() async {
    if (!_currentState.isDirty) {
      final oldState = _currentState;
      _currentState = _currentState.copyWith(
        isDirty: true,
        lastModified: DateTime.now(),
      );
      _notifyStateChange(oldState, 'mark_dirty');
    }
  }
  
  @override
  Future<void> markClean() async {
    if (_currentState.isDirty) {
      final oldState = _currentState;
      _currentState = _currentState.toClean();
      _notifyStateChange(oldState, 'mark_clean');
    }
  }
  
  @override
  Future<void> setLoading(bool isLoading) async {
    if (_currentState.isLoading != isLoading) {
      final oldState = _currentState;
      _currentState = isLoading 
          ? _currentState.toLoading()
          : _currentState.copyWith(isLoading: false, lastModified: DateTime.now());
      _notifyStateChange(oldState, isLoading ? 'set_loading' : 'clear_loading');
    }
  }
  
  @override
  Future<void> setError(String? error) async {
    if (_currentState.error != error) {
      final oldState = _currentState;
      _currentState = error != null
          ? _currentState.toError(error)
          : _currentState.copyWith(error: null, lastModified: DateTime.now());
      _notifyStateChange(oldState, error != null ? 'set_error' : 'clear_error');
    }
  }
  
  @override
  Future<void> setValidationResult(FormValidationResult result) async {
    final oldState = _currentState;
    _currentState = _currentState.withValidation(result);
    _notifyStateChange(oldState, 'set_validation');
  }
  
  @override
  void saveSnapshot(String key) {
    _snapshots[key] = _currentState;
  }
  
  @override
  Future<void> restoreSnapshot(String key) async {
    final snapshot = _snapshots[key];
    if (snapshot != null) {
      final oldState = _currentState;
      _currentState = snapshot;
      _notifyStateChange(oldState, 'restore_snapshot_$key');
    }
  }
  
  @override
  bool get canSubmit => _currentState.canSubmit;
  
  @override
  bool get hasUnsavedChanges => _currentState.isDirty;
  
  final List<FormStateChangeListener<T>> _stateListeners = [];
  
  @override
  void addListener(FormStateChangeListener<T> listener) {
    _stateListeners.add(listener);
  }
  
  @override
  void removeListener(FormStateChangeListener<T> listener) {
    _stateListeners.remove(listener);
  }
  
  /// Notify all state listeners
  void _notifyStateListeners() {
    for (final listener in _stateListeners) {
      listener(_currentState);
    }
  }
  
  /// Notify state change
  void _notifyStateChange(FormState<T> oldState, String action) {
    _tracker.trackChange(oldState, _currentState, action);
    _notifyStateListeners();
    _stateController.add(_currentState);
  }
  
  /// Schedule validation with debouncing
  void _scheduleValidation() {
    _validationTimer?.cancel();
    _validationTimer = Timer(validationDebounce, () {
    });
  }
  
  /// Start auto-save timer
  void _startAutoSave() {
    if (onAutoSave == null) return;
    
    _autoSaveTimer = Timer.periodic(autoSaveInterval, (timer) async {
      if (_currentState.isDirty && _currentState.data != null) {
        try {
          await onAutoSave!(_currentState.data as T);
          await markClean();
        } catch (e) {
          debugPrint('Auto-save failed: $e');
        }
      }
    });
  }
  
  /// Reset auto-save timer
  void _resetAutoSave() {
    if (!autoSaveEnabled) return;
    
    _autoSaveTimer?.cancel();
    _startAutoSave();
  }
  
  /// Get state tracker for debugging
  FormStateTracker<T> get tracker => _tracker;
  
  /// Get snapshot keys
  List<String> get snapshotKeys => _snapshots.keys.toList();
  
  /// Clear all snapshots
  void clearSnapshots() {
    _snapshots.clear();
  }
  
  /// Remove specific snapshot
  void removeSnapshot(String key) {
    _snapshots.remove(key);
  }
  
  /// Get validation debounce timer status
  bool get isValidationScheduled => _validationTimer?.isActive ?? false;
  
  /// Force immediate validation (cancels debounce)
  void forceValidation() {
    _validationTimer?.cancel();
  }
  
  /// Manually trigger auto-save
  Future<void> triggerAutoSave() async {
    if (onAutoSave != null && _currentState.data != null) {
      await onAutoSave!(_currentState.data as T);
      await markClean();
    }
  }
  
  @override
  void dispose() {
    _validationTimer?.cancel();
    _autoSaveTimer?.cancel();
    _stateController.close();
    _tracker.clear();
    _snapshots.clear();
    _stateListeners.clear();
  }
}

/// Provider-compatible form state manager
/// 
/// This class wraps FormStateManager to provide ChangeNotifier compatibility
/// for use with Flutter Provider package.
class ProviderFormStateManager<T> extends ChangeNotifier {
  
  ProviderFormStateManager({
    T? initialData,
    Duration validationDebounce = const Duration(milliseconds: 300),
    bool autoSaveEnabled = false,
    Duration autoSaveInterval = const Duration(seconds: 30),
    Future<void> Function(T data)? onAutoSave,
  }) {
    _manager = FormStateManager<T>(
      initialData: initialData,
      validationDebounce: validationDebounce,
      autoSaveEnabled: autoSaveEnabled,
      autoSaveInterval: autoSaveInterval,
      onAutoSave: onAutoSave,
    );
    _manager.addListener((state) => notifyListeners());
  }
  
  /// Create a provider-compatible state manager with validation
  factory ProviderFormStateManager.withValidator({
    T? initialData,
    IFormValidator<T>? validator,
    Duration validationDebounce = const Duration(milliseconds: 300),
    bool autoSaveEnabled = false,
    Duration autoSaveInterval = const Duration(seconds: 30),
    Future<void> Function(T data)? onAutoSave,
  }) {
    final manager = ProviderFormStateManager<T>(
      initialData: initialData,
      validationDebounce: validationDebounce,
      autoSaveEnabled: autoSaveEnabled,
      autoSaveInterval: autoSaveInterval,
      onAutoSave: onAutoSave,
    );
    if (validator != null) {
      manager._manager.addListener((state) {
        if (state.data != null) {
          validator.validateForm(state.data as T).then((result) {
            manager.setValidationResult(result);
          });
        }
      });
    }
    
    return manager;
  }
  late final FormStateManager<T> _manager;
  FormState<T> get currentState => _manager.currentState;
  Stream<FormState<T>> get stateStream => _manager.stateStream;
  bool get canSubmit => _manager.canSubmit;
  bool get hasUnsavedChanges => _manager.hasUnsavedChanges;
  Future<void> updateField(String fieldName, dynamic value) => _manager.updateField(fieldName, value);
  Future<void> updateFields(Map<String, dynamic> fieldUpdates) => _manager.updateFields(fieldUpdates);
  Future<void> setFormData(T data) => _manager.setFormData(data);
  Future<void> reset() => _manager.reset();
  Future<void> markDirty() => _manager.markDirty();
  Future<void> markClean() => _manager.markClean();
  Future<void> setLoading(bool isLoading) => _manager.setLoading(isLoading);
  Future<void> setError(String? error) => _manager.setError(error);
  Future<void> setValidationResult(FormValidationResult result) => _manager.setValidationResult(result);
  void saveSnapshot(String key) => _manager.saveSnapshot(key);
  Future<void> restoreSnapshot(String key) => _manager.restoreSnapshot(key);
  
  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }
}

/// Form state manager builder for easy configuration
class FormStateManagerBuilder<T> {
  T? _initialData;
  Duration _validationDebounce = const Duration(milliseconds: 300);
  bool _autoSaveEnabled = false;
  Duration _autoSaveInterval = const Duration(seconds: 30);
  Future<void> Function(T data)? _onAutoSave;
  IFormValidator<T>? _validator;
  
  /// Set initial data
  FormStateManagerBuilder<T> withInitialData(T data) {
    _initialData = data;
    return this;
  }
  
  /// Set validation debounce
  FormStateManagerBuilder<T> withValidationDebounce(Duration duration) {
    _validationDebounce = duration;
    return this;
  }
  
  /// Enable auto-save
  FormStateManagerBuilder<T> withAutoSave({
    required Duration interval,
    required Future<void> Function(T data) onSave,
  }) {
    _autoSaveEnabled = true;
    _autoSaveInterval = interval;
    _onAutoSave = onSave;
    return this;
  }
  
  /// Set validator
  FormStateManagerBuilder<T> withValidator(IFormValidator<T> validator) {
    _validator = validator;
    return this;
  }
  
  /// Build form state manager
  FormStateManager<T> build() {
    return FormStateManager<T>(
      initialData: _initialData,
      validationDebounce: _validationDebounce,
      autoSaveEnabled: _autoSaveEnabled,
      autoSaveInterval: _autoSaveInterval,
      onAutoSave: _onAutoSave,
    );
  }
  
  /// Build provider-compatible form state manager
  ProviderFormStateManager<T> buildProvider() {
    return ProviderFormStateManager.withValidator(
      initialData: _initialData,
      validator: _validator,
      validationDebounce: _validationDebounce,
      autoSaveEnabled: _autoSaveEnabled,
      autoSaveInterval: _autoSaveInterval,
      onAutoSave: _onAutoSave,
    );
  }
}