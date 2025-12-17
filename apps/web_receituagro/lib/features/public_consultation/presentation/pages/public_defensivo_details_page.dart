import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../defensivos/domain/entities/defensivo.dart';
import '../../../defensivos/domain/entities/diagnostico.dart';
import '../providers/public_defensivos_providers.dart';

class PublicDefensivoDetailsPage extends ConsumerWidget {
  final String id;

  const PublicDefensivoDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defensivoAsync = ref.watch(publicDefensivoDetailsProvider(id));
    final diagnosticosAsync = ref.watch(publicDefensivoDiagnosticosProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Defensivo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: defensivoAsync.when(
        data: (defensivo) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      defensivo.nomeComum,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Informações Gerais
                    _SectionTitle(title: 'Informações Gerais'),
                    const SizedBox(height: 8),
                    _InfoGeraisCard(defensivo: defensivo),
                    const SizedBox(height: 24),

                    // Ingredientes Ativos
                    _SectionTitle(title: 'Ingredientes Ativos'),
                    const SizedBox(height: 8),
                    _IngredientesAtivosCard(defensivo: defensivo),
                    const SizedBox(height: 24),

                    // Informações Adicionais
                    _SectionTitle(title: 'Informações Adicionais'),
                    const SizedBox(height: 8),
                    _InfoAdicionaisCard(defensivo: defensivo),
                    const SizedBox(height: 24),

                    // Diagnósticos (Culturas e Pragas)
                    _SectionTitle(title: 'Diagnósticos (Culturas e Pragas)'),
                    const SizedBox(height: 8),
                    diagnosticosAsync.when(
                      data: (diagnosticos) => _DiagnosticosCard(diagnosticos: diagnosticos),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Erro ao carregar diagnósticos: $e'),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar defensivo: $e')),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _InfoGeraisCard extends StatelessWidget {
  final Defensivo defensivo;

  const _InfoGeraisCard({required this.defensivo});

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'label': 'Nome Técnico', 'value': defensivo.nomeTecnico},
      {'label': 'Fabricante', 'value': defensivo.fabricante},
      {'label': 'Registro MAPA', 'value': defensivo.mapa},
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fields.length,
          itemBuilder: (context, index) {
            final item = fields[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['label']}:',
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item['value'] ?? '-'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IngredientesAtivosCard extends StatelessWidget {
  final Defensivo defensivo;

  const _IngredientesAtivosCard({required this.defensivo});

  @override
  Widget build(BuildContext context) {
    // Simple split for display purposes, assuming format "Ingrediente1+Ingrediente2"
    final ingredientes = defensivo.ingredienteAtivo.split('+');
    final dosagens = defensivo.quantProduto?.split('+') ?? List.filled(ingredientes.length, '-');

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(child: Text('Ingrediente', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Concentração', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ingredientes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(ingredientes[index].trim())),
                      Expanded(child: Text(index < dosagens.length ? dosagens[index].trim() : '-')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoAdicionaisCard extends StatelessWidget {
  final Defensivo defensivo;

  const _InfoAdicionaisCard({required this.defensivo});

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'label': 'Toxicologia', 'value': defensivo.toxico},
      {'label': 'Inflamável', 'value': defensivo.inflamavel},
      {'label': 'Corrosivo', 'value': defensivo.corrosivo},
      {'label': 'Modo de Ação', 'value': defensivo.modoAcao},
      {'label': 'Classe Agronômica', 'value': defensivo.classeAgronomica},
      {'label': 'Classe Ambiental', 'value': defensivo.classAmbiental},
      {'label': 'Formulação', 'value': defensivo.formulacao},
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fields.length,
          itemBuilder: (context, index) {
            final item = fields[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['label']}:',
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item['value'] ?? '-'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DiagnosticosCard extends StatelessWidget {
  final List<Diagnostico> diagnosticos;

  const _DiagnosticosCard({required this.diagnosticos});

  @override
  Widget build(BuildContext context) {
    if (diagnosticos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhum diagnóstico cadastrado.'),
        ),
      );
    }

    // Group by Cultura
    final Map<String, List<Diagnostico>> grouped = {};
    for (var d in diagnosticos) {
      final cultura = d.culturaNome ?? 'Outras';
      if (!grouped.containsKey(cultura)) {
        grouped[cultura] = [];
      }
      grouped[cultura]!.add(d);
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grouped.keys.length,
          separatorBuilder: (context, index) => const Divider(height: 32),
          itemBuilder: (context, index) {
            final cultura = grouped.keys.elementAt(index);
            final items = grouped[cultura]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cultura,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.pragaNomeComum ?? 'Praga desconhecida',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                if (item.pragaNomeCientifico != null)
                                  Text(
                                    item.pragaNomeCientifico!,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Dose: ${item.dsMin ?? '-'} - ${item.dsMax ?? '-'} ${item.um ?? ''}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
