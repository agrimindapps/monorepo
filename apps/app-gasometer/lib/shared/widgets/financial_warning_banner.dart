/// Financial Warning Banner Widget
/// Shows warnings and notifications for financial data operations
library;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/financial_core.dart';

/// Types of financial warnings
enum FinancialWarningType {
  unsyncedData,
  highValueTransaction,
  conflictDetected,
  validationFailed,
  offlineMode,
  syncRetrying,
}

/// Financial warning banner widget
class FinancialWarningBanner extends StatelessWidget {

  const FinancialWarningBanner({
    super.key,
    this.warningType,
    this.customMessage,
    this.onAction,
    this.actionLabel,
    this.dismissible = true,
    this.onDismiss,
  });

  /// Auto-detecting banner based on sync service state
  const FinancialWarningBanner.auto({
    super.key,
    this.onAction,
    this.actionLabel,
    this.dismissible = true,
    this.onDismiss,
  })  : warningType = null,
        customMessage = null;
  final FinancialWarningType? warningType;
  final String? customMessage;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool dismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (warningType == null && customMessage == null) {
return Consumer(
          builder: (context, ref, child) {
            final syncService = FinancialModule.syncService;
          final autoWarning = _detectWarning(syncService);
          if (autoWarning == null) return const SizedBox.shrink();

          return _buildBanner(context, autoWarning, syncService);
        },
      );
    }

    return _buildBanner(context, warningType, null);
  }

  Widget _buildBanner(BuildContext context, FinancialWarningType? type, FinancialSyncService? syncService) {
    if (type == null && customMessage == null) return const SizedBox.shrink();

    final config = type != null ? _getWarningConfig(type, syncService) : _getCustomConfig();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        color: config.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                config.icon,
                color: config.iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: config.textColor,
                        fontSize: 14,
                      ),
                    ),
                    if (config.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        config.message,
                        style: TextStyle(
                          color: config.textColor.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (config.showAction && (onAction != null || config.defaultAction != null)) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onAction ?? config.defaultAction,
                  style: TextButton.styleFrom(
                    foregroundColor: config.textColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    actionLabel ?? config.actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              if (dismissible) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDismiss ?? () {
                  },
                  icon: Icon(
                    Icons.close,
                    color: config.textColor.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  FinancialWarningType? _detectWarning(FinancialSyncService syncService) {
    final stats = syncService.getQueueStats();
    final pendingFinancial = stats['financial_queued'] as int? ?? 0;
    final retrying = stats['retrying'] as int? ?? 0;
    final highPriority = stats['high_priority_queued'] as int? ?? 0;
    if (retrying > 0) return FinancialWarningType.syncRetrying;
    if (highPriority > 0) return FinancialWarningType.highValueTransaction;
    if (pendingFinancial > 0) return FinancialWarningType.unsyncedData;

    return null;
  }

  _WarningConfig _getWarningConfig(FinancialWarningType type, FinancialSyncService? syncService) {
    final stats = syncService?.getQueueStats() ?? <String, dynamic>{};

    switch (type) {
      case FinancialWarningType.unsyncedData:
        final count = stats['financial_queued'] as int? ?? 0;
        return _WarningConfig(
          icon: Icons.cloud_off,
          title: 'Dados Financeiros Não Sincronizados',
          message: '$count registro(s) aguardando sincronização. '
              'Seus dados podem não estar atualizados em outros dispositivos.',
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          iconColor: Colors.orange,
          textColor: Colors.orange.shade800,
          showAction: true,
          actionLabel: 'Sincronizar',
          defaultAction: () {
          },
        );

      case FinancialWarningType.highValueTransaction:
        final count = stats['high_priority_queued'] as int? ?? 0;
        return _WarningConfig(
          icon: Icons.priority_high,
          title: 'Transações de Alto Valor Pendentes',
          message: '$count transação(ões) de alto valor aguardando sincronização. '
              'Verifique se os dados estão corretos.',
          backgroundColor: Colors.red.withValues(alpha:0.1),
          iconColor: Colors.red,
          textColor: Colors.red.shade800,
          showAction: true,
          actionLabel: 'Verificar',
          defaultAction: () {
          },
        );

      case FinancialWarningType.conflictDetected:
        return _WarningConfig(
          icon: Icons.warning,
          title: 'Conflito de Dados Detectado',
          message: 'Foram encontradas versões diferentes dos mesmos dados financeiros. '
              'Resolução manual necessária.',
          backgroundColor: Colors.deepOrange.withValues(alpha:0.1),
          iconColor: Colors.deepOrange,
          textColor: Colors.deepOrange.shade800,
          showAction: true,
          actionLabel: 'Resolver',
          defaultAction: () {
          },
        );

      case FinancialWarningType.validationFailed:
        return _WarningConfig(
          icon: Icons.error_outline,
          title: 'Erro de Validação',
          message: 'Alguns dados financeiros contêm erros que impedem a sincronização. '
              'Corrija os dados antes de continuar.',
          backgroundColor: Colors.red.withValues(alpha:0.1),
          iconColor: Colors.red,
          textColor: Colors.red.shade800,
          showAction: true,
          actionLabel: 'Corrigir',
          defaultAction: () {
          },
        );

      case FinancialWarningType.offlineMode:
        return _WarningConfig(
          icon: Icons.wifi_off,
          title: 'Modo Offline',
          message: 'Sem conexão com a internet. Os dados financeiros serão '
              'sincronizados quando a conexão for restabelecida.',
          backgroundColor: Colors.grey.withValues(alpha:0.1),
          iconColor: Colors.grey,
          textColor: Colors.grey.shade800,
          showAction: false,
          actionLabel: '',
        );

      case FinancialWarningType.syncRetrying:
        final count = stats['retrying'] as int? ?? 0;
        return _WarningConfig(
          icon: Icons.refresh,
          title: 'Tentando Sincronizar Novamente',
          message: '$count item(ns) falharam na sincronização e estão sendo '
              'tentados novamente automaticamente.',
          backgroundColor: Colors.amber.withValues(alpha:0.1),
          iconColor: Colors.amber,
          textColor: Colors.amber.shade800,
          showAction: true,
          actionLabel: 'Detalhes',
          defaultAction: () {
          },
        );
    }
  }

  _WarningConfig _getCustomConfig() {
    return _WarningConfig(
      icon: Icons.info,
      title: 'Aviso',
      message: customMessage ?? '',
      backgroundColor: Colors.blue.withValues(alpha:0.1),
      iconColor: Colors.blue,
      textColor: Colors.blue.shade800,
      showAction: onAction != null,
      actionLabel: actionLabel ?? 'OK',
    );
  }
}

/// Warning configuration class
class _WarningConfig {

  const _WarningConfig({
    required this.icon,
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.showAction,
    required this.actionLabel,
    this.defaultAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final bool showAction;
  final String actionLabel;
  final VoidCallback? defaultAction;
}

/// Extension for easy banner display
extension FinancialWarningBannerExtension on BuildContext {
  /// Show a temporary financial warning banner
  void showFinancialWarning({
    required FinancialWarningType type,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 5),
  }) {
    final overlay = Overlay.of(this);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: FinancialWarningBanner(
          warningType: type,
          onAction: onAction,
          actionLabel: actionLabel,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
    Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}
