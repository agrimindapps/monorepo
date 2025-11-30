// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/achievement_model.dart';

class AchievementsCardWidget extends StatelessWidget {
  final List<WeightAchievement> achievements;

  const AchievementsCardWidget({
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: achievement.isUnlocked
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              achievement.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: achievement.isUnlocked
                                    ? Colors.green[800]
                                    : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                achievement.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: achievement.isUnlocked
                                      ? Colors.green[800]
                                      : Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              achievement.isUnlocked
                                  ? Icons.check_circle
                                  : Icons.lock,
                              color: achievement.isUnlocked
                                  ? Colors.green
                                  : Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
