import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../../domain/entities/praga.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/pragas_providers.dart';

/// Pragas list page
class PragasListPage extends ConsumerWidget {
  const PragasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pragasAsync = ref.watch(pragasProvider);
    final authState = ref.watch(authProvider);

    return InternalPageLayout(
      title: 'Pragas',
      actions: [
        // New praga button (only for Editor/Admin)
        authState.whenOrNull(
          data: (user) {
            if (user?.canWrite == true) {
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  Navigator.of(context).pushNamed('/pragas/new');
                },
                tooltip: 'Nova Praga',
              );
            }
            return null;
          },
        ) ?? const SizedBox.shrink(),
      ],
      body: pragasAsync.when(
        data: (pragas) => _buildContent(context, ref, pragas),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Praga> pragas,
  ) {
    if (pragas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma praga cadastrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre a primeira praga para começar',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(pragasProvider.notifier).refresh();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: pragas.length,
            itemBuilder: (context, index) {
              final praga = pragas[index];
              return _PragaCard(praga: praga);
            },
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar pragas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(pragasProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }
}

/// Praga card widget
class _PragaCard extends ConsumerWidget {
  final Praga praga;

  const _PragaCard({required this.praga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/pragas/details',
            arguments: {'id': praga.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bug_report,
                      color: Colors.orange.shade700,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  // Edit button (visible for Editor/Admin)
                  ref.watch(authProvider).whenOrNull(
                    data: (user) {
                      if (user?.canWrite == true) {
                        return IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/pragas/edit',
                              arguments: {'id': praga.id},
                            );
                          },
                          tooltip: 'Editar',
                        );
                      }
                      return null;
                    },
                  ) ?? const SizedBox.shrink(),
                ],
              ),

              const SizedBox(height: 12),

              // Nome Comum
              Text(
                praga.nomeComum,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Nome Científico (italic)
              Text(
                praga.nomeCientifico,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Ordem
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  praga.ordem,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
