import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../../domain/entities/praga.dart';
import '../../domain/entities/tipo_praga.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/pragas_providers.dart';

/// Pragas list page with DataTable (similar to Vue.js)
class PragasListPage extends ConsumerStatefulWidget {
  const PragasListPage({super.key});

  @override
  ConsumerState<PragasListPage> createState() => _PragasListPageState();
}

class _PragasListPageState extends ConsumerState<PragasListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pragasAsync = ref.watch(pragasProvider);
    final authState = ref.watch(authProvider);
    final pragasWithInfoAsync = ref.watch(pragasWithInfoProvider);
    final pragasWithPlantaInfoAsync = ref.watch(pragasWithPlantaInfoProvider);

    return InternalPageLayout(
      title: 'Pragas',
      actions: [
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(pragasProvider);
            ref.invalidate(pragasWithInfoProvider);
            ref.invalidate(pragasWithPlantaInfoProvider);
          },
          tooltip: 'Atualizar',
        ),
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
            ) ??
            const SizedBox.shrink(),
      ],
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome comum, científico ou pseudo nomes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          // Content
          Expanded(
            child: pragasAsync.when(
              data: (pragas) {
                final pragasWithInfo = pragasWithInfoAsync.asData?.value ?? {};
                final pragasWithPlantaInfo =
                    pragasWithPlantaInfoAsync.asData?.value ?? {};

                return _buildDataTable(
                  context,
                  ref,
                  pragas,
                  pragasWithInfo,
                  pragasWithPlantaInfo,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildError(context, ref, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  List<Praga> _filterPragas(List<Praga> pragas) {
    if (_searchQuery.isEmpty) return pragas;

    return pragas.where((praga) {
      final nomeComum = praga.nomeComum.toLowerCase();
      final nomeCientifico = praga.nomeCientifico.toLowerCase();
      final nomesSecundarios = praga.nomesSecundarios?.toLowerCase() ?? '';

      return nomeComum.contains(_searchQuery) ||
          nomeCientifico.contains(_searchQuery) ||
          nomesSecundarios.contains(_searchQuery);
    }).toList();
  }

  Widget _buildDataTable(
    BuildContext context,
    WidgetRef ref,
    List<Praga> pragas,
    Set<String> pragasWithInfo,
    Set<String> pragasWithPlantaInfo,
  ) {
    final filteredPragas = _filterPragas(pragas);
    final authState = ref.watch(authProvider);
    final canWrite = authState.asData?.value?.canWrite ?? false;

    if (filteredPragas.isEmpty) {
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
              _searchQuery.isNotEmpty
                  ? 'Nenhuma praga encontrada para "$_searchQuery"'
                  : 'Nenhuma praga cadastrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Cadastre a primeira praga para começar',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(pragasProvider.notifier).refresh();
        ref.invalidate(pragasWithInfoProvider);
        ref.invalidate(pragasWithPlantaInfoProvider);
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
            columns: [
              const DataColumn(
                label: Text(
                  'Nome Científico',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Praga',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Pseudo Nomes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Tipo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Info',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'img',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (canWrite)
                const DataColumn(
                  label: Text(
                    'Ações',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
            rows: filteredPragas.map((praga) {
              final hasInfo = pragasWithInfo.contains(praga.id) ||
                  pragasWithPlantaInfo.contains(praga.id);

              return DataRow(
                cells: [
                  // Nome Científico (clickable link)
                  DataCell(
                    InkWell(
                      onTap: () => _navigateToDetails(context, praga.id),
                      child: Text(
                        praga.nomeCientifico,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  // Nome Comum (Praga)
                  DataCell(Text(praga.nomeComum)),
                  // Pseudo Nomes
                  DataCell(
                    Text(
                      praga.nomesSecundarios ?? '-',
                      style: TextStyle(
                        color: praga.nomesSecundarios != null
                            ? null
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  // Tipo (badge colorido)
                  DataCell(_buildTipoBadge(praga.tipoPraga)),
                  // Info indicator
                  DataCell(_buildInfoIndicator(hasInfo)),
                  // Image indicator
                  DataCell(_buildImageIndicator(praga.imageUrl)),
                  // Ações
                  if (canWrite)
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: Colors.blue,
                        onPressed: () => _navigateToEdit(context, praga.id),
                        tooltip: 'Editar',
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

  Widget _buildTipoBadge(TipoPraga? tipo) {
    if (tipo == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '-',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tipo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: tipo.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tipo.icon,
            size: 14,
            color: tipo.color,
          ),
          const SizedBox(width: 4),
          Text(
            tipo.descricao,
            style: TextStyle(
              fontSize: 12,
              color: tipo.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIndicator(bool hasInfo) {
    if (hasInfo) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 20,
      );
    }
    return Icon(
      Icons.remove_circle_outline,
      color: Colors.grey[300],
      size: 20,
    );
  }

  Widget _buildImageIndicator(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return const Icon(
        Icons.image,
        color: Colors.grey,
        size: 20,
      );
    }
    return Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey[300],
      size: 20,
    );
  }

  void _navigateToDetails(BuildContext context, String id) {
    Navigator.of(context).pushNamed(
      '/pragas/details',
      arguments: {'id': id},
    );
  }

  void _navigateToEdit(BuildContext context, String id) {
    Navigator.of(context).pushNamed(
      '/pragas/edit',
      arguments: {'id': id},
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
}
