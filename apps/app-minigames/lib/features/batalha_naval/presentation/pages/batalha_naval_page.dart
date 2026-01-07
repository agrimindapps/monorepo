import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/batalha_naval_entities.dart';
import '../providers/batalha_naval_controller.dart';
import '../widgets/batalha_naval_widgets.dart';

class BatalhaNavalPage extends ConsumerWidget {
  const BatalhaNavalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batalhaNavalControllerProvider);
    final notifier = ref.read(batalhaNavalControllerProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        title: const Text('Batalha Naval'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: notifier.reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: state.phase == GamePhase.gameOver
                  ? (state.winner == 'Jogador' ? Colors.green.shade800 : Colors.red.shade800)
                  : Colors.blue.shade900,
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Ship placement info
            if (state.phase == GamePhase.placing)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ShipPlacementInfo(
                  currentShip: state.currentShipType,
                  orientation: state.orientation,
                  onRotate: notifier.toggleOrientation,
                ),
              ),

            // Game boards
            Expanded(
              child: isWide
                  ? _buildWideLayout(state, notifier)
                  : _buildNarrowLayout(state, notifier),
            ),

            // Fleet status during play
            if (state.phase == GamePhase.playing && state.playerShips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FleetStatus(ships: state.playerShips, title: 'Sua Frota'),
                    FleetStatus(ships: state.enemyShips, title: 'Frota Inimiga'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BatalhaNavalState state, BatalhaNavalController notifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: BattleGrid(
              board: state.playerBoard,
              title: 'Seu Tabuleiro',
              showShips: true,
              onCellTap: state.phase == GamePhase.placing
                  ? (r, c) => notifier.placeShip(r, c)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BattleGrid(
              board: state.enemyBoardView,
              title: 'Tabuleiro Inimigo',
              isEnemy: true,
              showShips: false,
              onCellTap: state.phase == GamePhase.playing && state.isPlayerTurn
                  ? (r, c) => notifier.attack(r, c)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BatalhaNavalState state, BatalhaNavalController notifier) {
    return DefaultTabController(
      length: 2,
      initialIndex: state.phase == GamePhase.placing ? 0 : 1,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Seu Tabuleiro'),
              Tab(text: 'Atacar'),
            ],
            indicatorColor: Colors.cyan,
            labelColor: Colors.white,
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BattleGrid(
                    board: state.playerBoard,
                    title: '',
                    showShips: true,
                    onCellTap: state.phase == GamePhase.placing
                        ? (r, c) => notifier.placeShip(r, c)
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BattleGrid(
                    board: state.enemyBoardView,
                    title: '',
                    isEnemy: true,
                    showShips: false,
                    onCellTap: state.phase == GamePhase.playing && state.isPlayerTurn
                        ? (r, c) => notifier.attack(r, c)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
