// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Funcionalidades Principais',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Conheça todas as ferramentas que o ReceiturAgro oferece',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 60),
          _buildFeaturesGrid(context),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      {
        'icon': FontAwesome.bug_solid,
        'title': 'Identificação de Pragas',
        'description':
            'Catálogo completo com mais de 1.000 pragas, insetos e doenças que afetam as lavouras.',
        'color': Colors.orange.shade700,
      },
      {
        'icon': FontAwesome.flask_solid,
        'title': 'Defensivos Agrícolas',
        'description':
            'Base de dados com todos os defensivos registrados no MAPA e suas informações técnicas.',
        'color': Colors.blue.shade700,
      },
      {
        'icon': FontAwesome.chart_column_solid,
        'title': 'Diagnósticos',
        'description':
            'Inteligência para diagnóstico e recomendação personalizada para cada situação específica.',
        'color': Colors.purple.shade700,
      },
      {
        'icon': FontAwesome.seedling_solid,
        'title': 'Culturas',
        'description':
            'Informações detalhadas sobre diversas culturas e suas pragas mais comuns.',
        'color': Colors.green.shade700,
      },
      {
        'icon': FontAwesome.heart_solid,
        'title': 'Favoritos',
        'description':
            'Salve suas pragas, defensivos e diagnósticos favoritos para acesso rápido.',
        'color': Colors.red.shade700,
      },
      {
        'icon': FontAwesome.share_nodes_solid,
        'title': 'Compartilhamento',
        'description':
            'Compartilhe informações com outros produtores, técnicos e consultores agrícolas.',
        'color': Colors.teal.shade700,
      },
    ];

    final Size screenSize = MediaQuery.of(context).size;
    final int crossAxisCount = _getCrossAxisCount(screenSize.width);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: _getChildAspectRatio(screenSize.width),
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _buildFeatureCard(
              icon: features[index]['icon'] as IconData,
              title: features[index]['title'] as String,
              description: features[index]['description'] as String,
              color: features[index]['color'] as Color,
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) {
      return 3;
    } else if (width > 800) {
      return 2;
    } else {
      return 1;
    }
  }

  double _getChildAspectRatio(double width) {
    if (width > 1200) {
      return 1.2;
    } else if (width > 800) {
      return 1.3;
    } else {
      return 1.5;
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
