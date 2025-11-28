import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/defensivo.dart';
import '../../domain/entities/defensivo_filter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/defensivos_providers.dart';

/// Defensivos list page with Riverpod
class DefensivosListPage extends ConsumerStatefulWidget {
  const DefensivosListPage({super.key});

  @override
  ConsumerState<DefensivosListPage> createState() => _DefensivosListPageState();
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
    final defensivosAsync = ref.watch(defensivosProvider);
    final authState = ref.watch(authProvider);
    final currentFilter = ref.watch(currentFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Defensivos Agrícolas'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(defensivosProvider.notifier).refresh();
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
                  // Export button (Editor + Admin)
                  if (user.canWrite)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/exportar');
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Exportar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  const SizedBox(width: 8),

                  // New Defensivo button (only for Editor/Admin)
                  if (user.canWrite)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/defensivo/new');
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Novo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  const SizedBox(width: 8),

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
                                'Deseja realmente sair do sistema?',
                              ),
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
                                .read(authProvider.notifier)
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
          // Search bar with filters
          _buildSearchBar(currentFilter),

          // Main content
          Expanded(
            child: defensivosAsync.when(
              data: (defensivos) => _buildContent(defensivos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(DefensivoFilter currentFilter) {
    final filterCounts = ref.watch(filterCountsProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                                  .read(defensivosProvider.notifier)
                                  .showAll();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(defensivosProvider.notifier).search(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isNotEmpty) {
                    ref.read(defensivosProvider.notifier).search(query);
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(defensivosProvider.notifier).showAll();
                  ref.read(currentFilterProvider.notifier).reset();
                },
                child: const Text('Limpar'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DefensivoFilter.values.map((filter) {
                final isSelected = currentFilter == filter;
                final count = filterCounts[filter] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter.icon != null) ...[
                          Icon(
                            filter.icon,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(filter.label),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selectedColor: Colors.green.shade600,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                    onSelected: (selected) {
                      ref.read(currentFilterProvider.notifier).setFilter(filter);
                      ref.read(currentPageProvider.notifier).firstPage();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Defensivo> defensivos) {
    final filteredList = ref.watch(filteredDefensivosProvider);

    if (filteredList.isEmpty) {
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
          child: _DefensivosGrid(
            onCopyName: _copyDefensivoName,
            onDelete: _confirmDeleteDefensivo,
          ),
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
              ref.read(defensivosProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// Copy defensivo name to clipboard
  void _copyDefensivoName(BuildContext context, String name) {
    // For web, we show a snackbar with the name
    // User can select and copy from the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText('Nome: $name'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Confirm delete defensivo dialog
  Future<void> _confirmDeleteDefensivo(
    BuildContext context,
    WidgetRef ref,
    Defensivo defensivo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Defensivo'),
        content: Text(
          'Deseja realmente excluir o defensivo "${defensivo.nomeComum}"?\n\n'
          'Esta ação não pode ser desfeita e todos os dados relacionados '
          '(diagnósticos, informações técnicas, etc.) também serão excluídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(defensivosProvider.notifier)
          .deleteDefensivo(defensivo.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Defensivo excluído com sucesso'
                  : 'Erro ao excluir defensivo',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

/// DataTable widget for defensivos with enhanced columns
class _DefensivosGrid extends ConsumerWidget {
  final void Function(BuildContext context, String name) onCopyName;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    Defensivo defensivo,
  )
  onDelete;

  const _DefensivosGrid({required this.onCopyName, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedDefensivos = ref.watch(paginatedDefensivosProvider);
    final statsMap = ref.watch(defensivosStatsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.green.shade50),
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            columnSpacing: 24,
            columns: const [
              DataColumn(
                label: Text(
                  'Defensivo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fabricante',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tóxico',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Diagn.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                tooltip: 'Preenchidos / Total de Diagnósticos',
              ),
              DataColumn(
                label: Text(
                  'Preench.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                tooltip: 'Diagnósticos Completos',
              ),
              DataColumn(
                label: Text(
                  'Info.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                tooltip: 'Informações Complementares',
              ),
              DataColumn(
                label: Text(
                  'Ações',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: paginatedDefensivos.map((defensivo) {
              final stats =
                  statsMap[defensivo.id] ?? const DefensivoStats.empty();

              return DataRow(
                cells: [
                  // Nome do Defensivo
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            defensivo.nomeComum,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (defensivo.ingredienteAtivo.isNotEmpty)
                            Text(
                              defensivo.ingredienteAtivo,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Fabricante
                  DataCell(
                    SizedBox(
                      width: 140,
                      child: Text(
                        defensivo.fabricante.isEmpty
                            ? '-'
                            : defensivo.fabricante,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Classe Toxicológica
                  DataCell(
                    _buildToxicoCell(defensivo.toxico),
                  ),
                  // Diagnósticos (X/Y)
                  DataCell(
                    _buildDiagnosticosCell(stats),
                  ),
                  // Preenchimento (check if complete)
                  DataCell(
                    _buildPreenchimentoCell(stats),
                  ),
                  // Informações (check if has info)
                  DataCell(
                    _buildInfoCell(stats),
                  ),
                  // Ações
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View button
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          tooltip: 'Ver detalhes',
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/defensivo',
                              arguments: {'id': defensivo.id},
                            );
                          },
                        ),
                        // Edit button (only for writers)
                        Consumer(
                          builder: (context, ref, _) {
                            final authState = ref.watch(authProvider);
                            return authState.when(
                              data: (user) {
                                if (user?.canWrite == true) {
                                  return IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    tooltip: 'Editar',
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        '/defensivo/edit',
                                        arguments: {'id': defensivo.id},
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                        // Copy button
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            size: 20,
                            color: Colors.blue.shade600,
                          ),
                          tooltip: 'Copiar nome',
                          onPressed: () {
                            onCopyName(context, defensivo.nomeComum);
                          },
                        ),
                        // Delete button (only for admin)
                        Consumer(
                          builder: (context, ref, _) {
                            final authState = ref.watch(authProvider);
                            return authState.when(
                              data: (user) {
                                if (user?.isAdmin == true) {
                                  return IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Excluir',
                                    onPressed: () {
                                      onDelete(context, ref, defensivo);
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildToxicoCell(String? toxico) {
    if (toxico == null || toxico.isEmpty) {
      return const Text('-', style: TextStyle(color: Colors.grey));
    }

    // Map toxicity class to color
    Color color;
    switch (toxico.toUpperCase()) {
      case 'I':
        color = Colors.red.shade700;
        break;
      case 'II':
        color = Colors.orange.shade700;
        break;
      case 'III':
        color = Colors.yellow.shade800;
        break;
      case 'IV':
        color = Colors.green.shade700;
        break;
      default:
        color = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        toxico,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDiagnosticosCell(DefensivoStats stats) {
    final hasAny = stats.hasDiagnosticos;
    final isComplete = stats.isDiagnosticosComplete;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stats.diagnosticoDisplay,
          style: TextStyle(
            color: hasAny
                ? (isComplete ? Colors.green.shade700 : Colors.orange.shade700)
                : Colors.grey,
            fontWeight: hasAny ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (hasAny && !isComplete) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.warning_amber,
            size: 14,
            color: Colors.orange.shade700,
          ),
        ],
      ],
    );
  }

  Widget _buildPreenchimentoCell(DefensivoStats stats) {
    if (stats.isDiagnosticosComplete && stats.hasDiagnosticos) {
      return Icon(
        Icons.check_circle,
        color: Colors.green.shade600,
        size: 20,
      );
    }
    return Icon(
      Icons.radio_button_unchecked,
      color: Colors.grey.shade400,
      size: 20,
    );
  }

  Widget _buildInfoCell(DefensivoStats stats) {
    if (stats.hasInfo) {
      return Icon(
        Icons.check_circle,
        color: Colors.green.shade600,
        size: 20,
      );
    }
    return Icon(
      Icons.radio_button_unchecked,
      color: Colors.grey.shade400,
      size: 20,
    );
  }
}

/// Total count widget
class _TotalCount extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredList = ref.watch(filteredDefensivosProvider);
    final defensivosAsync = ref.watch(defensivosProvider);

    return defensivosAsync.when(
      data: (defensivos) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Exibindo ${filteredList.length} de ${defensivos.length} registros',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
