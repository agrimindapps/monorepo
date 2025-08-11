import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/plant.dart';
import '../providers/plant_details_provider.dart';
import '../widgets/plant_details_header.dart';
import '../widgets/plant_details_info.dart';
import '../widgets/plant_details_care.dart';
import '../widgets/plant_details_config.dart';
import '../../../../core/theme/colors.dart';

class PlantDetailsPage extends StatefulWidget {
  final String plantId;

  const PlantDetailsPage({
    super.key,
    required this.plantId,
  });

  @override
  State<PlantDetailsPage> createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage> {
  late PlantDetailsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<PlantDetailsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadPlant(widget.plantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PlantDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.plant == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.hasError && provider.plant == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Erro desconhecido',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _provider.loadPlant(widget.plantId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          final plant = provider.plant;
          if (plant == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, plant),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlantDetailsHeader(plant: plant),
                    const SizedBox(height: 24),
                    PlantDetailsInfo(plant: plant),
                    const SizedBox(height: 24),
                    PlantDetailsCare(plant: plant),
                    const SizedBox(height: 24),
                    PlantDetailsConfig(plant: plant),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<PlantDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.plant == null) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: () => _showEditOptions(context, provider.plant!),
            child: const Icon(Icons.edit),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showMoreOptions(context, plant),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PlantisColors.primary.withValues(alpha: 0.1),
                PlantisColors.primaryLight.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: plant.imageBase64 != null
              ? Container() // TODO: Implement image display
              : Icon(
                  Icons.eco,
                  size: 80,
                  color: PlantisColors.primary.withValues(alpha: 0.3),
                ),
        ),
      ),
    );
  }

  void _showEditOptions(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar planta'),
              onTap: () {
                Navigator.pop(context);
                context.push('/plants/form/${plant.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Alterar foto'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement photo change
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Registrar cuidado'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement care registration
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[400]),
              title: Text(
                'Excluir planta',
                style: TextStyle(color: Colors.red[400]),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir planta'),
        content: const Text(
          'Tem certeza que deseja excluir esta planta? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _deletePlant(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deletePlant(BuildContext context) async {
    Navigator.pop(context); // Close dialog
    
    final success = await _provider.deletePlant();
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Return to previous page
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_provider.errorMessage ?? 'Erro ao excluir planta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}