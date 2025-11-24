import 'package:core/core.dart' hide Column;

import '../data/repositories/culturas_repository_impl.dart';
import '../data/services/culturas_query_service.dart';
import '../data/services/culturas_search_service.dart';
import '../domain/repositories/i_culturas_repository.dart';
import '../domain/usecases/get_culturas_usecase.dart';

/// Configuração de injeção de dependências para o módulo Culturas
/// DEPRECATED: Use Riverpod providers instead
void configureCulturasDependencies() {}
