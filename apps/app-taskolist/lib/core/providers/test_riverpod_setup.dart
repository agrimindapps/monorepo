import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_riverpod_setup.g.dart';

/// Provider de teste para validar setup de code generation
@riverpod
String helloRiverpod(Ref ref) {
  return 'Hello Riverpod Code Generation!';
}

/// Provider assíncrono de teste
@riverpod
Future<int> asyncCounter(Ref ref) async {
  await Future<int>.delayed(const Duration(milliseconds: 100));
  return 42;
}

/// Provider de teste com parâmetro (substitui .family)
@riverpod
String greet(Ref ref, String name) {
  return 'Hello, $name!';
}
