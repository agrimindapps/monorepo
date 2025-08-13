// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class ApplicationTabsWidget extends StatelessWidget {
  final String dosagem;
  final String vazaoTerrestre;
  final String vazaoAerea;
  final String intervaloAplicacao;
  final String intervaloSeguranca;
  final String tecnologia;
  final double fontSize;
  final bool isDark;

  const ApplicationTabsWidget({
    super.key,
    required this.dosagem,
    required this.vazaoTerrestre,
    required this.vazaoAerea,
    required this.intervaloAplicacao,
    required this.intervaloSeguranca,
    required this.tecnologia,
    required this.fontSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Três abas: Dosagem, Intervalos e Tecnologia
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: TabBarView(
              children: [
                _buildDosagemTab(),
                _buildIntervalosTab(),
                _buildTecnologiaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: isDark ? Colors.green.shade700 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(25.0),
        ),
        labelColor: isDark ? Colors.white : Colors.green.shade800,
        unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        tabs: const [
          Tab(text: 'Dosagem'),
          Tab(text: 'Intervalos'),
          Tab(text: 'Tecnologia'),
        ],
      ),
    );
  }

  Widget _buildDosagemTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            'Dosagem',
            dosagem,
            FontAwesome.droplet_solid,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Vazão (Terrestre)',
            vazaoTerrestre,
            FontAwesome.tractor_solid,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Vazão (Aérea)',
            vazaoAerea,
            FontAwesome.plane_solid,
            Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalosTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            'Intervalo de Aplicação',
            intervaloAplicacao,
            FontAwesome.calendar_days_solid,
            Colors.teal,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Intervalo de Segurança',
            intervaloSeguranca,
            FontAwesome.shield_solid,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTecnologiaTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: tecnologia.isNotEmpty
            ? Text(
                tecnologia,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              )
            : _buildEmptyMessage('Não há informações de tecnologia disponíveis'),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.shade900.withValues(alpha: 0.2) : color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? color.shade700 : color.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? color.shade300 : color.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? color.shade300 : color.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
