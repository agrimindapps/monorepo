/// Serviço responsável por formatação de dados de exibição
class DataFormattingService {
  /// Formata uma data para exibição no formato brasileiro
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formata uma data com hora para exibição
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
