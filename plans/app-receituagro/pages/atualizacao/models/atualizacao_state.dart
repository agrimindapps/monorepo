// Project imports:
import 'atualizacao_model.dart';

class AtualizacaoState {
  final List<AtualizacaoModel> atualizacoesList;
  final bool isLoading;
  final bool isDark;

  const AtualizacaoState({
    this.atualizacoesList = const [],
    this.isLoading = true,
    this.isDark = false,
  });

  AtualizacaoState copyWith({
    List<AtualizacaoModel>? atualizacoesList,
    bool? isLoading,
    bool? isDark,
  }) {
    return AtualizacaoState(
      atualizacoesList: atualizacoesList ?? this.atualizacoesList,
      isLoading: isLoading ?? this.isLoading,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AtualizacaoState &&
        _listEquals(other.atualizacoesList, atualizacoesList) &&
        other.isLoading == isLoading &&
        other.isDark == isDark;
  }

  @override
  int get hashCode {
    return atualizacoesList.hashCode ^
        isLoading.hashCode ^
        isDark.hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
