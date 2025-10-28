import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'di_providers.g.dart';

/// Provider to access GetIt instance in Riverpod
/// This allows feature providers to access DI container
@riverpod
GetIt getIt(GetItRef ref) {
  return GetIt.instance;
}
