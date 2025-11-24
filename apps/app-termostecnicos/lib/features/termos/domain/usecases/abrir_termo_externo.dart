import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failures.dart';
import '../entities/termo.dart';

/// Use case for opening term in external browser (Google search)
class AbrirTermoExterno {
  Future<Either<Failure, Unit>> call(Termo termo) async {
    try {
      final link = 'https://www.google.com/search?q=${termo.termo}';
      final url = Uri.parse(link);

      if (!await launchUrl(url)) {
        return const Left(
          UnknownFailure(message: 'Não foi possível abrir o navegador'),
        );
      }

      return const Right(unit);
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'Erro ao abrir termo no navegador'),
      );
    }
  }
}
