import 'package:flutter/material.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B), // Emerald 900
            Color(0xFF047857), // Emerald 700
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Números que Inspiram',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Junte-se a milhares de pessoas transformando suas vidas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.green[100],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          isMobile ? _buildMobileStats() : _buildDesktopStats(),
        ],
      ),
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('10k+', 'Usuários Ativos', Icons.people),
        _buildStatCard('500k+', 'Refeições Registradas', Icons.restaurant),
        _buildStatCard('95%', 'Taxa de Satisfação', Icons.thumb_up),
        _buildStatCard('4.8', 'Avaliação Média', Icons.star),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('10k+', 'Usuários Ativos', Icons.people)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('500k+', 'Refeições', Icons.restaurant)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildStatCard('95%', 'Satisfação', Icons.thumb_up)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('4.8', 'Avaliação', Icons.star)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green[300], size: 40),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[100],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
