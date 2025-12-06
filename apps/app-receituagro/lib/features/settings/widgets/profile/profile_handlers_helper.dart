import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/core_providers.dart';

/// Helper com handlers complexos do ProfilePage
/// Responsabilidade: Handlers que não são simples callbacks
class ProfileHandlersHelper {
  const ProfileHandlersHelper._();

  /// Handler para limpeza de dados (extraído do ProfilePage)
  static Future<void> handleClearData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authProvider).value;
    final userId = authState?.currentUser?.id ?? 'unknown';

    try {
      final analytics = ref.read(analyticsServiceProvider);

      analytics.trackEvent(
        'clear_data_attempt',
        parameters: {'user_id': userId, 'trigger_source': 'profile_page'},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Limpando dados locais...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 30),
        ),
      );

      final dataCleaner = ref.read(dataCleanerServiceProvider);

      final hasData = await dataCleaner.hasDataToClear();
      if (!hasData) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Não há dados locais para limpar'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        analytics.trackEvent(
          'clear_data_no_data',
          parameters: {'user_id': userId},
        );
        return;
      }

      final stats = await dataCleaner.getDataStatsBeforeCleaning();
      debugPrint('📊 Dados a serem limpos: $stats');

      final result = await dataCleaner.clearAllAppData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        final success = result['success'] as bool? ?? false;
        final errors = result['errors'] as List? ?? [];
        final totalCleared = result['totalRecordsCleared'] as int? ?? 0;
        final duration = result['duration'] as int? ?? 0;

        if (success && errors.isEmpty) {
          analytics.trackEvent(
            'clear_data_success',
            parameters: {
              'user_id': userId,
              'total_cleared': totalCleared.toString(),
              'duration_ms': duration.toString(),
            },
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dados limpos com sucesso! $totalCleared registros removidos',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (success && errors.isNotEmpty) {
          analytics.trackEvent(
            'clear_data_partial',
            parameters: {
              'user_id': userId,
              'total_cleared': totalCleared.toString(),
              'errors_count': errors.length.toString(),
            },
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dados limpos com ${errors.length} avisos',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          final mainError =
              result['mainError']?.toString() ?? 'Erro desconhecido';
          analytics.trackEvent(
            'clear_data_failed',
            parameters: {'user_id': userId, 'error': mainError},
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Erro ao limpar dados: $mainError',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      final analytics = ref.read(analyticsServiceProvider);
      analytics.trackError('clear_data_exception', e.toString());

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Erro inesperado ao limpar dados: $e',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Handler para sincronização de dados (extraído do ProfilePage)
  static Future<void> handleSyncRefresh(
    BuildContext context,
    WidgetRef ref,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Sincronizando dados...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final syncService = ref.read(receitaAgroSyncServiceProvider);

      if (!syncService.canSync) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Serviço de sincronização não está pronto'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final result = await syncService.sync();

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Erro ao sincronizar: ${failure.message}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          },
          (syncResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncResult.success
                            ? 'Sincronizado! ${syncResult.itemsSynced} itens em ${syncResult.duration.inSeconds}s'
                            : 'Sincronização parcial: ${syncResult.itemsSynced} OK, ${syncResult.itemsFailed} falhas',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor:
                    syncResult.success ? Colors.green : Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Erro inesperado: $e',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
