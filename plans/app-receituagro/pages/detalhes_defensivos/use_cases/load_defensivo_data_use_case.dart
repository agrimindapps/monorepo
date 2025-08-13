// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/defensivos_repository.dart';
import '../interfaces/i_load_defensivo_use_case.dart';
import '../models/defensivo_details_model.dart';

/// Use case para carregamento de dados de defensivo
class LoadDefensivoDataUseCase implements ILoadDefensivoUseCase {
  final DefensivosRepository _repository;

  LoadDefensivoDataUseCase({DefensivosRepository? repository})
      : _repository = repository ?? Get.find<DefensivosRepository>();

  @override
  Future<DefensivoDetailsModel> execute(String defensivoId) async {
    if (defensivoId.isEmpty) {
      throw ArgumentError('DefensivoId não pode estar vazio');
    }

    try {
      // Carrega dados básicos
      final basicData = await loadBasicData(defensivoId);
      if (basicData.isEmpty) {
        throw Exception('Defensivo não encontrado');
      }

      // Carrega informações detalhadas
      final detailedInfo = await loadDetailedInfo(defensivoId);
      
      // Carrega diagnósticos
      final diagnostics = await loadDiagnostics(defensivoId);

      // Monta o modelo completo
      return DefensivoDetailsModel(
        caracteristicas: _processBasicData(basicData),
        informacoes: detailedInfo,
        diagnosticos: diagnostics,
      );
    } catch (e) {
      throw Exception('Erro ao carregar defensivo: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> loadBasicData(String defensivoId) async {
    try {
      final data = await _repository.getDefensivoById(defensivoId);
      return data;
    } catch (e) {
      throw Exception('Erro ao carregar dados básicos: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> loadDetailedInfo(String defensivoId) async {
    try {
      final info = await _repository.getDefensivosInfo(defensivoId);
      return info;
    } catch (e) {
      throw Exception('Erro ao carregar informações detalhadas: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadDiagnostics(String defensivoId) async {
    try {
      final diagnostics = _repository.getDefensivoDiagnosticos(defensivoId, 1);
      return diagnostics.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erro ao carregar diagnósticos: $e');
    }
  }

  /// Processa os dados básicos aplicando formatações necessárias
  Map<String, dynamic> _processBasicData(Map<String, dynamic> rawData) {
    final processedData = Map<String, dynamic>.from(rawData);
    
    // Formatar ingrediente ativo
    final ingrediente = processedData['ingredienteAtivo'] ?? '';
    final quantidade = processedData['quantProduto'] ?? '';
    
    if (ingrediente.isNotEmpty && quantidade.isNotEmpty) {
      processedData['ingredienteAtivo'] = '$ingrediente ($quantidade)';
    }
    
    return processedData;
  }

  /// Carrega dados de forma paralela para melhor performance
  Future<DefensivoDetailsModel> executeParallel(String defensivoId) async {
    if (defensivoId.isEmpty) {
      throw ArgumentError('DefensivoId não pode estar vazio');
    }

    try {
      // Carrega todos os dados em paralelo
      final results = await Future.wait([
        loadBasicData(defensivoId),
        loadDetailedInfo(defensivoId),
        loadDiagnostics(defensivoId),
      ]);

      final basicData = results[0] as Map<String, dynamic>;
      final detailedInfo = results[1] as Map<String, dynamic>;
      final diagnostics = results[2] as List<Map<String, dynamic>>;

      if (basicData.isEmpty) {
        throw Exception('Defensivo não encontrado');
      }

      return DefensivoDetailsModel(
        caracteristicas: _processBasicData(basicData),
        informacoes: detailedInfo,
        diagnosticos: diagnostics,
      );
    } catch (e) {
      throw Exception('Erro ao carregar defensivo: $e');
    }
  }
}
