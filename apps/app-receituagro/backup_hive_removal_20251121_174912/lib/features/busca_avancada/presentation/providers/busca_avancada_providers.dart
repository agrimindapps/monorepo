import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/diagnostico_integration_service.dart';
import '../../domain/services/i_busca_metadata_service.dart';
import '../../domain/services/i_busca_validation_service.dart';

part 'busca_avancada_providers.g.dart';

@riverpod
DiagnosticoIntegrationService diagnosticoIntegrationService(DiagnosticoIntegrationServiceRef ref) {
  return di.sl<DiagnosticoIntegrationService>();
}

@riverpod
IBuscaMetadataService buscaMetadataService(BuscaMetadataServiceRef ref) {
  return di.sl<IBuscaMetadataService>();
}

@riverpod
IBuscaValidationService buscaValidationService(BuscaValidationServiceRef ref) {
  return di.sl<IBuscaValidationService>();
}
