import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/maintenance_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../../../shared/widgets/vehicle_selector.dart';

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

  String _selectedFilter = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String? _selectedVehicleId;

  List<MaintenanceEntity> get _filteredRecords {
    final maintenanceProvider = context.watch<MaintenanceProvider>();
    var filtered = maintenanceProvider.maintenanceRecords;

    // Aplicar filtro por veículo
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.vehicleId == _selectedFilter).toList();
    }

    // Aplicar filtro por categoria (tipo)
    if (_selectedCategory != 'all') {
      switch (_selectedCategory) {
        case 'preventiva':
          filtered = filtered.where((r) => r.isPreventive).toList();
          break;
        case 'corretiva':
          filtered = filtered.where((r) => r.isCorrective).toList();
          break;
        case 'revisao':
          filtered = filtered.where((r) => r.isInspection).toList();
          break;
        case 'emergencial':
          filtered = filtered.where((r) => r.isEmergency).toList();
          break;
      }
    }

    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final title = r.title.toLowerCase();
        final type = r.type.displayName.toLowerCase();
        final workshop = (r.workshopName ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || 
               type.contains(query) || 
               workshop.contains(query);
      }).toList();
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
                      padding: const EdgeInsets.all(16.0),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.build,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manutenções',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Histórico de manutenções dos seus veículos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilters(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Buscar por tipo, veículo ou oficina...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos os veículos')),
                    DropdownMenuItem(value: '1', child: Text('Honda Civic')),
                    DropdownMenuItem(value: '2', child: Text('Toyota Corolla')),
                  ],
                  onChanged: (value) => setState(() => _selectedFilter = value!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todas as categorias')),
                    DropdownMenuItem(value: 'preventiva', child: Text('Preventiva')),
                    DropdownMenuItem(value: 'corretiva', child: Text('Corretiva')),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VehicleSelector(
          selectedVehicleId: _selectedVehicleId,
          onVehicleChanged: (vehicleId) {
            setState(() {
              _selectedVehicleId = vehicleId;
              _selectedFilter = vehicleId ?? 'all';
            });
          },
          showEmptyOption: true,
        ),
        const SizedBox(height: 24),
        if (_filteredRecords.isEmpty)
          _buildEmptyState()
        else ...[
          _buildStatistics(),
          const SizedBox(height: 24),
          _buildUpcomingMaintenances(),
          const SizedBox(height: 24),
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
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Preventivas',
            preventiveCount.toString(),
            Icons.schedule,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 12),
        ...upcomingServices.take(2).map((service) {
          final daysUntil = service.nextServiceDate!
              .difference(DateTime.now())
              .inDays;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
        const Text(
          'Histórico de Manutenções',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._filteredRecords.map((record) => _buildRecordCard(record)),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final date = record['date'] as DateTime;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final isPreventive = record['category'] == 'preventiva';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: () => _showRecordDetails(record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPreventive ? Icons.schedule : Icons.build_circle,
                      color: isPreventive ? Colors.blue : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                record['type'],
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              record['vehicleName'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              record['workshop'],
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
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
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
        const SizedBox(width: 6),
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
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.build_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhuma manutenção encontrada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre a primeira manutenção do seu veículo',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/maintenance/add'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: 'Nova Manutenção',
      child: const Icon(Icons.add),
    );
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                record['type'],
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
              _buildDetailRow('Veículo', record['vehicleName']),
              _buildDetailRow('Oficina', record['workshop']),
              _buildDetailRow('Data', _formatDate(record['date'])),
              _buildDetailRow('Odômetro', '${record['odometer']} km'),
              _buildDetailRow('Custo', 'R\$ ${record['cost'].toStringAsFixed(2)}'),
              _buildDetailRow('Categoria', 
                record['category'] == 'preventiva' ? 'Preventiva' : 'Corretiva'),
              const SizedBox(height: 12),
              const Text(
                'Descrição:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                record['description'],
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              if (record['nextService'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notification_important,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Próxima manutenção: ${_formatDate(record['nextService'])}',
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