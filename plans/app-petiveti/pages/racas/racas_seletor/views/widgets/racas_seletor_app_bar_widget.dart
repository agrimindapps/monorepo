// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/page_header_widget.dart';
import '../../controllers/racas_seletor_controller.dart';

class RacasSeletorAppBarWidget extends StatelessWidget {
  final RacasSeletorController controller;

  const RacasSeletorAppBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageHeaderWidget(
      title: 'Espécies Animais',
      subtitle: _buildSubtitle(),
      icon: Icons.pets,
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Estatísticas',
          onPressed: () => _showEstatisticas(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
          onPressed: controller.recarregar,
        ),
      ],
    );
  }

  String _buildSubtitle() {
    if (controller.isLoading) {
      return 'Carregando espécies...';
    }
    
    if (controller.hasError) {
      return 'Erro ao carregar espécies';
    }

    final stats = controller.estatisticas;
    return 'Explore ${stats['totalEspecies']} espécies e ${stats['totalRacas']} raças';
  }

  void _showEstatisticas(BuildContext context) {
    final stats = controller.estatisticas;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.blue),
            SizedBox(width: 8),
            Text('Estatísticas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatItem('Total de Espécies', '${stats['totalEspecies']}', Icons.category),
            _buildStatItem('Total de Raças', '${stats['totalRacas']}', Icons.pets),
            _buildStatItem('Espécies com Raças', '${stats['especiesComRacas']}', Icons.check_circle),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
