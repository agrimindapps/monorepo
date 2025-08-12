// widgets/offline_indicator.dart - Indicador de status offline

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../core/services/sync_firebase_service.dart';
import '../pages/offline_settings_screen.dart';
import '../providers/sync_provider.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  // Widget constante para performance
  static const Widget _shrinkWidget = SizedBox.shrink();
  static const Widget _iconSpacer = SizedBox(width: 8);
  static const Widget _badgeSpacer = SizedBox(width: 4);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        // Se está online e não há itens pendentes, não mostrar nada
        if (syncProvider.isOnline &&
            syncProvider.pendingSyncItems == 0 &&
            !syncProvider.isOfflineMode) {
          return _shrinkWidget;
        }

        return GestureDetector(
          onTap: () => _showOfflineSettings(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getBackgroundColor(syncProvider),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getBorderColor(syncProvider),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getStatusIcon(syncProvider),
                _iconSpacer,
                Flexible(
                  child: Text(
                    _getStatusText(syncProvider),
                    style: TextStyle(
                      color: _getTextColor(syncProvider),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (syncProvider.pendingSyncItems > 0) ...[
                  _badgeSpacer,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${syncProvider.pendingSyncItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (!syncProvider.isOnline) {
      return const Icon(Icons.wifi_off, size: 16, color: Colors.red);
    }

    if (syncProvider.isOfflineMode) {
      return const Icon(Icons.cloud_off, size: 16, color: Colors.orange);
    }

    if (syncProvider.pendingSyncItems > 0) {
      return const Icon(Icons.sync_problem, size: 16, color: Colors.orange);
    }

    return const Icon(Icons.check_circle, size: 16, color: Colors.green);
  }

  String _getStatusText(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return 'Sincronizando...';
    }

    if (!syncProvider.isOnline) {
      return 'Sem conexão';
    }

    if (syncProvider.isOfflineMode) {
      return 'Modo Offline';
    }

    if (syncProvider.pendingSyncItems > 0) {
      return '${syncProvider.pendingSyncItems} pendente${syncProvider.pendingSyncItems > 1 ? 's' : ''}';
    }

    return 'Sincronizado';
  }

  Color _getBackgroundColor(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return Colors.blue[50]!;
    }

    if (!syncProvider.isOnline) {
      return Colors.red[50]!;
    }

    if (syncProvider.isOfflineMode || syncProvider.pendingSyncItems > 0) {
      return Colors.orange[50]!;
    }

    return Colors.green[50]!;
  }

  Color _getBorderColor(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return Colors.blue[200]!;
    }

    if (!syncProvider.isOnline) {
      return Colors.red[200]!;
    }

    if (syncProvider.isOfflineMode || syncProvider.pendingSyncItems > 0) {
      return Colors.orange[200]!;
    }

    return Colors.green[200]!;
  }

  Color _getTextColor(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return Colors.blue[700]!;
    }

    if (!syncProvider.isOnline) {
      return Colors.red[700]!;
    }

    if (syncProvider.isOfflineMode || syncProvider.pendingSyncItems > 0) {
      return Colors.orange[700]!;
    }

    return Colors.green[700]!;
  }

  void _showOfflineSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OfflineSettingsScreen(),
      ),
    );
  }
}

// Widget simplificado para usar na AppBar
class AppBarOfflineIndicator extends StatelessWidget {
  const AppBarOfflineIndicator({super.key});

  // Widget constante para performance
  static const Widget _shrinkWidget = SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        // Mostrar apenas se há algo relevante
        if (syncProvider.isOnline &&
            syncProvider.pendingSyncItems == 0 &&
            !syncProvider.isOfflineMode &&
            syncProvider.syncStatus != SyncStatus.syncing) {
          return _shrinkWidget;
        }

        return IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OfflineSettingsScreen(),
            ),
          ),
          icon: Stack(
            children: [
              _getIcon(syncProvider),
              if (syncProvider.pendingSyncItems > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      syncProvider.pendingSyncItems > 9
                          ? '9+'
                          : '${syncProvider.pendingSyncItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: _getTooltip(syncProvider),
        );
      },
    );
  }

  Widget _getIcon(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return const Icon(Icons.sync, color: Colors.blue);
    }

    if (!syncProvider.isOnline) {
      return const Icon(Icons.wifi_off, color: Colors.red);
    }

    if (syncProvider.isOfflineMode) {
      return const Icon(Icons.cloud_off, color: Colors.orange);
    }

    if (syncProvider.pendingSyncItems > 0) {
      return const Icon(Icons.sync_problem, color: Colors.orange);
    }

    return const Icon(Icons.cloud_done, color: Colors.green);
  }

  String _getTooltip(SyncProvider syncProvider) {
    if (syncProvider.syncStatus == SyncStatus.syncing) {
      return 'Sincronizando dados...';
    }

    if (!syncProvider.isOnline) {
      return 'Sem conexão com a internet';
    }

    if (syncProvider.isOfflineMode) {
      return 'Modo offline ativado';
    }

    if (syncProvider.pendingSyncItems > 0) {
      return '${syncProvider.pendingSyncItems} itens aguardando sincronização';
    }

    return 'Dados sincronizados';
  }
}
