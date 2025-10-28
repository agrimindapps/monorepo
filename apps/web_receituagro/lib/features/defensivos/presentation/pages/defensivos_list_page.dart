import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/defensivo.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/defensivos_providers.dart';
import '../widgets/defensivo_card.dart';

/// Defensivos list page with Riverpod
class DefensivosListPage extends ConsumerStatefulWidget {
  const DefensivosListPage({super.key});

  @override
  ConsumerState<DefensivosListPage> createState() =>
      _DefensivosListPageState();
}

class _DefensivosListPageState extends ConsumerState<DefensivosListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defensivosAsync = ref.watch(defensivosNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Defensivos Agrícolas'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(defensivosNotifierProvider.notifier).refresh();
            },
            tooltip: 'Atualizar',
          ),

          // Auth-aware actions
          authState.when(
            data: (user) {
              if (user == null) {
                // Not authenticated - show login button
                return TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Authenticated - show user menu
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // New Defensivo button (only for Editor/Admin)
                  if (user.canWrite)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/defensivo/new');
                      },
                      tooltip: 'Novo Defensivo',
                    ),

                  // Admin panel button (only for Admin)
                  if (user.isAdmin)
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/admin');
                      },
                      tooltip: 'Painel Admin',
                    ),

                  const SizedBox(width: 8),

                  // User menu
                  PopupMenuButton<String>(
                    tooltip: 'Menu do usuário',
                    icon: CircleAvatar(
                      backgroundColor: Colors.green.shade700,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    itemBuilder: (context) => [
                      // User info header
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                user.role.displayName,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.green.shade100,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),

                      // Admin panel option (Admin only)
                      if (user.isAdmin)
                        const PopupMenuItem<String>(
                          value: 'admin',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.admin_panel_settings),
                            title: Text('Painel Admin'),
                            dense: true,
                          ),
                        ),

                      // Users management (Admin only)
                      if (user.isAdmin)
                        const PopupMenuItem<String>(
                          value: 'users',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.people),
                            title: Text('Gerenciar Usuários'),
                            dense: true,
                          ),
                        ),

                      // Divider before logout (if admin options exist)
                      if (user.isAdmin) const PopupMenuDivider(),

                      // Logout
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            'Sair',
                            style: TextStyle(color: Colors.red),
                          ),
                          dense: true,
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case 'admin':
                          Navigator.of(context).pushNamed('/admin');
                          break;
                        case 'users':
                          Navigator.of(context).pushNamed('/users');
                          break;
                        case 'logout':
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sair'),
                              content: const Text(
                                  'Deseja realmente sair do sistema?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Sair'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logout realizado com sucesso'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                          break;
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              tooltip: 'Entrar',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Main content
          Expanded(
            child: defensivosAsync.when(
              data: (defensivos) => _buildContent(defensivos),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => _buildError(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar defensivo, ingrediente ativo...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(defensivosNotifierProvider.notifier)
                              .showAll();
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  ref
                      .read(defensivosNotifierProvider.notifier)
                      .search(value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                ref.read(defensivosNotifierProvider.notifier).search(query);
              }
            },
            icon: const Icon(Icons.search),
            label: const Text('Buscar'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(defensivosNotifierProvider.notifier).showAll();
            },
            child: const Text('Todos'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Defensivo> defensivos) {
    if (defensivos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum defensivo encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Grid
        Expanded(
          child: _DefensivosGrid(),
        ),

        // Pagination
        _buildPagination(),

        // Total count
        _TotalCount(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPagination() {
    final currentPage = ref.watch(currentPageProvider);
    final totalPagesCount = ref.watch(totalPagesProvider);
    final pageNumbersList = ref.watch(pageNumbersProvider);

    if (totalPagesCount <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First page
          IconButton(
            onPressed: currentPage > 0
                ? () {
                    ref.read(currentPageProvider.notifier).firstPage();
                  }
                : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'Primeira página',
          ),

          // Previous page
          IconButton(
            onPressed: currentPage > 0
                ? () {
                    ref.read(currentPageProvider.notifier).previousPage();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),

          // Page numbers
          ...pageNumbersList.map((page) {
            final isCurrentPage = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentPage ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(40, 40),
                ),
                onPressed: () {
                  ref.read(currentPageProvider.notifier).goToPage(page);
                },
                child: Text('${page + 1}'),
              ),
            );
          }),

          // Next page
          IconButton(
            onPressed: currentPage < totalPagesCount - 1
                ? () {
                    ref
                        .read(currentPageProvider.notifier)
                        .nextPage(totalPagesCount);
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
          ),

          // Last page
          IconButton(
            onPressed: currentPage < totalPagesCount - 1
                ? () {
                    ref
                        .read(currentPageProvider.notifier)
                        .lastPage(totalPagesCount);
                  }
                : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Última página',
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar defensivos',
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
              ref.read(defensivosNotifierProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

/// Grid widget optimized for rebuilds
class _DefensivosGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedDefensivos = ref.watch(paginatedDefensivosProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: paginatedDefensivos.length,
          itemBuilder: (context, index) {
            final defensivo = paginatedDefensivos[index];
            return DefensivoCard(defensivo: defensivo);
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }
}

/// Total count widget
class _TotalCount extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defensivosAsync = ref.watch(defensivosNotifierProvider);

    return defensivosAsync.when(
      data: (defensivos) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Total de registros: ${defensivos.length}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
