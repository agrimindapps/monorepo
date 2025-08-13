// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade800,
            Colors.green.shade900,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'ReceiturAgro em Números',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estatísticas que mostram o impacto do nosso aplicativo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 50),
          isSmallScreen ? _buildMobileStats() : _buildDesktopStats(),
        ],
      ),
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        _buildStatItem(
          icon: FontAwesome.download_solid,
          number: '100k+',
          label: 'Downloads',
        ),
        const SizedBox(height: 30),
        _buildStatItem(
          icon: FontAwesome.user_solid,
          number: '50k+',
          label: 'Usuários Ativos',
        ),
        const SizedBox(height: 30),
        _buildStatItem(
          icon: FontAwesome.database_solid,
          number: '5k+',
          label: 'Registros de Pragas',
        ),
        const SizedBox(height: 30),
        _buildStatItem(
          icon: FontAwesome.flask_solid,
          number: '2k+',
          label: 'Defensivos Catalogados',
        ),
      ],
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildStatItem(
            icon: FontAwesome.download_solid,
            number: '100k+',
            label: 'Downloads',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: FontAwesome.user_solid,
            number: '50k+',
            label: 'Usuários Ativos',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: FontAwesome.database_solid,
            number: '5k+',
            label: 'Registros de Pragas',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: FontAwesome.flask_solid,
            number: '2k+',
            label: 'Defensivos Catalogados',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String number,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          number,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
