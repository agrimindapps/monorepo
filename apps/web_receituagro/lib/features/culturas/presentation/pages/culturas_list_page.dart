import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../../domain/entities/cultura.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/culturas_providers.dart';

/// Culturas list page
class CulturasListPage extends ConsumerWidget {
  const CulturasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final culturasAsync = ref.watch(culturasProvider);
    final authState = ref.watch(authProvider);

    return InternalPageLayout(
      title: 'Culturas',
      actions: [
        // New cultura button (only for Editor/Admin)
        authState.whenOrNull(
          data: (user) {
            if (user?.canWrite == true) {
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  Navigator.of(context).pushNamed('/culturas/new');
                },
                tooltip: 'Nova Cultura',
              );
            }
            return null;
          },
        ) ?? const SizedBox.shrink(),
      ],
      body: culturasAsync.when(
        data: (culturas) => _buildContent(context, ref, culturas),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Cultura> culturas,
  ) {
    if (culturas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grass_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma cultura cadastrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre a primeira cultura para começar',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(culturasProvider.notifier).refresh();
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
            itemCount: culturas.length,
            itemBuilder: (context, index) {
              final cultura = culturas[index];
              return _CulturaCard(cultura: cultura);
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
            'Erro ao carregar culturas',
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
              ref.read(culturasProvider.notifier).refresh();
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

/// Cultura card widget
class _CulturaCard extends ConsumerWidget {
  final Cultura cultura;

  const _CulturaCard({required this.cultura});

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
            '/culturas/details',
            arguments: {'id': cultura.id},
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
                      color: Colors.lightGreen.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.grass,
                      color: Colors.lightGreen.shade700,
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
                              '/culturas/edit',
                              arguments: {'id': cultura.id},
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
                cultura.nomeComum,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Nome Científico (italic)
              Text(
                cultura.nomeCientifico,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Família
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  cultura.familia,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
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
