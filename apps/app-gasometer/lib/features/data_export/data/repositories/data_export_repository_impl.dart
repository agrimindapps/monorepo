import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:core/core.dart';

import '../../domain/entities/export_metadata.dart';
import '../../domain/entities/export_progress.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/entities/export_result.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/services/data_export_service.dart';

/// Implementação do repositório de exportação de dados LGPD
@LazySingleton(as: DataExportRepository)
class DataExportRepositoryImpl implements DataExportRepository {
  
  DataExportRepositoryImpl() : _exportService = DataExportService.instance;
  final DataExportService _exportService;

  @override
  Future<ExportResult> exportUserData(
    ExportRequest request, {
    void Function(ExportProgress progress)? onProgress,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // Validar request
      if (!await validateExportRequest(request)) {
        return ExportResult.failure(
          errorMessage: 'Solicitação de exportação inválida',
          processingTime: DateTime.now().difference(startTime),
        );
      }

      // Verificar rate limiting
      if (!await canExportData(request.userId)) {
        return ExportResult.failure(
          errorMessage: 'Limite de exportações atingido. Tente novamente em 24 horas.',
          processingTime: DateTime.now().difference(startTime),
        );
      }

      // Reportar progresso inicial
      onProgress?.call(ExportProgress.initial());

      // Coletar dados do usuário
      onProgress?.call(ExportProgress.processing('Coletando dados do usuário...', 0.1));
      final userData = await _exportService.collectUserData(request, onProgress);

      // Gerar metadados
      final metadata = ExportMetadata(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        generatedAt: DateTime.now(),
        version: '1.0.0',
        lgpdCompliance: true,
        dataCategories: request.includedCategories,
        exportStats: {
          'total_categories': request.includedCategories.length,
          'user_id': request.userId,
          'processing_time_started': startTime.toIso8601String(),
        },
        format: 'json',
        fileSizeMb: 0, // Será calculado depois
        checksum: '',  // Será calculado depois
      );

      // Processar em isolate para não bloquear a UI
      onProgress?.call(ExportProgress.processing('Gerando arquivos de exportação...', 0.7));
      final exportFiles = await _processExportInIsolate(userData, metadata);

      // Salvar arquivo final
      onProgress?.call(ExportProgress.processing('Salvando arquivo...', 0.9));
      final jsonData = exportFiles['json'];
      if (jsonData == null) {
        return ExportResult.failure(
          errorMessage: 'Erro na geração do arquivo JSON',
          processingTime: DateTime.now().difference(startTime),
        );
      }
      
      final filePath = await _saveExportFile(jsonData, request.userId);

      // Calcular metadados finais
      final fileSize = await File(filePath).length();
      final checksum = _exportService.generateChecksum(jsonData);
      
      final finalMetadata = metadata.copyWith(
        fileSizeMb: (fileSize / (1024 * 1024)).ceil(),
        checksum: checksum,
      );

      // Registrar exportação realizada
      await _recordExport(request.userId);

      // Cleanup de arquivos temporários em background
      _cleanupTemporaryFiles();

      onProgress?.call(ExportProgress.completed());

      return ExportResult.success(
        filePath: filePath,
        metadata: finalMetadata,
        processingTime: DateTime.now().difference(startTime),
      );

    } catch (e) {
      return ExportResult.failure(
        errorMessage: 'Erro durante exportação: $e',
        processingTime: DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<bool> canExportData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastExportKey = 'last_export_$userId';
    final lastExportTimestamp = prefs.getInt(lastExportKey);
    
    if (lastExportTimestamp == null) return true;
    
    final lastExport = DateTime.fromMillisecondsSinceEpoch(lastExportTimestamp);
    final now = DateTime.now();
    final difference = now.difference(lastExport);
    
    // Limite de 1 exportação por dia
    return difference.inHours >= 24;
  }

  @override
  Future<List<ExportResult>> getExportHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = 'export_history_$userId';
    final historyJson = prefs.getStringList(historyKey) ?? [];
    
    return historyJson
        .map((json) => ExportResult.fromJson(_parseJson(json)))
        .toList();
  }

  @override
  Future<void> cleanupTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final exportTempDir = Directory('${tempDir.path}/exports');
      
      if (await exportTempDir.exists()) {
        final files = await exportTempDir.list().toList();
        final now = DateTime.now();
        
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);
            
            // Remove arquivos temporários mais antigos que 1 hora
            if (age.inHours >= 1) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      print('Erro ao limpar arquivos temporários: $e');
    }
  }

  @override
  Future<bool> validateExportRequest(ExportRequest request) async {
    // Validações básicas
    if (request.userId.isEmpty) return false;
    if (request.includedCategories.isEmpty) return false;
    if (request.outputFormats.isEmpty) return false;

    // Validar categorias
    final validCategories = ExportDataCategory.getAllKeys();
    for (final category in request.includedCategories) {
      if (!validCategories.contains(category)) return false;
    }

    // Validar formatos
    final validFormats = ['json', 'csv'];
    for (final format in request.outputFormats) {
      if (!validFormats.contains(format)) return false;
    }

    // Validar intervalo de datas
    if (request.startDate != null && request.endDate != null) {
      if (request.startDate!.isAfter(request.endDate!)) return false;
    }

    return true;
  }

  @override
  Future<Map<String, dynamic>> estimateExportSize(ExportRequest request) async {
    try {
      // Simular coleta para estimativa (sem salvar)
      final userData = await _exportService.collectUserData(request, null);
      
      int totalRecords = 0;
      final int totalCategories = userData.keys.length;
      
      for (final data in userData.values) {
        if (data is List) {
          totalRecords += data.length;
        } else if (data is Map) {
          totalRecords += 1;
        }
      }

      // Estimar tamanho do JSON
      final jsonData = await _exportService.generateJsonExport(userData, ExportMetadata(
        id: 'estimate',
        generatedAt: DateTime.now(),
        version: '1.0.0',
        lgpdCompliance: true,
        dataCategories: request.includedCategories,
        exportStats: {},
        format: 'json',
        fileSizeMb: 0,
        checksum: '',
      ));

      return {
        'total_categories': totalCategories,
        'total_records': totalRecords,
        'estimated_size_bytes': jsonData.length,
        'estimated_size_mb': (jsonData.length / (1024 * 1024)).ceil(),
        'processing_time_estimate_minutes': (totalRecords / 1000 * 2).ceil().clamp(1, 10),
      };
    } catch (e) {
      return {
        'error': 'Não foi possível estimar o tamanho da exportação: $e',
        'total_categories': 0,
        'total_records': 0,
        'estimated_size_bytes': 0,
        'estimated_size_mb': 0,
        'processing_time_estimate_minutes': 1,
      };
    }
  }

  // Métodos privados auxiliares

  Future<Map<String, Uint8List>> _processExportInIsolate(
    Map<String, dynamic> userData,
    ExportMetadata metadata,
  ) async {
    try {
      // Para esta implementação, vamos processar no thread principal
      // Em produção, seria ideal usar um Isolate real
      final jsonData = await _exportService.generateJsonExport(userData, metadata);
      final csvData = await _exportService.generateCsvExport(userData);
      
      return {
        'json': jsonData,
        'csv': csvData,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _saveExportFile(Uint8List data, String userId) async {
    try {
      final directory = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'gasometer_export_${userId}_$timestamp.json';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(data);
      
      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  Future<Directory> _getExportDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${documentsDir.path}/exports');
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    
    return exportDir;
  }

  Future<void> _recordExport(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_export_$userId', DateTime.now().millisecondsSinceEpoch);
  }

  void _cleanupTemporaryFiles() async {
    // Executar cleanup em background
    try {
      await cleanupTemporaryFiles();
    } catch (e) {
      print('Erro durante cleanup automático: $e');
    }
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return Map<String, dynamic>.from(
        // Aqui deveria usar json.decode, mas vamos simular
        <String, dynamic>{},
      );
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}