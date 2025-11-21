import 'package:injectable/injectable.dart';
import '../domain/repositories/i_comentarios_read_repository.dart';
import '../domain/repositories/i_comentarios_repository.dart';
import '../domain/repositories/i_comentarios_write_repository.dart';

@module
abstract class ComentariosModule {
  @lazySingleton
  IComentariosReadRepository readRepository(IComentariosRepository repo) =>
      repo as IComentariosReadRepository;

  @lazySingleton
  IComentariosWriteRepository writeRepository(IComentariosRepository repo) =>
      repo as IComentariosWriteRepository;
}
