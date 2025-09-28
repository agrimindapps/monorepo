import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/providers/background_sync_provider.dart';
import '../../../core/sync/background_sync_status.dart';
import '../../../core/theme/colors.dart';

/// Discrete sync indicator that shows at the top of screens without blocking UI
class DiscreteSyncIndicator extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const DiscreteSyncIndicator({super.key, this.onRetry, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Consumer<BackgroundSyncProvider?>(
      builder: (context, syncProvider, child) {
        if (syncProvider == null || !syncProvider.shouldShowSyncIndicator()) {
          return const SizedBox.shrink();
        }

        return _buildSyncBanner(context, syncProvider);
      },
    );
  }

  Widget _buildSyncBanner(
    BuildContext context,
    BackgroundSyncProvider syncProvider,
  ) {
    final isError = syncProvider.syncStatus.toString().contains('error');
    final isCompleted = syncProvider.syncStatus.toString().contains(
      'completed',
    );
    final isInProgress = syncProvider.isSyncInProgress;

    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    if (isError) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      iconColor = Colors.red.shade600;
      icon = Icons.error_outline;
    } else if (isCompleted) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      iconColor = Colors.green.shade600;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = PlantisColors.primaryLight.withValues(alpha: 0.1);
      textColor = PlantisColors.primary;
      iconColor = PlantisColors.primary;
      icon = Icons.sync;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isInProgress)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            )
          else
            Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getSyncTitle(syncProvider.syncStatus),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (syncProvider.currentSyncMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      syncProvider.getSyncStatusMessage(),
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isError && onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                foregroundColor: iconColor,
              ),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 16,
                color: iconColor.withValues(alpha: 0.7),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
        ],
      ),
    );
  }

  String _getSyncTitle(BackgroundSyncStatus status) {
    switch (status) {
      case BackgroundSyncStatus.idle:
        return 'Pronto para sincronizar';
      case BackgroundSyncStatus.syncing:
        return 'Sincronizando dados...';
      case BackgroundSyncStatus.completed:
        return 'Sincronização concluída';
      case BackgroundSyncStatus.error:
        return 'Erro na sincronização';
      case BackgroundSyncStatus.cancelled:
        return 'Sincronização cancelada';
    }
  }
}

/// Floating sync indicator that can be positioned anywhere on screen
class FloatingSyncIndicator extends StatelessWidget {
  final Alignment alignment;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;

  const FloatingSyncIndicator({
    super.key,
    this.alignment = Alignment.topCenter,
    this.margin = const EdgeInsets.only(top: 8),
    this.onRetry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BackgroundSyncProvider?>(
      builder: (context, syncProvider, child) {
        if (syncProvider == null || !syncProvider.shouldShowSyncIndicator()) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: alignment,
          child: Container(
            margin: margin,
            child: _buildFloatingCard(context, syncProvider),
          ),
        );
      },
    );
  }

  Widget _buildFloatingCard(
    BuildContext context,
    BackgroundSyncProvider syncProvider,
  ) {
    final isError = syncProvider.syncStatus.toString().contains('error');
    final isInProgress = syncProvider.isSyncInProgress;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isError
                    ? Colors.red.shade300
                    : PlantisColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isInProgress)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isError ? Colors.red : PlantisColors.primary,
                  ),
                ),
              )
            else
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 14,
                color: isError ? Colors.red : Colors.green,
              ),
            const SizedBox(width: 8),
            Text(
              _getShortMessage(syncProvider.syncStatus),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isError ? Colors.red.shade700 : Colors.black87,
              ),
            ),
            if (isError && onRetry != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRetry,
                child: Icon(
                  Icons.refresh,
                  size: 14,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getShortMessage(BackgroundSyncStatus status) {
    switch (status) {
      case BackgroundSyncStatus.idle:
        return 'Aguardando';
      case BackgroundSyncStatus.syncing:
        return 'Sincronizando';
      case BackgroundSyncStatus.completed:
        return 'Concluído';
      case BackgroundSyncStatus.error:
        return 'Erro';
      case BackgroundSyncStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Minimal sync dot indicator for app bars or status areas
class SyncDotIndicator extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const SyncDotIndicator({super.key, this.size = 8.0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<BackgroundSyncProvider?>(
      builder: (context, syncProvider, child) {
        if (syncProvider == null || !syncProvider.shouldShowSyncIndicator()) {
          return const SizedBox.shrink();
        }

        final isError = syncProvider.syncStatus.toString().contains('error');
        final isInProgress = syncProvider.isSyncInProgress;

        Color color;
        if (isError) {
          color = Colors.red;
        } else if (isInProgress) {
          color = PlantisColors.primary;
        } else {
          color = Colors.green;
        }

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                if (isInProgress)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child:
                isInProgress
                    ? Container(
                      padding: EdgeInsets.all(size * 0.2),
                      child: const CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                    : null,
          ),
        );
      },
    );
  }
}
