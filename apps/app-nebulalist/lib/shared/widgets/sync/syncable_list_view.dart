import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dependency_providers.dart';

/// ListView com pull-to-refresh integrado para sync
///
/// Automaticamente sincroniza quando user puxa para baixo.
/// Mostra indicador de progresso durante sync.
///
/// **Uso:**
/// ```dart
/// SyncableListView(
///   itemCount: items.length,
///   itemBuilder: (context, index) => ListTile(...),
///   onSyncComplete: () {
///     // Opcional: refresh local data
///     ref.refresh(listsProvider);
///   },
/// )
/// ```
class SyncableListView extends ConsumerWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback? onSyncComplete;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const SyncableListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onSyncComplete,
    this.emptyWidget,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(nebulalistSyncServiceProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger sync
        final result = await syncService.sync();

        result.fold(
          (failure) {
            // Mostra erro se sync falhou
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao sincronizar: ${failure.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          (syncResult) {
            // Sucesso
            if (context.mounted) {
              final message = syncResult.itemsSynced > 0
                  ? 'Sincronizados ${syncResult.itemsSynced} itens'
                  : 'Tudo sincronizado';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            // Callback opcional para refresh de dados locais
            onSyncComplete?.call();
          },
        );
      },
      child: itemCount == 0 && emptyWidget != null
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(child: emptyWidget),
              ),
            )
          : ListView.builder(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              padding: padding ?? const EdgeInsets.all(16),
              physics: physics ?? const AlwaysScrollableScrollPhysics(),
            ),
    );
  }
}

/// GridView com pull-to-refresh integrado
class SyncableGridView extends ConsumerWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final VoidCallback? onSyncComplete;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const SyncableGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.onSyncComplete,
    this.emptyWidget,
    this.padding,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(nebulalistSyncServiceProvider);

    return RefreshIndicator(
      onRefresh: () async {
        final result = await syncService.sync();

        result.fold(
          (failure) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao sincronizar: ${failure.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          (syncResult) {
            if (context.mounted) {
              final message = syncResult.itemsSynced > 0
                  ? 'Sincronizados ${syncResult.itemsSynced} itens'
                  : 'Tudo sincronizado';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }

            onSyncComplete?.call();
          },
        );
      },
      child: itemCount == 0 && emptyWidget != null
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(child: emptyWidget),
              ),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              padding: padding ?? const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
            ),
    );
  }
}
