// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class TowerGameLogic {
  // Propriedades de dimensão
  double blockWidth;
  double blockHeight = 30.0;
  double posX = 0;
  double lastBlockX = 0;
  double screenWidth;

  // Estado do jogo
  bool movingRight = true;
  int score = 0;
  int highScore = 0;
  bool isPaused = false;
  bool isGameOver = false;
  List<BlockData> blocks = [];

  // Propriedades adicionais de estado
  bool isPerfectPlacement = false;
  int combo = 0;
  int lastDropScore = 0;

  // Configurações de jogo
  double blockSpeed = 5.0;
  double speedIncrement = 0.2;
  GameDifficulty difficulty = GameDifficulty.medium;

  // Construtor
  TowerGameLogic({required this.blockWidth, required this.screenWidth});

  // Inicia um novo jogo
  void startNewGame() {
    blocks.clear();
    blockWidth = 200.0;
    lastBlockX = 0;
    posX = 0;
    score = 0;
    combo = 0;
    lastDropScore = 0;
    blockSpeed = 5.0 * difficulty.speedMultiplier;
    speedIncrement = 0.2 * difficulty.speedMultiplier;
    isPaused = false;
    isGameOver = false;
    movingRight = true;
    isPerfectPlacement = false;
  }

  // Atualiza a posição do bloco em movimento
  void updateMovingBlock() {
    if (isPaused) return;

    if (movingRight) {
      posX += blockSpeed;
      if (posX + blockWidth >= screenWidth) {
        movingRight = false;
      }
    } else {
      posX -= blockSpeed;
      if (posX <= 0) {
        movingRight = true;
      }
    }
  }

  // Tenta colocar o bloco atual na torre
  bool dropBlock() {
    double overlap = blockWidth - (posX - lastBlockX).abs();

    if (overlap <= 0) {
      isGameOver = true;
      return false;
    }

    // Calcular pontuação por precisão
    double precision = overlap / blockWidth;
    lastDropScore = (precision * 10).round();

    // Verifica colocação perfeita (>= 90% de precisão)
    isPerfectPlacement = precision >= 0.9;

    // Sistema de combo para colocações perfeitas consecutivas
    if (isPerfectPlacement) {
      combo++;
      lastDropScore = lastDropScore * combo;
    } else {
      combo = 0;
    }

    blockWidth = overlap;
    lastBlockX = posX;

    // Adiciona o bloco à lista
    blocks.add(BlockData(
        width: blockWidth,
        height: blockHeight,
        posX: lastBlockX,
        color: GameColors
            .blockColors[blocks.length % GameColors.blockColors.length]));

    score += lastDropScore;

    // Aumenta a velocidade gradualmente
    blockSpeed += speedIncrement;

    return true;
  }

  // Carrega o recorde
  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('tower_high_score') ?? 0;
  }

  // Salva o recorde se for maior que o atual
  Future<void> saveHighScore() async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tower_high_score', score);
      highScore = score;
    }
  }

  // Alterna o estado de pausa do jogo
  void togglePause() {
    isPaused = !isPaused;
  }

  // Retorna a dificuldade atual formatada para exibição
  String getDifficultyLabel() {
    return difficulty.label;
  }

  // Retorna a cor para o próximo bloco
  Color getNextBlockColor() {
    return GameColors
        .blockColors[blocks.length % GameColors.blockColors.length];
  }
}

// Classe para armazenar dados de cada bloco
class BlockData {
  final double width;
  final double height;
  final double posX;
  final Color color;

  BlockData(
      {required this.width,
      required this.height,
      required this.posX,
      required this.color});
}
