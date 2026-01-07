import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/recent_access_provider.dart';
import '../../../../core/widgets/internal_page_layout.dart';
import '../../domain/entities/tipo_praga.dart';
import '../providers/praga_detalhes_provider.dart';
import '../widgets/praga_info_form.dart';
import '../widgets/planta_info_form.dart';
import '../widgets/praga_diagnosticos_list.dart';

/// Praga Detalhes Page - View/Edit with Tabs
class PragaDetalhesPage extends ConsumerStatefulWidget {
  final String pragaId;

  const PragaDetalhesPage({
    super.key,
    required this.pragaId,
  });

  @override
  ConsumerState<PragaDetalhesPage> createState() => _PragaDetalhesPageState();
}

class _PragaDetalhesPageState extends ConsumerState<PragaDetalhesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load praga data and register access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pragaDetalhesProvider.notifier).loadPraga(widget.pragaId);
    });
  }

  /// Register access when praga data is loaded
  void _registerAccess(dynamic praga) {
    if (praga != null) {
      ref.read(recentAccessProvider.notifier).addPragaAccess(praga);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detalhesState = ref.watch(pragaDetalhesProvider);
    final praga = detalhesState.praga;

    // Register access when praga is loaded (only once)
    ref.listen<PragaDetalhesState>(
      pragaDetalhesProvider,
      (previous, next) {
        if (previous?.praga == null && next.praga != null) {
          _registerAccess(next.praga!);
        }
      },
    );

    return InternalPageLayout(
      title: praga?.nomeComum ?? 'Detalhes da Praga',
      actions: [
        // Edit toggle button
        if (!detalhesState.isLoading && praga != null) ...[
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            tooltip: _isEditing ? 'Cancelar edição' : 'Editar',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          const SizedBox(width: 8),
          // Edit full praga button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/pragas/edit',
                arguments: {'id': widget.pragaId},
              );
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('Editar Praga'),
          ),
        ],
      ],
      body: detalhesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detalhesState.error != null
              ? _buildErrorView(detalhesState.error!)
              : praga == null
                  ? const Center(child: Text('Praga não encontrada'))
                  : Column(
                      children: [
                        // Praga header card
                        _buildPragaHeader(praga),

                        // Tabs
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.info_outline),
                                text: 'Informações',
                              ),
                              Tab(
                                icon: Icon(Icons.science),
                                text: 'Diagnósticos',
                              ),
                            ],
                          ),
                        ),

                        // Tab content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Tab 1: Informações
                              _buildInformacoesTab(detalhesState),
                              // Tab 2: Diagnósticos
                              _buildDiagnosticosTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildPragaHeader(dynamic praga) {
    final tipoPraga = praga.tipoPraga ?? TipoPraga.inseto;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: tipoPraga.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: praga.imageUrl != null && praga.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        praga.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(tipoPraga),
                      ),
                    )
                  : _buildPlaceholderIcon(tipoPraga),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tipoPraga.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tipoPraga.icon, size: 16, color: tipoPraga.color),
                        const SizedBox(width: 4),
                        Text(
                          tipoPraga.descricao,
                          style: TextStyle(
                            color: tipoPraga.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nome comum
                  Text(
                    praga.nomeComum,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Nome científico
                  Text(
                    praga.nomeCientifico,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Taxonomia
                  Wrap(
                    spacing: 16,
                    children: [
                      _buildTaxonomyChip('Ordem', praga.ordem),
                      _buildTaxonomyChip('Família', praga.familia),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(TipoPraga tipoPraga) {
    return Center(
      child: Icon(
        tipoPraga.icon,
        size: 64,
        color: tipoPraga.color.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildTaxonomyChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoesTab(PragaDetalhesState state) {
    final praga = state.praga;
    if (praga == null) return const SizedBox.shrink();

    final tipoPraga = praga.tipoPraga ?? TipoPraga.inseto;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show appropriate form based on tipo
              if (tipoPraga.usesPlantaInfo)
                PlantaInfoForm(
                  initialInfo: state.plantaInfo,
                  pragaId: widget.pragaId,
                  readOnly: !_isEditing,
                  onSave: _isEditing
                      ? (info) async {
                          setState(() => _isSaving = true);
                          final result = await ref
                              .read(pragaDetalhesProvider.notifier)
                              .savePlantaInfo(info);

                          setState(() => _isSaving = false);

                          if (mounted) {
                            result.fold(
                              (failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro: ${failure.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Informações salvas com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                setState(() => _isEditing = false);
                              },
                            );
                          }
                        }
                      : null,
                )
              else
                PragaInfoForm(
                  initialInfo: state.pragaInfo,
                  pragaId: widget.pragaId,
                  readOnly: !_isEditing,
                  onSave: _isEditing
                      ? (info) async {
                          setState(() => _isSaving = true);
                          final result = await ref
                              .read(pragaDetalhesProvider.notifier)
                              .savePragaInfo(info);

                          setState(() => _isSaving = false);

                          if (mounted) {
                            result.fold(
                              (failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro: ${failure.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Informações salvas com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                setState(() => _isEditing = false);
                              },
                            );
                          }
                        }
                      : null,
                ),

              // Loading indicator while saving
              if (_isSaving) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticosTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PragaDiagnosticosList(pragaId: widget.pragaId),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(pragaDetalhesProvider.notifier)
                  .loadPraga(widget.pragaId);
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
