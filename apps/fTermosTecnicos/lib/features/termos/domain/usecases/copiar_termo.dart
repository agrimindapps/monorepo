import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/termo.dart';

/// Use case for copying term content to clipboard
@injectable
class CopiarTermo {
  Future<Either<Failure, Unit>> call(Termo termo) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(termo.termo);
      buffer.writeln(termo.descricao);
      buffer.writeln();
      buffer.writeln('App Termos Técnicos - Agrimind Soluções');

      await Clipboard.setData(ClipboardData(text: buffer.toString()));

      return const Right(unit);
    } catch (e) {
      return const Left(
        UnknownFailure(message: 'Erro ao copiar termo'),
      );
    }
  }
}
