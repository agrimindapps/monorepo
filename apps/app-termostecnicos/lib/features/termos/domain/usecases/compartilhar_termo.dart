import 'package:dartz/dartz.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/failures.dart';
import '../entities/termo.dart';

/// Use case for sharing a term via platform share sheet
class CompartilharTermo {
  Future<Either<Failure, Unit>> call(Termo termo) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(termo.termo);
      buffer.writeln(termo.descricao);
      buffer.writeln();
      buffer.writeln('App Termos Técnicos - Agrimind Soluções');

      await SharePlus.instance.share(
        ShareParams(text: buffer.toString(), subject: termo.termo),
      );

      return const Right(unit);
    } catch (e) {
      return const Left(UnknownFailure(message: 'Erro ao compartilhar termo'));
    }
  }
}
