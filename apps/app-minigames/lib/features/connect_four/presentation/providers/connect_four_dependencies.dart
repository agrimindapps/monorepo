import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'connect_four_dependencies.g.dart';

@riverpod
SharedPreferences connect_fourSharedPreferences(Ref ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
}
