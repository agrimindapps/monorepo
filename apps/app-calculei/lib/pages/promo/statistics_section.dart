// Flutter imports:
import 'package:flutter/material.dart';

class StatisticsSection extends StatelessWidget {
  final List<Map<String, dynamic>> statistics;

  const StatisticsSection({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Column(
        children: [
          const Text(
            'Calculei em Números',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: statistics
                      .map((stat) => _buildStatCard(
                            value: stat['value'],
                            label: stat['label'],
                            icon: stat['icon'],
                            context: context,
                          ))
                      .toList(),
                );
              } else {
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: statistics
                      .map((stat) => SizedBox(
                            width: (constraints.maxWidth - 60) / 2,
                            child: _buildStatCard(
                              value: stat['value'],
                              label: stat['label'],
                              icon: stat['icon'],
                              context: context,
                            ),
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Card de estatística
  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 36,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
