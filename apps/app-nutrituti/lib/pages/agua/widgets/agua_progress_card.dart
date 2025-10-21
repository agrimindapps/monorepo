// Flutter imports:
import 'package:flutter/material.dart';

class AguaProgressCard extends StatelessWidget {
  final double dailyWaterGoal;
  final double todayProgress;
  final VoidCallback onAjustarMeta;

  const AguaProgressCard({
    super.key,
    required this.dailyWaterGoal,
    required this.todayProgress,
    required this.onAjustarMeta,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Meta Diária de Água',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: todayProgress / dailyWaterGoal,
                        backgroundColor: Colors.blue[100],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 10,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(todayProgress / dailyWaterGoal * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${todayProgress.toInt()}ml',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Meta: ${dailyWaterGoal.toInt()}ml',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: onAjustarMeta,
                      child: const Text('Ajustar Meta'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
