import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/busca_datasource_impl.dart';
import '../../data/services/busca_metadata_service_impl.dart';
import '../../data/services/busca_validation_service_impl.dart';
import '../../domain/services/i_busca_metadata_service.dart';
import '../../domain/services/i_busca_validation_service.dart';

part 'busca_avancada_providers.g.dart';

@riverpod
IBuscaMetadataService buscaMetadataService(Ref ref) {
  final datasource = ref.watch(buscaDatasourceProvider);
  return BuscaMetadataService(datasource);
}

@riverpod
IBuscaValidationService buscaValidationService(Ref ref) {
  return BuscaValidationService();
}

@riverpod
BuscaDatasourceImpl buscaDatasource(Ref ref) {
  final culturaRepo = ref.watch(culturasRepositoryProvider);
  final pragasRepo = ref.watch(pragasRepositoryProvider);
  final fitossanitarioRepo = ref.watch(fitossanitariosRepositoryProvider);
  final diagnosticoRepo = ref.watch(diagnosticoRepositoryProvider);
  return BuscaDatasourceImpl(
    culturaRepo,
    pragasRepo,
    fitossanitarioRepo,
    diagnosticoRepo,
  );
}
