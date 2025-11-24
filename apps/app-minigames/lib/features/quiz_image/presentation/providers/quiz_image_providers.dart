import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/quiz_image_local_data_source.dart';
import '../../data/repositories/quiz_image_repository_impl.dart';
import '../../domain/repositories/quiz_image_repository.dart';
import '../../domain/services/answer_validation_service.dart';
import '../../domain/services/game_state_manager_service.dart';
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

part 'quiz_image_providers.g.dart';

// Data Layer
@riverpod
QuizImageLocalDatasource quizImageLocalDatasource(
    QuizImageLocalDatasourceRef ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return QuizImageLocalDatasource(sharedPreferences);
}

@riverpod
QuizImageRepository quizImageRepository(QuizImageRepositoryRef ref) {
  final datasource = ref.watch(quizImageLocalDatasourceProvider);
  return QuizImageRepositoryImpl(datasource);
}

// Services
@riverpod
QuizImageAnswerValidationService quizImageAnswerValidationService(
    QuizImageAnswerValidationServiceRef ref) {
  return AnswerValidationService();
}

@riverpod
GameStateManagerService gameStateManagerService(
    GameStateManagerServiceRef ref) {
  return GameStateManagerService();
}

@riverpod
QuizImageQuestionManagerService quizImageQuestionManagerService(
    QuizImageQuestionManagerServiceRef ref) {
  final random = ref.watch(randomProvider);
  return QuestionManagerService(random: random);
}

// Use Cases
@riverpod
QuizImageGenerateGameQuestionsUseCase quizImageGenerateGameQuestionsUseCase(
    QuizImageGenerateGameQuestionsUseCaseRef ref) {
  final questionManager = ref.watch(quizImageQuestionManagerServiceProvider);
  return GenerateGameQuestionsUseCase(questionManager);
}

@riverpod
QuizImageHandleTimeoutUseCase quizImageHandleTimeoutUseCase(
    QuizImageHandleTimeoutUseCaseRef ref) {
  final gameStateManager = ref.watch(gameStateManagerServiceProvider);
  return HandleTimeoutUseCase(gameStateManager);
}

@riverpod
QuizImageLoadHighScoreUseCase quizImageLoadHighScoreUseCase(
    QuizImageLoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(quizImageRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
QuizImageNextQuestionUseCase quizImageNextQuestionUseCase(
    QuizImageNextQuestionUseCaseRef ref) {
  final questionManager = ref.watch(quizImageQuestionManagerServiceProvider);
  return NextQuestionUseCase(questionManager);
}

@riverpod
QuizImageRestartGameUseCase quizImageRestartGameUseCase(
    QuizImageRestartGameUseCaseRef ref) {
  final questionManager = ref.watch(quizImageQuestionManagerServiceProvider);
  final gameStateManager = ref.watch(gameStateManagerServiceProvider);
  return RestartGameUseCase(questionManager, gameStateManager);
}

@riverpod
QuizImageSaveHighScoreUseCase quizImageSaveHighScoreUseCase(
    QuizImageSaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(quizImageRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
QuizImageSelectAnswerUseCase quizImageSelectAnswerUseCase(
    QuizImageSelectAnswerUseCaseRef ref) {
  final answerValidator = ref.watch(quizImageAnswerValidationServiceProvider);
  final gameStateManager = ref.watch(gameStateManagerServiceProvider);
  return SelectAnswerUseCase(answerValidator, gameStateManager);
}

@riverpod
QuizImageStartGameUseCase quizImageStartGameUseCase(
    QuizImageStartGameUseCaseRef ref) {
  final generateQuestions =
      ref.watch(quizImageGenerateGameQuestionsUseCaseProvider);
  final gameStateManager = ref.watch(gameStateManagerServiceProvider);
  return StartGameUseCase(generateQuestions, gameStateManager);
}

@riverpod
QuizImageUpdateTimerUseCase quizImageUpdateTimerUseCase(
    QuizImageUpdateTimerUseCaseRef ref) {
  return UpdateTimerUseCase();
}
