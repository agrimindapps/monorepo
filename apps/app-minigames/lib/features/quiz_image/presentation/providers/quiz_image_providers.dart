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
QuizImageLocalDataSource quizImageLocalDatasource(Ref ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return QuizImageLocalDataSourceImpl(sharedPreferences);
}

@riverpod
QuizImageRepository quizImageRepository(Ref ref) {
  final datasource = ref.watch(quizImageLocalDatasourceProvider);
  return QuizImageRepositoryImpl(datasource);
}

// Services
@riverpod
AnswerValidationService quizImageAnswerValidationService(Ref ref) {
  return AnswerValidationService();
}

@riverpod
GameStateManagerService gameStateManagerService(Ref ref) {
  return GameStateManagerService();
}

@riverpod
QuestionManagerService quizImageQuestionManagerService(Ref ref) {
  final random = ref.watch(randomProvider);
  return QuestionManagerService(random: random);
}

// Use Cases
@riverpod
GenerateGameQuestionsUseCase quizImageGenerateGameQuestionsUseCase(Ref ref) {
  final repository = ref.watch(quizImageRepositoryProvider);
  return GenerateGameQuestionsUseCase(repository);
}

@riverpod
HandleTimeoutUseCase quizImageHandleTimeoutUseCase(Ref ref) {
  return HandleTimeoutUseCase();
}

@riverpod
LoadHighScoreUseCase quizImageLoadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(quizImageRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
NextQuestionUseCase quizImageNextQuestionUseCase(Ref ref) {
  return NextQuestionUseCase();
}

@riverpod
RestartGameUseCase quizImageRestartGameUseCase(Ref ref) {
  return RestartGameUseCase();
}

@riverpod
SaveHighScoreUseCase quizImageSaveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(quizImageRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

@riverpod
SelectAnswerUseCase quizImageSelectAnswerUseCase(Ref ref) {
  return SelectAnswerUseCase();
}

@riverpod
StartGameUseCase quizImageStartGameUseCase(Ref ref) {
  return StartGameUseCase();
}

@riverpod
UpdateTimerUseCase quizImageUpdateTimerUseCase(Ref ref) {
  return UpdateTimerUseCase();
}
