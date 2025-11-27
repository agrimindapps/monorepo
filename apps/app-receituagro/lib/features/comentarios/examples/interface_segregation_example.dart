/// **Interface Segregation Principle Example**
///
/// This file demonstrates how to use the segregated read/write interfaces
/// for the Comentarios repository following ISP (Interface Segregation Principle).
///
/// ## Benefits:
///
/// 1. **Clear Intent**: Dependencies show exactly what operations a class needs
/// 2. **Better Testing**: Mock only read or write operations as needed
/// 3. **Security**: Easy to restrict write access to specific services
/// 4. **Flexibility**: Can inject different implementations for read/write

library;

import '../domain/entities/comentario_entity.dart';
import '../domain/repositories/i_comentarios_read_repository.dart';
import '../domain/repositories/i_comentarios_repository.dart';
import '../domain/repositories/i_comentarios_write_repository.dart';

/// ✅ Example 1: Read-only service
/// Only needs to query comments - depends on IComentariosReadRepository
class ComentariosListService {
  final IComentariosReadRepository _readRepo;

  ComentariosListService(this._readRepo);

  Future<List<ComentarioEntity>> getActiveComments() async {
    final all = await _readRepo.getAllComentarios();
    return all.where((c) => c.status).toList();
  }

  Future<ComentarioEntity?> findById(String id) async {
    return await _readRepo.getComentarioById(id);
  }

  Future<List<ComentarioEntity>> searchByKeyword(String keyword) async {
    return await _readRepo.searchComentarios(keyword);
  }

  // ❌ Cannot call write operations - compile-time safety!
  // _readRepo.addComentario(...) // ERROR: Method not defined
}

/// ✅ Example 2: Write-only service
/// Only needs to modify comments - depends on IComentariosWriteRepository
class ComentariosEditorService {
  final IComentariosWriteRepository _writeRepo;

  ComentariosEditorService(this._writeRepo);

  Future<void> createComment(ComentarioEntity comment) async {
    await _writeRepo.addComentario(comment);
  }

  Future<void> updateComment(ComentarioEntity comment) async {
    await _writeRepo.updateComentario(comment);
  }

  Future<void> removeComment(String id) async {
    await _writeRepo.deleteComentario(id);
  }

  // ❌ Cannot call read operations - compile-time safety!
  // _writeRepo.getAllComentarios() // ERROR: Method not defined
}

/// ✅ Example 3: Service that needs both read and write
/// Depends on combined interface for backward compatibility
class ComentariosSyncService {
  final IComentariosRepository _repo;

  ComentariosSyncService(this._repo);

  Future<void> syncComment(ComentarioEntity comment) async {
    // Can use both read and write operations
    final existing = await _repo.getComentarioById(comment.id);

    if (existing == null) {
      await _repo.addComentario(comment);
    } else {
      await _repo.updateComentario(comment);
    }
  }
}

/// ✅ Example 4: Dependency Injection with segregated interfaces
class ExampleDependencySetup {
  void setupServices() {
    // In real code, use Riverpod providers for DI

    // Read-only services get read repository
    // final listService = ComentariosListService(
    //   ref.watch(comentariosReadRepositoryProvider),
    // );

    // Write-only services get write repository
    // final editorService = ComentariosEditorService(
    //   ref.watch(comentariosWriteRepositoryProvider),
    // );

    // Services needing both get combined interface
    // final syncService = ComentariosSyncService(
    //   getIt<IComentariosRepository>(),
    // );
  }
}

/// ✅ Example 5: Testing with segregated interfaces
/// Mock only what you need!
/*
// Read-only test - only mock read operations
class MockComentariosReadRepository extends Mock
    implements IComentariosReadRepository {}

test('should load active comments', () async {
  final mockReadRepo = MockComentariosReadRepository();
  final service = ComentariosListService(mockReadRepo);

  when(() => mockReadRepo.getAllComentarios())
      .thenAnswer((_) async => [activeComment]);

  final result = await service.getActiveComments();

  expect(result.length, 1);
  verify(() => mockReadRepo.getAllComentarios()).called(1);
  // No need to mock write operations!
});
*/
