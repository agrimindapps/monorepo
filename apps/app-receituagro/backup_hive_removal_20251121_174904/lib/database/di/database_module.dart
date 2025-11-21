import 'package:injectable/injectable.dart';

/// Módulo DI para registrar o banco de dados Drift e seus repositórios
@module
abstract class DatabaseModule {
  // Database já está registrado via @lazySingleton na classe ReceituagroDatabase
  // Os repositórios já estão registrados via @lazySingleton nas suas classes

  // Este módulo serve apenas como ponto de documentação
  // e pode ser usado no futuro para configurações adicionais
}
