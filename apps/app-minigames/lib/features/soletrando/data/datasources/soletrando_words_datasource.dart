import 'dart:math';

import '../../domain/entities/enums.dart';
import '../../domain/entities/word_entity.dart';

/// Word data structure
class WordData {
  final String word;
  final String category;
  final String? definition;
  final String? example;

  const WordData(
    this.word,
    this.category, {
    this.definition,
    this.example,
  });
}

/// Data source for word lists by category and difficulty
class SoletrandoWordsDataSource {
  /// Word lists organized by category
  static const Map<WordCategory, List<WordData>> _wordsByCategory = {
    WordCategory.fruits: [
      WordData('BANANA', 'Frutas',
          definition: 'Fruta amarela alongada', example: 'Banana nanica'),
      WordData('LARANJA', 'Frutas',
          definition: 'Fruta cítrica alaranjada', example: 'Suco de laranja'),
      WordData('ABACAXI', 'Frutas',
          definition: 'Fruta tropical espinhosa', example: 'Abacaxi maduro'),
      WordData('MORANGO', 'Frutas',
          definition: 'Fruta vermelha pequena', example: 'Morango com chantilly'),
      WordData('MANGA', 'Frutas',
          definition: 'Fruta tropical amarela', example: 'Manga palmer'),
      WordData('MELANCIA', 'Frutas',
          definition: 'Fruta grande e verde com polpa vermelha',
          example: 'Melancia gelada'),
      WordData('GOIABA', 'Frutas',
          definition: 'Fruta tropical rosada', example: 'Goiabada cascão'),
      WordData('UVA', 'Frutas',
          definition: 'Fruta pequena em cachos', example: 'Uva passa'),
      WordData('MAÇÃ', 'Frutas',
          definition: 'Fruta vermelha redonda', example: 'Maçã verde'),
      WordData('PERA', 'Frutas',
          definition: 'Fruta em formato de sino', example: 'Pera williams'),
      WordData('MAMÃO', 'Frutas',
          definition: 'Fruta tropical alaranjada', example: 'Mamão papaia'),
      WordData('ABACATE', 'Frutas',
          definition: 'Fruta verde cremosa', example: 'Vitamina de abacate'),
    ],
    WordCategory.animals: [
      WordData('CACHORRO', 'Animais',
          definition: 'Animal doméstico canino', example: 'Melhor amigo do homem'),
      WordData('ELEFANTE', 'Animais',
          definition: 'Grande mamífero com tromba', example: 'Elefante africano'),
      WordData('GIRAFA', 'Animais',
          definition: 'Animal de pescoço longo', example: 'Girafa da savana'),
      WordData('LEOPARDO', 'Animais',
          definition: 'Felino manchado', example: 'Leopardo caçando'),
      WordData('PAPAGAIO', 'Animais',
          definition: 'Ave colorida que fala', example: 'Papagaio brasileiro'),
      WordData('GATO', 'Animais',
          definition: 'Felino doméstico', example: 'Gato siamês'),
      WordData('LEÃO', 'Animais',
          definition: 'Rei da selva', example: 'Leão africano'),
      WordData('TIGRE', 'Animais',
          definition: 'Felino listrado', example: 'Tigre de bengala'),
      WordData('COELHO', 'Animais',
          definition: 'Animal de orelhas longas', example: 'Coelho branco'),
      WordData('TARTARUGA', 'Animais',
          definition: 'Réptil com casco', example: 'Tartaruga marinha'),
      WordData('BALEIA', 'Animais',
          definition: 'Maior mamífero marinho', example: 'Baleia azul'),
      WordData('PINGUIM', 'Animais',
          definition: 'Ave que não voa do polo sul', example: 'Pinguim imperador'),
    ],
    WordCategory.countries: [
      WordData('BRASIL', 'Países',
          definition: 'Maior país da América do Sul', example: 'País do futebol'),
      WordData('ITÁLIA', 'Países',
          definition: 'País em formato de bota', example: 'Terra da pizza'),
      WordData('ARGENTINA', 'Países',
          definition: 'País sul-americano', example: 'Terra do tango'),
      WordData('PORTUGAL', 'Países',
          definition: 'País europeu', example: 'Terra dos navegadores'),
      WordData('ESPANHA', 'Países',
          definition: 'País da península ibérica', example: 'Terra do flamenco'),
      WordData('FRANÇA', 'Países',
          definition: 'País europeu', example: 'Terra da Torre Eiffel'),
      WordData('ALEMANHA', 'Países',
          definition: 'País da Europa central', example: 'Terra das cervejas'),
      WordData('JAPÃO', 'Países',
          definition: 'País insular asiático', example: 'Terra do sol nascente'),
      WordData('CHINA', 'Países',
          definition: 'País asiático mais populoso', example: 'Terra da Grande Muralha'),
      WordData('MÉXICO', 'Países',
          definition: 'País norte-americano', example: 'Terra dos astecas'),
      WordData('PERU', 'Países',
          definition: 'País sul-americano', example: 'Terra dos incas'),
      WordData('CHILE', 'Países',
          definition: 'País alongado na América do Sul', example: 'Terra dos vinhos'),
    ],
    WordCategory.professions: [
      WordData('MÉDICO', 'Profissões',
          definition: 'Profissional da saúde', example: 'Médico cirurgião'),
      WordData('ENGENHEIRO', 'Profissões',
          definition: 'Profissional de obras e projetos', example: 'Engenheiro civil'),
      WordData('PROFESSOR', 'Profissões',
          definition: 'Profissional da educação', example: 'Professor universitário'),
      WordData('BOMBEIRO', 'Profissões',
          definition: 'Combate incêndios', example: 'Bombeiro militar'),
      WordData('DESIGNER', 'Profissões',
          definition: 'Profissional criativo', example: 'Designer gráfico'),
      WordData('ADVOGADO', 'Profissões',
          definition: 'Profissional do direito', example: 'Advogado criminalista'),
      WordData('DENTISTA', 'Profissões',
          definition: 'Cuida dos dentes', example: 'Dentista ortodontista'),
      WordData('ARQUITETO', 'Profissões',
          definition: 'Projeta construções', example: 'Arquiteto paisagista'),
      WordData('ENFERMEIRO', 'Profissões',
          definition: 'Profissional de enfermagem', example: 'Enfermeiro chefe'),
      WordData('POLICIAL', 'Profissões',
          definition: 'Mantém a ordem pública', example: 'Policial militar'),
      WordData('JORNALISTA', 'Profissões',
          definition: 'Profissional da comunicação', example: 'Jornalista investigativo'),
      WordData('VETERINÁRIO', 'Profissões',
          definition: 'Cuida de animais', example: 'Veterinário de pequenos animais'),
    ],
  };

  /// Get random word for category and difficulty
  WordEntity getRandomWord({
    required WordCategory category,
    required GameDifficulty difficulty,
  }) {
    final categoryWords = _wordsByCategory[category] ?? [];

    if (categoryWords.isEmpty) {
      throw Exception('Nenhuma palavra disponível para categoria: ${category.name}');
    }

    // Filter words by difficulty based on length
    List<WordData> filteredWords;
    switch (difficulty) {
      case GameDifficulty.easy:
        // Easy: 3-6 letters
        filteredWords = categoryWords.where((w) => w.word.length >= 3 && w.word.length <= 6).toList();
        break;
      case GameDifficulty.medium:
        // Medium: 5-9 letters
        filteredWords = categoryWords.where((w) => w.word.length >= 5 && w.word.length <= 9).toList();
        break;
      case GameDifficulty.hard:
        // Hard: 8+ letters
        filteredWords = categoryWords.where((w) => w.word.length >= 8).toList();
        break;
    }

    // Fallback to all words if filter is too restrictive
    if (filteredWords.isEmpty) {
      filteredWords = categoryWords;
    }

    // Select random word
    final randomIndex = Random().nextInt(filteredWords.length);
    final wordData = filteredWords[randomIndex];

    return WordEntity(
      word: wordData.word,
      category: category,
      difficulty: difficulty,
      definition: wordData.definition,
      example: wordData.example,
    );
  }

  /// Get all words for a category
  List<WordEntity> getAllWords(WordCategory category, GameDifficulty difficulty) {
    final categoryWords = _wordsByCategory[category] ?? [];
    return categoryWords
        .map((data) => WordEntity(
              word: data.word,
              category: category,
              difficulty: difficulty,
              definition: data.definition,
              example: data.example,
            ))
        .toList();
  }

  /// Get word count for category
  int getWordCount(WordCategory category) {
    return _wordsByCategory[category]?.length ?? 0;
  }

  /// Get total word count
  int get totalWordCount {
    return _wordsByCategory.values.fold(0, (sum, words) => sum + words.length);
  }
}
