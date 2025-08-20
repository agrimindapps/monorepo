import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/plant_task.dart';
import '../providers/plant_details_provider.dart';
import '../providers/plant_task_provider.dart';
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark 
        ? const Color(0xFF1C1C1E) 
        : theme.colorScheme.surface,
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
                      const SizedBox(height: 16),
                      _buildTabBar(context),
                      const SizedBox(height: 16),
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

  Widget _buildNotesCard(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark 
              ? const Color(0xFF2C2C2E)
              : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
                blurRadius: theme.brightness == Brightness.dark ? 8 : 12,
                offset: const Offset(0, 4),
                spreadRadius: theme.brightness == Brightness.dark ? 0 : 2,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.note_outlined,
                  size: 20,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  plant.notes!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        color: theme.brightness == Brightness.dark 
          ? const Color(0xFF2C2C2E)
          : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.08),
            blurRadius: theme.brightness == Brightness.dark ? 8 : 12,
            offset: const Offset(0, 4),
            spreadRadius: theme.brightness == Brightness.dark ? 0 : 2,
          ),
        ],
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline, size: 20),
            text: 'Visão Geral',
          ),
          Tab(
            icon: Icon(Icons.task_alt, size: 20),
            text: 'Tarefas',
          ),
          Tab(
            icon: Icon(Icons.spa, size: 20),
            text: 'Cuidados',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble_outline, size: 20),
            text: 'Comentários',
          ),
        ],
      ),
    );
  }

  Widget _buildVisaoGeralTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PlantDetailsInfo(plant: plant),
          
          // Card de Observações separado
          if (plant.notes != null && plant.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildNotesCard(context, plant),
          ],
          
          if (plant.hasImage) ...[
            const SizedBox(height: 24),
            _buildImageGallery(context, plant),
          ],
        ],
      ),
    );
  }

  Widget _buildTarefasTab(BuildContext context, Plant plant) {
    return Consumer<PlantTaskProvider>(
      builder: (context, taskProvider, child) {
        // Generate tasks for plant if not already generated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (taskProvider.getTasksForPlant(plant.id).isEmpty && plant.config != null) {
            taskProvider.generateTasksForPlant(plant);
          }
        });

        final tasks = taskProvider.getTasksForPlant(plant.id);
        final pendingTasks = taskProvider.getPendingTasksForPlant(plant.id);
        final upcomingTasks = taskProvider.getUpcomingTasksForPlant(plant.id);
        final overdueTasks = taskProvider.getOverdueTasksForPlant(plant.id);

        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tasks.isEmpty) {
          return _buildEmptyTasksState(context, plant);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Summary Cards
              _buildTaskSummaryCards(context, overdueTasks, upcomingTasks, pendingTasks),
              
              const SizedBox(height: 24),
              
              // Overdue Tasks
              if (overdueTasks.isNotEmpty) ...[
                _buildTaskSection(
                  context,
                  title: 'Tarefas Atrasadas',
                  tasks: overdueTasks,
                  color: Colors.red,
                  icon: Icons.warning,
                ),
                const SizedBox(height: 24),
              ],
              
              // Upcoming Tasks
              if (upcomingTasks.isNotEmpty) ...[
                _buildTaskSection(
                  context,
                  title: 'Próximas Tarefas',
                  tasks: upcomingTasks,
                  color: Colors.orange,
                  icon: Icons.schedule,
                ),
                const SizedBox(height: 24),
              ],
              
              // All Pending Tasks
              _buildTaskSection(
                context,
                title: 'Todas as Tarefas',
                tasks: pendingTasks,
                color: PlantisColors.primary,
                icon: Icons.task_alt,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCuidadosTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
    return _CommentsTab(plant: plant);
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

  Widget _buildEmptyTasksState(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                  blurRadius: theme.brightness == Brightness.dark ? 8 : 12,
                  offset: const Offset(0, 4),
                  spreadRadius: theme.brightness == Brightness.dark ? 0 : 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.eco,
                  size: 80,
                  color: PlantisColors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua ${plant.displayName} está em dia!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Não há tarefas pendentes no momento. Continue cuidando bem da sua planta!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummaryCards(BuildContext context, List<PlantTask> overdueTasks, List<PlantTask> upcomingTasks, List<PlantTask> pendingTasks) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Em atraso',
            overdueTasks.length.toString(),
            Colors.red,
            Icons.schedule,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Próximas',
            upcomingTasks.length.toString(),
            Colors.orange,
            Icons.upcoming,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Pendentes',
            pendingTasks.length.toString(),
            PlantisColors.primary,
            Icons.pending_actions,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String count, Color color, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, {
    required String title,
    required List<PlantTask> tasks,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final taskProvider = context.read<PlantTaskProvider>();
    
    if (tasks.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tasks.length.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => _buildTaskCard(context, task, taskProvider)),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, PlantTask task, PlantTaskProvider taskProvider) {
    final theme = Theme.of(context);
    final color = _getTaskColor(task);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.08),
            blurRadius: theme.brightness == Brightness.dark ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTaskIcon(task.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.description ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (task.status != TaskStatus.completed)
            IconButton(
              onPressed: () => taskProvider.completeTask(task.plantId, task.id),
              icon: Icon(
                Icons.check_circle_outline,
                color: PlantisColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTaskColor(PlantTask task) {
    switch (task.status) {
      case TaskStatus.overdue:
        return Colors.red;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.pending:
        if (task.isDueToday || task.isDueSoon) {
          return Colors.orange;
        }
        return PlantisColors.primary;
    }
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.eco;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.sunlightCheck:
        return Icons.wb_sunny;
      case TaskType.pestInspection:
        return Icons.bug_report;
      case TaskType.replanting:
        return Icons.grass;
    }
  }
}

class _CommentsTab extends StatefulWidget {
  final Plant plant;

  const _CommentsTab({
    required this.plant,
  });

  @override
  State<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<_CommentsTab> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _comments = []; // TODO: Integrar com sistema real de comentários

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _comments.add(text);
        _commentController.clear();
      });
      _focusNode.unfocus();
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : theme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: const Color(0xFF55D85A),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Comentários',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          
          // Input Field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: isDark 
                ? Border.all(color: Colors.grey.withValues(alpha: 0.1))
                : null,
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
                  blurRadius: isDark ? 6 : 8,
                  offset: const Offset(0, 2),
                  spreadRadius: isDark ? 0 : 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Adicionar comentário...',
                          hintStyle: TextStyle(
                            color: isDark 
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.grey[600],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        onChanged: (value) {
                          setState(() {}); // Para atualizar o contador
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _commentController.text.trim().isNotEmpty ? _addComment : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _commentController.text.trim().isNotEmpty 
                            ? const Color(0xFF55D85A)
                            : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: _commentController.text.trim().isNotEmpty 
                            ? Colors.white
                            : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_commentController.text.length}/500',
                      style: TextStyle(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Content Area
          Expanded(
            child: _comments.isEmpty 
              ? _buildEmptyState(context, isDark)
              : _buildCommentsList(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF2C2C2E)
                : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: isDark 
                ? Border.all(color: Colors.grey.withValues(alpha: 0.1))
                : null,
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isDark ? 4 : 6,
                  offset: const Offset(0, 2),
                  spreadRadius: isDark ? 0 : 1,
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: isDark 
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum comentário ainda',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Adicione suas observações e\nacompanhe o desenvolvimento da sua\nplanta!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark 
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isDark 
              ? Border.all(color: Colors.grey.withValues(alpha: 0.1))
              : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: isDark 
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
                blurRadius: isDark ? 4 : 6,
                offset: const Offset(0, 2),
                spreadRadius: isDark ? 0 : 1,
              ),
            ],
          ),
          child: Text(
            _comments[index],
            style: TextStyle(
              color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}
