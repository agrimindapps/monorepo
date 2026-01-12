import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'space_invaders_dependencies.g.dart';

@riverpod
SharedPreferences spaceInvadersSharedPreferences(Ref ref) {
  throw UnimplementedError(
    'spaceInvadersSharedPreferencesProvider must be overridden in main.dart',
  );
}
