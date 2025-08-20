import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/plant.dart';
import '../../providers/plant_details_provider.dart';
import '../../providers/plant_task_provider.dart';
import 'plant_details_controller.dart';
import 'plant_image_section.dart';
import 'plant_info_section.dart';
import 'plant_care_section.dart';
import 'plant_tasks_section.dart';
import 'plant_notes_section.dart';
import '../../../../../core/theme/colors.dart';

/// Widget principal da tela de detalhes da planta
/// Responsável apenas pela estrutura visual e coordenação dos componentes
class PlantDetailsView extends StatefulWidget {
  final String plantId;

  const PlantDetailsView({
    super.key,
    required this.plantId,
  });

  @override
  State<PlantDetailsView> createState() => _PlantDetailsViewState();
}

class _PlantDetailsViewState extends State<PlantDetailsView>
    with TickerProviderStateMixin {
  late PlantDetailsController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Inicializar controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlantDetailsProvider>();
      _controller = PlantDetailsController(
        context: context,
        provider: provider,
      );
      _controller.loadPlant(widget.plantId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          // Estados de loading e erro
          if (provider.isLoading && provider.plant == null) {
            return _buildLoadingState(context);
          }

          if (provider.hasError && provider.plant == null) {
            return _buildErrorState(context, provider.errorMessage);
          }

          final plant = provider.plant;
          if (plant == null) {
            return _buildLoadingState(context);
          }

          // Tela principal com a planta carregada
          return _buildMainContent(context, plant);
        },
      ),
      floatingActionButton: Consumer<PlantDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.plant == null) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: () => _controller.showEditOptions(provider.plant!),
            backgroundColor: PlantisColors.primary,
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando planta...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar planta',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Erro desconhecido',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _controller.refresh(widget.plantId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _controller.goBack(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Plant plant) {
    return CustomScrollView(
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
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(context, plant),
                    _buildTasksTab(context, plant),
                    _buildCareTab(context, plant),
                    _buildNotesTab(context, plant),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
        onPressed: () => _controller.goBack(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
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
          onPressed: () => _controller.showMoreOptions(plant),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
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
        background: PlantImageSection(
          plant: plant,
          onEditImages: () {
            // TODO: Implementar navegação para edição de imagens
          },
        ),
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
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Visão Geral',
          ),
          Tab(
            icon: Icon(Icons.task_alt),
            text: 'Tarefas',
          ),
          Tab(
            icon: Icon(Icons.spa),
            text: 'Cuidados',
          ),
          Tab(
            icon: Icon(Icons.comment),
            text: 'Observações',
          ),
        ],
        indicator: BoxDecoration(
          color: PlantisColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: PlantisColors.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PlantInfoSection(plant: plant),
    );
  }

  Widget _buildTasksTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<PlantTaskProvider>(
        builder: (context, taskProvider, child) {
          return PlantTasksSection(plant: plant);
        },
      ),
    );
  }

  Widget _buildCareTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PlantCareSection(plant: plant),
    );
  }

  Widget _buildNotesTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PlantNotesSection(plant: plant),
    );
  }
}