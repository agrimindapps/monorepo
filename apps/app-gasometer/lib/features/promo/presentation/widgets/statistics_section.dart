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
              'Projetos para quando o GasOMeter estiver em funcionamento',
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
            'Usuários Esperados',
            'No primeiro ano',
            Icons.people,
            Colors.blue[700]!,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            '50M+',
            'Litros Monitorados',
            'Por mês',
            Icons.local_gas_station,
            Colors.green[700]!,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            '30%',
            'Economia Média',
            'Em combustível',
            Icons.savings,
            Colors.amber[700]!,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            '99.9%',
            'Disponibilidade',
            'Do sistema',
            Icons.cloud_done,
            Colors.purple[700]!,
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
                'Usuários Esperados',
                'No primeiro ano',
                Icons.people,
                Colors.blue[700]!,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                '50M+',
                'Litros Monitorados',
                'Por mês',
                Icons.local_gas_station,
                Colors.green[700]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '30%',
                'Economia Média',
                'Em combustível',
                Icons.savings,
                Colors.amber[700]!,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                '99.9%',
                'Disponibilidade',
                'Do sistema',
                Icons.cloud_done,
                Colors.purple[700]!,
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
