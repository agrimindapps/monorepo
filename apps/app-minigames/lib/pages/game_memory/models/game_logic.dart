// Dart imports:
import 'dart:math';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'memory_card.dart';

/// Classe responsável por toda a lógica do jogo da memória
class MemoryGameLogic {
  // Configurações
  GameDifficulty difficulty;
  bool isGameStarted = false;
  bool isGameOver = false;
  bool isPaused = false;

  // Estado do jogo
  late List<MemoryCard> cards;
  int? firstCardIndex;
  int? secondCardIndex;
  int moves = 0;
  int matchedPairs = 0;
  int totalPairs = 0;

  // Tempo e pontuação
  int elapsedTimeInSeconds = 0;
  int bestScore = 0;

  // Construtor
  MemoryGameLogic({
    this.difficulty = GameDifficulty.medium,
  });

  /// Inicializa ou reinicia o jogo
  void initializeGame() {
    final gridSize = difficulty.gridSize;
    final totalCards = gridSize * gridSize;
    totalPairs = totalCards ~/ 2;

    // Resetar estado
    isGameStarted = false;
    isGameOver = false;
    isPaused = false;
    moves = 0;
    matchedPairs = 0;
    elapsedTimeInSeconds = 0;
    firstCardIndex = null;
    secondCardIndex = null;

    // Criar as cartas do jogo
    cards = _createCards();
  }

  /// Cria e embaralha as cartas para um novo jogo
  List<MemoryCard> _createCards() {
    final List<MemoryCard> newCards = [];

    // Criar pares com cores e ícones
    for (int i = 0; i < totalPairs; i++) {
      final color = CardThemes.cardColors[i % CardThemes.cardColors.length];
      final icon = CardThemes.cardIcons[i % CardThemes.cardIcons.length];

      // Criar duas cartas com o mesmo ID de par
      newCards.add(MemoryCard(
        id: i * 2,
        pairId: i,
        color: color,
        icon: icon,
      ));

      newCards.add(MemoryCard(
        id: i * 2 + 1,
        pairId: i,
        color: color,
        icon: icon,
      ));
    }

    // Embaralhar as cartas
    newCards.shuffle(Random());

    return newCards;
  }

  /// Inicia o jogo
  void startGame() {
    if (!isGameStarted) {
      isGameStarted = true;
    }
  }

  /// Processa o clique em uma carta e retorna se o movimento foi válido
  bool flipCard(int index) {
    // Verificações de estado do jogo
    if (isPaused || isGameOver) {
      return false;
    }

    // Verificação da carta
    if (cards[index].state != CardState.hidden) {
      return false;
    }

    // Se este for o primeiro cartão revelado
    if (firstCardIndex == null) {
      cards[index] = cards[index].copyWith(newState: CardState.revealed);
      firstCardIndex = index;
      return true;
    }

    // Se este for o segundo cartão revelado (e não é o mesmo que o primeiro)
    else if (secondCardIndex == null && firstCardIndex != index) {
      cards[index] = cards[index].copyWith(newState: CardState.revealed);
      secondCardIndex = index;
      moves++;

      // Verificar se as cartas correspondem
      if (cards[firstCardIndex!].matches(cards[secondCardIndex!])) {
        _handleMatchedCards();
      }

      return true;
    }

    return false;
  }

  /// Processa o caso de cartas iguais
  void _handleMatchedCards() {
    // Atualiza o estado das cartas para matched
    cards[firstCardIndex!] =
        cards[firstCardIndex!].copyWith(newState: CardState.matched);
    cards[secondCardIndex!] =
        cards[secondCardIndex!].copyWith(newState: CardState.matched);

    matchedPairs++;
    firstCardIndex = null;
    secondCardIndex = null;

    // Verificar se o jogo acabou
    if (matchedPairs == totalPairs) {
      isGameOver = true;
    }
  }

  /// Reset dos índices de cartas selecionadas
  void resetSelectedCards() {
    if (firstCardIndex != null && secondCardIndex != null) {
      // Virar as cartas que não correspondem de volta para baixo
      if (cards[firstCardIndex!].state != CardState.matched) {
        cards[firstCardIndex!] =
            cards[firstCardIndex!].copyWith(newState: CardState.hidden);
      }

      if (cards[secondCardIndex!].state != CardState.matched) {
        cards[secondCardIndex!] =
            cards[secondCardIndex!].copyWith(newState: CardState.hidden);
      }

      firstCardIndex = null;
      secondCardIndex = null;
    }
  }

  /// Pausa ou despausa o jogo
  void togglePause() {
    isPaused = !isPaused;
  }

  /// Calcula a pontuação com base em movimentos, tempo e dificuldade
  int calculateScore() {
    if (moves == 0 || elapsedTimeInSeconds == 0) return 0;

    // Fator de dificuldade
    int difficultyFactor = 0;
    switch (difficulty) {
      case GameDifficulty.easy:
        difficultyFactor = 1;
        break;
      case GameDifficulty.medium:
        difficultyFactor = 2;
        break;
      case GameDifficulty.hard:
        difficultyFactor = 3;
        break;
    }

    // Cálculo da pontuação: pares encontrados + fator de dificuldade, penalizado pelo tempo e movimentos
    double efficiencyFactor = (totalPairs.toDouble() / moves) *
        (totalPairs.toDouble() * 10 / elapsedTimeInSeconds);

    // Limitamos o fator de eficiência para evitar pontuações extremas
    efficiencyFactor = efficiencyFactor.clamp(0.1, 3.0);

    int score =
        ((matchedPairs * 100 * difficultyFactor) * efficiencyFactor).round();

    return score;
  }

  /// Carrega o recorde do armazenamento
  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'memory_best_score_${difficulty.name}';
    bestScore = prefs.getInt(key) ?? 0;
  }

  /// Salva o recorde se for maior que o atual
  Future<bool> saveBestScore() async {
    final currentScore = calculateScore();

    if (currentScore > bestScore) {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'memory_best_score_${difficulty.name}';
      await prefs.setInt(key, currentScore);
      bestScore = currentScore;
      return true;
    }

    return false;
  }
}
