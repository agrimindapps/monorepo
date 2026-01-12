import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';

class MemoryHighScoresPage extends ConsumerWidget {
  const MemoryHighScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GamePageLayout(
      title: 'High Scores - Memory',
      accentColor: const Color(0xFF9C27B0),
      maxGameWidth: 600,
      child: Center(
        child: Text(
          'High Scores em desenvolvimento...\n\nJá temos persistência funcionando!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
        ),
      ),
    );
  }
}
