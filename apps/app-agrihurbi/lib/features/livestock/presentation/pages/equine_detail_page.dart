import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/equine_entity.dart';
import '../providers/equines_provider.dart';

/// Página de detalhes completos do equino com visualização rica
///
/// Apresenta todas as informações do equino de forma organizada e visualmente
/// atraente, seguindo padrões Material 3 e fornecendo navegação para edição
class EquineDetailPage extends ConsumerStatefulWidget {
  const EquineDetailPage({
    super.key,
    required this.equineId,
  });

  /// ID do equino a ser exibido
  final String equineId;

  @override
  ConsumerState<EquineDetailPage> createState() => _EquineDetailPageState();
}

class _EquineDetailPageState extends ConsumerState<EquineDetailPage> {
  final _scrollController = ScrollController();
  EquineEntity? _equine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquineDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEquineDetails() async {
    final provider = ref.read(equinesProviderProvider);
    var equine = provider.getEquineById(widget.equineId);
    if (equine == null) {
      await provider.loadEquineById(widget.equineId);
      equine = provider.selectedEquine;
    }

    if (mounted) {
      setState(() {
        _equine = equine;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _equine == null
              ? _buildErrorState()
              : _buildDetailContent(),
      floatingActionButton: _equine != null
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToEdit(),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
            )
          : null,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Equino não encontrado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Não foi possível carregar os detalhes do equino',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildCharacteristicsCard(),
              const SizedBox(height: 16),
              _buildPhysicalInfoCard(),
              const SizedBox(height: 16),
              _buildHistoryCard(),
              const SizedBox(height: 16),
              _buildMetadataCard(),
              const SizedBox(height: 80), // Space for FAB
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _equine!.commonName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: _equine!.imageUrls.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _equine!.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlaceholderImage(),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Compartilhar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.pets,
        size: 80,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _equine!.commonName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Equino',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _equine!.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _equine!.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    _equine!.isActive ? 'ATIVO' : 'INATIVO',
                    style: TextStyle(
                      color: _equine!.isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_equine!.registrationId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.badge,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${_equine!.registrationId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('País de Origem', _equine!.originCountry, Icons.public),
            _buildInfoRow(
              'Uso Principal',
              _equine!.primaryUse.displayName,
              Icons.work,
            ),
            if (_equine!.geneticInfluences.isNotEmpty)
              _buildInfoRow(
                'Influências Genéticas',
                _equine!.geneticInfluences,
                Icons.biotech,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Temperamento',
              _equine!.temperament.displayName,
              Icons.psychology,
            ),
            _buildInfoRow(
              'Pelagem',
              _equine!.coat.displayName,
              Icons.palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Físicas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPhysicalMetric(
                    'Altura',
                    _equine!.height,
                    Icons.height,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhysicalMetric(
                    'Peso',
                    _equine!.weight,
                    Icons.monitor_weight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'Não informado',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: value.isEmpty
                      ? Theme.of(context).colorScheme.outline
                      : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    if (_equine!.history.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'História da Raça',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              _equine!.history,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Sistema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_equine!.createdAt != null)
              _buildInfoRow(
                'Criado em',
                dateFormat.format(_equine!.createdAt!),
                Icons.add_circle_outline,
              ),
            if (_equine!.updatedAt != null)
              _buildInfoRow(
                'Última atualização',
                dateFormat.format(_equine!.updatedAt!),
                Icons.update,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareEquine();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _shareEquine() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidade de compartilhamento em desenvolvimento'),
        action: SnackBarAction(
          label: 'Copiar Texto',
          onPressed: () {
          },
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o equino "${_equine!.commonName}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEquine();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteEquine() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de exclusão de equinos em desenvolvimento'),
      ),
    );
    context.pop(); // Return to previous screen
  }

  void _navigateToEdit() {
    context.push('/home/livestock/equines/edit/${_equine!.id}');
  }
}
