import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/flappbird_local_datasource.dart';
import '../../data/repositories/flappbird_repository_impl.dart';
import '../../domain/repositories/flappbird_repository.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'flappbird_providers.g.dart';

// Data Sources

@riverpod
FlappbirdLocalDataSource flappbirdLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FlappbirdLocalDataSource(prefs);
}

// Repositories

@Riverpod(keepAlive: true)
FlappbirdRepository flappbirdRepository(Ref ref) {
  final dataSource = ref.watch(flappbirdLocalDataSourceProvider);
  return FlappbirdRepositoryImpl(dataSource);
}

// Use Cases

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(flappbirdRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(flappbirdRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}
