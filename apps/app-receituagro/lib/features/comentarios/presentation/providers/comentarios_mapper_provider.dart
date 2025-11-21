import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/comentarios_mapper.dart';

part 'comentarios_mapper_provider.g.dart';

@riverpod
IComentariosMapper comentariosMapper(ComentariosMapperRef ref) {
  return ComentariosMapper();
}
