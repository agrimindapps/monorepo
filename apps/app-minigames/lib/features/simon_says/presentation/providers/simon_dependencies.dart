import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'simon_dependencies.g.dart';

@riverpod
SharedPreferences simonSharedPreferences(Ref ref) {
  throw UnimplementedError(
    'simonSharedPreferencesProvider must be overridden in main.dart',
  );
}
