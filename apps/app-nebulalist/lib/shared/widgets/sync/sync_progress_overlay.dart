import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../../../core/providers/dependency_providers.dart';

/// Overlay que exibe progresso de sincronização
///
/// Mostra:
/// - Barra de progresso circular
/// - Item atual sendo sincronizado
/// - Status da operação
///
/// **Uso:**
/// ```dart
/// Stack(
///   children: [
///     YourContent(),
///     SyncProgressOverlay(), // Auto-gerenciado via stream
///   ],
/// )
/// ```
class SyncProgressOverlay extends ConsumerWidget {
  const SyncProgressOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(nebulalistSyncServiceProvider);

    return StreamBuilder<ServiceProgress>(
      stream: syncService.progressStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final progress = snapshot.data!;

        // Não mostra se sync foi completado
        if (progress.operation == 'completed') {
          return const SizedBox.shrink();
        }

        return _ProgressOverlayContent(progress: progress);
      },
    );
  }
}

/// Conteúdo visual do overlay
class _ProgressOverlayContent extends StatelessWidget {
  final ServiceProgress progress;

  const _ProgressOverlayContent({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = progress.total > 0
        ? progress.current / progress.total
        : null; // Indeterminate

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de sync
                Icon(
                  Icons.sync,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  'Sincronizando...',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                // Item atual
                if (progress.currentItem != null)
                  Text(
                    progress.currentItem!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),

                // Barra de progresso
                if (progressValue != null)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${progress.current} de ${progress.total}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
