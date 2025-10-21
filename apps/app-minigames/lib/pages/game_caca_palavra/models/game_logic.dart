// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'position.dart';
import 'word.dart';

class CacaPalavrasLogic {
  // Configuração do jogo
  GameDifficulty difficulty;
  int gridSize;

  // Estado do jogo
  late List<List<String>> grid;
  late List<Word> words;
  List<Position> selectedPositions = [];
  bool isGameOver = false;
  int foundWords = 0;

  // Lista de palavras disponíveis no jogo
  final List<String> availableWords = [
    'AMOR',
    'VIDA',
    'PAZ',
    'FELIZ',
    'SAUDE',
    'CASA',
    'SOL',
    'LUA',
    'TERRA',
    'CEU',
    'MAR',
    'FLOR',
    'ARTE',
    'LIVRO',
    'TEMPO',
    'FOGO',
    'AGUA',
    'VENTO',
    'FRUTA',
    'GATO',
    'CACHORRO',
    'AMIGO',
    'FAMILIA',
    'TRABALHO',
    'ESTUDO',
    'SONHO',
    'CHUVA',
    'ESTRELA',
    'NUVEM',
    'JARDIM',
    'ARVORE',
    'PEIXE',
    'PASSARO',
    'MONTANHA',
    'PRAIA',
    'CINEMA',
  ];

  // Construtor
  CacaPalavrasLogic({
    this.difficulty = GameDifficulty.medium,
  }) : gridSize = difficulty.gridSize {
    _initializeGame();
  }

  // Inicializa o jogo
  void _initializeGame() {
    // Inicializa o grid com caracteres vazios
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    words = [];
    selectedPositions = [];
    isGameOver = false;
    foundWords = 0;

    // Gera o grid com palavras
    _generateGrid();
  }

  // Reinicia o jogo
  void restartGame({GameDifficulty? newDifficulty}) {
    if (newDifficulty != null) {
      difficulty = newDifficulty;
      gridSize = difficulty.gridSize;
    }
    _initializeGame();
  }

  // Gera o grid com as palavras
  void _generateGrid() {
    // Seleciona palavras aleatórias
    final randomWords = _selectRandomWords();

    // Posiciona as palavras no grid
    for (final word in randomWords) {
      _placeWordOnGrid(word);
    }

    // Preenche espaços vazios com letras aleatórias
    _fillEmptySpaces();
  }

  // Seleciona palavras aleatórias da lista disponível
  List<String> _selectRandomWords() {
    final random = Random();
    final wordCount = difficulty.wordCount;

    // Embaralha a lista de palavras disponíveis
    final shuffledWords = List.of(availableWords)..shuffle();

    // Seleciona as palavras conforme dificuldade
    return shuffledWords
        .where((word) =>
            word.length <= gridSize) // Garante que a palavra cabe no grid
        .take(wordCount)
        .map((word) => word.toUpperCase()) // Converte para maiúsculas
        .toList();
  }

  // Tenta colocar uma palavra no grid
  bool _placeWordOnGrid(String word) {
    final random = Random();
    const maxAttempts =
        100; // Limita o número de tentativas para evitar loops infinitos
    final directions = Direction.values.toList()
      ..shuffle(); // Aleatoriza a ordem das direções

    // Tenta cada direção em ordem aleatória para melhor distribuição
    for (final direction in directions) {
      for (int attempt = 0;
          attempt < maxAttempts ~/ directions.length;
          attempt++) {
        // Escolhe uma posição inicial aleatória e verifica se é possível posicionar a palavra
        final positionInfo =
            _calculatePositionForDirection(word, direction, random);
        if (positionInfo == null) continue;

        final (startRow, startCol, positions) = positionInfo;

        // Coloca a palavra no grid
        for (int i = 0; i < word.length; i++) {
          final position = positions[i];
          grid[position.row][position.col] = word[i];
        }

        // Adiciona a palavra à lista de palavras
        words.add(Word(
          text: word,
          direction: direction,
          positions: positions,
        ));

        return true;
      }
    }

    return false;
  }

  // Calcula a posição inicial e verifica se uma palavra pode ser colocada em uma direção específica
  (int, int, List<Position>)? _calculatePositionForDirection(
      String word, Direction direction, Random random) {
    int startRow, startCol;
    List<Position> positions = [];

    switch (direction) {
      case Direction.horizontal:
        startRow = random.nextInt(gridSize);
        startCol = random.nextInt(gridSize - word.length + 1);

        // Verifica se a palavra cabe
        if (!_canPlaceWord(word, startRow, startCol, 0, 1)) {
          return null;
        }

        // Cria posições
        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow, startCol + i));
        }
        break;

      case Direction.vertical:
        startRow = random.nextInt(gridSize - word.length + 1);
        startCol = random.nextInt(gridSize);

        // Verifica se a palavra cabe
        if (!_canPlaceWord(word, startRow, startCol, 1, 0)) {
          return null;
        }

        // Cria posições
        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol));
        }
        break;

      case Direction.diagonalDown:
        startRow = random.nextInt(gridSize - word.length + 1);
        startCol = random.nextInt(gridSize - word.length + 1);

        // Verifica se a palavra cabe
        if (!_canPlaceWord(word, startRow, startCol, 1, 1)) {
          return null;
        }

        // Cria posições
        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol + i));
        }
        break;

      case Direction.diagonalUp:
        startRow = random.nextInt(gridSize - word.length + 1) + word.length - 1;
        startCol = random.nextInt(gridSize - word.length + 1);

        // Verifica se a palavra cabe
        if (!_canPlaceWord(word, startRow, startCol, -1, 1)) {
          return null;
        }

        // Cria posições
        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow - i, startCol + i));
        }
        break;
    }

    return (startRow, startCol, positions);
  }

  // Verifica se uma palavra pode ser colocada em uma posição específica
  bool _canPlaceWord(
      String word, int startRow, int startCol, int rowDelta, int colDelta) {
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * rowDelta;
      final col = startCol + i * colDelta;

      // Verifica se a célula está vazia ou já tem a mesma letra
      if (grid[row][col] != '' && grid[row][col] != word[i]) {
        return false;
      }
    }
    return true;
  }

  // Preenche os espaços vazios do grid com letras aleatórias
  void _fillEmptySpaces() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == '') {
          grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  // Processa a seleção de uma letra
  void selectPosition(int row, int col) {
    if (isGameOver) return;

    final position = Position(row, col);

    // Se nenhuma posição foi selecionada ainda, ou se a posição está adjacente à última selecionada
    if (selectedPositions.isEmpty || _isAdjacentAndAligned(position)) {
      selectedPositions.add(position);
    } else if (selectedPositions.contains(position)) {
      // Se a posição já foi selecionada e é a última, remove-a
      if (position == selectedPositions.last) {
        selectedPositions.removeLast();
      }
      // Se a posição já foi selecionada e não é a última, limpa toda seleção
      else {
        selectedPositions.clear();
      }
    } else {
      // Se a posição não é adjacente e alinhada, limpa a seleção e adiciona a nova
      selectedPositions.clear();
      selectedPositions.add(position);
    }
  }

  // Verifica se uma posição é adjacente à última posição selecionada e está alinhada
  bool _isAdjacentAndAligned(Position position) {
    if (selectedPositions.isEmpty) return true;
    final lastPos = selectedPositions.last;

    // Calcula a direção entre as posições
    final rowDiff = position.row - lastPos.row;
    final colDiff = position.col - lastPos.col;

    // Verifica se é adjacente
    final isAdjacent = (rowDiff.abs() <= 1 && colDiff.abs() <= 1);

    if (!isAdjacent) return false;

    // Se há apenas uma posição selecionada, qualquer adjacente é válida
    if (selectedPositions.length <= 1) return true;

    // Se há mais posições, verifica se a direção é consistente com as seleções anteriores
    final prevPos = selectedPositions[selectedPositions.length - 2];
    final prevRowDiff = lastPos.row - prevPos.row;
    final prevColDiff = lastPos.col - prevPos.col;

    // Verifica se a direção é a mesma
    return (rowDiff == prevRowDiff && colDiff == prevColDiff);
  }

  // Verifica se a seleção atual forma uma palavra
  void checkSelection() {
    if (selectedPositions.length < 2) return;

    for (int i = 0; i < words.length; i++) {
      if (!words[i].isFound && words[i].matchesPositions(selectedPositions)) {
        words[i] = words[i].copyWith(isFound: true);
        foundWords++;

        // Verifica se o jogo terminou
        if (foundWords == words.length) {
          isGameOver = true;
        }

        break;
      }
    }

    // Limpa a seleção após verificar
    selectedPositions.clear();
  }

  // Retorna o progresso do jogo em porcentagem (0-100)
  double get progress {
    return foundWords / words.length * 100;
  }
}
