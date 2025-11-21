
/// Service responsible for formatting legal document dates
/// Follows SRP by handling only date formatting concerns

class LegalDateFormatter {
  /// Format the current date in Portuguese format
  /// Example: "31 de Outubro de 2025"
  String formatCurrentDate() {
    final now = DateTime.now();
    return _formatDate(now);
  }

  /// Format a specific date in Portuguese format
  String formatDate(DateTime date) {
    return _formatDate(date);
  }

  /// Format a date string (ISO 8601) in Portuguese format
  String formatDateString(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return _formatDate(date);
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} de ${_getMonthName(date.month)} de ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  /// Get abbreviated month name (e.g., "Jan", "Fev")
  String getAbbreviatedMonthName(int month) {
    return _getMonthName(month).substring(0, 3);
  }
}
