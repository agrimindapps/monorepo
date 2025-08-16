import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/plant.dart';
import '../providers/plant_details_provider.dart';
import '../widgets/plant_details_info.dart';
import '../widgets/plant_details_care.dart';
import '../widgets/plant_details_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/image_service.dart';

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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Erro desconhecido',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

          return DefaultTabController(
            length: 4,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, plant),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildTabBar(context),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: TabBarView(
                          children: [
                            _buildVisaoGeralTab(context, plant),
                            _buildTarefasTab(context, plant),
                            _buildCuidadosTab(context, plant),
                            _buildComentariosTab(context, plant),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
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
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
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
          child: plant.hasImage && plant.primaryImageUrl != null
              ? ImageService().buildImagePreview(
                  plant.primaryImageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.eco,
                  size: 80,
                  color: PlantisColors.primary.withValues(alpha: 0.3),
                ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    
    if (plant.imageUrls.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fotos da Planta',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plant.imageUrls.length > 1)
                TextButton(
                  onPressed: () => _showFullGallery(context, plant),
                  child: Text(
                    'Ver todas (${plant.imageUrls.length})',
                    style: TextStyle(
                      color: PlantisColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: plant.imageUrls.length > 3 ? 3 : plant.imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => _showImagePreview(context, plant.imageUrls, index),
                    child: Hero(
                      tag: 'plant_image_$index',
                      child: Container(
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ImageService().buildImagePreview(
                                plant.imageUrls[index],
                                width: 160,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              if (index == 2 && plant.imageUrls.length > 3)
                                Container(
                                  color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.6),
                                  child: Center(
                                    child: Text(
                                      '+${plant.imageUrls.length - 3}',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Theme.of(context).colorScheme.scrim,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Hero(
                    tag: 'plant_image_$index',
                    child: InteractiveViewer(
                      child: ImageService().buildImagePreview(
                        imageUrls[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullGallery(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Galeria de Fotos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: plant.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showImagePreview(context, plant.imageUrls, index);
                    },
                    child: Hero(
                      tag: 'plant_image_gallery_$index',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageService().buildImagePreview(
                          plant.imageUrls[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Visão Geral'),
          Tab(text: 'Tarefas'),
          Tab(text: 'Cuidados'),
          Tab(text: 'Comentários'),
        ],
      ),
    );
  }

  Widget _buildVisaoGeralTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          PlantDetailsInfo(plant: plant),
          if (plant.hasImage) ...[
            const SizedBox(height: 24),
            _buildImageGallery(context, plant),
          ],
        ],
      ),
    );
  }

  Widget _buildTarefasTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tarefas da Planta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistema de tarefas em desenvolvimento.\nEm breve você poderá gerenciar todas as tarefas relacionadas à ${plant.name}.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuidadosTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          PlantDetailsConfig(plant: plant),
          const SizedBox(height: 16),
          PlantDetailsCare(plant: plant),
        ],
      ),
    );
  }

  Widget _buildComentariosTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.comment,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Comentários e Observações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistema de comentários em desenvolvimento.\nEm breve você poderá adicionar observações e notas sobre ${plant.name}.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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