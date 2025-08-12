// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoGeral extends StatelessWidget {
  const GraficoGeral({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SummaryCards(),
        const SizedBox(height: 24),
        MediaQuery.of(context).size.width > 1024
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildExpenseDistributionChart(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildFuelEfficiencyCard(),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildExpenseDistributionChart(),
                  const SizedBox(height: 16),
                  _buildFuelEfficiencyCard(),
                ],
              ),
        const SizedBox(height: 24),
        _buildYearlyComparisonChart(),
      ],
    );
  }

  Widget _buildExpenseDistributionChart() {
    final data = [
      PieChartSectionData(
        value: 45,
        title: '45%',
        color: Colors.blue,
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 30,
        title: '30%',
        color: Colors.orange,
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 15,
        title: '15%',
        color: Colors.red,
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: 10,
        title: '10%',
        color: Colors.green,
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 390,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Distribuição de Gastos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                flex: 1,
                child: PieChart(
                  PieChartData(
                    sections: data,
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildLegendItem(
                          'Combustível', Colors.blue, 'R\$ 2.350,00'),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                          'Manutenção', Colors.orange, 'R\$ 1.580,00'),
                      const SizedBox(height: 12),
                      _buildLegendItem('Impostos', Colors.red, 'R\$ 780,00'),
                      const SizedBox(height: 12),
                      _buildLegendItem('Outros', Colors.green, 'R\$ 520,00'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFuelEfficiencyCard() {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 340,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Eficiência de Combustível',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEfficiencyGauge(12.8),
                ],
              ),
              const SizedBox(height: 24),
              _buildEfficiencyStat('Média atual', '12.8 km/l'),
              const SizedBox(height: 8),
              _buildEfficiencyStat('Melhor registro', '14.3 km/l'),
              const SizedBox(height: 8),
              _buildEfficiencyStat('Pior registro', '9.2 km/l'),
              const SizedBox(height: 8),
              _buildEfficiencyStat('Média ano passado', '11.9 km/l'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEfficiencyGauge(double efficiency) {
    // Mock gauge with colored indicators
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 10),
            ),
          ),
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: efficiency < 10
                    ? Colors.red
                    : (efficiency < 12 ? Colors.orange : Colors.green),
                width: 10,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                efficiency.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'km/l',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildYearlyComparisonChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparação Anual de Gastos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1500,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            'Jan',
                            'Fev',
                            'Mar',
                            'Abr',
                            'Mai',
                            'Jun',
                            'Jul',
                            'Ago',
                            'Set',
                            'Out',
                            'Nov',
                            'Dez'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text('');
                        },
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
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    _makeGroupData(0, 800, 950),
                    _makeGroupData(1, 750, 820),
                    _makeGroupData(2, 900, 850),
                    _makeGroupData(3, 1100, 980),
                    _makeGroupData(4, 950, 1050),
                    _makeGroupData(5, 1200, 1100),
                    _makeGroupData(6, 1300, 1150),
                    _makeGroupData(7, 1050, 1200),
                    _makeGroupData(8, 950, 900),
                    _makeGroupData(9, 1000, 930),
                    _makeGroupData(10, 850, 920),
                    _makeGroupData(11, 1100, 980),
                  ],
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegendItem('2024', Colors.blue),
                const SizedBox(width: 24),
                _buildChartLegendItem('2023', Colors.grey[400]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.blue,
          width: 8,
          borderRadius: BorderRadius.circular(2),
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.grey[400],
          width: 8,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _CardData(
        title: 'Total Gasto em 2024',
        value: 'R\$ 5.230,00',
        icon: Icons.attach_money,
        color: Colors.green,
        trend: '+12.5% vs 2023',
      ),
      const _CardData(
        title: 'Litros Abastecidos',
        value: '487 L',
        icon: Icons.local_gas_station,
        color: Colors.blue,
        trend: '+8.2% vs 2023',
      ),
      const _CardData(
        title: 'Distância Percorrida',
        value: '6.243 km',
        icon: Icons.speed,
        color: Colors.purple,
        trend: '+15.7% vs 2023',
      ),
      const _CardData(
        title: 'Manutenções',
        value: '5',
        icon: Icons.build,
        color: Colors.orange,
        trend: '-2 vs 2023',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1024 ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        for (final card in cards)
          _buildSummaryCard(
            card.title,
            card.value,
            card.icon,
            card.color,
            card.trend,
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, String trend) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trend,
              style: TextStyle(
                fontSize: 12,
                color: trend.contains('+') ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _CardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });
}
