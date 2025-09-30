import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/appointments_provider.dart';

/// **Appointments Auto-Reload Manager**
/// 
/// Manages automatic reloading of appointments when animal selection changes.
/// This widget provides a clean separation of auto-reload logic from the main
/// page widget, with proper lifecycle management and error handling.
/// 
/// ## Features:
/// - **Automatic Reloading**: Detects animal selection changes
/// - **Lifecycle Management**: Proper setup and cleanup of listeners
/// - **Error Handling**: Graceful handling of reload failures
/// - **Performance Optimized**: Debounced reloads to prevent excessive API calls
/// - **Memory Safe**: No memory leaks from unmanaged listeners
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced auto-reload state management
class AppointmentsAutoReloadManager extends ConsumerStatefulWidget {
  final String? selectedAnimalId;
  final Widget child;
  final VoidCallback? onReloadStart;
  final VoidCallback? onReloadComplete;
  final void Function(String)? onReloadError;

  /// Creates an auto-reload manager for appointments.
  /// 
  /// @param selectedAnimalId Currently selected animal ID to watch for changes
  /// @param child Child widget to render
  /// @param onReloadStart Optional callback when reload starts
  /// @param onReloadComplete Optional callback when reload completes successfully
  /// @param onReloadError Optional callback when reload fails
  const AppointmentsAutoReloadManager({
    super.key,
    required this.selectedAnimalId,
    required this.child,
    this.onReloadStart,
    this.onReloadComplete,
    this.onReloadError,
  });

  @override
  ConsumerState<AppointmentsAutoReloadManager> createState() => 
      _AppointmentsAutoReloadManagerState();
}

class _AppointmentsAutoReloadManagerState 
    extends ConsumerState<AppointmentsAutoReloadManager> {
  String? _lastAnimalId;
  Timer? _debounceTimer;
  bool _isReloading = false;
  final Map<String, DateTime> _lastLoadTimes = {};

  @override
  void initState() {
    super.initState();
    _lastAnimalId = widget.selectedAnimalId;
    
    // Perform initial load if animal is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedAnimalId != null) {
        _performReloadWithDebounce(widget.selectedAnimalId!, isInitial: true);
      }
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppointmentsAutoReloadManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if animal selection has changed
    if (widget.selectedAnimalId != _lastAnimalId) {
      _handleAnimalChange(oldWidget.selectedAnimalId, widget.selectedAnimalId);
      _lastAnimalId = widget.selectedAnimalId;
    }
  }

  /// **Handle Animal Selection Changes**
  /// 
  /// Manages the transition when animal selection changes, including
  /// clearing old data and loading new appointments.
  /// 
  /// @param previousAnimalId Previously selected animal ID
  /// @param newAnimalId Newly selected animal ID
  void _handleAnimalChange(String? previousAnimalId, String? newAnimalId) {
    // If we had a previous animal and now have a different one, reload
    if (previousAnimalId != null && newAnimalId != null && previousAnimalId != newAnimalId) {
      _performReloadWithDebounce(newAnimalId);
    }
    // If we now have an animal selected for the first time
    else if (previousAnimalId == null && newAnimalId != null) {
      _performReloadWithDebounce(newAnimalId, isInitial: true);
    }
    // If animal was deselected, clear the appointments
    else if (previousAnimalId != null && newAnimalId == null) {
      _clearAppointments();
    }
  }

  /// **Perform Reload with Debouncing**
  /// 
  /// Adds debouncing to prevent excessive API calls when animal selection
  /// changes rapidly or during quick navigation.
  /// 
  /// @param animalId Animal ID to load appointments for
  /// @param isInitial Whether this is the initial load
  void _performReloadWithDebounce(String animalId, {bool isInitial = false}) {
    // Cancel existing timer
    _debounceTimer?.cancel();
    
    // For initial loads, don't debounce
    if (isInitial) {
      _performReload(animalId, isInitial: true);
      return;
    }
    
    // Check if we recently loaded for this animal (cache check)
    final lastLoadTime = _lastLoadTimes[animalId];
    final now = DateTime.now();
    if (lastLoadTime != null && now.difference(lastLoadTime).inSeconds < 30) {
      // Skip reload if we loaded recently (within 30 seconds)
      return;
    }
    
    // Set debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performReload(animalId);
    });
  }

  /// **Perform Appointments Reload**
  /// 
  /// Executes the actual appointment loading with proper error handling
  /// and callback management.
  /// 
  /// @param animalId Animal ID to load appointments for
  /// @param isInitial Whether this is the initial load
  Future<void> _performReload(String animalId, {bool isInitial = false}) async {
    // Prevent concurrent reloads
    if (_isReloading) return;
    
    try {
      _isReloading = true;
      
      // Notify reload start
      widget.onReloadStart?.call();
      
      // Load appointments using the provider
      await ref.read(appointmentsProvider.notifier).loadAppointments(animalId);
      
      // Update cache timestamp
      _lastLoadTimes[animalId] = DateTime.now();
      
      // Check if the operation was successful
      final state = ref.read(appointmentsProvider);
      if (state.errorMessage != null) {
        widget.onReloadError?.call(state.errorMessage!);
      } else {
        widget.onReloadComplete?.call();
      }
    } catch (error) {
      // Handle any unexpected errors
      widget.onReloadError?.call(error.toString());
    } finally {
      _isReloading = false;
    }
  }

  /// **Clear Appointments**
  /// 
  /// Clears the current appointments when no animal is selected.
  void _clearAppointments() {
    // Clear appointments through the provider
    ref.read(appointmentsProvider.notifier).clearAppointments();
  }

  /// **Manual Reload Trigger**
  /// 
  /// Public method to manually trigger a reload of appointments.
  /// Useful for refresh buttons or pull-to-refresh gestures.
  /// Manual reloads bypass cache to ensure fresh data.
  Future<void> manualReload() async {
    final animalId = widget.selectedAnimalId;
    if (animalId != null) {
      // Clear cache entry for manual reloads
      _lastLoadTimes.remove(animalId);
      await _performReload(animalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// **Auto-Reload Mixin**
/// 
/// Mixin that provides auto-reload functionality to any StatefulWidget.
/// This provides a reusable way to add auto-reload behavior to multiple
/// pages or widgets that need appointments auto-reloading.
/// 
/// ## Usage:
/// ```dart
/// class MyPage extends StatefulWidget with AppointmentsAutoReloadMixin {
///   // ... widget implementation
/// }
/// ```
mixin AppointmentsAutoReloadMixin<T extends StatefulWidget> on State<T> {
  String? _trackedAnimalId;
  
  /// Override this method to provide the current animal ID
  String? get currentAnimalId;
  
  /// Override this method to handle reload events
  Future<void> onAppointmentsReload(String animalId);
  
  /// Override this method to handle reload errors
  void onAppointmentsReloadError(String error) {
    // Default implementation - show error message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar consultas: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  @override
  void initState() {
    super.initState();
    _trackedAnimalId = currentAnimalId;
    
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentAnimalId != null) {
        onAppointmentsReload(currentAnimalId!);
      }
    });
  }
  
  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check for animal ID changes
    if (currentAnimalId != _trackedAnimalId) {
      if (currentAnimalId != null) {
        onAppointmentsReload(currentAnimalId!);
      }
      _trackedAnimalId = currentAnimalId;
    }
  }
  
  /// Manually trigger a reload
  Future<void> triggerManualReload() async {
    if (currentAnimalId != null) {
      try {
        await onAppointmentsReload(currentAnimalId!);
      } catch (error) {
        onAppointmentsReloadError(error.toString());
      }
    }
  }
}