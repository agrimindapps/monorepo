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
    return const [
      QuizQuestionModel(
        id: '1',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9a/Flag_of_Spain.svg',
        options: ['Itália', 'Espanha', 'França', 'Portugal', 'México'],
        correctAnswer: 'Espanha',
      ),
      QuizQuestionModel(
        id: '2',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/05/Flag_of_Brazil.svg',
        options: ['Argentina', 'Brasil', 'Colômbia', 'Uruguai', 'Venezuela'],
        correctAnswer: 'Brasil',
      ),
      QuizQuestionModel(
        id: '3',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/c3/Flag_of_France.svg',
        options: ['Alemanha', 'Holanda', 'França', 'Itália', 'Bélgica'],
        correctAnswer: 'França',
      ),
      QuizQuestionModel(
        id: '4',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/b/ba/Flag_of_Germany.svg',
        options: ['Bélgica', 'Alemanha', 'Áustria', 'Suíça', 'Polônia'],
        correctAnswer: 'Alemanha',
      ),
      QuizQuestionModel(
        id: '5',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/a/a4/Flag_of_the_United_States.svg',
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
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9e/Flag_of_Japan.svg',
        options: ['China', 'Coreia do Sul', 'Japão', 'Vietnã', 'Tailândia'],
        correctAnswer: 'Japão',
      ),
      QuizQuestionModel(
        id: '7',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/0f/Flag_of_South_Korea.svg',
        options: ['Japão', 'Taiwan', 'Vietnã', 'Coreia do Sul', 'China'],
        correctAnswer: 'Coreia do Sul',
      ),
      QuizQuestionModel(
        id: '8',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/09/Flag_of_South_Korea.svg',
        options: [
          'Taiwan',
          'Coreia do Norte',
          'Indonésia',
          'Coreia do Sul',
          'Filipinas',
        ],
        correctAnswer: 'Coreia do Sul',
      ),
      QuizQuestionModel(
        id: '9',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/f/fa/Flag_of_the_People%27s_Republic_of_China.svg',
        options: ['Vietnã', 'China', 'Hong Kong', 'Taiwan', 'Coreia do Norte'],
        correctAnswer: 'China',
      ),
      QuizQuestionModel(
        id: '10',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/41/Flag_of_India.svg',
        options: ['Paquistão', 'Bangladesh', 'Nepal', 'Butão', 'Índia'],
        correctAnswer: 'Índia',
      ),
      QuizQuestionModel(
        id: '11',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/49/Flag_of_Ukraine.svg',
        options: ['Suécia', 'Ucrânia', 'Romênia', 'Eslováquia', 'Moldova'],
        correctAnswer: 'Ucrânia',
      ),
      QuizQuestionModel(
        id: '12',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/f/f3/Flag_of_Russia.svg',
        options: ['Polônia', 'Eslováquia', 'Eslovênia', 'Rússia', 'Sérvia'],
        correctAnswer: 'Rússia',
      ),
      QuizQuestionModel(
        id: '13',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/03/Flag_of_Italy.svg',
        options: ['México', 'Hungria', 'Itália', 'Irlanda', 'Bulgária'],
        correctAnswer: 'Itália',
      ),
      QuizQuestionModel(
        id: '14',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/1/1a/Flag_of_Argentina.svg',
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
        id: '15',
        question: 'Esta é a bandeira de qual país?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/8/88/Flag_of_Australia_%28converted%29.svg',
        options: [
          'Nova Zelândia',
          'Reino Unido',
          'Austrália',
          'Fiji',
          'Tuvalu',
        ],
        correctAnswer: 'Austrália',
      ),
    ];
  }
}
