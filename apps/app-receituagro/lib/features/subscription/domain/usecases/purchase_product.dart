import 'package:core/core.dart';

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
  PurchaseProductUseCase(this.coreRepository);

  final ISubscriptionRepository coreRepository;

  @override
  Future<Either<Failure, SubscriptionEntity>> call(
    PurchaseProductUseCaseParams params,
  ) async {
    if (params.productId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do produto não pode ser vazio'),
      );
    }

    return coreRepository.purchaseProduct(productId: params.productId);
  }
}
