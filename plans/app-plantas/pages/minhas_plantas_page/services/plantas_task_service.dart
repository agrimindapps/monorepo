// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../services/domain/tasks/simple_task_service.dart';
import 'plantas_state_service.dart';

/// Serviço especializado para operações com tarefas de plantas
/// Separado do controller para melhor organização de responsabilidades
class PlantasTaskService extends GetxService {
  static PlantasTaskService get instance => Get.find<PlantasTaskService>();

  PlantasStateService get _stateService => PlantasStateService.instance;

  /// Inicializa o serviço
  Future<void> initialize() async {
    debugPrint('🔧 PlantasTaskService: Inicializando...');
    await SimpleTaskService.instance.initialize();
    debugPrint('✅ PlantasTaskService: Inicializado com sucesso');
  }

  /// Marca uma tarefa como concluída e agenda a próxima
  Future<void> marcarTarefaConcluida(String tarefaId, int intervaloDias,
      {String? observacoes}) async {
    try {
      debugPrint(
          '✅ PlantasTaskService: Marcando tarefa como concluída: $tarefaId');

      await SimpleTaskService.instance.initialize();
      await SimpleTaskService.instance
          .completeTask(tarefaId, intervaloDias, observacoes: observacoes);

      _showSuccessSnackbar('Tarefa marcada como concluída!');
      debugPrint('✅ PlantasTaskService: Tarefa concluída com sucesso');
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao marcar tarefa: $e');
      _showErrorSnackbar('Erro ao marcar tarefa', e.toString());
      rethrow;
    }
  }

  /// Reagenda uma tarefa para outra data
  Future<void> reagendarTarefa(String tarefaId, DateTime novaData) async {
    try {
      debugPrint('📅 PlantasTaskService: Reagendando tarefa: $tarefaId');

      await SimpleTaskService.instance.initialize();
      await SimpleTaskService.instance.rescheduleTask(tarefaId, novaData);

      _showSuccessSnackbar('Tarefa reagendada com sucesso!');
      debugPrint('✅ PlantasTaskService: Tarefa reagendada com sucesso');
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao reagendar tarefa: $e');
      _showErrorSnackbar('Erro ao reagendar tarefa', e.toString());
      rethrow;
    }
  }

  /// Cancela uma tarefa
  Future<void> cancelarTarefa(String tarefaId) async {
    try {
      debugPrint('❌ PlantasTaskService: Cancelando tarefa: $tarefaId');

      await SimpleTaskService.instance.initialize();
      await SimpleTaskService.instance.cancelTask(tarefaId);

      _showSuccessSnackbar('Tarefa cancelada com sucesso!');
      debugPrint('✅ PlantasTaskService: Tarefa cancelada com sucesso');
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao cancelar tarefa: $e');
      _showErrorSnackbar('Erro ao cancelar tarefa', e.toString());
      rethrow;
    }
  }

  /// Obtém tarefas pendentes de uma planta específica
  Future<List<Map<String, dynamic>>> getTarefasPendentes(
      String plantaId) async {
    try {
      debugPrint(
          '📋 PlantasTaskService: Buscando tarefas pendentes: $plantaId');

      await SimpleTaskService.instance.initialize();
      final tarefas =
          await SimpleTaskService.instance.getPendingPlantTasks(plantaId);

      // Converter TarefaModel para Map para compatibilidade com widgets existentes
      final tarefasMap = tarefas
          .map((tarefa) => {
                'id': tarefa.id,
                'plantaId': tarefa.plantaId,
                'tipo': tarefa
                    .tipoCuidado, // Para compatibilidade com TaskItemWidget
                'tipoCuidado': tarefa.tipoCuidado,
                'dataLimite': tarefa
                    .dataExecucao, // Para compatibilidade com TaskItemWidget
                'dataExecucao': tarefa.dataExecucao,
                'concluida': tarefa.concluida,
                'observacoes': tarefa.observacoes,
                'proximaData': tarefa.dataExecucao, // Para compatibilidade
              })
          .toList();

      debugPrint(
          '✅ PlantasTaskService: ${tarefasMap.length} tarefas encontradas');
      return tarefasMap;
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao buscar tarefas pendentes: $e');
      return [];
    }
  }

  /// Obtém todas as tarefas de hoje
  Future<List<Map<String, dynamic>>> getTarefasHoje() async {
    try {
      debugPrint('📅 PlantasTaskService: Buscando tarefas de hoje');

      await SimpleTaskService.instance.initialize();
      final tarefas = await SimpleTaskService.instance.getTodayTasks();

      final tarefasMap = tarefas
          .map((tarefa) => {
                'id': tarefa.id,
                'plantaId': tarefa.plantaId,
                'tipo': tarefa
                    .tipoCuidado, // Para compatibilidade com TaskItemWidget
                'tipoCuidado': tarefa.tipoCuidado,
                'dataLimite': tarefa
                    .dataExecucao, // Para compatibilidade com TaskItemWidget
                'dataExecucao': tarefa.dataExecucao,
                'concluida': tarefa.concluida,
                'observacoes': tarefa.observacoes,
                'proximaData': tarefa.dataExecucao,
              })
          .toList();

      debugPrint(
          '✅ PlantasTaskService: ${tarefasMap.length} tarefas de hoje encontradas');
      return tarefasMap;
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao buscar tarefas de hoje: $e');
      return [];
    }
  }

  /// Obtém tarefas futuras
  Future<List<Map<String, dynamic>>> getTarefasProximas() async {
    try {
      debugPrint('🔮 PlantasTaskService: Buscando tarefas próximas');

      await SimpleTaskService.instance.initialize();
      final tarefas = await SimpleTaskService.instance.getUpcomingTasks();

      final tarefasMap = tarefas
          .map((tarefa) => {
                'id': tarefa.id,
                'plantaId': tarefa.plantaId,
                'tipo': tarefa
                    .tipoCuidado, // Para compatibilidade com TaskItemWidget
                'tipoCuidado': tarefa.tipoCuidado,
                'dataLimite': tarefa
                    .dataExecucao, // Para compatibilidade com TaskItemWidget
                'dataExecucao': tarefa.dataExecucao,
                'concluida': tarefa.concluida,
                'observacoes': tarefa.observacoes,
                'proximaData': tarefa.dataExecucao,
              })
          .toList();

      debugPrint(
          '✅ PlantasTaskService: ${tarefasMap.length} tarefas futuras encontradas');
      return tarefasMap;
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao buscar tarefas futuras: $e');
      return [];
    }
  }

  /// Obtém estatísticas de tarefas
  Future<Map<String, int>> getEstatisticasTarefas() async {
    try {
      debugPrint('📊 PlantasTaskService: Calculando estatísticas de tarefas');

      final tarefasHoje = await getTarefasHoje();
      final tarefasProximas = await getTarefasProximas();

      int totalPendentes = 0;
      int totalConcluidas = 0;

      // Contar tarefas de todas as plantas
      for (final planta in _stateService.plantas.value) {
        final tarefasPlanta = await getTarefasPendentes(planta.id);
        for (final tarefa in tarefasPlanta) {
          if (tarefa['concluida'] == true) {
            totalConcluidas++;
          } else {
            totalPendentes++;
          }
        }
      }

      final stats = {
        'hoje': tarefasHoje.length,
        'proximas': tarefasProximas.length,
        'pendentes': totalPendentes,
        'concluidas': totalConcluidas,
      };

      debugPrint('✅ PlantasTaskService: Estatísticas calculadas: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ PlantasTaskService: Erro ao calcular estatísticas: $e');
      return {
        'hoje': 0,
        'proximas': 0,
        'pendentes': 0,
        'concluidas': 0,
      };
    }
  }

  /// Mostra snackbar de sucesso
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF20B2AA),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Mostra snackbar de erro
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
