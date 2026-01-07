import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/batalha_naval_entities.dart';

part 'batalha_naval_controller.g.dart';

@immutable
class BatalhaNavalState {
  final List<List<CellState>> playerBoard;
  final List<List<CellState>> enemyBoard;
  final List<List<CellState>> enemyBoardView; // What player sees
  final List<Ship> playerShips;
  final List<Ship> enemyShips;
  final GamePhase phase;
  final int currentShipIndex;
  final ShipOrientation orientation;
  final bool isPlayerTurn;
  final String? winner;
  final String message;

  const BatalhaNavalState({
    required this.playerBoard,
    required this.enemyBoard,
    required this.enemyBoardView,
    this.playerShips = const [],
    this.enemyShips = const [],
    this.phase = GamePhase.placing,
    this.currentShipIndex = 0,
    this.orientation = ShipOrientation.horizontal,
    this.isPlayerTurn = true,
    this.winner,
    this.message = 'Posicione seus navios',
  });

  factory BatalhaNavalState.initial() {
    return BatalhaNavalState(
      playerBoard: List.generate(10, (_) => List.filled(10, CellState.empty)),
      enemyBoard: List.generate(10, (_) => List.filled(10, CellState.empty)),
      enemyBoardView: List.generate(10, (_) => List.filled(10, CellState.empty)),
    );
  }

  ShipType? get currentShipType {
    if (currentShipIndex >= ShipType.defaultFleet.length) return null;
    return ShipType.defaultFleet[currentShipIndex];
  }

  int get playerShipsRemaining => playerShips.where((s) => !s.isSunk).length;
  int get enemyShipsRemaining => enemyShips.where((s) => !s.isSunk).length;

  BatalhaNavalState copyWith({
    List<List<CellState>>? playerBoard,
    List<List<CellState>>? enemyBoard,
    List<List<CellState>>? enemyBoardView,
    List<Ship>? playerShips,
    List<Ship>? enemyShips,
    GamePhase? phase,
    int? currentShipIndex,
    ShipOrientation? orientation,
    bool? isPlayerTurn,
    String? winner,
    String? message,
  }) {
    return BatalhaNavalState(
      playerBoard: playerBoard ?? this.playerBoard,
      enemyBoard: enemyBoard ?? this.enemyBoard,
      enemyBoardView: enemyBoardView ?? this.enemyBoardView,
      playerShips: playerShips ?? this.playerShips,
      enemyShips: enemyShips ?? this.enemyShips,
      phase: phase ?? this.phase,
      currentShipIndex: currentShipIndex ?? this.currentShipIndex,
      orientation: orientation ?? this.orientation,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      winner: winner ?? this.winner,
      message: message ?? this.message,
    );
  }
}

@riverpod
class BatalhaNavalController extends _$BatalhaNavalController {
  final Random _random = Random();

  @override
  BatalhaNavalState build() => BatalhaNavalState.initial();

  void toggleOrientation() {
    if (state.phase != GamePhase.placing) return;
    state = state.copyWith(
      orientation: state.orientation == ShipOrientation.horizontal
          ? ShipOrientation.vertical
          : ShipOrientation.horizontal,
    );
  }

  void placeShip(int row, int col) {
    if (state.phase != GamePhase.placing) return;
    final shipType = state.currentShipType;
    if (shipType == null) return;

    if (!_canPlaceShip(state.playerBoard, row, col, shipType.size, state.orientation)) {
      state = state.copyWith(message: 'Posição inválida!');
      return;
    }

    final newBoard = _copyBoard(state.playerBoard);
    final positions = <List<int>>[];

    for (int i = 0; i < shipType.size; i++) {
      final r = state.orientation == ShipOrientation.vertical ? row + i : row;
      final c = state.orientation == ShipOrientation.horizontal ? col + i : col;
      newBoard[r][c] = CellState.ship;
      positions.add([r, c]);
    }

    final newShip = Ship(name: shipType.name, size: shipType.size, positions: positions);
    final newShips = [...state.playerShips, newShip];
    final nextIndex = state.currentShipIndex + 1;

    if (nextIndex >= ShipType.defaultFleet.length) {
      // All ships placed, setup enemy and start game
      final enemyBoard = _copyBoard(state.enemyBoard);
      final enemyShips = _placeEnemyShips(enemyBoard);

      state = state.copyWith(
        playerBoard: newBoard,
        playerShips: newShips,
        enemyBoard: enemyBoard,
        enemyShips: enemyShips,
        currentShipIndex: nextIndex,
        phase: GamePhase.playing,
        message: 'Ataque o inimigo!',
      );
    } else {
      state = state.copyWith(
        playerBoard: newBoard,
        playerShips: newShips,
        currentShipIndex: nextIndex,
        message: 'Posicione: ${ShipType.defaultFleet[nextIndex].name}',
      );
    }
  }

  void attack(int row, int col) {
    if (state.phase != GamePhase.playing) return;
    if (!state.isPlayerTurn) return;
    if (state.enemyBoardView[row][col] != CellState.empty) {
      state = state.copyWith(message: 'Já atacou aqui!');
      return;
    }

    final newEnemyView = _copyBoard(state.enemyBoardView);
    final newEnemyBoard = _copyBoard(state.enemyBoard);
    final newEnemyShips = state.enemyShips.map((s) => s.copyWith()).toList();

    bool isHit = state.enemyBoard[row][col] == CellState.ship;

    if (isHit) {
      newEnemyView[row][col] = CellState.hit;
      newEnemyBoard[row][col] = CellState.hit;

      // Find and update the hit ship
      for (int i = 0; i < newEnemyShips.length; i++) {
        if (newEnemyShips[i].positions.any((p) => p[0] == row && p[1] == col)) {
          newEnemyShips[i] = newEnemyShips[i].copyWith(hits: newEnemyShips[i].hits + 1);
          break;
        }
      }

      // Check win condition
      if (newEnemyShips.every((s) => s.isSunk)) {
        state = state.copyWith(
          enemyBoardView: newEnemyView,
          enemyBoard: newEnemyBoard,
          enemyShips: newEnemyShips,
          phase: GamePhase.gameOver,
          winner: 'Jogador',
          message: 'Você venceu!',
        );
        return;
      }

      state = state.copyWith(
        enemyBoardView: newEnemyView,
        enemyBoard: newEnemyBoard,
        enemyShips: newEnemyShips,
        message: 'Acertou! Ataque novamente.',
      );
    } else {
      newEnemyView[row][col] = CellState.miss;

      state = state.copyWith(
        enemyBoardView: newEnemyView,
        isPlayerTurn: false,
        message: 'Água! Vez do inimigo...',
      );

      // Enemy turn (delayed)
      Future.delayed(const Duration(milliseconds: 800), _enemyAttack);
    }
  }

  void _enemyAttack() {
    if (state.phase != GamePhase.playing) return;

    // Simple AI: random attack on empty cells
    final emptyCells = <List<int>>[];
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        if (state.playerBoard[r][c] == CellState.empty ||
            state.playerBoard[r][c] == CellState.ship) {
          emptyCells.add([r, c]);
        }
      }
    }

    if (emptyCells.isEmpty) return;

    final target = emptyCells[_random.nextInt(emptyCells.length)];
    final row = target[0];
    final col = target[1];

    final newPlayerBoard = _copyBoard(state.playerBoard);
    final newPlayerShips = state.playerShips.map((s) => s.copyWith()).toList();

    bool isHit = state.playerBoard[row][col] == CellState.ship;

    if (isHit) {
      newPlayerBoard[row][col] = CellState.hit;

      // Find and update the hit ship
      for (int i = 0; i < newPlayerShips.length; i++) {
        if (newPlayerShips[i].positions.any((p) => p[0] == row && p[1] == col)) {
          newPlayerShips[i] = newPlayerShips[i].copyWith(hits: newPlayerShips[i].hits + 1);
          break;
        }
      }

      // Check lose condition
      if (newPlayerShips.every((s) => s.isSunk)) {
        state = state.copyWith(
          playerBoard: newPlayerBoard,
          playerShips: newPlayerShips,
          phase: GamePhase.gameOver,
          winner: 'Inimigo',
          message: 'Você perdeu!',
        );
        return;
      }

      state = state.copyWith(
        playerBoard: newPlayerBoard,
        playerShips: newPlayerShips,
        message: 'Inimigo acertou!',
      );

      // Enemy attacks again
      Future.delayed(const Duration(milliseconds: 800), _enemyAttack);
    } else {
      newPlayerBoard[row][col] = CellState.miss;

      state = state.copyWith(
        playerBoard: newPlayerBoard,
        isPlayerTurn: true,
        message: 'Inimigo errou! Sua vez.',
      );
    }
  }

  List<Ship> _placeEnemyShips(List<List<CellState>> board) {
    final ships = <Ship>[];

    for (final shipType in ShipType.defaultFleet) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 100) {
        final row = _random.nextInt(10);
        final col = _random.nextInt(10);
        final orientation = _random.nextBool()
            ? ShipOrientation.horizontal
            : ShipOrientation.vertical;

        if (_canPlaceShip(board, row, col, shipType.size, orientation)) {
          final positions = <List<int>>[];

          for (int i = 0; i < shipType.size; i++) {
            final r = orientation == ShipOrientation.vertical ? row + i : row;
            final c = orientation == ShipOrientation.horizontal ? col + i : col;
            board[r][c] = CellState.ship;
            positions.add([r, c]);
          }

          ships.add(Ship(name: shipType.name, size: shipType.size, positions: positions));
          placed = true;
        }
        attempts++;
      }
    }

    return ships;
  }

  bool _canPlaceShip(
    List<List<CellState>> board,
    int row,
    int col,
    int size,
    ShipOrientation orientation,
  ) {
    for (int i = 0; i < size; i++) {
      final r = orientation == ShipOrientation.vertical ? row + i : row;
      final c = orientation == ShipOrientation.horizontal ? col + i : col;

      if (r < 0 || r >= 10 || c < 0 || c >= 10) return false;
      if (board[r][c] != CellState.empty) return false;
    }
    return true;
  }

  List<List<CellState>> _copyBoard(List<List<CellState>> board) {
    return List.generate(10, (r) => List<CellState>.from(board[r]));
  }

  void reset() {
    state = BatalhaNavalState.initial();
  }
}
