import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Pull-to-Refresh Widget for Sync Operations
/// 
/// Features:
/// - Custom sync animations and indicators
/// - Multi-stage refresh (local + remote sync)
/// - Error handling with retry options
/// - Custom refresh messages and indicators
/// - Integration with sync status
class SyncRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String refreshMessage;
  final String syncingMessage;
  final double refreshTriggerDistance;
  final double refreshIndicatorExtent;
  final bool enablePullToRefresh;
  final Color? primaryColor;
  final Color? backgroundColor;

  const SyncRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage = 'Puxe para sincronizar',
    this.syncingMessage = 'Sincronizando dados...',
    this.refreshTriggerDistance = 80.0,
    this.refreshIndicatorExtent = 60.0,
    this.enablePullToRefresh = true,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  State<SyncRefreshWidget> createState() => _SyncRefreshWidgetState();
}

class _SyncRefreshWidgetState extends State<SyncRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRefreshing = false;
  RefreshPhase _currentPhase = RefreshPhase.idle;
  double _dragDistance = 0.0;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _statusMessage = widget.refreshMessage;
  }

  @override
  void dispose() {
    _positionController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enablePullToRefresh) {
      return widget.child;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                final indicatorHeight = _positionAnimation.value * widget.refreshIndicatorExtent;
                if (indicatorHeight == 0) return const SizedBox.shrink();
                
                return SizedBox(
                  height: indicatorHeight,
                  child: _buildRefreshIndicator(context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Handle scroll notifications for pull-to-refresh
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;
    
    if (notification is ScrollStartNotification) {
      _handleScrollStart(notification);
    } else if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate(notification);
    } else if (notification is ScrollEndNotification) {
      _handleScrollEnd(notification);
    }
    
    return false;
  }

  /// Handle scroll start
  void _handleScrollStart(ScrollStartNotification notification) {
    if (_currentPhase == RefreshPhase.idle) {
      _dragDistance = 0.0;
    }
  }

  /// Handle scroll update (dragging)
  void _handleScrollUpdate(ScrollUpdateNotification notification) {
    final metrics = notification.metrics;
    if (metrics.pixels <= 0 && notification.dragDetails != null) {
      setState(() {
        _dragDistance = -metrics.pixels;
      });

      final progress = math.min(_dragDistance / widget.refreshTriggerDistance, 1.0);
      _positionController.value = progress;
      if (_dragDistance >= widget.refreshTriggerDistance) {
        if (_currentPhase != RefreshPhase.readyToRefresh) {
          _updateRefreshPhase(RefreshPhase.readyToRefresh);
          _scaleController.forward().then((_) => _scaleController.reverse());
        }
      } else if (_dragDistance > 0) {
        if (_currentPhase != RefreshPhase.dragging) {
          _updateRefreshPhase(RefreshPhase.dragging);
        }
      }
    }
  }

  /// Handle scroll end
  void _handleScrollEnd(ScrollEndNotification notification) {
    if (_dragDistance >= widget.refreshTriggerDistance && !_isRefreshing) {
      _triggerRefresh();
    } else {
      _resetRefreshState();
    }
  }

  /// Update refresh phase and status message
  void _updateRefreshPhase(RefreshPhase phase) {
    setState(() {
      _currentPhase = phase;
      
      switch (phase) {
        case RefreshPhase.idle:
          _statusMessage = widget.refreshMessage;
          break;
        case RefreshPhase.dragging:
          _statusMessage = 'Continue puxando...';
          break;
        case RefreshPhase.readyToRefresh:
          _statusMessage = 'Solte para sincronizar';
          break;
        case RefreshPhase.refreshing:
          _statusMessage = widget.syncingMessage;
          break;
        case RefreshPhase.completed:
          _statusMessage = 'Sincronização completa!';
          break;
        case RefreshPhase.error:
          _statusMessage = 'Erro na sincronização';
          break;
      }
    });
  }

  /// Trigger refresh operation
  void _triggerRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });
    
    _updateRefreshPhase(RefreshPhase.refreshing);
    _rotationController.repeat();
    
    try {
      await widget.onRefresh();
      _updateRefreshPhase(RefreshPhase.completed);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
    } catch (error) {
      _updateRefreshPhase(RefreshPhase.error);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    } finally {
      _resetRefreshState();
    }
  }

  /// Reset refresh state
  void _resetRefreshState() {
    _rotationController.stop();
    _rotationController.reset();
    
    _positionController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _dragDistance = 0.0;
        });
        _updateRefreshPhase(RefreshPhase.idle);
      }
    });
  }

  /// Build custom refresh indicator
  Widget _buildRefreshIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSyncIcon(primaryColor),
            
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build sync icon with animations
  Widget _buildSyncIcon(Color color) {
    Widget iconWidget;
    
    switch (_currentPhase) {
      case RefreshPhase.idle:
      case RefreshPhase.dragging:
        final progress = math.min(_dragDistance / widget.refreshTriggerDistance, 1.0);
        iconWidget = Transform.rotate(
          angle: progress * math.pi,
          child: Icon(
            Icons.arrow_downward,
            color: color,
            size: 24,
          ),
        );
        break;
        
      case RefreshPhase.readyToRefresh:
        iconWidget = AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                Icons.sync,
                color: color,
                size: 24,
              ),
            );
          },
        );
        break;
        
      case RefreshPhase.refreshing:
        iconWidget = AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2.0 * math.pi,
              child: Icon(
                Icons.sync,
                color: color,
                size: 24,
              ),
            );
          },
        );
        break;
        
      case RefreshPhase.completed:
        iconWidget = const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 24,
        );
        break;
        
      case RefreshPhase.error:
        iconWidget = const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 24,
        );
        break;
    }
    
    return iconWidget;
  }
}

/// Refresh Phase Enum
enum RefreshPhase {
  idle,
  dragging,
  readyToRefresh,
  refreshing,
  completed,
  error,
}

/// Simplified Sync Refresh Wrapper
/// 
/// Easy-to-use wrapper for common sync refresh scenarios
class SimpleSyncRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool enabled;

  const SimpleSyncRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SyncRefreshWidget(
      onRefresh: onRefresh,
      enablePullToRefresh: enabled,
      child: child,
    );
  }
}

/// Multi-Stage Sync Refresh
/// 
/// Supports multiple sync stages (local, remote, etc.)
class MultiStageSyncRefresh extends StatefulWidget {
  final Widget child;
  final List<SyncStage> syncStages;
  final bool enabled;

  const MultiStageSyncRefresh({
    super.key,
    required this.child,
    required this.syncStages,
    this.enabled = true,
  });

  @override
  State<MultiStageSyncRefresh> createState() => _MultiStageSyncRefreshState();
}

class _MultiStageSyncRefreshState extends State<MultiStageSyncRefresh> {
  int _currentStageIndex = 0;
  String _currentStageMessage = '';

  @override
  Widget build(BuildContext context) {
    return SyncRefreshWidget(
      onRefresh: _performMultiStageSync,
      syncingMessage: _currentStageMessage,
      enablePullToRefresh: widget.enabled,
      child: widget.child,
    );
  }

  /// Perform multi-stage sync
  Future<void> _performMultiStageSync() async {
    for (int i = 0; i < widget.syncStages.length; i++) {
      setState(() {
        _currentStageIndex = i;
        _currentStageMessage = widget.syncStages[i].message;
      });
      
      await widget.syncStages[i].operation();
      if (i < widget.syncStages.length - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }
}

/// Sync Stage Data Model
class SyncStage {
  final String message;
  final Future<void> Function() operation;

  const SyncStage({
    required this.message,
    required this.operation,
  });
}
