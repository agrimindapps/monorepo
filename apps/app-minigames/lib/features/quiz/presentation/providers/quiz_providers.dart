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
QuizLocalDatasource quizLocalDatasource(QuizLocalDatasourceRef ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return QuizLocalDatasource(sharedPreferences);
}

@riverpod
QuizRepository quizRepository(QuizRepositoryRef ref) {
  final datasource = ref.watch(quizLocalDatasourceProvider);
  return QuizRepositoryImpl(datasource);
}

// Services
@riverpod
AnswerValidationService answerValidationService(
    AnswerValidationServiceRef ref) {
  return AnswerValidationService();
}

@riverpod
LifeManagementService lifeManagementService(LifeManagementServiceRef ref) {
  return LifeManagementService();
}

@riverpod
QuestionManagerService questionManagerService(QuestionManagerServiceRef ref) {
  final random = ref.watch(randomProvider);
  return QuestionManagerService(random: random);
}

// Use Cases
@riverpod
GenerateGameQuestionsUseCase generateGameQuestionsUseCase(
    GenerateGameQuestionsUseCaseRef ref) {
  final questionManager = ref.watch(questionManagerServiceProvider);
  return GenerateGameQuestionsUseCase(questionManager);
}

@riverpod
HandleTimeoutUseCase handleTimeoutUseCase(HandleTimeoutUseCaseRef ref) {
  final lifeManager = ref.watch(lifeManagementServiceProvider);
  return HandleTimeoutUseCase(lifeManager);
}

@riverpod
LoadHighScoreUseCase quizLoadHighScoreUseCase(QuizLoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
NextQuestionUseCase nextQuestionUseCase(NextQuestionUseCaseRef ref) {
  final questionManager = ref.watch(questionManagerServiceProvider);
  return NextQuestionUseCase(questionManager);
}

@riverpod
RestartGameUseCase quizRestartGameUseCase(QuizRestartGameUseCaseRef ref) {
  final questionManager = ref.watch(questionManagerServiceProvider);
  final lifeManager = ref.watch(lifeManagementServiceProvider);
  return RestartGameUseCase(questionManager, lifeManager);
}

@riverpod
SaveHighScoreUseCase quizSaveHighScoreUseCase(QuizSaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
SelectAnswerUseCase selectAnswerUseCase(SelectAnswerUseCaseRef ref) {
  final answerValidator = ref.watch(answerValidationServiceProvider);
  final lifeManager = ref.watch(lifeManagementServiceProvider);
  return SelectAnswerUseCase(answerValidator, lifeManager);
}

@riverpod
StartGameUseCase quizStartGameUseCase(QuizStartGameUseCaseRef ref) {
  final generateQuestions = ref.watch(generateGameQuestionsUseCaseProvider);
  final lifeManager = ref.watch(lifeManagementServiceProvider);
  return StartGameUseCase(generateQuestions, lifeManager);
}

@riverpod
UpdateTimerUseCase updateTimerUseCase(UpdateTimerUseCaseRef ref) {
  return UpdateTimerUseCase();
}
