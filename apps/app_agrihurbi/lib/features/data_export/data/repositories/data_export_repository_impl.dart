import '../../domain/entities/export_data.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../datasources/local_data_export_datasource.dart';
import '../services/export_formatter_service.dart';
import '../services/file_service.dart';

class DataExportRepositoryImpl implements DataExportRepository {
  final LocalDataExportDataSource _localDataSource;
  final ExportFormatterService _formatterService;
  final FileService _fileService;

  DataExportRepositoryImpl(
    this._localDataSource,
    this._formatterService,
    this._fileService,
  );

  @override
  Future<bool> canExport() async {
    final lastExportDate = await _localDataSource.getLastExportDate();

    if (lastExportDate == null) return true;

    final now = DateTime.now();
    final daysSinceLastExport = now.difference(lastExportDate).inDays;

    // Rate limit: 1 export por dia
    return daysSinceLastExport >= 1;
  }

  @override
  Future<DateTime?> getLastExportDate() async {
    return await _localDataSource.getLastExportDate();
  }

  @override
  Future<ExportData> collectUserData() async {
    final userProfile = await getUserProfile();
    final favorites = await getUserFavorites();
    final comments = await getUserComments();
    final preferences = await getUserPreferences();

    final totalRecords = (userProfile != null ? 1 : 0) +
                        favorites.length +
                        comments.length +
                        (preferences != null ? 1 : 0);

    return ExportData(
      userProfile: userProfile,
      favorites: favorites,
      comments: comments,
      preferences: preferences,
      metadata: ExportMetadata(
        exportDate: DateTime.now(),
        userId: 'current_user', // TODO: Get from auth service
        appVersion: '1.0.0', // TODO: Get from package info
        dataVersion: '1.0',
        format: 'complete',
        totalRecords: totalRecords,
      ),
    );
  }

  @override
  Future<String> exportData(ExportRequest request, ExportData data) async {
    return _formatterService.formatExportData(data, request.format);
  }

  @override
  Future<bool> saveExportFile(String content, String fileName) async {
    return await _fileService.saveFile(content, fileName);
  }

  @override
  Future<void> recordExport(ExportRequest request) async {
    final now = DateTime.now();
    await _localDataSource.saveExportRecord(now);

    // TODO: Implementar analytics/auditoria
    // await _analyticsService.trackExport(request);
  }

  @override
  Future<UserProfileData?> getUserProfile() async {
    return await _localDataSource.getUserProfileData();
  }

  @override
  Future<List<FavoriteData>> getUserFavorites() async {
    return await _localDataSource.getFavoritesData();
  }

  @override
  Future<List<CommentData>> getUserComments() async {
    return await _localDataSource.getCommentsData();
  }

  @override
  Future<UserPreferencesData?> getUserPreferences() async {
    return await _localDataSource.getPreferencesData();
  }
}