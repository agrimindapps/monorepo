// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import '../widgets/appbar_widget.dart';

class HomePageCar extends StatefulWidget {
  const HomePageCar({super.key});

  @override
  State<HomePageCar> createState() => _HomePageCarState();
}

class _HomePageCarState extends State<HomePageCar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomLocalAppBar(
        title: 'GasOMeter',
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AlignedGridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> features = [
                        {
                          'icon': Icons.directions_car,
                          'title': 'Veículos',
                          'description': 'Gerenciar veículos cadastrados',
                          'route': '/ferramentas/veiculos/veiculos',
                        },
                        {
                          'icon': Icons.local_gas_station,
                          'title': 'Abastecimento',
                          'description': 'Registrar abastecimentos',
                          'route': '/ferramentas/veiculos/abastecimento',
                        },
                        {
                          'icon': Icons.attach_money,
                          'title': 'Despesas',
                          'description': 'Controle de despesas',
                          'route': '/ferramentas/veiculos/despesas',
                        },
                        {
                          'icon': Icons.speed,
                          'title': 'Odômetro',
                          'description': 'Registros de kilometragem',
                          'route': '/ferramentas/veiculos/odometro',
                        },
                        {
                          'icon': Icons.build,
                          'title': 'Manutenções',
                          'description': 'Histórico de manutenções',
                          'route': '/ferramentas/veiculos/manutencoes',
                        },
                      ];

                      final feature = features[index];

                      return _buildFeatureCard(
                        icon: feature['icon'],
                        title: feature['title'],
                        description: feature['description'],
                        onTap: () => Navigator.pushNamed(
                          context,
                          feature['route'],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Odometro - Últimos 28 dias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryCard(
                        children: [
                          _buildVehicleKmInfo(
                            'Honda Civic 2022',
                            '1.234 km',
                            'Média: 41,1 km/dia',
                            Icons.arrow_upward,
                            Colors.green,
                          ),
                          const Divider(),
                          _buildVehicleKmInfo(
                            'Toyota Corolla 2023',
                            '987 km',
                            'Média: 32,9 km/dia',
                            Icons.arrow_downward,
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Abastecimentos - Últimos 28 dias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryCard(
                        children: [
                          _buildVehicleFuelInfo(
                            'Honda Civic 2022',
                            '128,5 L',
                            'R\$ 642,50',
                            'Média: R\$ 5,00/L',
                          ),
                          const Divider(),
                          _buildVehicleFuelInfo(
                            'Toyota Corolla 2023',
                            '98,2 L',
                            'R\$ 491,00',
                            'Média: R\$ 5,00/L',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Manutenções Agendadas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryCard(
                        children: [
                          _buildMaintenanceInfo(
                            'Honda Civic 2022',
                            'Troca de óleo',
                            'Em 3 dias (24/02)',
                            urgente: true,
                          ),
                          const Divider(),
                          _buildMaintenanceInfo(
                            'Toyota Corolla 2023',
                            'Revisão 30.000 km',
                            'Em 15 dias (08/03)',
                            urgente: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // TEMPORÁRIO: Botão para teste do SyncFirebaseService
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.science,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '🧪 MODO TESTE - MIGRAÇÃO SYNCFIREBASESERVICE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Testando nova arquitetura de sincronização antes da migração completa',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleKmInfo(
    String vehicle,
    String distance,
    String average,
    IconData trendIcon,
    Color trendColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      distance,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(trendIcon, color: trendColor, size: 16),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  average,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleFuelInfo(
    String vehicle,
    String volume,
    String total,
    String average,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  volume,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  total,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  average,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceInfo(
    String vehicle,
    String service,
    String dueDate, {
    bool urgente = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  service,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      dueDate,
                      style: TextStyle(
                        color: urgente ? Colors.red : Colors.grey[600],
                        fontWeight:
                            urgente ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (urgente) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
