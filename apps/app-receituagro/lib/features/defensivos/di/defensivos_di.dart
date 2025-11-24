import 'package:core/core.dart' hide Column;

import '../../../database/repositories/fitossanitarios_repository.dart';
import '../../../database/repositories/fitossanitarios_info_repository.dart';
import '../data/repositories/defensivos_repository_impl.dart';
import '../data/services/defensivos_filter_service.dart';
import '../data/services/defensivos_query_service.dart';
import '../data/services/defensivos_search_service.dart';
import '../data/services/defensivos_stats_service.dart';
import '../domain/repositories/i_defensivos_repository.dart';
import '../domain/usecases/get_defensivos_agrupados_usecase.dart';
import '../domain/usecases/get_defensivos_com_filtros_usecase.dart';
import '../domain/usecases/get_defensivos_completos_usecase.dart';
import '../domain/usecases/get_defensivos_usecase.dart';

/// Configuração de injeção de dependências para o módulo Defensivos
/// DEPRECATED: Use Riverpod providers instead
void configureDefensivosDependencies() {}
