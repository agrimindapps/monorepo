import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/public_defensivos_providers.dart';

class PublicDefensivosListPage extends ConsumerStatefulWidget {
  const PublicDefensivosListPage({super.key});

  @override
  ConsumerState<PublicDefensivosListPage> createState() =>
      _PublicDefensivosListPageState();
}

class _PublicDefensivosListPageState
    extends ConsumerState<PublicDefensivosListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defensivosAsync = ref.watch(publicDefensivosProvider);
    final paginatedDefensivos = ref.watch(publicPaginatedDefensivosProvider);
    final currentPage = ref.watch(publicCurrentPageProvider);
    final totalPages = ref.watch(publicTotalPagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta Pública de Defensivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(publicDefensivosProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar defensivo',
                hintText: 'Nome, ingrediente ativo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(publicDefensivosProvider.notifier).search('');
                  },
                ),
              ),
              onSubmitted: (value) {
                ref.read(publicDefensivosProvider.notifier).search(value);
              },
            ),
          ),

          // List Content
          Expanded(
            child: defensivosAsync.when(
              data: (_) {
                if (paginatedDefensivos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum defensivo encontrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: paginatedDefensivos.length,
                  itemBuilder: (context, index) {
                    final defensivo = paginatedDefensivos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          defensivo.nomeComum,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fabricante: ${defensivo.fabricante}'),
                            Text('Ingrediente: ${defensivo.ingredienteAtivo}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/defensivo',
                            arguments: {'id': defensivo.id},
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Erro ao carregar defensivos: $error')),
            ),
          ),

          // Pagination
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 0
                        ? () => ref
                              .read(publicCurrentPageProvider.notifier)
                              .previousPage()
                        : null,
                  ),
                  Text('Página ${currentPage + 1} de $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage < totalPages - 1
                        ? () => ref
                              .read(publicCurrentPageProvider.notifier)
                              .nextPage(totalPages)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
