import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'termostecnicos_database.dart';

part 'database_providers.g.dart';

/// Provider para o banco de dados TermosTecnicosDatabase
@riverpod
TermosTecnicosDatabase termosTecnicosDatabase(Ref ref) {
  return TermosTecnicosDatabase.production();
}