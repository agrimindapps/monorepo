// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:app_minigames/models/game_info.dart';
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'package:app_minigames/widgets/game_card.dart';
import 'game_2048/game_2048_page.dart';
import 'game_caca_palavra/game_caca_palavra_page.dart';
import 'game_campo_minado/campo_minado_page.dart';
import 'game_flappbird/game_flappbird_page.dart';
import 'game_memory/game_memory_page.dart';
import 'game_pingpong/pingpong_page.dart';
import 'game_quiz/game_quiz_page.dart';
import 'game_quiz_image/game_quiz_image_page.dart';
import 'game_snake/game_snake_page.dart';
import 'game_soletrando/game_soletrando_page.dart';
import 'game_sudoku/game_sudoku_page.dart';
import 'game_tictactoe/game_tictactoe_page.dart';
import '../features/tower/presentation/pages/tower_page.dart';

class DesktopPageMain extends StatefulWidget {
  const DesktopPageMain({super.key});

  @override
  State<DesktopPageMain> createState() => _DesktopPageMainState();
}

class _DesktopPageMainState extends State<DesktopPageMain> {
  final List<GameInfo> games = [
    GameInfo(
      title: '2048',
      description: 'Combine os números para chegar ao 2048!',
      icon: Icons.grid_4x4,
      color: Colors.blue,
      page: const Game2048Page(),
    ),
    GameInfo(
      title: 'Jogo da Memória',
      description: 'Encontre os pares de cartas combinando os emojis',
      icon: Icons.memory,
      color: Colors.green,
      page: const MemoryGame(),
    ),
    GameInfo(
      title: 'Quiz de Imagens',
      description: 'Adivinhe o nome correto das imagens',
      icon: Icons.image,
      color: Colors.purple,
      page: const QuizGamePage(),
    ),
    GameInfo(
      title: 'Quiz de Texto',
      description: 'Teste seus conhecimentos respondendo perguntas',
      icon: Icons.quiz,
      color: Colors.orange,
      page: const QuizPage(),
    ),
    GameInfo(
      title: 'Soletrando',
      description: 'Descubra a palavra letra por letra',
      icon: Icons.spellcheck,
      color: Colors.red,
      page: const GameSoletrandoPage(),
    ),
    GameInfo(
      title: 'Caça Palavras',
      description: 'Encontre palavras escondidas na grade de letras',
      icon: Icons.search,
      color: Colors.teal,
      page: const CacaPalavrasGame(),
    ),
    GameInfo(
      title: 'Sudoku',
      description: 'Complete o tabuleiro usando números de 1 a 9',
      icon: Icons.grid_on,
      color: Colors.indigo,
      page: const GameSudokuPage(),
    ),
    GameInfo(
      title: 'Tower Stack',
      description: 'Empilhe blocos e construa a torre mais alta possível',
      icon: Icons.architecture,
      color: Colors.amber,
      page: const TowerPage(),
    ),
    GameInfo(
      title: 'Snake',
      description: 'Controle a cobrinha e coma as frutas sem colidir',
      icon: Icons.line_style,
      color: Colors.lightGreen,
      page: const SnakeGame(),
    ),
    GameInfo(
      title: 'Flappy Bird',
      description: 'Voe entre os obstáculos e marque pontos',
      icon: Icons.flight,
      color: Colors.orangeAccent,
      page: const FlappyBirdGame(),
    ),
    GameInfo(
      title: 'Jogo da Velha',
      description: 'Desafie-se no clássico jogo de X e O',
      icon: Icons.grid_3x3,
      color: Colors.deepPurple,
      page: const TicTacToeGame(),
    ),
    GameInfo(
      title: 'Ping Pong',
      description: 'Jogue o clássico tênis de mesa virtual',
      icon: Icons.sports_tennis,
      color: Colors.pink,
      page: const PingPongPage(),
    ),
    GameInfo(
      title: 'Campo Minado',
      description: 'Encontre todas as células seguras sem pisar nas minas',
      icon: Icons.flag,
      color: Colors.deepOrange,
      page: const CampoMinadoPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHeaderWidget(
                    title: 'Mini Games',
                    subtitle: 'Escolha um jogo para se divertir e aprender!',
                    icon: Icons.games,
                  ),
                  const SizedBox(height: 24),
                  AlignedGridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      return GameCard(
                        game: games[index],
                        isMobile: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
