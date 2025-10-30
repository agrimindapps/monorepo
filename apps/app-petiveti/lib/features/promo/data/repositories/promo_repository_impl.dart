import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/promo_content.dart';
import '../../domain/repositories/promo_repository.dart';
import '../models/promo_content_model.dart';
import '../services/promo_error_handling_service.dart';

/// Promo Repository Implementation
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles data operations for promo feature
/// - **Dependency Inversion**: Depends on error handling service abstraction
class PromoRepositoryImpl implements PromoRepository {
  const PromoRepositoryImpl(this._errorHandlingService);

  final PromoErrorHandlingService _errorHandlingService;

  @override
  Future<Either<Failure, PromoContent>> getPromoContent() async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        await Future<void>.delayed(
            const Duration(seconds: 1)); // Simulate network delay
        final promoContent = PromoContentModel.mock();
        return promoContent;
      },
      operationName: 'carregar conteúdo promocional',
    );
  }

  @override
  Future<Either<Failure, void>> submitPreRegistration(String email) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        await Future<void>.delayed(const Duration(seconds: 2));
        // Note: Email validation is now done in use case via PromoValidationService
        // This layer only handles the submission
      },
      operationName: 'enviar pré-cadastro',
    );
  }

  @override
  Future<Either<Failure, void>> trackEvent(
      String event, Map<String, dynamic> parameters) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // ignore: avoid_print
        print('Analytics Event: $event with parameters: $parameters');
      },
      operationName: 'registrar evento',
    );
  }
}
