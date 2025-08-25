import 'dart:async';

import 'package:flutter/material.dart';

import '../../interfaces/i_connectivity_service.dart';
import '../../interfaces/i_sync_service.dart';

/// Real-time sync status widget that shows live sync progress
/// Updates automatically with smooth animations
class RealTimeSyncStatus extends StatefulWidget {
  final ISyncService syncService;
  final IConnectivityService connectivityService;
  final RealTimeSyncStyle style;
  final bool persistentDisplay;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const RealTimeSyncStatus({
    super.key,
    required this.syncService,
    required this.connectivityService,
    this.style = const RealTimeSyncStyle(),
    this.persistentDisplay = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
  });

  @override
  State<RealTimeSyncStatus> createState() => _RealTimeSyncStatusState();
}

class _RealTimeSyncStatusState extends State<RealTimeSyncStatus>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  
  Timer? _hideTimer;
  bool _isVisible = false;
  SyncStatus _lastSyncStatus = SyncStatus.idle;
  ConnectivityStatus _lastConnectivityStatus = ConnectivityStatus.connected;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _listenToSyncChanges();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  void _listenToSyncChanges() {
    // Listen to sync status changes
    widget.syncService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _lastSyncStatus = status;
        });
        _updateVisibility(status);
      }
    });

    // Listen to connectivity changes
    widget.connectivityService.connectivityStream.listen((status) {
      if (mounted) {
        setState(() {
          _lastConnectivityStatus = status;
        });
      }
    });
  }

  void _updateVisibility(SyncStatus status) {
    final shouldShow = widget.persistentDisplay || 
                      status != SyncStatus.idle || 
                      _lastConnectivityStatus != ConnectivityStatus.connected;

    if (shouldShow && !_isVisible) {
      _showStatus();
    } else if (!shouldShow && _isVisible) {
      _scheduleHide();
    }

    // Handle rotation animation for syncing status
    if (status == SyncStatus.syncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  void _showStatus() {
    setState(() {
      _isVisible = true;
    });
    _fadeController.forward();
    _hideTimer?.cancel();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _hideStatus();
      }
    });
  }

  void _hideStatus() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible && !widget.persistentDisplay) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildStatusCard(),
    );
  }

  Widget _buildStatusCard() {
    return StreamBuilder<SyncStatus>(
      stream: widget.syncService.syncStatusStream,
      builder: (context, syncSnapshot) {
        final syncStatus = syncSnapshot.data ?? SyncStatus.idle;
        
        return StreamBuilder<ConnectivityStatus>(
          stream: widget.connectivityService.connectivityStream,
          builder: (context, connectivitySnapshot) {
            final connectivityStatus = connectivitySnapshot.data ?? ConnectivityStatus.connected;
            
            return FutureBuilder<int>(
              future: widget.syncService.getPendingSyncCount(),
              builder: (context, pendingSnapshot) {
                final pendingCount = pendingSnapshot.data ?? 0;
                
                return _buildStatusContent(syncStatus, connectivityStatus, pendingCount);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatusContent(
    SyncStatus syncStatus,
    ConnectivityStatus connectivityStatus,
    int pendingCount,
  ) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(syncStatus, connectivityStatus, pendingCount);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: widget.style.margin ?? const EdgeInsets.all(8.0),
        padding: widget.style.padding ?? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: statusInfo.backgroundColor,
          borderRadius: widget.style.borderRadius ?? BorderRadius.circular(8.0),
          boxShadow: widget.style.showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(statusInfo),
            const SizedBox(width: 8.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusInfo.title,
                    style: widget.style.titleStyle?.copyWith(color: statusInfo.textColor) ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: statusInfo.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (statusInfo.subtitle != null)
                    Text(
                      statusInfo.subtitle!,
                      style: widget.style.subtitleStyle?.copyWith(color: statusInfo.textColor.withOpacity(0.8)) ??
                          theme.textTheme.bodySmall?.copyWith(
                            color: statusInfo.textColor.withOpacity(0.8),
                          ),
                    ),
                ],
              ),
            ),
            if (pendingCount > 0 && widget.style.showPendingCount) ...[
              const SizedBox(width: 8.0),
              _buildPendingCountBadge(pendingCount, statusInfo.textColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(StatusInfo statusInfo) {
    Widget icon = Icon(
      statusInfo.icon,
      size: widget.style.iconSize ?? 20.0,
      color: statusInfo.textColor,
    );

    if (statusInfo.animated) {
      return RotationTransition(
        turns: _rotationAnimation,
        child: icon,
      );
    }

    return icon;
  }

  Widget _buildPendingCountBadge(int count, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  StatusInfo _getStatusInfo(
    SyncStatus syncStatus,
    ConnectivityStatus connectivityStatus,
    int pendingCount,
  ) {
    if (connectivityStatus != ConnectivityStatus.connected) {
      return StatusInfo(
        icon: Icons.wifi_off,
        title: 'Offline',
        subtitle: pendingCount > 0 ? '$pendingCount items pending' : 'No internet connection',
        backgroundColor: widget.style.offlineColor ?? Colors.orange.shade600,
        textColor: widget.style.offlineTextColor ?? Colors.white,
        animated: false,
      );
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return StatusInfo(
          icon: Icons.sync,
          title: 'Syncing',
          subtitle: pendingCount > 0 ? '$pendingCount items remaining' : 'Synchronizing data...',
          backgroundColor: widget.style.syncingColor ?? Colors.blue.shade600,
          textColor: widget.style.syncingTextColor ?? Colors.white,
          animated: true,
        );
      
      case SyncStatus.error:
        return StatusInfo(
          icon: Icons.error_outline,
          title: 'Sync Failed',
          subtitle: 'Tap to retry',
          backgroundColor: widget.style.errorColor ?? Colors.red.shade600,
          textColor: widget.style.errorTextColor ?? Colors.white,
          animated: false,
        );
      
      case SyncStatus.completed:
        return StatusInfo(
          icon: Icons.check_circle_outline,
          title: 'Sync Complete',
          subtitle: 'All data synchronized',
          backgroundColor: widget.style.completedColor ?? Colors.green.shade600,
          textColor: widget.style.completedTextColor ?? Colors.white,
          animated: false,
        );
      
      default:
        if (pendingCount > 0) {
          return StatusInfo(
            icon: Icons.cloud_upload_outlined,
            title: 'Pending Sync',
            subtitle: '$pendingCount items waiting',
            backgroundColor: widget.style.pendingColor ?? Colors.amber.shade600,
            textColor: widget.style.pendingTextColor ?? Colors.white,
            animated: false,
          );
        }
        
        return StatusInfo(
          icon: Icons.cloud_done_outlined,
          title: 'All Synced',
          subtitle: 'Everything up to date',
          backgroundColor: widget.style.idleColor ?? Colors.grey.shade600,
          textColor: widget.style.idleTextColor ?? Colors.white,
          animated: false,
        );
    }
  }
}

/// Persistent sync status bar
class PersistentSyncStatusBar extends StatelessWidget {
  final ISyncService syncService;
  final IConnectivityService connectivityService;
  final bool isCompact;

  const PersistentSyncStatusBar({
    super.key,
    required this.syncService,
    required this.connectivityService,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      builder: (context, syncSnapshot) {
        final syncStatus = syncSnapshot.data ?? SyncStatus.idle;
        
        return StreamBuilder<ConnectivityStatus>(
          stream: connectivityService.connectivityStream,
          builder: (context, connectivitySnapshot) {
            final connectivityStatus = connectivitySnapshot.data ?? ConnectivityStatus.connected;
            
            if (connectivityStatus == ConnectivityStatus.connected && 
                syncStatus == SyncStatus.idle) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: isCompact ? 4.0 : 8.0,
              ),
              color: _getStatusColor(syncStatus, connectivityStatus),
              child: Row(
                children: [
                  if (!isCompact) ...[
                    _getStatusIcon(syncStatus, connectivityStatus),
                    const SizedBox(width: 8.0),
                  ],
                  Expanded(
                    child: Text(
                      _getStatusMessage(syncStatus, connectivityStatus),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 12.0 : 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  FutureBuilder<int>(
                    future: syncService.getPendingSyncCount(),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data ?? 0;
                      if (pendingCount == 0) return const SizedBox.shrink();
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          pendingCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(SyncStatus syncStatus, ConnectivityStatus connectivityStatus) {
    if (connectivityStatus != ConnectivityStatus.connected) {
      return Colors.orange.shade700;
    }
    
    switch (syncStatus) {
      case SyncStatus.syncing:
        return Colors.blue.shade700;
      case SyncStatus.error:
        return Colors.red.shade700;
      case SyncStatus.completed:
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _getStatusIcon(SyncStatus syncStatus, ConnectivityStatus connectivityStatus) {
    IconData icon;
    
    if (connectivityStatus != ConnectivityStatus.connected) {
      icon = Icons.wifi_off;
    } else {
      switch (syncStatus) {
        case SyncStatus.syncing:
          icon = Icons.sync;
          break;
        case SyncStatus.error:
          icon = Icons.error_outline;
          break;
        case SyncStatus.completed:
          icon = Icons.check_circle_outline;
          break;
        default:
          icon = Icons.cloud_queue;
      }
    }
    
    return Icon(
      icon,
      size: 16.0,
      color: Colors.white,
    );
  }

  String _getStatusMessage(SyncStatus syncStatus, ConnectivityStatus connectivityStatus) {
    if (connectivityStatus != ConnectivityStatus.connected) {
      return 'You are offline. Changes will sync when connected.';
    }
    
    switch (syncStatus) {
      case SyncStatus.syncing:
        return 'Synchronizing your data...';
      case SyncStatus.error:
        return 'Sync failed. Tap to retry.';
      case SyncStatus.completed:
        return 'All data synchronized successfully.';
      default:
        return 'Some changes are waiting to be synchronized.';
    }
  }
}

/// Status information model
class StatusInfo {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Color textColor;
  final bool animated;

  const StatusInfo({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.animated,
  });
}

/// Style configuration for real-time sync status
class RealTimeSyncStyle {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final bool showShadow;
  final bool showPendingCount;
  
  final Color? syncingColor;
  final Color? errorColor;
  final Color? completedColor;
  final Color? offlineColor;
  final Color? idleColor;
  final Color? pendingColor;
  
  final Color? syncingTextColor;
  final Color? errorTextColor;
  final Color? completedTextColor;
  final Color? offlineTextColor;
  final Color? idleTextColor;
  final Color? pendingTextColor;
  
  final double? iconSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const RealTimeSyncStyle({
    this.margin,
    this.padding,
    this.borderRadius,
    this.showShadow = true,
    this.showPendingCount = true,
    this.syncingColor,
    this.errorColor,
    this.completedColor,
    this.offlineColor,
    this.idleColor,
    this.pendingColor,
    this.syncingTextColor,
    this.errorTextColor,
    this.completedTextColor,
    this.offlineTextColor,
    this.idleTextColor,
    this.pendingTextColor,
    this.iconSize,
    this.titleStyle,
    this.subtitleStyle,
  });
}