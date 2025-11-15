import 'i_comentarios_read_repository.dart';
import 'i_comentarios_write_repository.dart';

/// Combined repository interface for comentarios.
/// 
/// **DEPRECATED**: This interface combines read and write operations for backward compatibility.
/// New code should use:
/// - [IComentariosReadRepository] for read-only operations
/// - [IComentariosWriteRepository] for write operations
/// 
/// This follows Interface Segregation Principle (ISP) - clients should not be forced
/// to depend on interfaces they don't use.
/// 
/// Benefits of segregation:
/// - Clearer separation of concerns
/// - Easier to mock in tests
/// - Better security control (read-only vs write access)
/// - More flexible dependency injection
@Deprecated('Use IComentariosReadRepository or IComentariosWriteRepository instead')
abstract class IComentariosRepository
    implements IComentariosReadRepository, IComentariosWriteRepository {
  // Empty - just combines the two interfaces for backward compatibility
}
