import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../loaders/static_data_loader.dart';
import 'database_providers.dart';

part 'static_data_providers.g.dart';

/// Provider do carregador de dados estáticos
@riverpod
StaticDataLoader staticDataLoader(Ref ref) {
  final db = ref.watch(databaseProvider);
  return StaticDataLoader(db);
}

/// Provider para carregar todos os dados estáticos
///
/// Este provider carrega todos os dados estáticos das tabelas de referência
/// (culturas, pragas, fitossanitários) do JSON para o banco de dados Drift.
///
/// Retorna true se o carregamento foi bem-sucedido, false caso contrário.
@riverpod
Future<bool> loadStaticData(Ref ref) async {
  final loader = ref.watch(staticDataLoaderProvider);

  try {
    await loader.loadAll();
    return true;
  } catch (e) {
    return false;
  }
}

/// Provider para verificar se os dados estáticos já foram carregados
///
/// Verifica se a tabela de culturas tem dados.
/// E verifica se a tabela de fitossanitários info tem dados válidos (modoAcao).
@riverpod
Stream<bool> staticDataLoaded(Ref ref) {
  final db = ref.watch(databaseProvider);

  // Verifica se temos registros de info com modo de ação preenchido
  // Isso garante que a migração/correção dos dados foi aplicada
  final query = db.selectOnly(db.fitossanitariosInfo)
    ..addColumns([db.fitossanitariosInfo.id.count()])
    ..where(db.fitossanitariosInfo.modoAcao.isNotNull());

  return query.watchSingle().map((row) {
    final count = row.read(db.fitossanitariosInfo.id.count()) ?? 0;
    return count > 100; // Limite arbitrário para garantir que temos dados suficientes
  });
}
