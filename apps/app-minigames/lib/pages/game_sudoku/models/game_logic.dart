// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/services/puzzle_generator.dart';
import 'package:app_minigames/services/puzzle_solver.dart';
import 'package:app_minigames/services/puzzle_validator.dart';
import 'sudoku_board.dart';

// TODO: Melhorias de Código
// TODO: Implementar padrão Observer para notificar alterações de estado sem depender do setState
// TODO: Criar classes separadas para Board e Cell para melhor modelagem de domínio
// TODO: Otimizar o algoritmo de geração de tabuleiros para garantir puzzles únicos
// TODO: Implementar padrão Repository para abstrair acesso a dados persistentes
// BUG: Reset de notas pode não funcionar corretamente ao mudar de célula em certos casos
// FIXME: Algoritmo de resolução pode ser muito lento para níveis difíceis
// TODO: Refatorar a lógica de verificação de conflitos para melhorar performance
// TODO: Implementar sistema de serialização para salvar/carregar jogos com JSON

// TODO: Melhorias de Funcionalidades
// TODO: Implementar múltiplos algoritmos de geração para maior variedade de puzzles
// TODO: Adicionar sistema de pontuação mais sofisticado com bônus por sequências
// TODO: Criar sistema de replay das jogadas para revisar os jogos
// TODO: Implementar níveis adicionais de dificuldade (muito fácil, extremo)
// TODO: Adicionar contador de notas automático para células com restrições óbvias
// TODO: Desenvolver sistema de verificações automáticas durante o jogo (verificação de progresso)
// TODO: Criar recurso de resumo estratégico ao finalizar um puzzle

class SudokuGameLogic {
  // Tamanho do tabuleiro
  static const int boardSize = 9;

  // Componentes especializados
  final SudokuBoard _board = SudokuBoard();
  final PuzzleGenerator _generator = PuzzleGenerator();
  final PuzzleSolver _solver = PuzzleSolver();
  final PuzzleValidator _validator = PuzzleValidator();

  // Getters para acesso ao estado do tabuleiro
  List<List<int>> get board => _board.board;
  List<List<int>> get solution => _board.solution;
  List<List<bool>> get isEditable => _board.isEditable;
  List<List<bool>> get hasConflict => _board.hasConflict;
  List<List<Set<int>>> get notes => _board.notes;

  // Estado do jogo
  bool isGameStarted = false;
  bool isGameOver = false;
  bool isPaused = false;
  bool isNoteMode = false;

  // Célula selecionada
  int selectedRow = -1;
  int selectedCol = -1;

  // Pontuação e configurações
  int hintsRemaining = 3;
  int elapsedSeconds = 0;
  int score = 0;
  DifficultyLevel difficulty = DifficultyLevel.medium;

  // Timer para o jogo
  Timer? gameTimer;

  // Propriedades para gerenciamento de recursos
  bool _isLoadingSaveData = false;
  bool _isSavingData = false;

  // Construtor
  SudokuGameLogic();

  // Inicializar o jogo
  void initializeGame() {
    _cleanupTimers();
    resetBoard();
    generatePuzzle();
    startTimer();
  }

  // Resetar o tabuleiro
  void resetBoard() {
    _board.reset();
    selectedRow = -1;
    selectedCol = -1;
    isGameStarted = false;
    isGameOver = false;
    isPaused = false;
    hintsRemaining = 3;
    elapsedSeconds = 0;
    score = 0;
  }

  // Gerar um novo quebra-cabeça
  void generatePuzzle() {
    // Gerar um tabuleiro resolvido
    _generator.generateSolvedBoard(_board);

    // Salvar a solução
    _board.saveSolution();

    // Remover células de acordo com a dificuldade
    _generator.removeRandomCells(_board, difficulty.cellsToRemove);

    isGameStarted = true;
  }


  // Verificar se um número é válido em uma posição
  bool isValidNumber(int row, int col, int num) {
    return _validator.isValidPlacement(_board, row, col, num);
  }

  // Selecionar uma célula
  void selectCell(int row, int col) {
    // Guarde a seleção anterior
    final int previousRow = selectedRow;
    final int previousCol = selectedCol;
    
    if (_board.isCellEditable(row, col)) {
      // Se a célula selecionada for diferente, atualize a seleção
      if (selectedRow != row || selectedCol != col) {
        selectedRow = row;
        selectedCol = col;
        
        // Verifica se havia uma célula selecionada anteriormente
        if (previousRow >= 0 && previousCol >= 0) {
          // Se a célula anterior tinha um número colocado, mas ainda tinha anotações,
          // limpe as anotações para evitar estados inconsistentes
          if (!_board.isEmpty(previousRow, previousCol) && _board.getCellNotes(previousRow, previousCol).isNotEmpty) {
            _board.clearNotes(previousRow, previousCol);
          }
        }
      }
    }
  }

  // Inserir um número na célula selecionada
  void insertNumber(int number) {
    if (selectedRow == -1 ||
        selectedCol == -1 ||
        !_board.isCellEditable(selectedRow, selectedCol)) {
      return;
    }

    if (isNoteMode) {
      toggleNote(number);
    } else {
      // Se já existir um número e não for o mesmo, limpe as anotações
      if (!_board.isEmpty(selectedRow, selectedCol) && _board.getCell(selectedRow, selectedCol) != number) {
        _board.clearNotes(selectedRow, selectedCol);
      }
      
      // Inserir número (limpa anotações se for diferente de 0)
      if (number != 0) {
        _board.clearNotes(selectedRow, selectedCol);
      }
      _board.setCell(selectedRow, selectedCol, number);

      // Verificar conflitos
      updateConflicts();

      // Verificar completude
      if (checkCompletion()) {
        endGame();
      }
    }
  }

  // Alternar modo de anotações
  void toggleNoteMode() {
    isNoteMode = !isNoteMode;
  }

  // Adicionar ou remover uma anotação
  void toggleNote(int number) {
    if (selectedRow == -1 ||
        selectedCol == -1 ||
        !_board.isCellEditable(selectedRow, selectedCol)) {
      return;
    }

    if (_board.getCellNotes(selectedRow, selectedCol).contains(number)) {
      _board.removeNote(selectedRow, selectedCol, number);
    } else {
      _board.addNote(selectedRow, selectedCol, number);
    }
  }

  // Atualizar conflitos no tabuleiro
  void updateConflicts([int? affectedRow, int? affectedCol]) {
    _validator.updateConflicts(_board, affectedRow, affectedCol);
  }

  // Verificar se o jogo foi completado
  bool checkCompletion() {
    return _validator.checkCompletion(_board);
  }

  // Fornecer uma dica
  bool giveHint() {
    if (hintsRemaining <= 0) return false;

    // Encontrar células vazias
    List<List<int>> emptyCells = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (_board.isEmpty(i, j)) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isEmpty) return false;

    // Escolher uma célula aleatoriamente
    emptyCells.shuffle();
    int row = emptyCells[0][0];
    int col = emptyCells[0][1];

    // Usar a solução para preencher a célula
    _board.setCell(row, col, _board.solution[row][col]);
    _board.setCellEditable(row, col, false);
    hintsRemaining--;

    // Atualizar conflitos
    updateConflicts();

    // Verificar se o jogo foi completado
    if (checkCompletion()) {
      endGame();
    }

    return true;
  }

  // Iniciar o temporizador
  void startTimer() {
    // Cancela timer existente de forma segura para evitar múltiplos timers
    _cancelTimerSafely();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Verificação adicional de segurança para evitar updates em estados inválidos
      if (isGameOver || isPaused) {
        timer.cancel();
        return;
      }
      elapsedSeconds++;
    });
  }

  // Pausar o jogo
  void pauseGame() {
    isPaused = true;
    _cancelTimerSafely();
  }

  // Retomar o jogo
  void resumeGame() {
    isPaused = false;
    startTimer();
  }

  // Encerrar o jogo
  void endGame() {
    isGameOver = true;

    // Cancela o timer de forma segura
    _cancelTimerSafely();

    calculateScore();
  }

  // Calcular a pontuação
  void calculateScore() {
    // Base: 1000 pontos
    int baseScore = 1000;

    // Penalidade por tempo: -2 pontos por segundo
    int timePenalty = elapsedSeconds * 2;

    // Bônus por dificuldade
    int difficultyBonus = 0;
    switch (difficulty) {
      case DifficultyLevel.easy:
        difficultyBonus = 0;
        break;
      case DifficultyLevel.medium:
        difficultyBonus = 500;
        break;
      case DifficultyLevel.hard:
        difficultyBonus = 1000;
        break;
    }

    score = baseScore - timePenalty + difficultyBonus;
    if (score < 0) score = 0;

    // Salvar high score
    saveHighScore();
  }

  // Carregar high score com gerenciamento de concorrência
  Future<int> loadHighScore() async {
    if (_isLoadingSaveData) {
      // Evita chamadas concorrentes
      return 0; // Valor temporário
    }
    
    _isLoadingSaveData = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('sudoku_high_score') ?? 0;
    } catch (e) {
      debugPrint('Erro ao carregar high score: $e');
      return 0;
    } finally {
      _isLoadingSaveData = false;
    }
  }

  // Salvar high score com gerenciamento de concorrência
  Future<void> saveHighScore() async {
    if (_isSavingData) {
      return; // Evita chamadas concorrentes
    }
    
    _isSavingData = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScore = await loadHighScore();

      if (score > highScore) {
        await prefs.setInt('sudoku_high_score', score);
      }
    } catch (e) {
      debugPrint('Erro ao salvar high score: $e');
    } finally {
      _isSavingData = false;
    }
  }

  // Formatar o tempo
  String getFormattedTime() {
    int minutes = elapsedSeconds ~/ 60;
    int seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Método auxiliar para cancelar timer de forma segura
  void _cancelTimerSafely() {
    try {
      gameTimer?.cancel();
    } catch (e) {
      debugPrint('Erro ao cancelar timer: $e');
    } finally {
      gameTimer = null;
    }
  }

  // Método para desativar todos os timers
  void _cleanupTimers() {
    _cancelTimerSafely();
  }

  // Método para depuração - monitoramento de uso de memória
  void logMemoryUsage() {
    final boardSize = board.length * board[0].length * 4; // 4 bytes por int
    final solutionSize = solution.length * solution[0].length * 4;
    final notesSize = notes.length * notes[0].length * 8; // Estimativa para Set
    
    debugPrint('Uso de memória estimado:');
    debugPrint('- Tabuleiro: $boardSize bytes');
    debugPrint('- Solução: $solutionSize bytes');
    debugPrint('- Anotações: $notesSize bytes');
    debugPrint('- Total: ${boardSize + solutionSize + notesSize} bytes');
  }

  // Liberar recursos
  void dispose() {
    _cleanupTimers();
  }
}
