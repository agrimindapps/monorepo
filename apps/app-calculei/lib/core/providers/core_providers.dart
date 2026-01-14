import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'core_providers.g.dart';

/// Provider for SharedPreferences
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Provider for Logger
@Riverpod(keepAlive: true)
Logger logger(Ref ref) {
  return Logger();
}
