// Project imports:
import '../models/cultura_model.dart';

class DataSanitizer {
  static List<CulturaModel> sanitizeApiData(List<dynamic> rawData) {
    return rawData
        .map((item) {
          if (item is Map<String, dynamic>) {
            return CulturaModel(
              idReg: sanitizeString(item['idReg']?.toString() ?? ''),
              cultura: sanitizeString(
                  item['cultura']?.toString() ?? 'Cultura desconhecida'),
              grupo: sanitizeString(
                  item['grupo']?.toString() ?? 'Sem grupo definido'),
            );
          }
          return null;
        })
        .where((item) => item != null)
        .cast<CulturaModel>()
        .toList();
  }

  static String sanitizeString(String input) {
    final sanitized = input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[^\w\s\-\.\(\)\/áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ]', caseSensitive: false), '');
    
    return sanitized.length > 255 
        ? sanitized.substring(0, 255) 
        : sanitized;
  }

  static String sanitizeSearchInput(String input) {
    final sanitized = input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\-\.áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ]', caseSensitive: false), '');
    
    return sanitized.length > 100 
        ? sanitized.substring(0, 100) 
        : sanitized;
  }
}
