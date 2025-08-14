import 'package:flutter/material.dart';
import 'add_odometer_page.dart';
import '../../../../shared/widgets/vehicle_selector.dart';

class OdometerPage extends StatefulWidget {
  const OdometerPage({super.key});

  @override
  State<OdometerPage> createState() => _OdometerPageState();
}

class _OdometerPageState extends State<OdometerPage> {
  String? _selectedVehicleId;
  int _currentMonthIndex = 0;
  bool _showStatistics = true;
  final bool _isLoading = false;

  final List<String> _months = [
    'Jan 25',
    'Fev 25',
    'Mar 25',
    'Abr 25',
    'Mai 25',
    'Jun 25',
    'Jul 25',
    'Ago 25',
  ];

  @override
  void initState() {
    super.initState();
  }

  final List<Map<String, dynamic>> _odometers = [
    {
      'id': 1,
      'date': DateTime(2025, 8, 15),
      'odometer': 25420.5,
      'difference': 120.3,
      'description': 'Viagem para o trabalho',
    },
    {
      'id': 2,
      'date': DateTime(2025, 8, 12),
      'odometer': 25300.2,
      'difference': 85.0,
      'description': 'Compras no shopping',
    },
    {
      'id': 3,
      'date': DateTime(2025, 8, 10),
      'odometer': 25215.2,
      'difference': 45.8,
      'description': 'Consulta médica',
    },
    {
      'id': 4,
      'date': DateTime(2025, 8, 8),
      'odometer': 25169.4,
      'difference': 32.1,
      'description': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_selectedVehicleId != null) _buildControls(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.speed,
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
                      'Odômetro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Registros de quilometragem',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedVehicleId != null)
                IconButton(
                  onPressed: () => setState(() => _showStatistics = !_showStatistics),
                  icon: Icon(
                    _showStatistics ? Icons.assessment : Icons.assessment_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: _showStatistics ? 'Ocultar estatísticas' : 'Mostrar estatísticas',
                ),
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Carregando...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
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
  }

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              VehicleSelector(
                selectedVehicleId: _selectedVehicleId,
                onVehicleChanged: (vehicleId) {
                  setState(() {
                    _selectedVehicleId = vehicleId;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildMonthsBar(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMonthsBar() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentMonthIndex;
          return GestureDetector(
            onTap: () => setState(() => _currentMonthIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Text(
                _months[index],
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedVehicleId == null) {
      return _buildNoVehicleSelected();
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_showStatistics) ...[
                  _buildStatisticsCard(),
                  const SizedBox(height: 16),
                ],
                _buildOdometerList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoVehicleSelected() {
    return Center(
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
              Icons.directions_car_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Selecione um veículo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um veículo para visualizar os registros de odômetro',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assessment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Estatísticas do Mês',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatisticItem('Km Inicial', '25.169,4', Icons.trip_origin)),
                Expanded(child: _buildStatisticItem('Km Final', '25.420,5', Icons.flag)),
                Expanded(child: _buildStatisticItem('Total Rodado', '251,1', Icons.trending_up)),
                Expanded(child: _buildStatisticItem('Média/Dia', '16,7', Icons.timeline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOdometerList() {
    if (_odometers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _odometers.map((odometer) => _buildOdometerItem(odometer)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
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
                Icons.speed_outlined,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum registro encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há registros de odômetro para este período',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerItem(Map<String, dynamic> odometer) {
    final date = odometer['date'] as DateTime;
    final dayOfMonth = date.day.toString().padLeft(2, '0');
    final weekday = _getWeekdayName(date.weekday);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () => _editOdometer(odometer),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Data
                Column(
                  children: [
                    Text(
                      weekday,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayOfMonth,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(width: 16),
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoChip(
                            icon: Icons.speed,
                            value: '${odometer['odometer'].toStringAsFixed(1)} km',
                            label: 'Odômetro',
                            isHighlighted: true,
                          ),
                          if (odometer['difference'] > 0)
                            _buildInfoChip(
                              icon: Icons.trending_up,
                              value: '${odometer['difference'].toStringAsFixed(1)} km',
                              label: 'Diferença',
                              isHighlighted: false,
                            ),
                        ],
                      ),
                      if (odometer['description'].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          odometer['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required String label,
    required bool isHighlighted,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildFloatingActionButton() {
    final hasSelectedVehicle = _selectedVehicleId != null;
    
    return FloatingActionButton(
      onPressed: hasSelectedVehicle ? _addOdometer : _showSelectVehicleMessage,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: hasSelectedVehicle 
          ? 'Adicionar registro de odômetro' 
          : 'Selecione um veículo primeiro',
      child: const Icon(Icons.add),
    );
  }

  void _showSelectVehicleMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecione um veículo primeiro'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    return weekdays[weekday - 1];
  }

  void _addOdometer() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddOdometerPage(),
    );
    
    if (result != null && mounted) {
      setState(() {
        _odometers.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          ...result,
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro cadastrado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editOdometer(Map<String, dynamic> odometer) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddOdometerPage(odometer: odometer),
    );
    
    if (result != null && mounted) {
      setState(() {
        final index = _odometers.indexWhere((o) => o['id'] == odometer['id']);
        if (index >= 0) {
          _odometers[index] = {
            'id': odometer['id'],
            ...result,
          };
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro editado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}