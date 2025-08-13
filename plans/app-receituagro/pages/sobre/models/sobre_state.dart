// Project imports:
import 'sobre_model.dart';

class SobreState {
  final SobreModel sobreData;
  final List<ContatoModel> contatos;
  final bool isLoading;
  final bool isDark;
  final String? error;

  const SobreState({
    this.sobreData = const SobreModel(),
    this.contatos = const [],
    this.isLoading = true,
    this.isDark = false,
    this.error,
  });

  SobreState copyWith({
    SobreModel? sobreData,
    List<ContatoModel>? contatos,
    bool? isLoading,
    bool? isDark,
    String? error,
  }) {
    return SobreState(
      sobreData: sobreData ?? this.sobreData,
      contatos: contatos ?? this.contatos,
      isLoading: isLoading ?? this.isLoading,
      isDark: isDark ?? this.isDark,
      error: error ?? this.error,
    );
  }

  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasContatos => contatos.isNotEmpty;
  int get totalContatos => contatos.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SobreState &&
        other.sobreData == sobreData &&
        _listEquals(other.contatos, contatos) &&
        other.isLoading == isLoading &&
        other.isDark == isDark &&
        other.error == error;
  }

  @override
  int get hashCode {
    return sobreData.hashCode ^
        contatos.hashCode ^
        isLoading.hashCode ^
        isDark.hashCode ^
        error.hashCode;
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
