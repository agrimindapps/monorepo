import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/soletrando_local_datasource.dart';
import '../../data/datasources/soletrando_words_datasource.dart';
import '../../data/repositories/soletrando_repository_impl.dart';
import '../../domain/repositories/soletrando_repository.dart';
import '../../domain/usecases/generate_word_usecase.dart';
import '../../domain/usecases/skip_word_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../../../core/providers/core_providers.dart';

part 'soletrando_providers.g.dart';

// =========================================================================
// DATA SOURCES
// =========================================================================

@riverpod
SoletrandoWordsDataSource soletrandoWordsDataSource(Ref ref) {
  return SoletrandoWordsDataSource();
}

@riverpod
Future<SoletrandoLocalDataSource> soletrandoLocalDataSource(Ref ref) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  return SoletrandoLocalDataSource(sharedPrefs);
}

// =========================================================================
// REPOSITORIES
// =========================================================================

@riverpod
Future<SoletrandoRepository> soletrandoRepository(Ref ref) async {
  final localDataSource =
      await ref.watch(soletrandoLocalDataSourceProvider.future);
  final wordsDataSource = ref.watch(soletrandoWordsDataSourceProvider);

  return SoletrandoRepositoryImpl(
    localDataSource: localDataSource,
    wordsDataSource: wordsDataSource,
  );
}

// =========================================================================
// USE CASES
// =========================================================================

@riverpod
Future<GenerateWordUseCase> generateWordUseCase(Ref ref) async {
  final repository = await ref.watch(soletrandoRepositoryProvider.future);
  return GenerateWordUseCase(repository);
}

@riverpod
Future<SkipWordUseCase> skipWordUseCase(Ref ref) async {
  final repository = await ref.watch(soletrandoRepositoryProvider.future);
  return SkipWordUseCase(repository);
}

@riverpod
Future<RestartGameUseCase> restartGameUseCase(Ref ref) async {
  final repository = await ref.watch(soletrandoRepositoryProvider.future);
  return RestartGameUseCase(repository);
}
