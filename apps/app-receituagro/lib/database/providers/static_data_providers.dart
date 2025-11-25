import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../loaders/static_data_loader.dart';
import '../receituagro_database.dart';
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
/// Se tiver, assume que todos os dados estáticos foram carregados.
@riverpod
Stream<bool> staticDataLoaded(Ref ref) {
  final db = ref.watch(databaseProvider);

  return (db.select(
    db.culturas,
  )..limit(1)).watch().map((List<Cultura> culturas) => culturas.isNotEmpty);
}
