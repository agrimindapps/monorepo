import 'package:core/core.dart' hide Column;

import '../../../core/services/error_handler_service.dart';
import '../../../database/repositories/comentarios_repository.dart';
import '../data/repositories/comentarios_repository_impl.dart';
import '../data/services/comentarios_id_service.dart';
import '../data/services/comentarios_mapper.dart';
import '../data/services/comentarios_search_service.dart';
import '../domain/repositories/i_comentarios_read_repository.dart';
import '../domain/repositories/i_comentarios_repository.dart';
import '../domain/repositories/i_comentarios_write_repository.dart';
import '../domain/usecases/add_comentario_usecase.dart';
import '../domain/usecases/delete_comentario_usecase.dart';
import '../domain/usecases/get_comentarios_usecase.dart';

/// Dependency Injection setup for Comentarios module following Clean Architecture.
/// DEPRECATED: Use Riverpod providers instead
class ComentariosDI {
  static void register(dynamic getIt) {}
  static void unregister(dynamic getIt) {}
}
