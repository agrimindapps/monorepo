import 'package:core/core.dart';

import '../repositories/i_subscription_repository.dart';

/// Use case para buscar produtos disponíveis do ReceitaAgro
@injectable
class GetAvailableProductsUseCase
    implements UseCase<List<ProductInfo>, NoParams> {
  GetAvailableProductsUseCase(this.repository);

  final IAppSubscriptionRepository repository;

  @override
  Future<Either<Failure, List<ProductInfo>>> call(NoParams params) async {
    return repository.getReceitaAgroProducts();
  }
}
