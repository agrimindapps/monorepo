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
                  text: 'Em ',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const TextSpan(
                  text: 'Números',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF673AB7),
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
              'Estatísticas que demonstram o poder do NebulaList',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: isMobile ? _buildMobileStats() : _buildDesktopStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '10K+',
            'Downloads',
            'Em breve',
            Icons.people,
            const Color(0xFF673AB7),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            '50K+',
            'Tarefas Completadas',
            'Por nossos usuários',
            Icons.task_alt,
            const Color(0xFF00BCD4),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            '4.8★',
            'Avaliação',
            'Na loja de apps',
            Icons.star,
            const Color(0xFFFFC107),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            '99%',
            'Satisfação',
            'Dos usuários',
            Icons.sentiment_very_satisfied,
            const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '10K+',
                'Downloads',
                'Em breve',
                Icons.people,
                const Color(0xFF673AB7),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                '50K+',
                'Tarefas Completadas',
                'Por nossos usuários',
                Icons.task_alt,
                const Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '4.8★',
                'Avaliação',
                'Na loja de apps',
                Icons.star,
                const Color(0xFFFFC107),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                '99%',
                'Satisfação',
                'Dos usuários',
                Icons.sentiment_very_satisfied,
                const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String number,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
