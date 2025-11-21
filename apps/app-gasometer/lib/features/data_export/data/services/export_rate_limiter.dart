import 'package:core/core.dart';

/// Controlador de taxa de exportação (rate limiter)
///
/// Responsabilidade: Gerenciar limites de frequência de exportações
/// Aplica SRP (Single Responsibility Principle)

class ExportRateLimiter {
  static const int _hoursBetweenExports = 24;

  /// Verifica se o usuário pode exportar dados
  Future<bool> canExport(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastExportKey = 'last_export_$userId';
      final lastExportTimestamp = prefs.getInt(lastExportKey);

      if (lastExportTimestamp == null) return true;

      final lastExport = DateTime.fromMillisecondsSinceEpoch(
        lastExportTimestamp,
      );
      final now = DateTime.now();
      final difference = now.difference(lastExport);

      return difference.inHours >= _hoursBetweenExports;
    } catch (e) {
      SecureLogger.warning('Erro ao verificar limite de exportação', error: e);
      return true; // Em caso de erro, permite a exportação
    }
  }

  /// Registra uma exportação
  Future<void> recordExport(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_export_$userId',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      SecureLogger.warning('Erro ao registrar exportação', error: e);
    }
  }

  /// Obtém tempo restante até próxima exportação permitida
  Future<Duration?> getTimeUntilNextExport(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastExportKey = 'last_export_$userId';
      final lastExportTimestamp = prefs.getInt(lastExportKey);

      if (lastExportTimestamp == null) return Duration.zero;

      final lastExport = DateTime.fromMillisecondsSinceEpoch(
        lastExportTimestamp,
      );
      final now = DateTime.now();
      final nextExport = lastExport.add(
        const Duration(hours: _hoursBetweenExports),
      );

      if (now.isAfter(nextExport)) {
        return Duration.zero;
      }

      return nextExport.difference(now);
    } catch (e) {
      return null;
    }
  }

  /// Limpa histórico de exportações (para testes ou admin)
  Future<void> clearHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_export_$userId');
    } catch (e) {
      SecureLogger.warning('Erro ao limpar histórico de exportação', error: e);
    }
  }
}
