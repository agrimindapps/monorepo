import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';

/// Serviço responsável por limpeza automática das boxes Hive
/// Implementa limpeza completa quando detectada mudança de versão
class DataCleaningService {
  
  /// Lista de todas as boxes que devem ser limpas
  static const List<String> _boxNames = [
    'culturas',
    'pragas',
    'fitossanitarios',
    'diagnosticos',
    'fitossanitarios_info',
    'plantas_inf',
    'pragas_inf',
  ];

  /// Limpa todas as boxes Hive de dados da aplicação
  /// Retorna Either com sucesso ou erro
  Future<Either<Exception, void>> clearAllDataBoxes() async {
    try {
      developer.log('Iniciando limpeza completa das boxes Hive...', name: 'DataCleaningService');
      
      int clearedBoxes = 0;
      List<String> errors = [];
      
      for (final boxName in _boxNames) {
        try {
          final result = await _clearSingleBox(boxName);
          
          result.fold(
            (error) => errors.add('$boxName: ${error.toString()}'),
            (_) => clearedBoxes++,
          );
          
        } catch (e) {
          errors.add('$boxName: $e');
          developer.log('Erro ao limpar box $boxName: $e', name: 'DataCleaningService');
        }
      }
      
      if (errors.isNotEmpty) {
        final errorMsg = 'Erros durante limpeza: ${errors.join(', ')}';
        developer.log(errorMsg, name: 'DataCleaningService');
        return Left(Exception(errorMsg));
      }
      
      developer.log('Limpeza concluída com sucesso. $clearedBoxes boxes limpos.', name: 'DataCleaningService');
      return const Right(null);
      
    } catch (e) {
      developer.log('Erro crítico durante limpeza das boxes: $e', name: 'DataCleaningService');
      return Left(Exception('Falha crítica na limpeza: ${e.toString()}'));
    }
  }

  /// Limpa uma box específica
  Future<Either<Exception, void>> _clearSingleBox(String boxName) async {
    try {
      developer.log('Limpando box: $boxName', name: 'DataCleaningService');
      
      // Verifica se a box está aberta
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<dynamic>(boxName);
        final itemCount = box.length;
        
        await box.clear();
        
        developer.log('Box $boxName limpo com sucesso ($itemCount itens removidos)', 
          name: 'DataCleaningService');
        
        return const Right(null);
      } else {
        developer.log('Box $boxName não está aberto, tentando abrir e limpar...', 
          name: 'DataCleaningService');
        
        try {
          final box = await Hive.openBox<dynamic>(boxName);
          final itemCount = box.length;
          
          await box.clear();
          await box.close();
          
          developer.log('Box $boxName aberto, limpo e fechado com sucesso ($itemCount itens removidos)', 
            name: 'DataCleaningService');
          
          return const Right(null);
        } catch (e) {
          developer.log('Erro ao abrir/limpar box $boxName: $e', name: 'DataCleaningService');
          return Left(Exception('Erro ao processar box $boxName: ${e.toString()}'));
        }
      }
      
    } catch (e) {
      developer.log('Erro ao limpar box $boxName: $e', name: 'DataCleaningService');
      return Left(Exception('Erro na limpeza de $boxName: ${e.toString()}'));
    }
  }

  /// Limpa dados de uma categoria específica
  Future<Either<Exception, void>> clearCategoryData(String category) async {
    try {
      developer.log('Limpando dados da categoria: $category', name: 'DataCleaningService');
      
      // Mapeia categoria para nome da box
      final boxName = _mapCategoryToBoxName(category);
      if (boxName == null) {
        return Left(Exception('Categoria não reconhecida: $category'));
      }
      
      return await _clearSingleBox(boxName);
      
    } catch (e) {
      developer.log('Erro ao limpar categoria $category: $e', name: 'DataCleaningService');
      return Left(Exception('Erro na categoria $category: ${e.toString()}'));
    }
  }

  /// Mapeia nome da categoria para nome da box Hive
  String? _mapCategoryToBoxName(String category) {
    switch (category.toLowerCase()) {
      case 'tbculturas':
        return 'culturas';
      case 'tbpragas':
        return 'pragas';
      case 'tbfitossanitarios':
        return 'fitossanitarios';
      case 'tbdiagnostico':
        return 'diagnosticos';
      case 'tbfitossanitariosinfo':
        return 'fitossanitarios_info';
      case 'tbplantasinf':
        return 'plantas_inf';
      case 'tbpragasinf':
        return 'pragas_inf';
      default:
        return null;
    }
  }

  /// Obtém estatísticas antes da limpeza (para logs)
  Future<Map<String, int>> getDataStatistics() async {
    try {
      final stats = <String, int>{};
      
      for (final boxName in _boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box<dynamic>(boxName);
            stats[boxName] = box.length;
          } else {
            stats[boxName] = 0;
          }
        } catch (e) {
          developer.log('Erro ao obter estatísticas da box $boxName: $e', name: 'DataCleaningService');
          stats[boxName] = -1; // Indica erro
        }
      }
      
      return stats;
      
    } catch (e) {
      developer.log('Erro ao obter estatísticas gerais: $e', name: 'DataCleaningService');
      return {};
    }
  }

  /// Verifica se alguma box tem dados (para determinar se limpeza é necessária)
  Future<bool> hasAnyData() async {
    try {
      for (final boxName in _boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box<dynamic>(boxName);
            if (box.isNotEmpty) {
              return true;
            }
          }
        } catch (e) {
          developer.log('Erro ao verificar dados da box $boxName: $e', name: 'DataCleaningService');
          // Continua verificando outras boxes
        }
      }
      
      return false;
      
    } catch (e) {
      developer.log('Erro ao verificar existência de dados: $e', name: 'DataCleaningService');
      return false;
    }
  }

  /// Limpa dados específicos com callback de progresso
  Future<Either<Exception, void>> clearDataWithProgress({
    required void Function(String boxName, int total) onProgress,
  }) async {
    try {
      developer.log('Iniciando limpeza com callback de progresso...', name: 'DataCleaningService');
      
      for (int i = 0; i < _boxNames.length; i++) {
        final boxName = _boxNames[i];
        
        onProgress(boxName, _boxNames.length);
        
        final result = await _clearSingleBox(boxName);
        if (result.isLeft()) {
          return result;
        }
        
        // Pequena pausa para permitir atualização da UI
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      
      developer.log('Limpeza com progresso concluída', name: 'DataCleaningService');
      return const Right(null);
      
    } catch (e) {
      developer.log('Erro durante limpeza com progresso: $e', name: 'DataCleaningService');
      return Left(Exception('Falha na limpeza com progresso: ${e.toString()}'));
    }
  }

  /// Força fechamento de todas as boxes antes da limpeza (método de emergência)
  Future<void> forceCloseAllBoxes() async {
    try {
      developer.log('Forçando fechamento de todas as boxes...', name: 'DataCleaningService');
      
      for (final boxName in _boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box<dynamic>(boxName).close();
            developer.log('Box $boxName fechado', name: 'DataCleaningService');
          }
        } catch (e) {
          developer.log('Erro ao fechar box $boxName: $e', name: 'DataCleaningService');
        }
      }
      
      developer.log('Fechamento forçado concluído', name: 'DataCleaningService');
      
    } catch (e) {
      developer.log('Erro durante fechamento forçado: $e', name: 'DataCleaningService');
    }
  }
}