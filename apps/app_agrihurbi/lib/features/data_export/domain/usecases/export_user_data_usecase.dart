import '../entities/export_request.dart';
import '../entities/export_data.dart';
import '../repositories/data_export_repository.dart';

class ExportUserDataUsecase {
  final DataExportRepository _repository;

  ExportUserDataUsecase(this._repository);

  Stream<ExportProgress> execute(ExportRequest request) async* {
    try {
      // Verificar disponibilidade
      yield ExportProgress(
        current: 0,
        total: 6,
        currentTask: 'Verificando disponibilidade...',
      );

      final canExport = await _repository.canExport();
      if (!canExport) {
        yield ExportProgress(
          current: 0,
          total: 6,
          currentTask: 'Export não disponível',
          error: 'Rate limit atingido. Tente novamente em 24 horas.',
        );
        return;
      }

      // Coletar dados
      yield ExportProgress(
        current: 1,
        total: 6,
        currentTask: 'Coletando dados do usuário...',
      );

      final exportData = await _collectUserData(request.dataTypes);

      // Processar dados
      yield ExportProgress(
        current: 2,
        total: 6,
        currentTask: 'Processando dados...',
      );

      if (request.sanitizeData) {
        // Sanitizar dados sensíveis se necessário
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Exportar dados
      yield ExportProgress(
        current: 3,
        total: 6,
        currentTask: 'Gerando arquivo de exportação...',
      );

      final exportedContent = await _repository.exportData(request, exportData);

      // Salvar arquivo
      yield ExportProgress(
        current: 4,
        total: 6,
        currentTask: 'Salvando arquivo...',
      );

      final fileName = request.defaultFileName;
      final saved = await _repository.saveExportFile(exportedContent, fileName);

      if (!saved) {
        yield ExportProgress(
          current: 4,
          total: 6,
          currentTask: 'Erro ao salvar arquivo',
          error: 'Não foi possível salvar o arquivo de exportação.',
        );
        return;
      }

      // Registrar exportação
      yield ExportProgress(
        current: 5,
        total: 6,
        currentTask: 'Finalizando...',
      );

      await _repository.recordExport(request);

      // Concluído
      yield ExportProgress(
        current: 6,
        total: 6,
        currentTask: 'Export concluído com sucesso!',
        isCompleted: true,
      );

    } catch (e) {
      yield ExportProgress(
        current: 0,
        total: 6,
        currentTask: 'Erro durante exportação',
        error: e.toString(),
      );
    }
  }

  Future<ExportData> _collectUserData(Set<DataType> dataTypes) async {
    final futures = <Future>[];
    UserProfileData? userProfile;
    List<FavoriteData> favorites = [];
    List<CommentData> comments = [];
    UserPreferencesData? preferences;

    if (dataTypes.contains(DataType.userProfile)) {
      futures.add(_repository.getUserProfile().then((data) => userProfile = data));
    }

    if (dataTypes.contains(DataType.favorites)) {
      futures.add(_repository.getUserFavorites().then((data) => favorites = data));
    }

    if (dataTypes.contains(DataType.comments)) {
      futures.add(_repository.getUserComments().then((data) => comments = data));
    }

    if (dataTypes.contains(DataType.preferences)) {
      futures.add(_repository.getUserPreferences().then((data) => preferences = data));
    }

    await Future.wait(futures);

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
        format: dataTypes.contains(DataType.userProfile) ? 'full' : 'partial',
        totalRecords: totalRecords,
      ),
    );
  }
}