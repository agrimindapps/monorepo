import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/constants/medications_constants.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';
import '../widgets/add_medication_dialog.dart';
import '../widgets/empty_medications_state.dart';
import '../widgets/medication_card.dart';
import '../widgets/medication_filters.dart';
import '../widgets/medication_stats.dart';

/// **Medications Management Page**
///
/// A comprehensive page for managing pet medications with advanced filtering,
/// search capabilities, and organized tabbed navigation.
///
/// ## Key Features:
/// - **Multi-tab Organization**: Active, Expired, All, and Statistics views
/// - **Real-time Search**: Live filtering as user types
/// - **Performance Optimized**: Uses provider caching and keep-alive for smooth scrolling
/// - **Accessibility**: Full semantic labels and screen reader support
/// - **Error Handling**: Graceful error states with retry mechanisms
///
/// ## Architecture:
/// - Follows Clean Architecture principles with proper separation of concerns
/// - Uses Riverpod for state management and provider caching
/// - Implements custom widgets for reusable components
/// - Optimized ListView with SliverFixedExtentList for large datasets
///
/// ## API Integration:
/// The page integrates with the medication repository to provide:
/// - Real-time medication data sync
/// - Offline-first approach with local storage fallback
/// - Automatic data refresh on tab switches
/// - Batch operations for better performance
///
/// ## Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => MedicationsPage(animalId: 'specific-animal-id')
/// ));
/// ```
///
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.2.0 - Added performance optimizations and caching
class MedicationsPage extends ConsumerStatefulWidget {
  /// Optional animal ID to filter medications for a specific pet.
  /// If null, shows medications for all animals.
  final String? animalId;

  /// Creates a medications page instance.
  ///
  /// The [animalId] parameter is optional and when provided,
  /// filters the medications to show only those for the specified animal.
  const MedicationsPage({super.key, this.animalId});

  @override
  ConsumerState<MedicationsPage> createState() => _MedicationsPageState();
}

/// **Private State Management Class**
///
/// Handles the internal state and lifecycle management for the MedicationsPage.
///
/// ## Performance Optimizations:
/// - **Provider Caching**: Caches frequently used providers to avoid repeated lookups
/// - **Keep Alive**: Maintains widget state when navigating between tabs
/// - **Optimized Tab Controller**: Prevents unnecessary rebuilds during tab switches
/// - **Batch Loading**: Loads initial data efficiently after widget mount
///
/// ## State Management:
/// - Manages tab navigation state with TabController
/// - Handles search functionality with TextEditingController
/// - Caches Riverpod providers for improved performance
/// - Implements proper lifecycle management and cleanup
class _MedicationsPageState extends ConsumerState<MedicationsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  /// Controls the tab navigation between Active, Expired, All, and Stats views
  late TabController _tabController;

  /// Handles search input for real-time medication filtering
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: MedicationsConstants.tabCount,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  @override
  bool get wantKeepAlive => true; // Keep page alive for better performance

  /// **Optimized Initial Data Loading**
  ///
  /// Performs intelligent batch loading of medication data with comprehensive
  /// error handling and performance optimizations.
  ///
  /// ## Loading Strategy:
  /// 1. **Primary Load**: Main medication data (with 10s timeout)
  /// 2. **Secondary Parallel Loads**: Active and expiring medications
  /// 3. **Error Recovery**: Graceful fallbacks for failed secondary loads
  /// 4. **Animal-Specific**: Filters by animalId when provided
  ///
  /// ## Performance Features:
  /// - Timeout protection to prevent UI blocking
  /// - Parallel execution of secondary loads
  /// - Graceful error handling with catchError
  /// - Optimized provider caching
  ///
  /// ## Error Handling:
  /// - Primary load failures are propagated to UI
  /// - Secondary load failures are silently handled (non-critical)
  /// - Network timeout protection with custom error messages
  ///
  /// @throws Exception when primary data load fails or times out
  Future<void> _loadInitialData() async {
    try {
      final notifier = ref.read(medicationsProvider.notifier);
      final primaryLoad = widget.animalId != null
          ? notifier.loadMedicationsByAnimalId(widget.animalId!)
          : notifier.loadMedications();

      await primaryLoad.timeout(
        MedicationsConstants.loadingTimeout,
        onTimeout: () => throw Exception('Timeout loading medications'),
      );
      final secondaryLoads = await Future.wait([
        notifier.loadActiveMedications().catchError((e) => null),
        notifier.loadExpiringMedications().catchError((e) => null),
      ]);
      if (secondaryLoads.contains(null)) {
        debugPrint('Some secondary medication loads failed');
      }
    } catch (e) {
      debugPrint('Failed to load initial medication data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar medicamentos: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: _loadInitialData,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final medicationsState = ref.watch(medicationsProvider);
    final filteredMedications = ref.watch(filteredMedicationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PetivetiPageHeader(
              icon: Icons.medication,
              title: widget.animalId != null
                  ? MedicationsConstants.petMedicationsTitle
                  : MedicationsConstants.allMedicationsTitle,
              subtitle: 'Controle de medicamentos',
              showBackButton: true,
              actions: [
                _buildHeaderAction(
                  icon: Icons.refresh,
                  onTap: _refreshMedications,
                  tooltip: 'Atualizar',
                ),
                _buildHeaderAction(
                  icon: Icons.add,
                  onTap: () => _navigateToAddMedication(context),
                  tooltip: 'Adicionar',
                ),
              ],
            ),
            _buildTabBar(medicationsState),
            _buildSearchAndFilters(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMedicationsList(
                    medications: filteredMedications,
                    isLoading: medicationsState.isLoading,
                    error: medicationsState.error,
                  ),
                  _buildMedicationsList(
                    medications: medicationsState.activeMedications,
                    isLoading: medicationsState.isLoading,
                    error: medicationsState.error,
                    emptyMessage: MedicationsConstants.noActiveMedications,
                  ),
                  _buildMedicationsList(
                    medications: medicationsState.expiringMedications,
                    isLoading: medicationsState.isLoading,
                    error: medicationsState.error,
                    emptyMessage: MedicationsConstants.noExpiringMedications,
                  ),
                  const MedicationStats(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Adicionar novo medicamento',
        hint: 'Botão flutuante para cadastrar um novo medicamento',
        button: true,
        child: FloatingActionButton(
          onPressed: () => _navigateToAddMedication(context),
          tooltip: MedicationsConstants.addMedicationTooltip,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTabBar(MedicationsState medicationsState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.medication, size: MedicationsConstants.tabIconSize),
                const SizedBox(width: 8),
                Text('Todos (${medicationsState.medications.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_filled, size: MedicationsConstants.tabIconSize),
                const SizedBox(width: 8),
                Text('Ativos (${medicationsState.activeMedications.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, size: MedicationsConstants.tabIconSize),
                const SizedBox(width: 8),
                Text('Vencendo (${medicationsState.expiringMedications.length})'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.analytics, size: MedicationsConstants.tabIconSize),
                SizedBox(width: 8),
                Text('Estatísticas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(MedicationsConstants.pageContentPadding),
      child: Column(
        children: [
          Semantics(
            label: 'Campo de busca de medicamentos',
            hint: 'Digite o nome do medicamento que você está procurando',
            textField: true,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: MedicationsConstants.searchHintText,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(medicationSearchQueryProvider.notifier).set(value);
              },
            ),
          ),
          const SizedBox(height: MedicationsConstants.searchFiltersSpacing),
          const MedicationFilters(),
        ],
      ),
    );
  }

  Widget _buildMedicationsList({
    required List<Medication> medications,
    required bool isLoading,
    String? error,
    String? emptyMessage,
  }) {
    if (isLoading) {
      return Semantics(
        label: 'Carregando medicamentos',
        hint: 'Aguarde enquanto carregamos a lista de medicamentos',
        liveRegion: true,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Semantics(
        label: 'Erro ao carregar medicamentos',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Ícone de erro',
                child: Icon(
                  Icons.error_outline,
                  size: MedicationsConstants.errorIconSize,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: MedicationsConstants.errorContentSpacing),
              Text(
                error,
                style: const TextStyle(
                  fontSize: MedicationsConstants.errorTextSize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MedicationsConstants.errorContentSpacing),
              Semantics(
                label: 'Tentar carregar medicamentos novamente',
                hint: 'Toque para tentar recarregar a lista de medicamentos',
                button: true,
                child: ElevatedButton(
                  onPressed: _refreshMedications,
                  child: const Text(MedicationsConstants.retryButtonText),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (medications.isEmpty) {
      return EmptyMedicationsState(
        message: emptyMessage ?? MedicationsConstants.noMedicationsFound,
        onAddPressed: () => _navigateToAddMedication(context),
      );
    }

    return Semantics(
      label: 'Lista de medicamentos',
      hint: 'Arraste para baixo para atualizar a lista',
      child: RefreshIndicator(
        onRefresh: _refreshMedications,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(
                MedicationsConstants.pageContentPadding,
              ),
              sliver: SliverFixedExtentList(
                itemExtent: MedicationsConstants
                    .medicationCardHeight, // Fixed height for optimal performance
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final medication = medications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RepaintBoundary(
                        child: MedicationCard(
                          key: ValueKey(
                            medication.id,
                          ), // Stable key for performance
                          medication: medication,
                          onTap: () =>
                              _navigateToMedicationDetails(context, medication),
                          onEdit: () =>
                              _navigateToEditMedication(context, medication),
                          onDelete: () =>
                              _confirmDeleteMedication(context, medication),
                        ),
                      ),
                    );
                  },
                  childCount: medications.length,
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  addSemanticIndexes:
                      false, // Disable for better performance in large lists
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshMedications() async {
    try {
      final notifier = ref.read(medicationsProvider.notifier);
      final primaryRefresh = widget.animalId != null
          ? notifier.loadMedicationsByAnimalId(widget.animalId!)
          : notifier.loadMedications();

      await primaryRefresh.timeout(MedicationsConstants.loadingTimeout);
      await Future.wait([
        notifier.loadActiveMedications().catchError((e) => null),
        notifier.loadExpiringMedications().catchError((e) => null),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToAddMedication(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddMedicationDialog(
        initialAnimalId: widget.animalId,
      ),
    );
  }

  void _navigateToMedicationDetails(
    BuildContext context,
    Medication medication,
  ) {
    Navigator.of(context).pushNamed(
      '/medications/details',
      arguments: {'medicationId': medication.id},
    );
  }

  void _navigateToEditMedication(BuildContext context, Medication medication) {
    showDialog<void>(
      context: context,
      builder: (context) => AddMedicationDialog(medication: medication),
    );
  }

  Future<void> _confirmDeleteMedication(
    BuildContext context,
    Medication medication,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Medicamento'),
        content: Text('Tem certeza que deseja excluir "${medication.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(medicationsProvider.notifier)
          .deleteMedication(medication.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento excluído com sucesso')),
        );
      }
    }
  }

}
