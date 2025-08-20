// Project imports:
import '../../../../controllers/pluviometros_controller.dart';
import '../../../../models/pluviometros_models.dart';

/// Interface para operações de repositório de pluviômetros
abstract class IPluviometroRepository {
  Future<void> addPluviometro(Pluviometro pluviometro);
  Future<void> updatePluviometro(Pluviometro pluviometro);
  Future<void> deletePluviometro(String id);
  Future<Pluviometro?> getPluviometro(String id);
  Future<List<Pluviometro>> getAllPluviometros();
}

/// Implementação do repositório que usa o controller existente
class PluviometroRepositoryService implements IPluviometroRepository {
  final PluviometrosController _controller;

  PluviometroRepositoryService({PluviometrosController? controller})
      : _controller = controller ?? PluviometrosController();

  @override
  Future<void> addPluviometro(Pluviometro pluviometro) async {
    try {
      await _controller.addPluviometro(pluviometro);
    } catch (e) {
      throw RepositoryException('Erro ao adicionar pluviômetro: $e');
    }
  }

  @override
  Future<void> updatePluviometro(Pluviometro pluviometro) async {
    try {
      await _controller.updatePluviometro(pluviometro);
    } catch (e) {
      throw RepositoryException('Erro ao atualizar pluviômetro: $e');
    }
  }

  @override
  Future<void> deletePluviometro(String id) async {
    try {
      final pluviometro = await getPluviometro(id);
      if (pluviometro != null) {
        await _controller.deletePluviometro(pluviometro);
      }
    } catch (e) {
      throw RepositoryException('Erro ao deletar pluviômetro: $e');
    }
  }

  @override
  Future<Pluviometro?> getPluviometro(String id) async {
    try {
      return await _controller.getPluviometroById(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Pluviometro>> getAllPluviometros() async {
    try {
      return await _controller.getPluviometros();
    } catch (e) {
      throw RepositoryException('Erro ao buscar pluviômetros: $e');
    }
  }
}

/// Exceção para erros do repositório
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
