/// Driver para testes de integração
/// 
/// Este arquivo permite rodar os testes de integração em dispositivos reais
/// Uso: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/vehicle_crud_test.dart
library;

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
