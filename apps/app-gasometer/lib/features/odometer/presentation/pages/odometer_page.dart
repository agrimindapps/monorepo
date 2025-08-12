import 'package:flutter/material.dart';
import 'add_odometer_page.dart';

class OdometerPage extends StatefulWidget {
  const OdometerPage({super.key});

  @override
  State<OdometerPage> createState() => _OdometerPageState();
}

class _OdometerPageState extends State<OdometerPage> {
  String? _selectedVehicle;
  int _currentMonthIndex = 0;
  bool _showStatistics = true;
  bool _isLoading = false;

  final List<String> _vehicles = [
    'Honda Civic 2022',
    'Toyota Corolla 2021',
  ];

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
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_selectedVehicle != null) _buildControls(),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.speed,
                  color: Color(0xFFFF5722),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Odômetro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Registros de quilometragem',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedVehicle != null)
                IconButton(
                  onPressed: () => setState(() => _showStatistics = !_showStatistics),
                  icon: Icon(
                    _showStatistics ? Icons.assessment : Icons.assessment_outlined,
                    color: const Color(0xFFFF5722),
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
              _buildVehicleSelector(),
              const SizedBox(height: 16),
              _buildMonthsBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicle,
          hint: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Text(
                'Selecione um veículo',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          isExpanded: true,
          items: _vehicles.map((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle,
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Color(0xFFFF5722), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    vehicle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedVehicle = value),
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
                color: isSelected ? const Color(0xFFFF5722) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF5722) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                _months[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
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
    if (_selectedVehicle == null) {
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
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              color: Colors.grey.shade400,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selecione um veículo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um veículo para visualizar os registros de odômetro',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
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
                    color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Color(0xFFFF5722),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Estatísticas do Mês',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF5722),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
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
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.speed_outlined,
                color: Colors.grey.shade400,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum registro encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há registros de odômetro para este período',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
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
          side: BorderSide(color: Colors.grey.shade200),
        ),
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
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayOfMonth,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
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
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
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
                ? const Color(0xFFFF5722).withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? const Color(0xFFFF5722)
                : Colors.grey.shade600,
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
                    ? Colors.black87
                    : Colors.grey.shade700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    final hasSelectedVehicle = _selectedVehicle != null;
    
    return FloatingActionButton.extended(
      onPressed: hasSelectedVehicle ? _addOdometer : null,
      backgroundColor: hasSelectedVehicle ? const Color(0xFFFF5722) : Colors.grey.shade400,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Novo Registro'),
      tooltip: 'Adicionar registro de odômetro',
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    return weekdays[weekday - 1];
  }

  void _addOdometer() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddOdometerPage(),
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro cadastrado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editOdometer(Map<String, dynamic> odometer) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddOdometerPage(odometer: odometer),
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro editado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}