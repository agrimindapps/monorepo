// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/tictactoe_controller.dart';

class StatisticsDialog extends StatelessWidget {
  final TicTacToeController controller;
  
  const StatisticsDialog({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    final stats = controller.getDetailedStats();
    final tips = controller.getGameTips();
    
    return AlertDialog(
      title: const Text('Estatísticas Detalhadas'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatSection('Desempenho Geral', [
              'Taxa de Vitória: ${stats['winRate']}%',
              'Duração Média: ${stats['averageGameDuration']}',
              'Total de Jogos: ${stats['totalGames']}',
            ]),
            const SizedBox(height: 16),
            if (tips.isNotEmpty) ...[
              _buildStatSection('Dicas Personalizadas', tips),
              const SizedBox(height: 16),
            ],
            if (stats['preferredPositions'] != null && 
                (stats['preferredPositions'] as Map).isNotEmpty) ...[
              _buildPositionHeatmap(stats['preferredPositions'] as Map<String, int>),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
  
  Widget _buildStatSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Text('• $item'),
        )),
      ],
    );
  }
  
  Widget _buildPositionHeatmap(Map<String, int> positions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posições Preferidas', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final row = index ~/ 3;
              final col = index % 3;
              final key = '$row-$col';
              final count = positions[key] ?? 0;
              final maxCount = positions.values.isNotEmpty 
                ? positions.values.reduce((a, b) => a > b ? a : b) 
                : 1;
              final intensity = count / maxCount;
              
              return Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: intensity * 0.7),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: intensity > 0.5 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Número indica quantas vezes você jogou nesta posição',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
