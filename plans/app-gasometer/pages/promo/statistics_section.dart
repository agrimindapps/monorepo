// Flutter imports:
import 'package:flutter/material.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isMobile ? 24 : screenSize.width * 0.08,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Estatísticas ',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'do Futuro',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const Text(
              'Aqui você poderá acompanhar o crescimento do GasOMeter em tempo real',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),

          // Layout adaptável para diferentes tamanhos de tela
          _buildResponsiveStatGrid(context),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Lista de estatísticas zeradas para pré-lançamento
    final statItems = [
      _buildStatData(
          '0', 'Downloads do App', Icons.download, Colors.blue[800]!),
      _buildStatData(
          '0', 'Sessões Iniciadas', Icons.play_arrow, Colors.green[700]!),
      _buildStatData('0', 'Veículos Registrados', Icons.directions_car,
          Colors.purple[700]!),
      _buildStatData(
          '0 km', 'Quilômetros Registrados', Icons.speed, Colors.orange[700]!),
    ];

    // Layout responsivo baseado no tamanho da tela
    if (screenWidth < 600) {
      // Mobile: Uma coluna vertical
      return Column(
        children: statItems
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildStatItem(item['value']!, item['label']!,
                      item['icon']!, item['color']!),
                ))
            .toList(),
      );
    } else if (screenWidth < 1000) {
      // Tablet: Duas colunas
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: statItems.length,
        itemBuilder: (context, index) {
          final item = statItems[index];
          return _buildStatItem(
              item['value']!, item['label']!, item['icon']!, item['color']!);
        },
      );
    } else {
      // Desktop: Linha horizontal ou mais colunas para telas muito grandes
      return LayoutBuilder(
        builder: (context, constraints) {
          // Determinar quantos itens cabem na largura baseado no espaço disponível
          final double availableWidth = constraints.maxWidth;
          final int columns = (availableWidth / 300).floor().clamp(1, 4);

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.spaceEvenly,
            children: statItems.map((item) {
              return SizedBox(
                width: (availableWidth / columns) - 24,
                child: _buildStatItem(item['value']!, item['label']!,
                    item['icon']!, item['color']!),
              );
            }).toList(),
          );
        },
      );
    }
  }

  Map<String, dynamic> _buildStatData(
      String value, String label, IconData icon, Color color) {
    return {
      'value': value,
      'label': label,
      'icon': icon,
      'color': color,
    };
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Container(
      width: double.infinity, // Ocupa todo o espaço disponível dentro do pai
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color.withValues(alpha: 0.3),
              ),
              // Overlay de "loading" para indicar que está zerado
              if (value == '0' || value == '0 km')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Text(
                    'EM BREVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: value == '0' || value == '0 km' ? Colors.grey[400] : color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: value == '0' || value == '0 km'
                  ? Colors.grey[400]
                  : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
