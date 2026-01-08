import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_minigames/features/home/presentation/pages/home_page.dart';
import 'package:app_minigames/features/tower/presentation/pages/tower_page.dart';
import 'package:app_minigames/features/tictactoe/presentation/pages/tictactoe_page.dart';
import 'package:app_minigames/features/campo_minado/presentation/pages/campo_minado_page.dart';
import 'package:app_minigames/features/sudoku/presentation/pages/sudoku_page.dart';
import 'package:app_minigames/features/snake/presentation/pages/snake_page.dart';
import 'package:app_minigames/features/memory/presentation/pages/memory_game_page.dart';
import 'package:app_minigames/features/game_2048/presentation/pages/game_2048_page.dart';
import 'package:app_minigames/features/flappbird/presentation/pages/flappbird_page.dart';
import 'package:app_minigames/features/pingpong/presentation/pages/pingpong_page.dart';
import 'package:app_minigames/features/quiz/presentation/pages/quiz_page.dart';
import 'package:app_minigames/features/quiz_image/presentation/pages/quiz_image_page.dart';
import 'package:app_minigames/features/caca_palavra/presentation/pages/caca_palavra_page.dart';
import 'package:app_minigames/features/soletrando/presentation/pages/soletrando_page.dart';
import 'package:app_minigames/features/dino_run/presentation/dino_run_page.dart';
import 'package:app_minigames/features/arkanoid/presentation/pages/arkanoid_page.dart';
import 'package:app_minigames/features/simon_says/presentation/pages/simon_says_page.dart';
import 'package:app_minigames/features/connect_four/presentation/pages/connect_four_page.dart';
import 'package:app_minigames/features/space_invaders/presentation/pages/space_invaders_page.dart';
import 'package:app_minigames/features/asteroids/presentation/pages/asteroids_page.dart';
import 'package:app_minigames/features/damas/presentation/pages/damas_page.dart';
import 'package:app_minigames/features/reversi/presentation/pages/reversi_page.dart';
import 'package:app_minigames/features/batalha_naval/presentation/pages/batalha_naval_page.dart';
import 'package:app_minigames/features/frogger/presentation/pages/frogger_page.dart';
import 'package:app_minigames/features/tetris/presentation/pages/tetris_page.dart';
import 'package:app_minigames/features/galaga/presentation/pages/galaga_page.dart';
import 'package:app_minigames/features/centipede/presentation/pages/centipede_page.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    // Game routes
    GoRoute(
      path: '/tower',
      builder: (context, state) => const TowerPage(),
    ),
    GoRoute(
      path: '/tictactoe',
      builder: (context, state) => const TicTacToePage(),
    ),
    GoRoute(
      path: '/campo-minado',
      builder: (context, state) => const CampoMinadoPage(),
    ),
    GoRoute(
      path: '/sudoku',
      builder: (context, state) => const SudokuPage(),
    ),
    GoRoute(
      path: '/snake',
      builder: (context, state) => const SnakePage(),
    ),
    GoRoute(
      path: '/memory',
      builder: (context, state) => const MemoryGamePage(),
    ),
    GoRoute(
      path: '/2048',
      builder: (context, state) => const Game2048Page(),
    ),
    GoRoute(
      path: '/flappbird',
      builder: (context, state) => const FlappbirdPage(),
    ),
    GoRoute(
      path: '/pingpong',
      builder: (context, state) => const PingpongPage(),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizPage(),
    ),
    GoRoute(
      path: '/quiz-image',
      builder: (context, state) => const QuizImagePage(),
    ),
    GoRoute(
      path: '/caca-palavra',
      builder: (context, state) => const CacaPalavraPage(),
    ),
    GoRoute(
      path: '/soletrando',
      builder: (context, state) => const SoletrandoPage(),
    ),
    GoRoute(
      path: '/dino-run',
      builder: (context, state) => const DinoRunPage(),
    ),
    GoRoute(
      path: '/arkanoid',
      builder: (context, state) => const ArkanoidPage(),
    ),
    GoRoute(
      path: '/simon-says',
      builder: (context, state) => const SimonSaysPage(),
    ),
    GoRoute(
      path: '/connect-four',
      builder: (context, state) => const ConnectFourPage(),
    ),
    GoRoute(
      path: '/space-invaders',
      builder: (context, state) => const SpaceInvadersPage(),
    ),
    GoRoute(
      path: '/asteroids',
      builder: (context, state) => const AsteroidsPage(),
    ),
    GoRoute(
      path: '/damas',
      builder: (context, state) => const DamasPage(),
    ),
    GoRoute(
      path: '/reversi',
      builder: (context, state) => const ReversiPage(),
    ),
    GoRoute(
      path: '/batalha-naval',
      builder: (context, state) => const BatalhaNavalPage(),
    ),
    GoRoute(
      path: '/frogger',
      builder: (context, state) => const FroggerPage(),
    ),
    GoRoute(
      path: '/tetris',
      builder: (context, state) => const TetrisPage(),
    ),
    GoRoute(
      path: '/galaga',
      builder: (context, state) => const GalagaPage(),
    ),
    GoRoute(
      path: '/centipede',
      builder: (context, state) => const CentipedePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.uri.path}'),
    ),
  ),
);
