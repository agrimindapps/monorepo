import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/feature_flags_provider.dart';

/// Global Sync Status Indicator Widget
/// 
/// Features:
/// - Real-time sync status display
/// - Progress indicators for ongoing sync
/// - Network status awareness
/// - Error state indicators
/// - Manual sync trigger
/// - Floating and inline variants
class SyncStatusIndicatorWidget extends StatefulWidget {
  /// Display variant: floating (FAB-like) or inline (embedded in UI)
  final SyncIndicatorVariant variant;
  
  /// Position when using floating variant
  final FloatingPosition? floatingPosition;
  
  /// Whether to show detailed status text
  final bool showStatusText;
  
  /// Whether to allow manual sync trigger
  final bool allowManualSync;
  
  /// Custom sync action callback
  final VoidCallback? onSyncPressed;
  
  /// Custom error action callback  
  final VoidCallback? onErrorPressed;

  const SyncStatusIndicatorWidget({
    super.key,
    this.variant = SyncIndicatorVariant.inline,
    this.floatingPosition,
    this.showStatusText = true,
    this.allowManualSync = true,
    this.onSyncPressed,
    this.onErrorPressed,
  });

  @override
  State<SyncStatusIndicatorWidget> createState() => _SyncStatusIndicatorWidgetState();
}

class _SyncStatusIndicatorWidgetState extends State<SyncStatusIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  // Mock sync state - in real implementation, this would come from a sync service
  SyncStatus _currentSyncStatus = SyncStatus.idle;
  double _syncProgress = 0.0;
  String _lastSyncTime = '';
  String _errorMessage = '';
  bool _hasNetworkConnection = true;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for syncing state
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for syncing spinner
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _initializeMockState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// Initialize mock sync state for demonstration
  void _initializeMockState() {
    // Simulate different sync states over time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentSyncStatus = SyncStatus.syncing;
          _syncProgress = 0.0;
        });
        _rotationController.repeat();
        _startProgressSimulation();
      }
    });
  }

  /// Simulate sync progress
  void _startProgressSimulation() {
    const duration = Duration(milliseconds: 100);
    Timer.periodic(duration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _syncProgress += 0.05;
      });
      
      if (_syncProgress >= 1.0) {
        timer.cancel();
        _completeSyncSimulation();
      }
    });
  }

  /// Complete sync simulation
  void _completeSyncSimulation() {
    _rotationController.stop();
    _rotationController.reset();
    
    setState(() {
      _currentSyncStatus = SyncStatus.success;
      _syncProgress = 1.0;
      _lastSyncTime = 'Agora';
    });
    
    // Return to idle after showing success
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentSyncStatus = SyncStatus.idle;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureFlagsProvider>(
      builder: (context, featureFlags, child) {
        // Don't show if sync is disabled
        if (!featureFlags.isContentSynchronizationEnabled) {
          return const SizedBox.shrink();
        }

        switch (widget.variant) {
          case SyncIndicatorVariant.floating:
            return _buildFloatingIndicator(context);
          case SyncIndicatorVariant.inline:
            return _buildInlineIndicator(context);
        }
      },
    );
  }

  /// Build floating sync indicator
  Widget _buildFloatingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: widget.floatingPosition?.bottom ?? 16,
      right: widget.floatingPosition?.right ?? 16,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _currentSyncStatus == SyncStatus.syncing ? _pulseAnimation.value : 1.0,
            child: FloatingActionButton.small(
              onPressed: _getSyncAction(),
              backgroundColor: _getSyncColor(theme),
              foregroundColor: Colors.white,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _currentSyncStatus == SyncStatus.syncing 
                        ? _rotationAnimation.value * 2.0 * 3.14159
                        : 0.0,
                    child: Icon(_getSyncIcon(), size: 20),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build inline sync indicator
  Widget _buildInlineIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSyncColor(theme).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSyncColor(theme).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Sync Icon with Animation
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _currentSyncStatus == SyncStatus.syncing 
                    ? _rotationAnimation.value * 2.0 * 3.14159
                    : 0.0,
                child: Icon(
                  _getSyncIcon(),
                  color: _getSyncColor(theme),
                  size: 20,
                ),
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Status Text and Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showStatusText) ...[
                  Text(
                    _getSyncStatusText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getSyncColor(theme),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                
                // Progress Bar (when syncing)
                if (_currentSyncStatus == SyncStatus.syncing) ...[
                  LinearProgressIndicator(
                    value: _syncProgress,
                    backgroundColor: _getSyncColor(theme).withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(_getSyncColor(theme)),
                    minHeight: 3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_syncProgress * 100).toInt()}% sincronizado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ] else ...[
                  Text(
                    _getStatusSubtext(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Action Button
          if (_getSyncAction() != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _getSyncAction(),
              icon: Icon(
                _getActionIcon(),
                size: 16,
                color: _getSyncColor(theme),
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(24, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get sync status color
  Color _getSyncColor(ThemeData theme) {
    switch (_currentSyncStatus) {
      case SyncStatus.idle:
        return theme.colorScheme.onSurfaceVariant;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  /// Get sync status icon
  IconData _getSyncIcon() {
    switch (_currentSyncStatus) {
      case SyncStatus.idle:
        return Icons.sync;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.check_circle;
      case SyncStatus.error:
        return Icons.sync_problem;
    }
  }

  /// Get action icon
  IconData _getActionIcon() {
    switch (_currentSyncStatus) {
      case SyncStatus.idle:
        return Icons.refresh;
      case SyncStatus.syncing:
        return Icons.stop;
      case SyncStatus.success:
        return Icons.refresh;
      case SyncStatus.error:
        return Icons.error_outline;
    }
  }

  /// Get sync status text
  String _getSyncStatusText() {
    switch (_currentSyncStatus) {
      case SyncStatus.idle:
        return 'Sincronizado';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.success:
        return 'Sincronização Completa';
      case SyncStatus.error:
        return 'Erro na Sincronização';
    }
  }

  /// Get status subtext
  String _getStatusSubtext() {
    switch (_currentSyncStatus) {
      case SyncStatus.idle:
        return _lastSyncTime.isNotEmpty 
            ? 'Última sincronização: $_lastSyncTime'
            : 'Toque para sincronizar';
      case SyncStatus.syncing:
        return 'Aguarde...';
      case SyncStatus.success:
        return 'Dados atualizados com sucesso';
      case SyncStatus.error:
        return _errorMessage.isNotEmpty ? _errorMessage : 'Tente novamente';
    }
  }

  /// Get sync action callback
  VoidCallback? _getSyncAction() {
    switch (_currentSyncStatus) {
      case SyncStatus.idle:
        return widget.allowManualSync ? (widget.onSyncPressed ?? _startManualSync) : null;
      case SyncStatus.syncing:
        return _stopSync;
      case SyncStatus.success:
        return widget.allowManualSync ? (widget.onSyncPressed ?? _startManualSync) : null;
      case SyncStatus.error:
        return widget.onErrorPressed ?? _retrySync;
    }
  }

  /// Start manual sync
  void _startManualSync() {
    setState(() {
      _currentSyncStatus = SyncStatus.syncing;
      _syncProgress = 0.0;
    });
    _rotationController.repeat();
    _startProgressSimulation();
  }

  /// Stop sync
  void _stopSync() {
    _rotationController.stop();
    _rotationController.reset();
    setState(() {
      _currentSyncStatus = SyncStatus.idle;
      _syncProgress = 0.0;
    });
  }

  /// Retry sync after error
  void _retrySync() {
    _startManualSync();
  }
}

/// Sync Status Enum
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

/// Sync Indicator Variant
enum SyncIndicatorVariant {
  floating,
  inline,
}

/// Floating Position Configuration
class FloatingPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const FloatingPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
}

/// Timer import placeholder - should be imported from dart:async
import 'dart:async';