// Project imports:
import '../interfaces/i_filter_service.dart';
import '../utils/defensivos_helpers.dart';

/// Serviço responsável pela lógica de filtros e ordenação
class FilterService implements IFilterService {
  @override
  List<T> filterByText<T>(List<T> sourceList, String searchText,
      String Function(T) getLine1, String Function(T) getLine2) {
    if (!isSearchValid(searchText)) {
      return sourceList;
    }

    final searchLower = searchText.toLowerCase();
    return sourceList
        .where((item) =>
            getLine1(item).toLowerCase().contains(searchLower) ||
            getLine2(item).toLowerCase().contains(searchLower))
        .toList();
  }

  @override
  List<T> sortList<T>(List<T> inputList, String sortField, bool isAscending,
      String Function(T) getLine1, String Function(T) getLine2) {
    final sortedList = List<T>.from(inputList);
    sortedList.sort((a, b) {
      String aValue;
      String bValue;

      switch (sortField) {
        case 'line1':
          aValue = getLine1(a);
          bValue = getLine1(b);
          break;
        case 'line2':
          aValue = getLine2(a);
          bValue = getLine2(b);
          break;
        default:
          aValue = getLine1(a);
          bValue = getLine1(b);
      }

      if (isAscending) {
        return aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else {
        return bValue.toLowerCase().compareTo(aValue.toLowerCase());
      }
    });
    return sortedList;
  }

  @override
  bool isSearchValid(String searchText) {
    return DefensivosHelpers.isSearchValid(searchText);
  }

  @override
  int calculateItemsToAdd(int currentPage, int currentFilteredLength,
      int totalFilteredLength, int itemsPerScroll) {
    if (currentPage == 0 || currentFilteredLength == 0) {
      return itemsPerScroll < totalFilteredLength
          ? itemsPerScroll
          : totalFilteredLength;
    }
    final remaining = totalFilteredLength - currentFilteredLength;
    return remaining < itemsPerScroll ? remaining : itemsPerScroll;
  }
}
