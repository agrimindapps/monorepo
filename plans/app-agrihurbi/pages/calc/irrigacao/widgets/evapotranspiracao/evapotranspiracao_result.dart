// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../controllers/evapotranspiracao_controller.dart';

class EvapotranspiracaoResult extends StatelessWidget {
  final EvapotranspiracaoController controller;
  final Animation<double> animation;

  EvapotranspiracaoResult({
    super.key,
    required this.controller,
    required this.animation,
  });

  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  void _compartilhar() {
    final shareText = '''
    Evapotranspiração da Cultura (ETc)

    Valores
    Evapotranspiração de Referência (ETo): ${_numberFormat.format(controller.evapotranspiracaoReferencia)} mm/dia
    Coeficiente de Cultura (Kc): ${_numberFormat.format(controller.coeficienteCultura)}
    Coeficiente de Estresse (Ks): ${_numberFormat.format(controller.coeficienteEstresse)}

    Resultado
    Evapotranspiração da Cultura (ETc): ${_numberFormat.format(controller.evapotranspiracaoCultura)} mm/dia
    
    Calculado com App FNutriTuti
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultHeader(),
              _buildResultValue(),
              const Divider(),
              _buildResultChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Resultados do Cálculo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _compartilhar,
            icon: const Icon(Icons.share, size: 20),
            tooltip: 'Compartilhar',
          ),
        ],
      ),
    );
  }

  Widget _buildResultValue() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo dos dados informados:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                  'ETo: ${_numberFormat.format(controller.evapotranspiracaoReferencia)} mm/dia',
                  FontAwesome.cloud_sun_rain_solid),
              _buildInfoChip(
                  'Kc: ${_numberFormat.format(controller.coeficienteCultura)}',
                  FontAwesome.leaf_solid),
              _buildInfoChip(
                  'Ks: ${_numberFormat.format(controller.coeficienteEstresse)}',
                  FontAwesome.link_slash_solid),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),

        // Resultado principal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FontAwesome.cloud_sun_solid,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Evapotranspiração da Cultura (ETc):',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${_numberFormat.format(controller.evapotranspiracaoCultura)} mm/dia',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildExplanationCard(),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade700,
        ),
      ),
      avatar: Icon(
        icon,
        size: 14,
        color: Colors.grey.shade700,
      ),
      backgroundColor: Colors.grey.shade100,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesome.lightbulb_solid,
            size: 18,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A evapotranspiração da cultura representa a quantidade de água que sua plantação necessita diariamente.',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultChart() {
    final barData = [
      controller.evapotranspiracaoReferencia.toDouble(),
      controller.evapotranspiracaoCultura.toDouble(),
    ];

    return SizedBox(
      height: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparativo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: barData.reduce(
                        (value, element) => value > element ? value : element) *
                    1.2,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _numberFormat.format(value),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = ['ETo', 'ETc'];
                        if (value >= 0 && value < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: barData.reduce((value, element) =>
                          value > element ? value : element) /
                      5,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: barData[0],
                        color: Colors.blue.shade300,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: barData[1],
                        color: Colors.blue.shade700,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ETo (Referência)',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ETc (Cultura)',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
