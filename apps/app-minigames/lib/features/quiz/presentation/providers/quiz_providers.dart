import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/quiz_local_data_source.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/services/answer_validation_service.dart';
import '../../domain/services/life_management_service.dart';
import '../../domain/services/question_manager_service.dart';
import '../../domain/usecases/generate_game_questions_usecase.dart';
import '../../domain/usecases/handle_timeout_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/next_question_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/select_answer_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/update_timer_usecase.dart';

part 'quiz_providers.g.dart';

// Data Layer
@riverpod
QuizLocalDataSource quizLocalDatasource(Ref ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return QuizLocalDataSourceImpl(sharedPreferences);
}

@riverpod
QuizRepository quizRepository(Ref ref) {
  final datasource = ref.watch(quizLocalDatasourceProvider);
  return QuizRepositoryImpl(datasource);
}

// Services
@riverpod
AnswerValidationService answerValidationService(Ref ref) {
  return AnswerValidationService();
}

@riverpod
LifeManagementService lifeManagementService(Ref ref) {
  return LifeManagementService();
}

@riverpod
QuestionManagerService questionManagerService(Ref ref) {
  final random = ref.watch(randomProvider);
  return QuestionManagerService(random: random);
}

// Use Cases
@riverpod
GenerateGameQuestionsUseCase generateGameQuestionsUseCase(Ref ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return GenerateGameQuestionsUseCase(repository);
}

@riverpod
HandleTimeoutUseCase handleTimeoutUseCase(Ref ref) {
  final lifeManager = ref.watch(lifeManagementServiceProvider);
  return HandleTimeoutUseCase(lifeManager);
}

@riverpod
LoadHighScoreUseCase quizLoadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
NextQuestionUseCase nextQuestionUseCase(Ref ref) {
  return NextQuestionUseCase();
}

@riverpod
RestartGameUseCase quizRestartGameUseCase(Ref ref) {
  return RestartGameUseCase();
}

@riverpod
SaveHighScoreUseCase quizSaveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
SelectAnswerUseCase selectAnswerUseCase(Ref ref) {
  final answerValidator = ref.watch(answerValidationServiceProvider);
  final lifeManager = ref.watch(lifeManagementServiceProvider);
  return SelectAnswerUseCase(answerValidator, lifeManager);
}

@riverpod
StartGameUseCase quizStartGameUseCase(Ref ref) {
  return StartGameUseCase();
}

@riverpod
UpdateTimerUseCase updateTimerUseCase(Ref ref) {
  return UpdateTimerUseCase();
}
