import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dependency_providers.dart';

/// Widget que exibe status de sincronização com badges
///
/// Mostra contadores de:
/// - Items pendentes de sync (amarelo)
/// - Items que falharam após 3 tentativas (vermelho)
///
/// **Uso:**
/// ```dart
/// AppBar(
///   actions: [
///     SyncStatusWidget(
///       onTapPending: () => showPendingDialog(),
///       onTapFailed: () => showFailedDialog(),
///     ),
///   ],
/// )
/// ```
class SyncStatusWidget extends ConsumerWidget {
  final VoidCallback? onTapPending;
  final VoidCallback? onTapFailed;
  final int maxRetries;

  const SyncStatusWidget({
    super.key,
    this.onTapPending,
    this.onTapFailed,
    this.maxRetries = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncQueueService = ref.watch(syncQueueServiceProvider);

    return FutureBuilder<Map<String, int>>(
      future: syncQueueService.getStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final pendingCount = stats['pending'] ?? 0;
        final failedCount = stats['failed'] ?? 0;

        // Se não há nada pendente ou falhado, não mostra nada
        if (pendingCount == 0 && failedCount == 0) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge de items pendentes
            if (pendingCount > 0)
              _SyncBadge(
                count: pendingCount,
                color: Colors.orange,
                icon: Icons.sync,
                label: 'Pendentes',
                onTap: onTapPending,
              ),
            if (pendingCount > 0 && failedCount > 0) const SizedBox(width: 8),
            // Badge de items falhados
            if (failedCount > 0)
              _SyncBadge(
                count: failedCount,
                color: Colors.red,
                icon: Icons.error_outline,
                label: 'Falhados',
                onTap: onTapFailed,
              ),
          ],
        );
      },
    );
  }
}

/// Badge individual para mostrar contador de sync
class _SyncBadge extends StatelessWidget {
  final int count;
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SyncBadge({
    required this.count,
    required this.color,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$count $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
