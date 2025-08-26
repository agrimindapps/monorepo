import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../../vehicles/presentation/pages/add_vehicle_page.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_provider.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  @override
  void initState() {
    super.initState();
    // Inicializar providers de forma lazy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().loadAllMaintenanceRecords();
      context.read<VehiclesProvider>().initialize();
    });
  }

  String? _selectedVehicleId;

  List<MaintenanceEntity> get _filteredRecords {
    final maintenanceProvider = context.watch<MaintenanceProvider>();
    var filtered = maintenanceProvider.maintenanceRecords;

    // Aplicar filtro por veículo selecionado
    if (_selectedVehicleId != null) {
      filtered = filtered.where((r) => r.vehicleId == _selectedVehicleId).toList();
    }

    // Ordenar por data (mais recente primeiro)
    filtered.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

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
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.build,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manutenções',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Histórico de manutenções dos seus veículos',
                    style: TextStyle(
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
                });
              },
            );
          },
        ),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        if (_filteredRecords.isEmpty)
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
  }

  Widget _buildStatistics() {
    final totalCost = _filteredRecords.fold<double>(
      0,
      (sum, record) => sum + record.cost,
    );
    final preventiveCount = _filteredRecords
        .where((r) => r.isPreventive)
        .length;
    final correctiveCount = _filteredRecords
        .where((r) => r.isCorrective)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Gasto Total',
            'R\$ ${totalCost.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: _buildStatCard(
            'Preventivas',
            preventiveCount.toString(),
            Icons.schedule,
            Colors.blue,
          ),
        ),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: _buildStatCard(
            'Corretivas',
            correctiveCount.toString(),
            Icons.build_circle,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingSm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: GasometerDesignTokens.spacingMd),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: GasometerDesignTokens.spacingMd),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
            Text(
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
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
              child: Row(
                children: [
                  Container(
                    padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingSm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: GasometerDesignTokens.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${service.vehicleId} - ${service.title}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Em $daysUntil dias',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        Text(
          'Histórico de Manutenções',
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeXl,
            fontWeight: GasometerDesignTokens.fontWeightBold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: GasometerDesignTokens.spacingLg),
        ..._filteredRecords.map((record) => _buildRecordCard(record)),
      ],
    );
  }

  Widget _buildRecordCard(MaintenanceEntity record) {
    final date = record.serviceDate;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final isPreventive = record.type == MaintenanceType.preventive;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: () => _showRecordDetails(record),
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        child: Padding(
          padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingCardPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd - 2),
                    decoration: BoxDecoration(
                      color: (isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.1),
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
                              child: Text(
                                record.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: GasometerDesignTokens.spacingXs),
                        Row(
                          children: [
                            Text(
                              'Veículo: ${record.vehicleId}', // TODO: Buscar nome do veículo
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(width: GasometerDesignTokens.spacingSm),
                            Text(
                              '•',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                            SizedBox(width: GasometerDesignTokens.spacingSm),
                            Text(
                              record.workshopName ?? 'Oficina não informada',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: GasometerDesignTokens.spacingMd),
              const Divider(height: 1),
              SizedBox(height: GasometerDesignTokens.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    Icons.speed,
                    '${record['odometer']} km',
                    'Odômetro',
                  ),
                  _buildInfoItem(
                    Icons.attach_money,
                    'R\$ ${record['cost'].toStringAsFixed(2)}',
                    'Custo',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.1),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        SizedBox(width: GasometerDesignTokens.spacingXs + 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EnhancedEmptyState.maintenances(
      onAddMaintenance: () => context.go('/maintenance/add'),
      onViewGuides: () {
        // TODO: Implementar navegação para guias
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guias de manutenção em breve!'),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final vehiclesProvider = context.watch<VehiclesProvider>();
    final hasSelectedVehicle = vehiclesProvider.vehicles.isNotEmpty;
    
    return FloatingActionButton(
      onPressed: hasSelectedVehicle ? () => context.go('/maintenance/add') : _showSelectVehicleMessage,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
      ),
      tooltip: hasSelectedVehicle 
          ? 'Nova Manutenção'
          : 'Cadastre um veículo primeiro',
      child: const Icon(Icons.add),
    );
  }

  void _showSelectVehicleMessage() {
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
          onPressed: () => _showAddVehicleDialog(context),
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
      await context.read<VehiclesProvider>().initialize();
    }
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              record['category'] == 'preventiva' ? Icons.schedule : Icons.build_circle,
              color: record['category'] == 'preventiva' ? Colors.blue : Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: GasometerDesignTokens.spacingSm),
            Expanded(
              child: Text(
                record['type'] as String? ?? '',
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
              _buildDetailRow('Veículo', record['vehicleName'] as String? ?? ''),
              _buildDetailRow('Oficina', record['workshop'] as String? ?? ''),
              _buildDetailRow('Data', _formatDate(record['date'] as DateTime? ?? DateTime.now())),
              _buildDetailRow('Odômetro', '${record['odometer']} km'),
              _buildDetailRow('Custo', 'R\$ ${record['cost'].toStringAsFixed(2)}'),
              _buildDetailRow('Categoria', 
                record['category'] == 'preventiva' ? 'Preventiva' : 'Corretiva'),
              SizedBox(height: GasometerDesignTokens.spacingMd),
              const Text(
                'Descrição:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: GasometerDesignTokens.spacingXs),
              Text(
                record['description'] as String? ?? '',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              if (record['nextService'] != null) ...[
                SizedBox(height: GasometerDesignTokens.spacingMd),
                Container(
                  padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                          'Próxima manutenção: ${_formatDate(record['nextService'] as DateTime? ?? DateTime.now())}',
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
          TextButton(
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
}