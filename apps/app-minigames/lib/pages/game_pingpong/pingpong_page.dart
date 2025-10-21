// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'ping_pong_game.dart';

class PingPongPage extends StatelessWidget {
  static const String title = 'Ping Pong';
  static const String subtitle = 'Um clássico jogo de Ping Pong';
  static const String icon = 'assets/imagens/others/games/pong.png';

  const PingPongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          // Header da página
          Padding(
            padding: EdgeInsets.all(16.0),
            child: PageHeaderWidget(
              title: 'Ping Pong',
              subtitle: 'Jogue o clássico tênis de mesa virtual',
              icon: Icons.sports_tennis,
              showBackButton: true,
            ),
          ),
          // Área do jogo
          Expanded(
            child: PingPongGame(),
          ),
        ],
      ),
    );
  }
}
