import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_riverpod_setup.g.dart';

/// Provider de teste para validar setup de code generation
@riverpod
String helloRiverpod(HelloRiverpodRef ref) {
  return 'Hello Riverpod Code Generation!';
}

/// Provider assíncrono de teste
@riverpod
Future<int> asyncCounter(AsyncCounterRef ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 42;
}

/// Provider de teste com parâmetro (substitui .family)
@riverpod
String greet(GreetRef ref, String name) {
  return 'Hello, $name!';
}
