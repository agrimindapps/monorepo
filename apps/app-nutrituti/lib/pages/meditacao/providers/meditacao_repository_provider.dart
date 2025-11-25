// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import '../repository/meditacao_repository.dart';

part 'meditacao_repository_provider.g.dart';

@riverpod
MeditacaoRepository meditacaoRepository(Ref ref) {
  return MeditacaoRepository();
}
