import 'package:core/core.dart';
import 'package:flutter/material.dart';

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

import 'page_transitions.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider para o GoRouter com Analytics integrado
final appRouterProvider = Provider<GoRouter>((ref) {
  final analyticsObserver = ref.watch(
    analyticsRouteObserverFamilyProvider('minigames_'),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: [analyticsObserver],
    routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const HomePage(),
        state: state,
      ),
    ),
    // Game routes with fade transitions
    GoRoute(
      path: '/tower',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const TowerPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/tictactoe',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const TicTacToePage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/campo-minado',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const CampoMinadoPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/sudoku',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const SudokuPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/snake',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const SnakePage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/memory',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const MemoryGamePage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/2048',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const Game2048Page(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/flappbird',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const FlappbirdPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/pingpong',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const PingpongPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/quiz',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const QuizPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/quiz-image',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const QuizImagePage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/caca-palavra',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const CacaPalavraPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/soletrando',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const SoletrandoPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/dino-run',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const DinoRunPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/arkanoid',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const ArkanoidPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/simon-says',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const SimonSaysPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/connect-four',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const ConnectFourPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/space-invaders',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const SpaceInvadersPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/asteroids',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const AsteroidsPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/damas',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const DamasPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/reversi',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const ReversiPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/batalha-naval',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const BatalhaNavalPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/frogger',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const FroggerPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/tetris',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const TetrisPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/galaga',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const GalagaPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/centipede',
      pageBuilder: (context, state) => fadeTransitionPage(
        child: const CentipedePage(),
        state: state,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.uri.path}'),
    ),
  ),
);
});

/// Mantido para compatibilidade - usar appRouterProvider quando possível
/// @deprecated Use appRouterProvider em Consumer widgets
GoRouter get appRouter => throw UnsupportedError(
      'Use appRouterProvider com ref.watch/read dentro de Consumer widgets',
    );
