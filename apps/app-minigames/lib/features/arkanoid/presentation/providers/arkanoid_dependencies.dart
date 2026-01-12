import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'arkanoid_dependencies.g.dart';

@riverpod
SharedPreferences arkanoidSharedPreferences(Ref ref) {
  throw UnimplementedError(
    'arkanoidSharedPreferencesProvider must be overridden in main.dart',
  );
}
