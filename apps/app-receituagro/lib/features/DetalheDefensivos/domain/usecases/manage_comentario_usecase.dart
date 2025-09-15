import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../../comentarios/domain/entities/comentario_entity.dart';
import '../repositories/comentario_repository.dart';

/// Caso de uso para gerenciar comentários (adicionar/editar/remover)
/// 
/// Este use case encapsula toda a lógica de negócio relacionada
/// ao gerenciamento de comentários
class ManageComentarioUseCase {
  const ManageComentarioUseCase(this._repository);

  final ComentarioRepository _repository;

  /// Adiciona um novo comentário
  ResultFuture<String> addComentario(AddComentarioParams params) async {
    // Validação de entrada
    if (!params.isValid) {
      return const Left(
        ServerFailure('Dados inválidos para adicionar comentário'),
      );
    }

    // Validação do conteúdo
    if (!_isValidContent(params.conteudo)) {
      return const Left(
        ServerFailure('Comentário deve ter entre 5 e 300 caracteres'),
      );
    }

    try {
      final comentario = ComentarioEntity(
        id: _generateComentarioId(),
        idReg: _generateIdReg(),
        titulo: params.titulo,
        conteudo: params.conteudo.trim(),
        ferramenta: params.ferramenta,
        pkIdentificador: params.pkIdentificador,
        status: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _repository.addComentario(comentario);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar comentário: ${e.toString()}'));
    }
  }

  /// Remove um comentário
  ResultFuture<void> deleteComentario(String comentarioId) async {
    if (comentarioId.isEmpty) {
      return const Left(
        ServerFailure('ID do comentário é obrigatório'),
      );
    }

    try {
      return await _repository.deleteComentario(comentarioId);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar comentário: ${e.toString()}'));
    }
  }

  /// Busca comentários por identificador
  ResultFuture<List<ComentarioEntity>> getComentarios(String pkIdentificador) async {
    if (pkIdentificador.isEmpty) {
      return const Left(
        ServerFailure('Identificador é obrigatório'),
      );
    }

    try {
      return await _repository.getComentariosByPkIdentificador(pkIdentificador);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar comentários: ${e.toString()}'));
    }
  }

  /// Valida o conteúdo do comentário
  bool _isValidContent(String content) {
    final trimmedContent = content.trim();
    return trimmedContent.length >= 5 && trimmedContent.length <= 300;
  }

  /// Gera um ID único para o comentário
  String _generateComentarioId() {
    return 'coment_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Gera um ID de registro único
  String _generateIdReg() {
    return 'reg_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Parâmetros para adicionar comentário
class AddComentarioParams {
  final String titulo;
  final String conteudo;
  final String ferramenta;
  final String pkIdentificador;

  const AddComentarioParams({
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
  });

  /// Valida se os parâmetros são válidos
  bool get isValid => 
      conteudo.isNotEmpty && 
      ferramenta.isNotEmpty && 
      pkIdentificador.isNotEmpty;
}