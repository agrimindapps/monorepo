// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

// ✅ IMPLEMENTED: Serialização segura do modelo para persistência dos dados entre sessões
// TODO: Refatorar estrutura de dados para usar classes imutáveis para maior segurança
// TODO: Separar palavras em arquivo JSON externo para facilitar manutenção e internacionalização
// TODO: Adicionar sistema de pontuação mais sofisticado baseado em dificuldade e tempo de resposta
// ✅ FIXED: Algoritmo de seleção de palavras otimizado para evitar repetições
// ✅ IMPLEMENTED: Sistema de palavras recentes para prevenir repetição imediata
// TODO: Implementar sistema de níveis com palavras progressivamente mais difíceis
// TODO: Adicionar mais categorias e palavras para aumentar a variedade do jogo
// TODO: Criar sistema de dicas contextualizado para cada palavra (além da categoria)

class SoletrandoGame {
  // Dados do jogo
  String currentWord = '';
  WordCategory currentCategory = WordCategory.fruits;
  List<String> displayWord = [];
  List<String> availableLetters = [];
  int lives = 3;
  int score = 0;

  // Resultado do jogo
  GameResult result = GameResult.inProgress;

  // Palavras já usadas
  List<String> usedWords = [];
  
  // Histórico das últimas palavras para evitar repetição imediata
  List<String> recentWords = [];
  static const int maxRecentWords = 3;
  
  // Metadados para serialização
  DateTime? lastSaved;
  String? sessionId;

  // Dicionário de palavras por categoria
  final Map<WordCategory, List<String>> wordCategories = {
    WordCategory.fruits: [
      'BANANA',
      'LARANJA',
      'ABACAXI',
      'MORANGO',
      'MANGA',
      'MELANCIA',
      'GOIABA'
    ],
    WordCategory.animals: [
      'CACHORRO',
      'ELEFANTE',
      'GIRAFA',
      'LEOPARDO',
      'PAPAGAIO'
    ],
    WordCategory.countries: [
      'BRASIL',
      'ITALIA',
      'ARGENTINA',
      'PORTUGAL',
      'ESPANHA'
    ],
    WordCategory.professions: [
      'MÉDICO',
      'ENGENHEIRO',
      'PROFESSOR',
      'BOMBEIRO',
      'DESIGNER'
    ],
  };

  SoletrandoGame() {
    resetGame();
  }

  // Reinicia o jogo mantendo a pontuação
  void resetGame() {
    lives = 3;
    result = GameResult.inProgress;
    startNewGame();
  }

  // Inicia um novo jogo com nova palavra
  void startNewGame() {
    currentWord = _selectOptimalWord();
    
    // Atualiza histórico de palavras
    _updateWordHistory(currentWord);

    // Inicializa a palavra exibida com underscores
    displayWord = List.filled(currentWord.length, '_');

    // Cria lista de letras disponíveis (inclui letras da palavra + algumas letras aleatórias)
    Set<String> letters = currentWord.split('').toSet();
    while (letters.length < currentWord.length + 5) {
      String randomLetter =
          String.fromCharCode(Random().nextInt(26) + 65); // Letras de A a Z
      letters.add(randomLetter);
    }
    availableLetters = letters.toList()..shuffle();

    // Reseta o resultado se necessário
    if (result != GameResult.inProgress) {
      result = GameResult.inProgress;
    }
  }

  // Verifica se a letra está na palavra
  bool checkLetter(String letter) {
    bool found = false;

    // Verifica se a letra existe na palavra
    for (int i = 0; i < currentWord.length; i++) {
      if (currentWord[i] == letter) {
        displayWord[i] = letter;
        found = true;
      }
    }

    // Atualiza o resultado do jogo se necessário
    if (!found) {
      lives--;
      if (lives <= 0) {
        result = GameResult.failure;
      }
    } else if (!displayWord.contains('_')) {
      // Palavra completada
      result = GameResult.success;
    }

    return found;
  }

  // Método para indicar que o tempo acabou
  void timeOut() {
    lives--;
    if (lives <= 0) {
      result = GameResult.failure;
    } else {
      result = GameResult.timeOut;
    }
  }

  // Verifica se o jogo terminou
  bool isGameOver() {
    return result == GameResult.success || result == GameResult.failure;
  }

  // Muda a categoria
  void changeCategory(WordCategory category) {
    currentCategory = category;
    // Limpa histórico de palavras recentes ao mudar categoria
    recentWords.clear();
    usedWords.clear();
    startNewGame();
  }

  // Seleciona a palavra mais adequada baseado no histórico e frequência
  String _selectOptimalWord() {
    final categoryWords = wordCategories[currentCategory]!;
    
    // Primeiro, tenta palavras não usadas e não recentes
    List<String> preferredWords = categoryWords
        .where((word) => !usedWords.contains(word) && !recentWords.contains(word))
        .toList();
    
    if (preferredWords.isNotEmpty) {
      return _selectRandomWordWithDiversity(preferredWords);
    }
    
    // Se não há palavras preferenciais, usa palavras não recentes
    List<String> nonRecentWords = categoryWords
        .where((word) => !recentWords.contains(word))
        .toList();
    
    if (nonRecentWords.isNotEmpty) {
      return _selectRandomWordWithDiversity(nonRecentWords);
    }
    
    // Como último recurso, limpa palavras recentes e seleciona qualquer uma
    if (categoryWords.length > maxRecentWords) {
      recentWords.clear();
      usedWords.clear();
    }
    
    return _selectRandomWordWithDiversity(categoryWords);
  }
  
  // Seleciona palavra considerando diversidade de tamanho
  String _selectRandomWordWithDiversity(List<String> words) {
    if (words.length <= 1) return words.first;
    
    // Agrupa palavras por tamanho para garantir diversidade
    final Map<int, List<String>> wordsByLength = {};
    for (final word in words) {
      wordsByLength.putIfAbsent(word.length, () => []).add(word);
    }
    
    // Se há palavras de tamanhos diferentes, prefere tamanhos não usados recentemente
    if (wordsByLength.length > 1) {
      final recentLengths = recentWords.map((w) => w.length).toSet();
      final unusedLengths = wordsByLength.keys.where((len) => !recentLengths.contains(len)).toList();
      
      if (unusedLengths.isNotEmpty) {
        final selectedLength = unusedLengths[Random().nextInt(unusedLengths.length)];
        final wordsOfLength = wordsByLength[selectedLength]!;
        return wordsOfLength[Random().nextInt(wordsOfLength.length)];
      }
    }
    
    // Seleção aleatória padrão
    return words[Random().nextInt(words.length)];
  }
  
  // Atualiza o histórico de palavras usadas
  void _updateWordHistory(String word) {
    // Adiciona à lista de palavras usadas
    if (!usedWords.contains(word)) {
      usedWords.add(word);
    }
    
    // Mantém o histórico de palavras recentes limitado
    recentWords.add(word);
    while (recentWords.length > maxRecentWords) {
      recentWords.removeAt(0);
    }
  }
  
  /// Serializa o estado do jogo para JSON com validação
  Map<String, dynamic> toJson() {
    final data = {
      'currentWord': currentWord,
      'currentCategory': currentCategory.name,
      'displayWord': displayWord,
      'availableLetters': availableLetters,
      'lives': lives,
      'score': score,
      'result': result.name,
      'usedWords': usedWords,
      'recentWords': recentWords,
      'lastSaved': DateTime.now().toIso8601String(),
      'sessionId': sessionId ?? _generateSessionId(),
      'version': '1.0.0',
    };
    
    // Validações básicas
    if (!_validateGameData(data)) {
      throw ArgumentError('Dados do jogo inválidos para serialização');
    }
    
    return data;
  }
  
  /// Deserializa o estado do jogo de JSON com validação
  static SoletrandoGame fromJson(Map<String, dynamic> json) {
    // Validação de versão
    if (json['version'] != '1.0.0') {
      throw ArgumentError('Versão do arquivo de save incompatível: ${json['version']}');
    }
    
    // Validações dos dados
    if (!_validateGameData(json)) {
      throw ArgumentError('Dados do jogo corrompidos ou inválidos');
    }
    
    final game = SoletrandoGame();
    
    try {
      game.currentWord = json['currentWord'] as String;
      game.currentCategory = WordCategory.values.firstWhere(
        (cat) => cat.name == json['currentCategory'],
        orElse: () => WordCategory.fruits,
      );
      game.displayWord = List<String>.from(json['displayWord']);
      game.availableLetters = List<String>.from(json['availableLetters']);
      game.lives = (json['lives'] as num).toInt();
      game.score = (json['score'] as num).toInt();
      game.result = GameResult.values.firstWhere(
        (result) => result.name == json['result'],
        orElse: () => GameResult.inProgress,
      );
      game.usedWords = List<String>.from(json['usedWords'] ?? []);
      game.recentWords = List<String>.from(json['recentWords'] ?? []);
      game.lastSaved = DateTime.tryParse(json['lastSaved'] ?? '');
      game.sessionId = json['sessionId'] as String?;
      
      // Validação final do estado restaurado
      if (!game._validateCurrentState()) {
        throw ArgumentError('Estado do jogo restaurado é inválido');
      }
      
      return game;
    } catch (e) {
      throw ArgumentError('Erro ao deserializar dados do jogo: $e');
    }
  }
  
  /// Valida os dados do jogo
  static bool _validateGameData(Map<String, dynamic> data) {
    try {
      // Campos obrigatórios
      final required = ['currentWord', 'currentCategory', 'displayWord', 
                       'availableLetters', 'lives', 'score', 'result'];
      
      for (final field in required) {
        if (!data.containsKey(field)) {
          return false;
        }
      }
      
      // Validações de tipo e range
      if (data['currentWord'] is! String || (data['currentWord'] as String).isEmpty) {
        return false;
      }
      
      if (data['lives'] is! num || (data['lives'] as num) < 0 || (data['lives'] as num) > 10) {
        return false;
      }
      
      if (data['score'] is! num || (data['score'] as num) < 0) {
        return false;
      }
      
      if (data['displayWord'] is! List || data['availableLetters'] is! List) {
        return false;
      }
      
      // Validação de categoria
      final categoryName = data['currentCategory'] as String;
      if (!WordCategory.values.any((cat) => cat.name == categoryName)) {
        return false;
      }
      
      // Validação de resultado
      final resultName = data['result'] as String;
      if (!GameResult.values.any((result) => result.name == resultName)) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Valida o estado atual do jogo
  bool _validateCurrentState() {
    try {
      // Palavra atual deve existir na categoria
      final categoryWords = wordCategories[currentCategory];
      if (categoryWords == null || !categoryWords.contains(currentWord)) {
        return false;
      }
      
      // Display word deve ter o mesmo tamanho que current word
      if (displayWord.length != currentWord.length) {
        return false;
      }
      
      // Todas as letras do display word devem estar na palavra atual ou ser '_'
      for (int i = 0; i < displayWord.length; i++) {
        final char = displayWord[i];
        if (char != '_' && char != currentWord[i]) {
          return false;
        }
      }
      
      // Available letters deve conter todas as letras da palavra
      final wordLetters = currentWord.split('').toSet();
      final availableSet = availableLetters.toSet();
      if (!wordLetters.every((letter) => availableSet.contains(letter))) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Gera um ID único para a sessão
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '${timestamp}_$random';
  }
  
  /// Cria uma cópia imutável do estado atual
  Map<String, dynamic> getImmutableState() {
    return Map<String, dynamic>.unmodifiable(toJson());
  }
  
  /// Verifica se os dados foram modificados desde o último save
  bool hasUnsavedChanges() {
    return lastSaved == null || 
           DateTime.now().difference(lastSaved!).inSeconds > 30;
  }
  
  /// Marca o jogo como salvo
  void markAsSaved() {
    lastSaved = DateTime.now();
  }
}
