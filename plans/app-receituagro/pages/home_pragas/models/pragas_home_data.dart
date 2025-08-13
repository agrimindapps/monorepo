// Project imports:
import 'praga_counts.dart';
import 'praga_item.dart';

class PragasHomeData {
  final PragaCounts counts;
  final List<PragaItem> pragasSugeridas;
  final List<PragaItem> ultimasPragasAcessadas;
  final int carouselCurrentIndex;

  PragasHomeData({
    PragaCounts? counts,
    this.pragasSugeridas = const [],
    this.ultimasPragasAcessadas = const [],
    this.carouselCurrentIndex = 0,
  }) : counts = counts ?? PragaCounts();

  PragasHomeData copyWith({
    PragaCounts? counts,
    List<PragaItem>? pragasSugeridas,
    List<PragaItem>? ultimasPragasAcessadas,
    int? carouselCurrentIndex,
  }) {
    return PragasHomeData(
      counts: counts ?? this.counts,
      pragasSugeridas: pragasSugeridas ?? this.pragasSugeridas,
      ultimasPragasAcessadas: ultimasPragasAcessadas ?? this.ultimasPragasAcessadas,
      carouselCurrentIndex: carouselCurrentIndex ?? this.carouselCurrentIndex,
    );
  }
}
