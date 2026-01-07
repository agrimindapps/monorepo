import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/batalha_naval_entities.dart';
import '../providers/batalha_naval_controller.dart';
import '../widgets/batalha_naval_widgets.dart';

class BatalhaNavalPage extends ConsumerWidget {
  const BatalhaNavalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batalhaNavalControllerProvider);
    final notifier = ref.read(batalhaNavalControllerProvider.notifier);

    return GamePageLayout(
      title: 'Batalha Naval',
      accentColor: const Color(0xFF0D47A1),
      instructions: state.phase == GamePhase.placing
          ? 'Posicione seus navios no tabuleiro.\n\n'
            '🔄 Toque em girar para mudar orientação\n'
            '📍 Toque no tabuleiro para posicionar'
          : 'Ataque o tabuleiro inimigo!\n\n'
            '💥 Vermelho = Acerto\n'
            '⚪ Branco = Água\n'
            '🚢 Afunde todos os navios!',
      maxGameWidth: 800,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: notifier.reset,
          tooltip: 'Reiniciar',
        ),
      ],
      child: _buildGameContent(context, state, notifier),
    );
  }

  Widget _buildGameContent(BuildContext context, BatalhaNavalState state, BatalhaNavalController notifier) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: state.phase == GamePhase.gameOver
                  ? (state.winner == 'Jogador' ? Colors.green.shade800 : Colors.red.shade800)
                  : Colors.blue.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Ship placement info
          if (state.phase == GamePhase.placing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ShipPlacementInfo(
                currentShip: state.currentShipType,
                orientation: state.orientation,
                onRotate: notifier.toggleOrientation,
              ),
            ),

          const SizedBox(height: 8),

          // Game boards
          isWide
              ? _buildWideLayout(state, notifier)
              : _buildNarrowLayout(state, notifier),

          // Fleet status during play
          if (state.phase == GamePhase.playing && state.playerShips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
    );
  }

  Widget _buildWideLayout(BatalhaNavalState state, BatalhaNavalController notifier) {
    return Row(
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
        const SizedBox(width: 12),
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
    );
  }

  Widget _buildNarrowLayout(BatalhaNavalState state, BatalhaNavalController notifier) {
    return DefaultTabController(
      length: 2,
      initialIndex: state.phase == GamePhase.placing ? 0 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Seu Tabuleiro'),
              Tab(text: 'Atacar'),
            ],
            indicatorColor: Colors.cyan,
            labelColor: Colors.white,
          ),
          SizedBox(
            height: 320,
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
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
                  padding: const EdgeInsets.all(8),
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
