import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/promo_content.dart';
import '../../domain/repositories/promo_repository.dart';
import '../models/promo_content_model.dart';

class PromoRepositoryImpl implements PromoRepository {
  const PromoRepositoryImpl();

  @override
  Future<Either<Failure, PromoContent>> getPromoContent() async {
    try {
      // For now, return mock data. In a real implementation,
      // this would fetch from an API or local storage
      await Future<void>.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      final promoContent = PromoContentModel.mock();
      return Right(promoContent);
    } catch (e) {
      return Left(ServerFailure(message: 'Falha ao carregar conteúdo promocional: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitPreRegistration(String email) async {
    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 2));
      
      // For now, just simulate success. In a real implementation,
      // this would send the email to a backend service
      if (email.isEmpty || !email.contains('@')) {
        return const Left(ValidationFailure(message: 'E-mail inválido'));
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Falha ao enviar pré-cadastro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> trackEvent(String event, Map<String, dynamic> parameters) async {
    try {
      // For now, just simulate success. In a real implementation,
      // this would send analytics events to services like Firebase Analytics
      await Future<void>.delayed(const Duration(milliseconds: 100));
      
      // Log the event for development purposes
      print('Analytics Event: $event with parameters: $parameters');
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Falha ao registrar evento: ${e.toString()}'));
    }
  }
}