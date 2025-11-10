import 'package:core/core.dart' hide Column;

import '../../presentation/services/subscription_error_message_service.dart';

/// Parâmetros para o use case de compra
class PurchaseProductUseCaseParams extends Equatable {
  const PurchaseProductUseCaseParams({
    required this.productId,
    this.userId,
    this.metadata,
  });

  final String productId;
  final String? userId;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [productId, userId, metadata];
}

/// Use case para comprar produto (usa core repository diretamente)
@injectable
class PurchaseProductUseCase
    implements UseCase<SubscriptionEntity, PurchaseProductUseCaseParams> {
  PurchaseProductUseCase(this.coreRepository, this.errorService);

  final ISubscriptionRepository coreRepository;
  final SubscriptionErrorMessageService errorService;

  @override
  Future<Either<Failure, SubscriptionEntity>> call(
    PurchaseProductUseCaseParams params,
  ) async {
    if (params.productId.trim().isEmpty) {
      return Left(ValidationFailure(errorService.getEmptyProductIdError()));
    }

    return coreRepository.purchaseProduct(productId: params.productId);
  }
}
