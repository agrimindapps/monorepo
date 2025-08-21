import 'package:flutter/material.dart';
import '../../interfaces/i_sync_service.dart';

/// Widget that shows synchronization status and pending items
/// Displays badges when items are not synchronized
class SyncStatusIndicator extends StatelessWidget {
  final ISyncService syncService;
  final SyncIndicatorStyle style;
  final VoidCallback? onTap;
  final bool showPendingCount;

  const SyncStatusIndicator({
    Key? key,
    required this.syncService,
    this.style = const SyncIndicatorStyle(),
    this.onTap,
    this.showPendingCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return FutureBuilder<int>(
          future: syncService.getPendingSyncCount(),
          builder: (context, pendingSnapshot) {
            final pendingCount = pendingSnapshot.data ?? 0;
            
            return _buildIndicator(context, status, pendingCount);
          },
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, SyncStatus status, int pendingCount) {
    final theme = Theme.of(context);
    
    if (status == SyncStatus.idle && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String tooltip;
    bool showAnimation = false;

    switch (status) {
      case SyncStatus.syncing:
        backgroundColor = style.syncingColor ?? Colors.blue.shade600;
        iconColor = style.syncingIconColor ?? Colors.white;
        icon = style.syncingIcon ?? Icons.sync;
        tooltip = 'Synchronizing...';
        showAnimation = true;
        break;
      case SyncStatus.error:
        backgroundColor = style.errorColor ?? Colors.red.shade600;
        iconColor = style.errorIconColor ?? Colors.white;
        icon = style.errorIcon ?? Icons.sync_problem;
        tooltip = 'Sync failed';
        break;
      case SyncStatus.completed:
        backgroundColor = style.completedColor ?? Colors.green.shade600;
        iconColor = style.completedIconColor ?? Colors.white;
        icon = style.completedIcon ?? Icons.check_circle;
        tooltip = 'Sync completed';
        break;
      case SyncStatus.offline:
        backgroundColor = style.offlineColor ?? Colors.orange.shade600;
        iconColor = style.offlineIconColor ?? Colors.white;
        icon = style.offlineIcon ?? Icons.cloud_off;
        tooltip = 'Offline - $pendingCount items pending';
        break;
      default:
        backgroundColor = style.idleColor ?? Colors.grey.shade600;
        iconColor = style.idleIconColor ?? Colors.white;
        icon = style.idleIcon ?? Icons.cloud_queue;
        tooltip = pendingCount > 0 ? '$pendingCount items pending sync' : 'All synced';
    }

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: style.padding ?? const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: style.borderRadius ?? BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAnimation)
                _buildAnimatedIcon(icon, iconColor)
              else
                Icon(
                  icon,
                  size: style.iconSize ?? 16.0,
                  color: iconColor,
                ),
              if (showPendingCount && pendingCount > 0) ...[
                const SizedBox(width: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    pendingCount.toString(),
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return RotationTransition(
          turns: const AlwaysStoppedAnimation(0.0),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Icon(
                  icon,
                  size: style.iconSize ?? 16.0,
                  color: color,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Floating sync status indicator
class FloatingSyncIndicator extends StatelessWidget {
  final ISyncService syncService;
  final Alignment alignment;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const FloatingSyncIndicator({
    Key? key,
    required this.syncService,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16.0),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return FutureBuilder<int>(
          future: syncService.getPendingSyncCount(),
          builder: (context, pendingSnapshot) {
            final pendingCount = pendingSnapshot.data ?? 0;
            
            // Only show when there's something to sync or sync is active
            if (status == SyncStatus.idle && pendingCount == 0) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: Align(
                alignment: alignment,
                child: Container(
                  margin: margin,
                  child: SyncStatusIndicator(
                    syncService: syncService,
                    onTap: onTap,
                    style: const SyncIndicatorStyle(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Progress indicator for sync operations
class SyncProgressIndicator extends StatelessWidget {
  final ISyncService syncService;
  final String? label;
  final bool showPercentage;

  const SyncProgressIndicator({
    Key? key,
    required this.syncService,
    this.label,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        if (status != SyncStatus.syncing) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<int>(
          future: syncService.getPendingSyncCount(),
          builder: (context, pendingSnapshot) {
            final pendingCount = pendingSnapshot.data ?? 0;
            
            return Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            label ?? 'Synchronizing data...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (showPercentage && pendingCount > 0)
                          Text(
                            '$pendingCount left',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const LinearProgressIndicator(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// List item indicator for unsync items
class UnsyncedItemIndicator extends StatelessWidget {
  final bool isUnsynced;
  final UnsyncedIndicatorStyle style;

  const UnsyncedItemIndicator({
    Key? key,
    required this.isUnsynced,
    this.style = const UnsyncedIndicatorStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isUnsynced) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: style.padding ?? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: style.backgroundColor ?? Colors.orange.shade100,
        borderRadius: style.borderRadius ?? BorderRadius.circular(8.0),
        border: Border.all(
          color: style.borderColor ?? Colors.orange.shade300,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon ?? Icons.cloud_upload,
            size: style.iconSize ?? 12.0,
            color: style.iconColor ?? Colors.orange.shade700,
          ),
          if (style.showText) ...[
            const SizedBox(width: 4.0),
            Text(
              style.text ?? 'Pending',
              style: TextStyle(
                fontSize: style.textSize ?? 10.0,
                color: style.textColor ?? Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Style configuration for sync indicators
class SyncIndicatorStyle {
  final Color? syncingColor;
  final Color? errorColor;
  final Color? completedColor;
  final Color? offlineColor;
  final Color? idleColor;
  
  final Color? syncingIconColor;
  final Color? errorIconColor;
  final Color? completedIconColor;
  final Color? offlineIconColor;
  final Color? idleIconColor;
  
  final IconData? syncingIcon;
  final IconData? errorIcon;
  final IconData? completedIcon;
  final IconData? offlineIcon;
  final IconData? idleIcon;
  
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const SyncIndicatorStyle({
    this.syncingColor,
    this.errorColor,
    this.completedColor,
    this.offlineColor,
    this.idleColor,
    this.syncingIconColor,
    this.errorIconColor,
    this.completedIconColor,
    this.offlineIconColor,
    this.idleIconColor,
    this.syncingIcon,
    this.errorIcon,
    this.completedIcon,
    this.offlineIcon,
    this.idleIcon,
    this.iconSize,
    this.padding,
    this.borderRadius,
  });
}

/// Style configuration for unsynced item indicators
class UnsyncedIndicatorStyle {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final IconData? icon;
  final String? text;
  final bool showText;
  final double? iconSize;
  final double? textSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const UnsyncedIndicatorStyle({
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.icon,
    this.text,
    this.showText = true,
    this.iconSize,
    this.textSize,
    this.padding,
    this.borderRadius,
  });
}