import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'dino_run_dependencies.g.dart';

@riverpod
SharedPreferences dinoRunSharedPreferences(Ref ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
}
