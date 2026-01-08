import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/high_score_model.dart';
import '../models/quiz_question_model.dart';

/// Local data source for quiz image game
/// Manages high score persistence and provides hardcoded questions
abstract class QuizImageLocalDataSource {
  /// Loads the high score from SharedPreferences
  Future<HighScoreModel> getHighScore();

  /// Saves the high score to SharedPreferences
  Future<void> saveHighScore(int score);

  /// Returns all 15 available quiz questions (hardcoded)
  List<QuizQuestionModel> getAvailableQuestions();
}

class QuizImageLocalDataSourceImpl implements QuizImageLocalDataSource {
  static const String _highScoreKey = 'quiz_image_high_score';

  final SharedPreferences sharedPreferences;

  QuizImageLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<HighScoreModel> getHighScore() async {
    try {
      final score = sharedPreferences.getInt(_highScoreKey) ?? 0;
      return HighScoreModel(score: score);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      await sharedPreferences.setInt(_highScoreKey, score);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  List<QuizQuestionModel> getAvailableQuestions() {
    // Using emoji flags instead of network images to avoid loading issues
    return const [
      QuizQuestionModel(
        id: '1',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇪🇸',
        options: ['Itália', 'Espanha', 'França', 'Portugal', 'México'],
        correctAnswer: 'Espanha',
      ),
      QuizQuestionModel(
        id: '2',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇧🇷',
        options: ['Argentina', 'Brasil', 'Colômbia', 'Uruguai', 'Venezuela'],
        correctAnswer: 'Brasil',
      ),
      QuizQuestionModel(
        id: '3',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇫🇷',
        options: ['Alemanha', 'Holanda', 'França', 'Itália', 'Bélgica'],
        correctAnswer: 'França',
      ),
      QuizQuestionModel(
        id: '4',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇩🇪',
        options: ['Bélgica', 'Alemanha', 'Áustria', 'Suíça', 'Polônia'],
        correctAnswer: 'Alemanha',
      ),
      QuizQuestionModel(
        id: '5',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇺🇸',
        options: [
          'Canadá',
          'Reino Unido',
          'Austrália',
          'Estados Unidos',
          'Irlanda',
        ],
        correctAnswer: 'Estados Unidos',
      ),
      QuizQuestionModel(
        id: '6',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇯🇵',
        options: ['China', 'Coreia do Sul', 'Japão', 'Vietnã', 'Tailândia'],
        correctAnswer: 'Japão',
      ),
      QuizQuestionModel(
        id: '7',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇰🇷',
        options: ['Japão', 'Taiwan', 'Vietnã', 'Coreia do Sul', 'China'],
        correctAnswer: 'Coreia do Sul',
      ),
      QuizQuestionModel(
        id: '8',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇨🇳',
        options: ['Vietnã', 'China', 'Hong Kong', 'Taiwan', 'Coreia do Norte'],
        correctAnswer: 'China',
      ),
      QuizQuestionModel(
        id: '9',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇮🇳',
        options: ['Paquistão', 'Bangladesh', 'Nepal', 'Butão', 'Índia'],
        correctAnswer: 'Índia',
      ),
      QuizQuestionModel(
        id: '10',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇺🇦',
        options: ['Suécia', 'Ucrânia', 'Romênia', 'Eslováquia', 'Moldova'],
        correctAnswer: 'Ucrânia',
      ),
      QuizQuestionModel(
        id: '11',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇷🇺',
        options: ['Polônia', 'Eslováquia', 'Eslovênia', 'Rússia', 'Sérvia'],
        correctAnswer: 'Rússia',
      ),
      QuizQuestionModel(
        id: '12',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇮🇹',
        options: ['México', 'Hungria', 'Itália', 'Irlanda', 'Bulgária'],
        correctAnswer: 'Itália',
      ),
      QuizQuestionModel(
        id: '13',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇦🇷',
        options: [
          'Uruguai',
          'Argentina',
          'Honduras',
          'El Salvador',
          'Nicarágua',
        ],
        correctAnswer: 'Argentina',
      ),
      QuizQuestionModel(
        id: '14',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇦🇺',
        options: [
          'Nova Zelândia',
          'Reino Unido',
          'Austrália',
          'Fiji',
          'Tuvalu',
        ],
        correctAnswer: 'Austrália',
      ),
      QuizQuestionModel(
        id: '15',
        question: 'Esta é a bandeira de qual país?',
        imageUrl: 'emoji:🇵🇹',
        options: ['Espanha', 'Brasil', 'Portugal', 'Moçambique', 'Angola'],
        correctAnswer: 'Portugal',
      ),
    ];
  }
}
