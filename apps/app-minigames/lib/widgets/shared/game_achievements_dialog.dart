import 'package:flutter/material.dart';

/// Generic achievements dialog that can be used by any game
/// 
/// This widget eliminates code duplication across game features.
/// Each game provides its own achievement data through the builder pattern.
class GameAchievementsDialog extends StatelessWidget {
  final String gameTitle;
  final AchievementStats stats;
  final AsyncSnapshot<List<AchievementItem>> achievementsSnapshot;
  final Color primaryColor;
  final Color secondaryColor;

  const GameAchievementsDialog({
    super.key,
    required this.gameTitle,
    required this.stats,
    required this.achievementsSnapshot,
    this.primaryColor = Colors.amber,
    this.secondaryColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildSummary(),
            Expanded(
              child: _buildContent(),
            ),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.3),
            secondaryColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conquistas - $gameTitle',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${stats.unlocked}/${stats.total} desbloqueadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCompletionColor(stats.completionPercent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${stats.completionPercent.toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('XP Total', stats.totalXp.toString(), Icons.star),
          _buildStat(
            'Maior Raridade',
            stats.highestRarity ?? '-',
            Icons.diamond,
            color: stats.highestRarityColor,
          ),
          _buildStat(
            'Restantes',
            stats.remaining.toString(),
            Icons.lock_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (achievementsSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (achievementsSnapshot.hasError) {
      return Center(
        child: Text(
          'Erro: ${achievementsSnapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final achievements = achievementsSnapshot.data ?? [];
    
    if (achievements.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma conquista disponível',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return _buildAchievementsList(achievements);
  }

  Widget _buildAchievementsList(List<AchievementItem> achievements) {
    // Group by category
    final Map<String, List<AchievementItem>> grouped = {};
    for (final achievement in achievements) {
      grouped.putIfAbsent(achievement.category, () => []).add(achievement);
    }

    return DefaultTabController(
      length: grouped.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white60,
            indicatorColor: primaryColor,
            tabs: grouped.keys.map((category) {
              final categoryAchievements = grouped[category]!;
              final unlockedCount = categoryAchievements
                  .where((a) => a.isUnlocked)
                  .length;
              
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(categoryAchievements.first.categoryEmoji),
                    const SizedBox(width: 4),
                    Text(category),
                    const SizedBox(width: 4),
                    Text(
                      '($unlockedCount/${categoryAchievements.length})',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: grouped.values.map((categoryAchievements) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryAchievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(categoryAchievements[index]);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementItem achievement) {
    final isLocked = !achievement.isUnlocked;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked 
            ? Colors.grey[850]
            : achievement.rarityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked 
              ? Colors.grey[700]! 
              : achievement.rarityColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isLocked 
                  ? Colors.grey[800]
                  : achievement.rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isLocked && achievement.isSecret ? '❓' : achievement.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isLocked && achievement.isSecret 
                            ? 'Conquista Secreta' 
                            : achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: achievement.rarityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        achievement.rarity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: achievement.rarityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isLocked && achievement.isSecret 
                      ? 'Continue jogando para descobrir'
                      : achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLocked 
                        ? Colors.grey[600]
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                // Progress
                if (!achievement.isUnlocked && !achievement.isSecret)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation(achievement.rarityColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.currentProgress}/${achievement.target}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                // Unlocked info
                if (achievement.isUnlocked)
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Desbloqueada',
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${achievement.xpReward} XP',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text(
          'Fechar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getCompletionColor(double percent) {
    if (percent >= 100) return Colors.green;
    if (percent >= 75) return Colors.blue;
    if (percent >= 50) return Colors.orange;
    if (percent >= 25) return Colors.deepOrange;
    return Colors.red;
  }
}

/// Stats data class for achievements
class AchievementStats {
  final int unlocked;
  final int total;
  final int totalXp;
  final String? highestRarity;
  final Color? highestRarityColor;
  final int remaining;
  final double completionPercent;

  const AchievementStats({
    required this.unlocked,
    required this.total,
    required this.totalXp,
    this.highestRarity,
    this.highestRarityColor,
    required this.remaining,
    required this.completionPercent,
  });
}

/// Individual achievement data
class AchievementItem {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String category;
  final String categoryEmoji;
  final String rarity;
  final Color rarityColor;
  final int xpReward;
  final bool isUnlocked;
  final bool isSecret;
  final int currentProgress;
  final int target;
  
  double get progress => target > 0 ? currentProgress / target : 0.0;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.categoryEmoji,
    required this.rarity,
    required this.rarityColor,
    required this.xpReward,
    required this.isUnlocked,
    this.isSecret = false,
    this.currentProgress = 0,
    this.target = 1,
  });
}
