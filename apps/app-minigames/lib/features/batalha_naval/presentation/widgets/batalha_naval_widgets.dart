import 'package:flutter/material.dart';

import '../../domain/entities/batalha_naval_entities.dart';

class BattleGrid extends StatelessWidget {
  final List<List<CellState>> board;
  final bool isEnemy;
  final bool showShips;
  final Function(int row, int col)? onCellTap;
  final String title;

  const BattleGrid({
    super.key,
    required this.board,
    required this.title,
    this.isEnemy = false,
    this.showShips = true,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade900, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                final row = index ~/ 10;
                final col = index % 10;
                final cell = board[row][col];

                return GestureDetector(
                  onTap: onCellTap != null ? () => onCellTap!(row, col) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getCellColor(cell, showShips),
                      border: Border.all(
                        color: Colors.blue.shade800,
                        width: 0.5,
                      ),
                    ),
                    child: _getCellIcon(cell),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getCellColor(CellState cell, bool showShips) {
    switch (cell) {
      case CellState.empty:
        return Colors.blue.shade700;
      case CellState.ship:
        return showShips ? Colors.grey.shade600 : Colors.blue.shade700;
      case CellState.hit:
        return Colors.red.shade700;
      case CellState.miss:
        return Colors.blue.shade900;
    }
  }

  Widget? _getCellIcon(CellState cell) {
    switch (cell) {
      case CellState.hit:
        return const Center(
          child: Icon(Icons.close, color: Colors.white, size: 16),
        );
      case CellState.miss:
        return Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
        );
      default:
        return null;
    }
  }
}

class ShipPlacementInfo extends StatelessWidget {
  final ShipType? currentShip;
  final ShipOrientation orientation;
  final VoidCallback onRotate;

  const ShipPlacementInfo({
    super.key,
    required this.currentShip,
    required this.orientation,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    if (currentShip == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentShip!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tamanho: ${currentShip!.size}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Row(
            children: List.generate(
              currentShip!.size,
              (i) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(1),
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onRotate,
            icon: const Icon(Icons.rotate_right, color: Colors.white),
            tooltip: 'Rotacionar',
          ),
          Text(
            orientation == ShipOrientation.horizontal ? 'H' : 'V',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class FleetStatus extends StatelessWidget {
  final List<Ship> ships;
  final String title;

  const FleetStatus({
    super.key,
    required this.ships,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...ships.map((ship) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                ship.isSunk ? Icons.close : Icons.check,
                color: ship.isSunk ? Colors.red : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                ship.name,
                style: TextStyle(
                  color: ship.isSunk ? Colors.red.shade300 : Colors.white70,
                  fontSize: 12,
                  decoration: ship.isSunk ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
