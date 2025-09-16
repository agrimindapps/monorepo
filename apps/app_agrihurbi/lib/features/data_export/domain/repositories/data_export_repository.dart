import '../entities/export_data.dart';
import '../entities/export_request.dart';

abstract class DataExportRepository {
  /// Verifica se o usuário pode realizar um export (rate limiting)
  Future<bool> canExport();

  /// Obtém a data do último export realizado
  Future<DateTime?> getLastExportDate();

  /// Coleta todos os dados do usuário para exportação
  Future<ExportData> collectUserData();

  /// Exporta os dados no formato especificado
  Future<String> exportData(ExportRequest request, ExportData data);

  /// Salva o arquivo de exportação no dispositivo
  Future<bool> saveExportFile(String content, String fileName);

  /// Registra a exportação para auditoria e rate limiting
  Future<void> recordExport(ExportRequest request);

  /// Obtém dados do perfil do usuário
  Future<UserProfileData?> getUserProfile();

  /// Obtém favoritos do usuário
  Future<List<FavoriteData>> getUserFavorites();

  /// Obtém comentários do usuário
  Future<List<CommentData>> getUserComments();

  /// Obtém preferências/configurações do usuário
  Future<UserPreferencesData?> getUserPreferences();
}