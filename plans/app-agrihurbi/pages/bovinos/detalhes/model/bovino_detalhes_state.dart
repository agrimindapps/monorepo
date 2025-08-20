// Project imports:
import '../../../../models/bovino_class.dart';

class BovinoDetalhesState {
  final bool isLoading;
  final String? erro;
  final BovinoClass? bovino;

  BovinoDetalhesState({
    this.isLoading = false,
    this.erro,
    this.bovino,
  });

  BovinoDetalhesState copyWith({
    bool? isLoading,
    String? erro,
    BovinoClass? bovino,
  }) {
    return BovinoDetalhesState(
      isLoading: isLoading ?? this.isLoading,
      erro: erro ?? this.erro,
      bovino: bovino ?? this.bovino,
    );
  }
}
