// Project imports:
import 'defensivos_constants.dart';

class DefensivosHelpers {
  static final Map<double, int> _crossAxisCountCache = {};

  static int calculateCrossAxisCount(double screenWidth) {
    if (_crossAxisCountCache.containsKey(screenWidth)) {
      return _crossAxisCountCache[screenWidth]!;
    }
    
    int count;
    if (screenWidth < DefensivosConstants.mobileBreakpoint) {
      count = DefensivosConstants.mobileCrossAxisCount;
    } else if (screenWidth < DefensivosConstants.tabletBreakpoint) {
      count = DefensivosConstants.tabletCrossAxisCount;
    } else {
      count = DefensivosConstants.desktopCrossAxisCount;
    }
    
    _crossAxisCountCache[screenWidth] = count;
    return count;
  }

  static void clearCache() {
    _crossAxisCountCache.clear();
  }

  static bool shouldShowLoadMore(int currentLength, int totalLength) {
    return currentLength < totalLength;
  }

  static bool isSearchValid(String searchText) {
    return searchText.length >= DefensivosConstants.minSearchLength;
  }
}
