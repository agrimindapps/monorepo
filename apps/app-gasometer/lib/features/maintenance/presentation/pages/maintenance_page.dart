import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/pages/add_vehicle_page.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_provider.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  String? _selectedVehicleId;
  
  // ✅ PERFORMANCE FIX: Cached providers
  late final MaintenanceProvider _maintenanceProvider;
  late final VehiclesProvider _vehiclesProvider;
  
  // ✅ PERFORMANCE FIX: Memoize filtered records
  List<MaintenanceEntity>? _cachedFilteredRecords;
  String? _lastVehicleId;
  List<MaintenanceEntity>? _lastMaintenanceRecords;
  
  @override
  void initState() {
    super.initState();
    // ✅ PERFORMANCE FIX: Cache providers once in initState
    _maintenanceProvider = context.read<MaintenanceProvider>();
    _vehiclesProvider = context.read<VehiclesProvider>();
    
    // Inicializar providers de forma lazy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maintenanceProvider.loadAllMaintenanceRecords();
      _vehiclesProvider.initialize();
    });
  }

  // ✅ PERFORMANCE FIX: Memoized filtered records with caching
  List<MaintenanceEntity> get _filteredRecords {
    final currentRecords = _maintenanceProvider.maintenanceRecords;
    
    // Check if cache is still valid
    if (_cachedFilteredRecords != null &&
        _lastVehicleId == _selectedVehicleId &&
        _lastMaintenanceRecords == currentRecords) {
      return _cachedFilteredRecords!;
    }
    
    // Rebuild cache
    var filtered = List<MaintenanceEntity>.from(currentRecords);

    // Apply vehicle filter
    if (_selectedVehicleId != null) {
      filtered = filtered.where((r) => r.vehicleId == _selectedVehicleId).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

    // Update cache
    _cachedFilteredRecords = filtered;
    _lastVehicleId = _selectedVehicleId;
    _lastMaintenanceRecords = currentRecords;

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingPagePadding),
                      child: _buildContent(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GasometerDesignTokens.colorHeaderBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Semantics(
                label: 'Seção de manutenções',
                hint: 'Página principal para gerenciar manutenções',
                child: const Icon(
                  Icons.build,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticText.heading(
                    'Manutenções',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SemanticText.subtitle(
                    'Histórico de manutenções dos seus veículos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContent(BuildContext context) {
    return Consumer<MaintenanceProvider>(
      builder: (context, maintenanceProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<VehiclesProvider>(
              builder: (context, vehiclesProvider, child) {
                return EnhancedVehicleSelector(
                  selectedVehicleId: _selectedVehicleId,
                  onVehicleChanged: (String? vehicleId) {
                    setState(() {
                      _selectedVehicleId = vehicleId;
                      // ✅ PERFORMANCE FIX: Invalidate cache when vehicle changes
                      _cachedFilteredRecords = null;
                    });
                  },
                );
              },
            ),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            
            if (maintenanceProvider.isLoading)
              StandardLoadingView.initial(
                message: 'Carregando manutenções...',
                height: 400,
              )
            else if (maintenanceProvider.state == ProviderState.error)
              _buildErrorState(maintenanceProvider.errorMessage!, () => maintenanceProvider.loadAllMaintenanceRecords())
            else if (_filteredRecords.isEmpty)
              _buildEmptyState()
            else ...[
              _buildStatistics(),
              SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
              _buildUpcomingMaintenances(),
              SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
              _buildRecordsList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatistics() {
    // Use cached statistics from provider instead of calculating in build method
    final statistics = _maintenanceProvider.statistics;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Gasto Total',
            'R\$ ${statistics.totalCost.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: _buildStatCard(
            'Preventivas',
            statistics.preventiveCount.toString(),
            Icons.schedule,
            Colors.blue,
          ),
        ),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: _buildStatCard(
            'Corretivas',
            statistics.correctiveCount.toString(),
            Icons.build_circle,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SemanticCard(
      semanticLabel: 'Estatística de $title: $value',
      semanticHint: 'Informação sobre $title das manutenções',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingSm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: GasometerDesignTokens.spacingMd),
              SemanticText.label(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          SemanticText(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMaintenances() {
    final upcomingServices = _filteredRecords
        .where((r) => r.nextServiceDate != null)
        .where((r) => r.nextServiceDate!.isAfter(DateTime.now()))
        .toList();

    if (upcomingServices.isEmpty) return const SizedBox.shrink();

    upcomingServices.sort((a, b) => 
      a.nextServiceDate!.compareTo(b.nextServiceDate!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notification_important, color: Theme.of(context).colorScheme.primary, size: 20),
            SizedBox(width: GasometerDesignTokens.spacingSm),
            SemanticText.heading(
              'Próximas Manutenções',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        ...upcomingServices.take(2).map((service) {
          final daysUntil = service.nextServiceDate!
              .difference(DateTime.now())
              .inDays;
          final urgencyDescription = daysUntil <= 7 ? 'urgente' : daysUntil <= 30 ? 'próxima' : 'futura';
          
          return Semantics(
            label: 'Manutenção $urgencyDescription: ${service.title} do veículo ${service.vehicleId} em $daysUntil dias',
            hint: 'Lembrete de manutenção programada',
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
                side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: Padding(
                padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
                child: Row(
                  children: [
                    Semantics(
                      label: 'Ícone de lembrete',
                      child: Container(
                        padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingSm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: GasometerDesignTokens.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SemanticText.heading(
                            '${service.vehicleId} - ${service.title}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SemanticText.label(
                            'Em $daysUntil dias',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Histórico de Manutenções',
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeXl,
            fontWeight: GasometerDesignTokens.fontWeightBold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: GasometerDesignTokens.spacingLg),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredRecords.length,
          itemBuilder: (context, index) {
            return _OptimizedMaintenanceCard(
              key: ValueKey(_filteredRecords[index].id),
              record: _filteredRecords[index],
              onTap: () => _showRecordDetails(_filteredRecords[index]),
            );
          },
        ),
      ],
    );
  }



  Widget _buildEmptyState() {
    return EnhancedEmptyState.maintenances(
      onAddMaintenance: () => context.go('/maintenance/add'),
      onViewGuides: () {
        // Check if widget is still mounted before using context
        if (mounted) {
          // Navigation to guides implementation pending
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guias de manutenção em breve!'),
            ),
          );
        }
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final vehiclesProvider = context.watch<VehiclesProvider>();
    final hasSelectedVehicle = vehiclesProvider.vehicles.isNotEmpty;
    
    return SemanticButton.fab(
      semanticLabel: hasSelectedVehicle ? 'Registrar nova manutenção' : 'Cadastrar veículo primeiro',
      semanticHint: hasSelectedVehicle 
          ? 'Abre formulário para cadastrar uma nova manutenção'
          : 'É necessário ter pelo menos um veículo cadastrado para registrar manutenções',
      onPressed: hasSelectedVehicle ? () => context.go('/maintenance/add') : _showSelectVehicleMessage,
      child: Icon(hasSelectedVehicle ? Icons.add : Icons.warning),
    );
  }

  void _showSelectVehicleMessage() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cadastre um veículo primeiro para registrar manutenções'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusInput,
          ),
        ),
        action: SnackBarAction(
          label: 'Cadastrar',
          onPressed: () {
            // Check if widget is still mounted before using context
            if (mounted) {
              _showAddVehicleDialog(context);
            }
          },
        ),
      ),
    );
  }

  Future<void> _showAddVehicleDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    // Se resultado for true, recarregar veículos
    if (result == true && context.mounted) {
      await _vehiclesProvider.initialize();
    }
  }

  void _showRecordDetails(MaintenanceEntity record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              record.type == MaintenanceType.preventive ? Icons.schedule : Icons.build_circle,
              color: record.type == MaintenanceType.preventive ? Colors.blue : Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: GasometerDesignTokens.spacingSm),
            Expanded(
              child: Text(
                record.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Veículo', record.vehicleId),
              _buildDetailRow('Oficina', record.workshopName ?? 'Não informado'),
              _buildDetailRow('Data', _formatDate(record.serviceDate)),
              _buildDetailRow('Odômetro', '${record.odometer} km'),
              _buildDetailRow('Custo', 'R\$ ${record.cost.toStringAsFixed(2)}'),
              _buildDetailRow('Categoria', 
                record.type == MaintenanceType.preventive ? 'Preventiva' : 'Corretiva'),
              SizedBox(height: GasometerDesignTokens.spacingMd),
              const Text(
                'Descrição:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: GasometerDesignTokens.spacingXs),
              Text(
                record.description ?? 'Sem descrição',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
              if (record.nextServiceDate != null) ...[
                SizedBox(height: GasometerDesignTokens.spacingMd),
                Container(
                  padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notification_important,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: GasometerDesignTokens.spacingSm),
                      Expanded(
                        child: Text(
                          'Próxima manutenção: ${_formatDate(record.nextServiceDate!)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          SemanticButton(
            semanticLabel: 'Fechar detalhes da manutenção',
            semanticHint: 'Fecha a janela de detalhes da manutenção',
            type: ButtonType.text,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Erro de carregamento',
              hint: 'Ícone indicando erro no carregamento das manutenções',
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            SemanticText.heading(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SemanticText(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SemanticButton(
              semanticLabel: 'Tentar carregar manutenções novamente',
              semanticHint: 'Tenta recarregar os dados das manutenções após o erro',
              type: ButtonType.elevated,
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget otimizado para card de manutenção
class _OptimizedMaintenanceCard extends StatelessWidget {
  final MaintenanceEntity record;
  final VoidCallback onTap;

  const _OptimizedMaintenanceCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = record.serviceDate;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final isPreventive = record.type == MaintenanceType.preventive;
    final typeDescription = isPreventive ? 'preventiva' : 'corretiva';
    final semanticLabel = 'Manutenção $typeDescription ${record.title} em $formattedDate, custo R\$ ${record.cost.toStringAsFixed(2)}, odômetro ${record.odometer} km';

    return SemanticCard(
      semanticLabel: semanticLabel,
      semanticHint: 'Toque para ver detalhes completos da manutenção',
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _buildHeader(context, formattedDate, isPreventive),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          const Divider(height: 1),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildFooter(context, isPreventive),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String formattedDate, bool isPreventive) {
    return Row(
      children: [
        Container(
          padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd - 2),
          decoration: BoxDecoration(
            color: (isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary)
                .withOpacity(0.1),
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
          ),
          child: Icon(
            isPreventive ? Icons.schedule : Icons.build_circle,
            color: isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SemanticText.heading(
                      record.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SemanticText.label(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: GasometerDesignTokens.spacingXs),
              Row(
                children: [
                  Text(
                    'Veículo: ${record.vehicleId}', // Vehicle name lookup pending
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(width: GasometerDesignTokens.spacingSm),
                  Text(
                    '•',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  SizedBox(width: GasometerDesignTokens.spacingSm),
                  Text(
                    record.workshopName ?? 'Oficina não informada',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isPreventive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(
          context,
          Icons.speed,
          '${record.odometer} km',
          'Odômetro',
        ),
        _buildInfoItem(
          context,
          Icons.attach_money,
          'R\$ ${record.cost.toStringAsFixed(2)}',
          'Custo',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isPreventive ? 'Preventiva' : 'Corretiva',
            style: TextStyle(
              fontSize: 12,
              color: isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Semantics(
      label: '$label: $value',
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: GasometerDesignTokens.spacingXs + 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemanticText(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SemanticText.label(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}