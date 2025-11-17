import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';

@lazySingleton
class WeightErrorHandlingService {
  Failure handleFailure(dynamic e) {
    if (e is Failure) {
      return e;
    }
    return const CacheFailure(message: 'Erro inesperado ao acessar o cache');
  }
}
