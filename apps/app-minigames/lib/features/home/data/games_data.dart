import 'package:flutter/material.dart';
import '../domain/entities/game_entity.dart';
import '../domain/enums/game_category.dart';

/// Static list of all available games
class GamesData {
  static const List<GameEntity> allGames = [
    GameEntity(
      id: 'snake',
      name: 'Snake',
      description: 'Clássico jogo da cobrinha. Coma e cresça!',
      route: '/snake',
      icon: Icons.pest_control,
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF2E7D32),
      category: GameCategory.arcade,
      isFeatured: true,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: '2048',
      name: '2048',
      description: 'Combine os números e chegue a 2048!',
      route: '/2048',
      icon: Icons.grid_on,
      primaryColor: Color(0xFFFF9800),
      secondaryColor: Color(0xFFF57C00),
      category: GameCategory.puzzle,
      isFeatured: true,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'tictactoe',
      name: 'Jogo da Velha',
      description: 'O clássico Tic Tac Toe. Desafie um amigo!',
      route: '/tictactoe',
      icon: Icons.grid_3x3,
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF1565C0),
      category: GameCategory.strategy,
      isFeatured: true,
      isNew: false,
      playerCount: 2,
    ),
    GameEntity(
      id: 'memory',
      name: 'Jogo da Memória',
      description: 'Encontre os pares e teste sua memória',
      route: '/memory',
      icon: Icons.psychology,
      primaryColor: Color(0xFFE91E63),
      secondaryColor: Color(0xFFC2185B),
      category: GameCategory.puzzle,
      isFeatured: true,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'campo-minado',
      name: 'Campo Minado',
      description: 'Evite as minas e limpe o campo!',
      route: '/campo-minado',
      icon: Icons.dangerous,
      primaryColor: Color(0xFF607D8B),
      secondaryColor: Color(0xFF455A64),
      category: GameCategory.strategy,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'sudoku',
      name: 'Sudoku',
      description: 'Preencha a grade com números de 1 a 9',
      route: '/sudoku',
      icon: Icons.grid_4x4,
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF7B1FA2),
      category: GameCategory.puzzle,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'tower',
      name: 'Torre de Hanói',
      description: 'Mova todos os discos para a última torre',
      route: '/tower',
      icon: Icons.layers,
      primaryColor: Color(0xFF3F51B5),
      secondaryColor: Color(0xFF303F9F),
      category: GameCategory.puzzle,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'flappbird',
      name: 'Flappy Bird',
      description: 'Voe entre os obstáculos sem bater!',
      route: '/flappbird',
      icon: Icons.flutter_dash,
      primaryColor: Color(0xFF00BCD4),
      secondaryColor: Color(0xFF0097A7),
      category: GameCategory.arcade,
      isNew: true,
      playerCount: 1,
    ),
    GameEntity(
      id: 'pingpong',
      name: 'Ping Pong',
      description: 'O clássico jogo de tênis de mesa',
      route: '/pingpong',
      icon: Icons.sports_tennis,
      primaryColor: Color(0xFF8BC34A),
      secondaryColor: Color(0xFF689F38),
      category: GameCategory.arcade,
      isNew: true,
      playerCount: 2,
    ),
    GameEntity(
      id: 'quiz',
      name: 'Quiz',
      description: 'Teste seus conhecimentos gerais',
      route: '/quiz',
      icon: Icons.quiz,
      primaryColor: Color(0xFF673AB7),
      secondaryColor: Color(0xFF512DA8),
      category: GameCategory.quiz,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'quiz-image',
      name: 'Quiz de Imagens',
      description: 'Adivinhe a imagem correta',
      route: '/quiz-image',
      icon: Icons.image_search,
      primaryColor: Color(0xFF009688),
      secondaryColor: Color(0xFF00796B),
      category: GameCategory.quiz,
      isNew: true,
      playerCount: 1,
    ),
    GameEntity(
      id: 'caca-palavra',
      name: 'Caça Palavras',
      description: 'Encontre as palavras escondidas',
      route: '/caca-palavra',
      icon: Icons.search,
      primaryColor: Color(0xFFFF5722),
      secondaryColor: Color(0xFFE64A19),
      category: GameCategory.word,
      isNew: false,
      playerCount: 1,
    ),
    GameEntity(
      id: 'soletrando',
      name: 'Soletrando',
      description: 'Forme palavras com as letras disponíveis',
      route: '/soletrando',
      icon: Icons.abc,
      primaryColor: Color(0xFF795548),
      secondaryColor: Color(0xFF5D4037),
      category: GameCategory.word,
      isNew: false,
      playerCount: 1,
    ),
  ];

  /// Get featured games
  static List<GameEntity> get featuredGames =>
      allGames.where((g) => g.isFeatured).toList();

  /// Get new games
  static List<GameEntity> get newGames =>
      allGames.where((g) => g.isNew).toList();

  /// Get games by category
  static List<GameEntity> getByCategory(GameCategory category) {
    if (category == GameCategory.all) return allGames;
    return allGames.where((g) => g.category == category).toList();
  }

  /// Search games by name
  static List<GameEntity> search(String query) {
    if (query.isEmpty) return allGames;
    final lowerQuery = query.toLowerCase();
    return allGames
        .where((g) =>
            g.name.toLowerCase().contains(lowerQuery) ||
            g.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get multiplayer games
  static List<GameEntity> get multiplayerGames =>
      allGames.where((g) => g.playerCount > 1).toList();
}
