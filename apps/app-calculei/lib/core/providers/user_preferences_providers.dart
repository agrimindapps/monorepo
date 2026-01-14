import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_preferences_service.dart';

part 'user_preferences_providers.g.dart';

/// Provider for SharedPreferences instance
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Provider for UserPreferencesService
@Riverpod(keepAlive: true)
Future<UserPreferencesService> userPreferencesService(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return UserPreferencesService(prefs);
}

/// Provider for favorite calculator routes
@riverpod
class FavoriteCalculators extends _$FavoriteCalculators {
  @override
  Future<List<String>> build() async {
    final service = await ref.watch(userPreferencesServiceProvider.future);
    return service.getFavorites();
  }

  Future<void> toggle(String route) async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.toggleFavorite(route);
    state = AsyncValue.data(service.getFavorites());
  }

  bool isFavorite(String route) {
    return state.value?.contains(route) ?? false;
  }
}

/// Provider for recent calculator routes
@riverpod
class RecentCalculators extends _$RecentCalculators {
  @override
  Future<List<String>> build() async {
    final service = await ref.watch(userPreferencesServiceProvider.future);
    return service.getRecents();
  }

  Future<void> addRecent(String route) async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.addRecent(route);
    state = AsyncValue.data(service.getRecents());
  }

  Future<void> clear() async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.clearRecents();
    state = const AsyncValue.data([]);
  }
}

/// Provider for view mode (grid/list)
@riverpod
class ViewMode extends _$ViewMode {
  @override
  Future<String> build() async {
    final service = await ref.watch(userPreferencesServiceProvider.future);
    return service.getViewMode();
  }

  Future<void> toggle() async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    final currentMode = state.value ?? 'grid';
    final newMode = currentMode == 'grid' ? 'list' : 'grid';
    await service.setViewMode(newMode);
    state = AsyncValue.data(newMode);
  }

  Future<void> setMode(String mode) async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.setViewMode(mode);
    state = AsyncValue.data(mode);
  }

  bool isGrid() => state.value == 'grid';
  bool isList() => state.value == 'list';
}
