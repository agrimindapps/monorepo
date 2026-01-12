import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'frogger_dependencies.g.dart';

@riverpod
SharedPreferences froggerSharedPreferences(Ref ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
}
