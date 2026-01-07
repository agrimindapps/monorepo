import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/connect_four_controller.dart';

class ConnectFourPage extends ConsumerWidget {
  const ConnectFourPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectFourControllerProvider);
    final notifier = ref.read(connectFourControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Lig 4'),
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
      body: Column(
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildStatus(state),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 7 / 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade700, width: 8),
                  ),
                  child: Row(
                    children: List.generate(7, (colIndex) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => notifier.dropChip(colIndex),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: List.generate(6, (rowIndex) {
                              final cellValue = state.board[rowIndex][colIndex];
                              final isWinning = state.winningLine.any(
                                (pos) => pos[0] == rowIndex && pos[1] == colIndex
                              );

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getCellColor(cellValue),
                                    border: isWinning 
                                      ? Border.all(color: Colors.white, width: 4)
                                      : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(2, 2),
                                        blurRadius: 2,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(ConnectFourState state) {
    if (state.winner != null) {
      return Column(
        children: [
          Text(
            state.winner == 1 ? 'Jogador 1 Venceu!' : 'Jogador 2 Venceu!',
            style: TextStyle(
              color: state.winner == 1 ? Colors.red : Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em recarregar para jogar novamente',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }
    
    if (state.isDraw) {
      return const Text(
        'Empate!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Vez do: ',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.currentPlayer == 1 ? Colors.red : Colors.yellow,
          ),
        ),
      ],
    );
  }

  Color _getCellColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return const Color(0xFF1A1A2E); // Background color for "empty" hole
    }
  }
}
