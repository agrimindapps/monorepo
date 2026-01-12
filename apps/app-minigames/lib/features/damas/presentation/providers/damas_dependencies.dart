import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'damas_dependencies.g.dart';

@riverpod
SharedPreferences damasSharedPreferences(Ref ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
}
