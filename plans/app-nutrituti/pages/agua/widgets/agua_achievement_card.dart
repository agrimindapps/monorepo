// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/achievement_model.dart';

class AguaAchievementCard extends StatelessWidget {
  final RxList<WaterAchievement> achievements;

  const AguaAchievementCard({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conquistas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: achievements
                      .map((achievement) => Tooltip(
                            message: achievement.description,
                            child: Chip(
                              avatar: Text(achievement.title.split(' ')[0]),
                              label: Text(achievement.title.split(' ')[1]),
                              backgroundColor: achievement.isUnlocked
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                            ),
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }
}
