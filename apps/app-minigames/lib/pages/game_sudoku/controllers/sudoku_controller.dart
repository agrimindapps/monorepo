// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';

class SudokuController extends ChangeNotifier {
  final SudokuGameLogic _model = SudokuGameLogic();

  SudokuGameLogic get model => _model;

  bool get isGameStarted => _model.isGameStarted;
  bool get isGameOver => _model.isGameOver;
  bool get isPaused => _model.isPaused;
  bool get isNoteMode => _model.isNoteMode;
  int get selectedRow => _model.selectedRow;
  int get selectedCol => _model.selectedCol;
  int get hintsRemaining => _model.hintsRemaining;
  int get score => _model.score;
  DifficultyLevel get difficulty => _model.difficulty;
  List<List<int>> get board => _model.board;
  List<List<bool>> get isEditable => _model.isEditable;
  List<List<bool>> get hasConflict => _model.hasConflict;
  List<List<Set<int>>> get notes => _model.notes;

  void initializeGame() {
    _model.initializeGame();
    notifyListeners();
  }

  void selectCell(int row, int col) {
    _model.selectCell(row, col);
    notifyListeners();
  }

  void insertNumber(int number) {
    _model.insertNumber(number);
    notifyListeners();
  }

  void toggleNoteMode() {
    _model.toggleNoteMode();
    notifyListeners();
  }

  bool giveHint() {
    final result = _model.giveHint();
    notifyListeners();
    return result;
  }

  void pauseGame() {
    _model.pauseGame();
    notifyListeners();
  }

  void resumeGame() {
    _model.resumeGame();
    notifyListeners();
  }

  void setDifficulty(DifficultyLevel difficulty) {
    _model.difficulty = difficulty;
    notifyListeners();
  }

  String getFormattedTime() {
    return _model.getFormattedTime();
  }

  bool checkCompletion() {
    return _model.checkCompletion();
  }

  void endGame() {
    _model.endGame();
    notifyListeners();
  }

  Future<int> loadHighScore() {
    return _model.loadHighScore();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
