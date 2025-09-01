import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/promo_repository.dart';

class SubmitPreRegistration implements UseCase<void, String> {
  final PromoRepository repository;

  SubmitPreRegistration(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure(message: 'Email inválido'));
    }

    return await repository.submitPreRegistration(email);
  }
}