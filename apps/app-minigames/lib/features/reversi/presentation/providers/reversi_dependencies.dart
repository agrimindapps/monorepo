import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reversi_dependencies.g.dart';

@riverpod
SharedPreferences reversiSharedPreferences(Ref ref) {
  throw UnimplementedError(
    'reversiSharedPreferencesProvider must be overridden in main.dart',
  );
}
