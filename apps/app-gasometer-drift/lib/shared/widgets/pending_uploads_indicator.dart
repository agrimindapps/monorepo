import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/providers/dependency_providers.dart';

/// Widget que mostra indicador de imagens pendentes de upload
/// Aparece quando há imagens que foram capturadas offline
/// e ainda não foram sincronizadas com o servidor
class PendingUploadsIndicator extends ConsumerWidget {
  const PendingUploadsIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageSyncService = ref.watch(imageSyncServiceProvider);

    // Usar FutureBuilder para carregar contagem de pendentes
    return FutureBuilder<int>(
      future: _getPendingCount(imageSyncService),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        if (pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border.all(color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount ${pendingCount == 1 ? 'imagem pendente' : 'imagens pendentes'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Será enviada quando conectar à internet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await imageSyncService.syncPendingImages();
                },
                child: Text(
                  'Tentar agora',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _getPendingCount(dynamic service) async {
    try {
      // Aguarda inicialização se necessário
      await service.initialize();
      return service.pendingCount as int;
    } catch (e) {
      return 0;
    }
  }
}

/// StreamBuilder version que atualiza em tempo real
class PendingUploadsIndicatorStream extends ConsumerWidget {
  const PendingUploadsIndicatorStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageSyncService = ref.watch(imageSyncServiceProvider);

    return StreamBuilder(
      stream: imageSyncService.progressStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final progress = snapshot.data!;

          if (progress.isCompleted) {
            // Sync completado - mostrar indicador estático
            return const PendingUploadsIndicator();
          }

          // Mostra progresso de sincronização
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: progress.percentage,
                    strokeWidth: 2,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enviando imagens...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${progress.current} de ${progress.total}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Sem dados de progresso - mostrar indicador estático
        return const PendingUploadsIndicator();
      },
    );
  }
}
