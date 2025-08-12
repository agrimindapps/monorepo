// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoManutencao extends StatelessWidget {
  const GraficoManutencao({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMaintenanceCostChart(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildMaintenanceTypeDistribution()),
            const SizedBox(width: 16),
            Expanded(child: _buildUpcomingMaintenanceCard()),
          ],
        ),
        const SizedBox(height: 24),
        _buildMaintenanceHistoryCard(),
      ],
    );
  }

  Widget _buildMaintenanceCostChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custos de Manutenção',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gastos com manutenção nos últimos 12 meses',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          return LineTooltipItem(
                            'R\$ ${spot.y.toStringAsFixed(2)}',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );

                          const labels = [
                            'Abr',
                            'Mai',
                            'Jun',
                            'Jul',
                            'Ago',
                            'Set',
                            'Out',
                            'Nov',
                            'Dez',
                            'Jan',
                            'Fev',
                            'Mar'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[value.toInt()], style: style),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'R\$ ${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 800,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 350),
                        FlSpot(1, 80),
                        FlSpot(2, 120),
                        FlSpot(3, 680),
                        FlSpot(4, 150),
                        FlSpot(5, 90),
                        FlSpot(6, 220),
                        FlSpot(7, 450),
                        FlSpot(8, 180),
                        FlSpot(9, 650),
                        FlSpot(10, 120),
                        FlSpot(11, 80),
                      ],
                      isCurved: false,
                      barWidth: 3,
                      color: Colors.orange,
                      dotData: const FlDotData(
                        show: true,
                        getDotPainter: _dotPainter,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Total anual: R\$ 3.170,00',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static FlDotPainter _dotPainter(spot, percent, bar, index) {
    return FlDotCirclePainter(
      radius: 5,
      color: Colors.orange,
      strokeWidth: 2,
      strokeColor: Colors.white,
    );
  }

  Widget _buildMaintenanceTypeDistribution() {
    final data = [
      PieChartSectionData(
        value: 35,
        title: '35%',
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      PieChartSectionData(
        value: 25,
        title: '25%',
        color: Colors.blue,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      PieChartSectionData(
        value: 18,
        title: '18%',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      PieChartSectionData(
        value: 12,
        title: '12%',
        color: Colors.purple,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      PieChartSectionData(
        value: 10,
        title: '10%',
        color: Colors.amber,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Manutenção',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLegendItem('Motor/Transmissão', Colors.red, 'R\$ 1.110,00'),
            const SizedBox(height: 8),
            _buildLegendItem('Freios/Suspensão', Colors.blue, 'R\$ 792,00'),
            const SizedBox(height: 8),
            _buildLegendItem('Elétrica', Colors.green, 'R\$ 570,00'),
            const SizedBox(height: 8),
            _buildLegendItem('Ar-condicionado', Colors.purple, 'R\$ 380,00'),
            const SizedBox(height: 8),
            _buildLegendItem('Outros', Colors.amber, 'R\$ 318,00'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildUpcomingMaintenanceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Próximas Manutenções',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMaintenanceItem(
              'Troca de óleo',
              '45.628 km / 46.000 km',
              0.95,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMaintenanceItem(
              'Filtro de ar',
              '45.628 km / 50.000 km',
              0.80,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMaintenanceItem(
              'Pastilhas de freio',
              '45.628 km / 55.000 km',
              0.65,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildMaintenanceItem(
              'Correia dentada',
              '45.628 km / 80.000 km',
              0.30,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Baseado no histórico e recomendações do fabricante',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceItem(
    String title,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 7,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMaintenanceHistoryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Manutenções',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildMaintenanceHistoryItem(
              '15/03/2024',
              'Troca de óleo e filtros',
              'R\$ 320,00',
              '45.000 km',
            ),
            const Divider(height: 24),
            _buildMaintenanceHistoryItem(
              '02/02/2024',
              'Alinhamento e balanceamento',
              'R\$ 180,00',
              '43.500 km',
            ),
            const Divider(height: 24),
            _buildMaintenanceHistoryItem(
              '15/01/2024',
              'Substituição das pastilhas de freio',
              'R\$ 450,00',
              '42.000 km',
            ),
            const Divider(height: 24),
            _buildMaintenanceHistoryItem(
              '28/11/2023',
              'Revisão completa + troca de correia',
              'R\$ 1.250,00',
              '40.000 km',
            ),
            const Divider(height: 24),
            _buildMaintenanceHistoryItem(
              '10/10/2023',
              'Substituição do filtro de combustível',
              'R\$ 150,00',
              '38.500 km',
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceHistoryItem(
    String date,
    String description,
    String cost,
    String odometer,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                odometer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            cost,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }
}
