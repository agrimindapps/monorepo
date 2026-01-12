import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/tetris_local_datasource.dart';

part 'tetris_dependencies.g.dart';

/// Provider para SharedPreferences
/// Deve ser sobrescrito no main.dart com a instância real
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
}

/// Provider para o datasource local do Tetris
@riverpod
TetrisLocalDatasource tetrisLocalDatasource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TetrisLocalDatasource(prefs);
}
