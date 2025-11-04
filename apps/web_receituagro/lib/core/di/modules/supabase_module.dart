import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for registering external dependencies like SupabaseClient
@module
abstract class SupabaseModule {
  /// Provides the Supabase client instance
  @lazySingleton
  SupabaseClient get client => Supabase.instance.client;
}
