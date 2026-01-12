import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/feedback_entity.dart';

/// Interface do repositório de feedback
/// 
/// Define as operações disponíveis para gerenciar feedbacks dos usuários.
/// A implementação concreta usa Firebase Firestore.
abstract class IFeedbackRepository {
  /// Envia um novo feedback
  /// 
  /// Qualquer usuário (mesmo não autenticado) pode enviar feedback.
  /// Retorna o ID do feedback criado em caso de sucesso.
  Future<Either<Failure, String>> submitFeedback(FeedbackEntity feedback);

  /// Lista todos os feedbacks (apenas admin autenticado)
  /// 
  /// Suporta paginação e filtros opcionais.
  Future<Either<Failure, List<FeedbackEntity>>> getFeedbacks({
    FeedbackStatus? status,
    FeedbackType? type,
    int limit = 50,
    String? lastDocumentId,
  });

  /// Obtém um feedback específico por ID (apenas admin)
  Future<Either<Failure, FeedbackEntity>> getFeedbackById(String id);

  /// Atualiza o status de um feedback (apenas admin)
  Future<Either<Failure, void>> updateFeedbackStatus(
    String id,
    FeedbackStatus status, {
    String? adminNotes,
  });

  /// Deleta um feedback (apenas admin)
  Future<Either<Failure, void>> deleteFeedback(String id);

  /// Stream de feedbacks em tempo real (apenas admin)
  Stream<Either<Failure, List<FeedbackEntity>>> watchFeedbacks({
    FeedbackStatus? status,
    FeedbackType? type,
    int limit = 50,
  });

  /// Obtém contagem de feedbacks por status (apenas admin)
  Future<Either<Failure, Map<FeedbackStatus, int>>> getFeedbackCounts();
}
