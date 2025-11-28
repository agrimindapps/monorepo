import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../defensivos/domain/entities/diagnostico.dart';
import '../../../defensivos/presentation/providers/defensivos_providers.dart';
import '../../../culturas/presentation/providers/culturas_providers.dart';
import '../providers/pragas_providers.dart';

/// Widget to display list of defensivos/diagnosticos for a praga
class PragaDiagnosticosList extends ConsumerStatefulWidget {
  final String pragaId;

  const PragaDiagnosticosList({
    super.key,
    required this.pragaId,
  });

  @override
  ConsumerState<PragaDiagnosticosList> createState() =>
      _PragaDiagnosticosListState();
}

class _PragaDiagnosticosListState extends ConsumerState<PragaDiagnosticosList> {
  String? _selectedCulturaId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final culturasAsync = ref.watch(culturasProvider);
    final diagnosticosAsync = ref.watch(diagnosticosByPragaProvider(widget.pragaId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Defensivos Indicados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lista de defensivos agrícolas indicados para controle desta praga',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Filters
        Row(
          children: [
            // Cultura filter dropdown
            Expanded(
              child: culturasAsync.when(
                data: (culturas) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCulturaId,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por Cultura',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas as culturas'),
                      ),
                      ...culturas.map((cultura) => DropdownMenuItem<String>(
                            value: cultura.id,
                            child: Text(cultura.nomeComum),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCulturaId = value;
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erro ao carregar culturas'),
              ),
            ),
            const SizedBox(width: 16),

            // Search field
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar defensivo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Diagnosticos list
        Expanded(
          child: diagnosticosAsync.when(
            data: (diagnosticos) {
              // Filter by cultura if selected
              var filtered = diagnosticos;
              if (_selectedCulturaId != null) {
                filtered = filtered
                    .where((d) => d.culturaId == _selectedCulturaId)
                    .toList();
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCulturaId != null
                            ? 'Nenhum defensivo encontrado para esta cultura'
                            : 'Nenhum defensivo indicado para esta praga',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final diagnostico = filtered[index];
                  return _DiagnosticoListTile(
                    diagnostico: diagnostico,
                    searchQuery: _searchQuery,
                    onTap: () => _showDiagnosticoDetails(context, diagnostico),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar diagnósticos: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDiagnosticoDetails(BuildContext context, Diagnostico diagnostico) {
    showDialog(
      context: context,
      builder: (context) => _DiagnosticoDetailsDialog(diagnostico: diagnostico),
    );
  }
}

/// List tile for a single diagnostico
class _DiagnosticoListTile extends ConsumerWidget {
  final Diagnostico diagnostico;
  final String searchQuery;
  final VoidCallback onTap;

  const _DiagnosticoListTile({
    required this.diagnostico,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defensivosAsync = ref.watch(defensivosProvider);

    return defensivosAsync.when(
      data: (defensivos) {
        final defensivo = defensivos
            .where((d) => d.id == diagnostico.defensivoId)
            .firstOrNull;

        if (defensivo == null) {
          return const SizedBox.shrink();
        }

        // Filter by search query
        if (searchQuery.isNotEmpty) {
          final searchableText =
              '${defensivo.nomeComum} ${defensivo.ingredienteAtivo}'
                  .toLowerCase();
          if (!searchableText.contains(searchQuery)) {
            return const SizedBox.shrink();
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.science, color: Colors.blue),
            ),
            title: Text(
              defensivo.nomeComum,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingrediente: ${defensivo.ingredienteAtivo}'),
                if (diagnostico.dsMin != null || diagnostico.dsMax != null)
                  Text(
                    'Dosagem: ${_formatDosagem(diagnostico)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        );
      },
      loading: () => const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Carregando...'),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatDosagem(Diagnostico d) {
    if (d.dsMin != null && d.dsMax != null) {
      return '${d.dsMin} - ${d.dsMax} ${d.um ?? ''}';
    } else if (d.dsMin != null) {
      return '${d.dsMin} ${d.um ?? ''}';
    } else if (d.dsMax != null) {
      return '${d.dsMax} ${d.um ?? ''}';
    }
    return 'Não especificada';
  }
}

/// Dialog showing detailed diagnostico information
class _DiagnosticoDetailsDialog extends ConsumerWidget {
  final Diagnostico diagnostico;

  const _DiagnosticoDetailsDialog({required this.diagnostico});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defensivosAsync = ref.watch(defensivosProvider);
    final culturasAsync = ref.watch(culturasProvider);

    return AlertDialog(
      title: const Text('Detalhes do Defensivo'),
      content: SizedBox(
        width: 500,
        child: defensivosAsync.when(
          data: (defensivos) {
            final defensivo = defensivos
                .where((d) => d.id == diagnostico.defensivoId)
                .firstOrNull;

            if (defensivo == null) {
              return const Text('Defensivo não encontrado');
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow('Nome Comercial', defensivo.nomeComum),
                  _buildInfoRow(
                      'Ingrediente Ativo', defensivo.ingredienteAtivo),
                  _buildInfoRow('Classe', defensivo.classeAgronomica ?? 'Não especificada'),

                  // Cultura
                  culturasAsync.when(
                    data: (culturas) {
                      final cultura = culturas
                          .where((c) => c.id == diagnostico.culturaId)
                          .firstOrNull;
                      return _buildInfoRow(
                          'Cultura', cultura?.nomeComum ?? 'Não especificada');
                    },
                    loading: () => _buildInfoRow('Cultura', 'Carregando...'),
                    error: (_, __) => _buildInfoRow('Cultura', 'Erro'),
                  ),

                  const Divider(height: 24),

                  // Dosagem
                  const Text(
                    'Dosagem',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Dose',
                    _formatDosagem(diagnostico),
                  ),

                  // Aplicação Terrestre
                  if (diagnostico.minAplicacaoT != null ||
                      diagnostico.maxAplicacaoT != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Aplicação Terrestre',
                      _formatAplicacaoTerrestre(diagnostico),
                    ),
                  ],

                  // Aplicação Aérea
                  if (diagnostico.minAplicacaoA != null ||
                      diagnostico.maxAplicacaoA != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Aplicação Aérea',
                      _formatAplicacaoAerea(diagnostico),
                    ),
                  ],

                  // Intervalos
                  if (diagnostico.intervalo != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Intervalo de Segurança',
                      '${diagnostico.intervalo} dias',
                    ),
                  ],

                  if (diagnostico.intervalo2 != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Intervalo de Reentrada',
                      '${diagnostico.intervalo2}',
                    ),
                  ],

                  // Época de aplicação
                  if (diagnostico.epocaAplicacao != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Época de Aplicação',
                      diagnostico.epocaAplicacao!,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Erro: $error'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to defensivo details
            Navigator.pushNamed(
              context,
              '/defensivo',
              arguments: {'id': diagnostico.defensivoId},
            );
          },
          child: const Text('Ver Defensivo'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDosagem(Diagnostico d) {
    if (d.dsMin != null && d.dsMax != null) {
      return '${d.dsMin} - ${d.dsMax} ${d.um ?? ''}';
    } else if (d.dsMin != null) {
      return '${d.dsMin} ${d.um ?? ''}';
    } else if (d.dsMax != null) {
      return '${d.dsMax} ${d.um ?? ''}';
    }
    return 'Não especificada';
  }

  String _formatAplicacaoTerrestre(Diagnostico d) {
    if (d.minAplicacaoT != null && d.maxAplicacaoT != null) {
      return '${d.minAplicacaoT} - ${d.maxAplicacaoT} ${d.umT ?? 'L/ha'}';
    } else if (d.minAplicacaoT != null) {
      return '${d.minAplicacaoT} ${d.umT ?? 'L/ha'}';
    } else if (d.maxAplicacaoT != null) {
      return '${d.maxAplicacaoT} ${d.umT ?? 'L/ha'}';
    }
    return 'Não especificada';
  }

  String _formatAplicacaoAerea(Diagnostico d) {
    if (d.minAplicacaoA != null && d.maxAplicacaoA != null) {
      return '${d.minAplicacaoA} - ${d.maxAplicacaoA} ${d.umA ?? 'L/ha'}';
    } else if (d.minAplicacaoA != null) {
      return '${d.minAplicacaoA} ${d.umA ?? 'L/ha'}';
    } else if (d.maxAplicacaoA != null) {
      return '${d.maxAplicacaoA} ${d.umA ?? 'L/ha'}';
    }
    return 'Não especificada';
  }
}
