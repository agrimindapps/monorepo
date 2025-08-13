// Project imports:
import '../../../database/espaco_model.dart';

abstract class IEspacosRepository {
  Future<void> initialize();
  Future<List<EspacoModel>> findAll();
  Future<EspacoModel?> findById(String id);
  Future<String> create(EspacoModel espaco);
  Future<void> update(String id, EspacoModel espaco);
  Future<void> delete(String id);
  Future<String> salvar(EspacoModel espaco);
  Future<bool> existeComNome(String nome, {String? excluirId});
  Stream<List<EspacoModel>> get espacosStream;
}
