// Project imports:
import 'promo_page_model.dart';

class PromoPageState {
  final PromoPageModel promoData;
  final bool isLoading;
  final bool isDark;
  final bool isScrolling;

  const PromoPageState({
    this.promoData = const PromoPageModel(),
    this.isLoading = false,
    this.isDark = false,
    this.isScrolling = false,
  });

  PromoPageState copyWith({
    PromoPageModel? promoData,
    bool? isLoading,
    bool? isDark,
    bool? isScrolling,
  }) {
    return PromoPageState(
      promoData: promoData ?? this.promoData,
      isLoading: isLoading ?? this.isLoading,
      isDark: isDark ?? this.isDark,
      isScrolling: isScrolling ?? this.isScrolling,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromoPageState &&
        other.promoData == promoData &&
        other.isLoading == isLoading &&
        other.isDark == isDark &&
        other.isScrolling == isScrolling;
  }

  @override
  int get hashCode {
    return promoData.hashCode ^
        isLoading.hashCode ^
        isDark.hashCode ^
        isScrolling.hashCode;
  }
}
