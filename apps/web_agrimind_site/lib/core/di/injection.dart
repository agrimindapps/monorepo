import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register external dependencies before injectable init
  await _registerExternalDependencies();

  // Initialize Injectable dependencies
  getIt.init();
}

/// Register external dependencies that aren't managed by Injectable
Future<void> _registerExternalDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Supabase client (assuming it's already initialized in main.dart)
  // If Supabase is not initialized yet, you need to initialize it first
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
}
