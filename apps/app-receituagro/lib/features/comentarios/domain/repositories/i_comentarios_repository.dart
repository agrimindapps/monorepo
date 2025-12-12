import 'i_comentarios_read_repository.dart';
import 'i_comentarios_write_repository.dart';

/// Combined repository interface for backward compatibility and ease of use.
/// Implements both Read and Write interfaces.
abstract class IComentariosRepository implements IComentariosReadRepository, IComentariosWriteRepository {}
