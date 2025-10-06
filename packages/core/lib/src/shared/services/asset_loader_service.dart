import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../contracts/i_asset_loader.dart';

/// Serviço para carregamento de assets JSON
/// Implementa a interface IAssetLoader
class AssetLoaderService implements IAssetLoader {
  
  @override
  Future<Either<Exception, List<Map<String, dynamic>>>> loadJsonAsset(String assetPath) async {
    try {
      developer.log('Carregando asset: $assetPath', name: 'AssetLoaderService');
      
      final String jsonString = await rootBundle.loadString(assetPath);
      final dynamic jsonData = json.decode(jsonString);
      if (jsonData is List) {
        final List<Map<String, dynamic>> dataList = jsonData
            .whereType<Map<String, dynamic>>()
            .cast<Map<String, dynamic>>()
            .toList();
            
        developer.log('Asset carregado: ${dataList.length} registros', name: 'AssetLoaderService');
        return Right(dataList);
      }
      if (jsonData is Map<String, dynamic>) {
        for (final value in jsonData.values) {
          if (value is List) {
            final List<Map<String, dynamic>> dataList = value
                .whereType<Map<String, dynamic>>()
                .cast<Map<String, dynamic>>()
                .toList();
                
            developer.log('Asset carregado: ${dataList.length} registros', name: 'AssetLoaderService');
            return Right(dataList);
          }
        }
      }
      
      return Left(Exception('Formato de JSON inválido em $assetPath'));
      
    } catch (e) {
      developer.log('Erro ao carregar asset $assetPath: $e', name: 'AssetLoaderService');
      return Left(Exception('Erro ao carregar asset $assetPath: ${e.toString()}'));
    }
  }

  /// Carrega múltiplos arquivos JSON de uma pasta
  Future<Either<Exception, List<Map<String, dynamic>>>> loadMultipleJsonAssets(
    List<String> assetPaths,
  ) async {
    try {
      developer.log('Carregando ${assetPaths.length} assets', name: 'AssetLoaderService');
      
      final List<Map<String, dynamic>> allData = [];
      
      for (final assetPath in assetPaths) {
        final result = await loadJsonAsset(assetPath);
        
        result.fold(
          (error) => throw error,
          (data) => allData.addAll(data),
        );
      }
      
      developer.log('Total de registros carregados: ${allData.length}', name: 'AssetLoaderService');
      return Right(allData);
      
    } catch (e) {
      developer.log('Erro ao carregar múltiplos assets: $e', name: 'AssetLoaderService');
      return Left(Exception('Erro ao carregar múltiplos assets: ${e.toString()}'));
    }
  }

  /// Gera lista de paths para arquivos numerados sequencialmente
  List<String> generateSequentialPaths(String basePath, String prefix, int count) {
    return List.generate(count, (index) => '$basePath$prefix$index.json');
  }

  /// Carrega todos os JSONs de uma categoria específica
  Future<Either<Exception, List<Map<String, dynamic>>>> loadCategoryData(String category) async {
    try {
      switch (category.toLowerCase()) {
        case 'tbculturas':
          return await loadJsonAsset('assets/database/json/tbculturas/TBCULTURAS0.json');
          
        case 'tbpragas':
          return await loadJsonAsset('assets/database/json/tbpragas/TBPRAGAS0.json');
          
        case 'tbplantasinf':
          return await loadJsonAsset('assets/database/json/tbplantasinf/TBPLANTASINF0.json');
          
        case 'tbfitossanitarios':
          final paths = generateSequentialPaths(
            'assets/database/json/tbfitossanitarios/', 
            'TBFITOSSANITARIOS', 
            3
          );
          return await loadMultipleJsonAssets(paths);
          
        case 'tbdiagnostico':
          final paths = generateSequentialPaths(
            'assets/database/json/tbdiagnostico/', 
            'TBDIAGNOSTICO', 
            65
          );
          return await loadMultipleJsonAssets(paths);
          
        case 'tbfitossanitariosinfo':
          final paths = generateSequentialPaths(
            'assets/database/json/tbfitossanitariosinfo/', 
            'TBFITOSSANITARIOSINFO', 
            99
          );
          return await loadMultipleJsonAssets(paths);
          
        case 'tbpragasinf':
          final paths = generateSequentialPaths(
            'assets/database/json/tbpragasinf/', 
            'TBPRAGASINF', 
            2
          );
          return await loadMultipleJsonAssets(paths);
          
        default:
          return Left(Exception('Categoria não encontrada: $category'));
      }
    } catch (e) {
      return Left(Exception('Erro ao carregar categoria $category: ${e.toString()}'));
    }
  }
}
