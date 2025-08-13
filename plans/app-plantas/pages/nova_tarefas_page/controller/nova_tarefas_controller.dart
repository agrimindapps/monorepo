// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../database/tarefa_model.dart';
import '../../../services/domain/tasks/simple_task_service.dart';
import '../services/care_type_service.dart';
import '../services/date_formatting_service.dart';

class NovaTarefasController extends GetxController {
  var tarefasHoje = <TarefaModel>[].obs;
  var tarefasConcluidasHoje = <TarefaModel>[].obs;
  var tarefasProximas = <TarefaModel>[].obs;
  var tarefasAtrasadas = <TarefaModel>[].obs;
  var isLoading = false.obs;
  var selectedTabIndex = 0.obs;
  var viewMode = 'hoje'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await SimpleTaskService.instance.initialize();
    carregarTarefas();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('📋 NovaTarefasController: onReady - controller pronto');
  }

  Future<void> carregarTarefas() async {
    try {
      debugPrint('📋 Carregando tarefas...');
      isLoading.value = true;

      // Carregar tarefas em paralelo
      final results = await Future.wait([
        SimpleTaskService.instance.getTodayTasks(),
        SimpleTaskService.instance.getTodayCompletedTasks(),
        SimpleTaskService.instance.getUpcomingTasks(),
        SimpleTaskService.instance.getOverdueTasks(),
      ]);

      tarefasHoje.value = results[0];
      tarefasConcluidasHoje.value = results[1];
      tarefasProximas.value = results[2];
      tarefasAtrasadas.value = results[3];

      debugPrint(
          '✅ Tarefas carregadas: ${tarefasHoje.length} hoje, ${tarefasConcluidasHoje.length} concluídas hoje, ${tarefasProximas.length} próximas, ${tarefasAtrasadas.length} atrasadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar tarefas: $e');
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'Erro ao carregar tarefas: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedTab(int index) {
    selectedTabIndex.value = index;
  }

  void setViewMode(String mode) {
    viewMode.value = mode;
  }

  /// Marca uma tarefa como concluída
  Future<void> marcarTarefaConcluida(
      TarefaModel tarefa, int intervaloDias) async {
    try {
      await SimpleTaskService.instance.completeTask(tarefa.id, intervaloDias);

      // Recarregar tarefas
      await carregarTarefas();

      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.success(context, 'Sucesso',
            'Tarefa "${CareTypeService.getName(tarefa.tipoCuidado)}" concluída!');
      }
    } catch (e) {
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(context, 'Erro', 'Erro ao marcar tarefa: $e');
      }
    }
  }

  /// Marca uma tarefa como concluída com data específica
  Future<void> marcarTarefaConcluidaComData(
      TarefaModel tarefa, int intervaloDias, DateTime dataConclusao) async {
    try {
      await SimpleTaskService.instance
          .completeTaskWithDate(tarefa.id, intervaloDias, dataConclusao);

      // Recarregar tarefas
      await carregarTarefas();

      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.success(context, 'Sucesso',
            'Tarefa "${CareTypeService.getName(tarefa.tipoCuidado)}" concluída em ${DateFormattingService.formatRelative(dataConclusao)}!');
      }
    } catch (e) {
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(context, 'Erro', 'Erro ao marcar tarefa: $e');
      }
    }
  }

  /// Reagenda uma tarefa para outra data
  Future<void> reagendarTarefa(TarefaModel tarefa, DateTime novaData) async {
    try {
      await SimpleTaskService.instance.rescheduleTask(tarefa.id, novaData);

      // Recarregar tarefas
      await carregarTarefas();

      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.success(context, 'Sucesso',
            'Tarefa reagendada para ${DateFormattingService.formatRelative(novaData)}');
      }
    } catch (e) {
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'Erro ao reagendar tarefa: $e');
      }
    }
  }

  /// Cancela uma tarefa (marca como concluída sem criar próxima)
  Future<void> cancelarTarefa(TarefaModel tarefa) async {
    try {
      await SimpleTaskService.instance.cancelTask(
        tarefa.id,
        observacoes: 'Tarefa cancelada pelo usuário',
      );

      // Recarregar tarefas
      await carregarTarefas();

      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.success(
            context, 'Sucesso', 'Tarefa cancelada com sucesso');
      }
    } catch (e) {
      final context = Get.context;
      if (context != null) {
        PlantasGetSnackbar.error(
            context, 'Erro', 'Erro ao cancelar tarefa: $e');
      }
    }
  }

  /// Obtém nome amigável para tipo de cuidado

  /// Obtém ícone para tipo de cuidado
  IconData getIconeParaTipoCuidado(String tipoCuidado) {
    switch (tipoCuidado) {
      case 'agua':
        return Icons.water_drop;
      case 'adubo':
        return Icons.eco;
      case 'banho_sol':
        return Icons.wb_sunny;
      case 'inspecao_pragas':
        return Icons.search;
      case 'poda':
        return Icons.content_cut;
      case 'replantar':
        return Icons.change_circle;
      default:
        return Icons.task;
    }
  }

  /// Obtém cor para tipo de cuidado (theme-aware)
  Color getCorParaTipoCuidado(String tipoCuidado, BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);

    switch (tipoCuidado) {
      case 'agua':
        return cores['info'] ?? Colors.blue;
      case 'adubo':
        return cores['sucesso'] ?? Colors.green;
      case 'banho_sol':
        return cores['aviso'] ?? Colors.orange;
      case 'inspecao_pragas':
        return cores['primaria'] ?? Colors.purple;
      case 'poda':
        return cores['textoSecundario'] ?? Colors.brown;
      case 'replantar':
        return cores['primaria'] ?? Colors.teal;
      default:
        return cores['textoSecundario'] ?? Colors.grey;
    }
  }

  /// Obtém estatísticas das tarefas
  Map<String, int> get estatisticas {
    return {
      'hoje': tarefasHoje.length,
      'proximas': tarefasProximas.length,
      'atrasadas': tarefasAtrasadas.length,
      'total':
          tarefasHoje.length + tarefasProximas.length + tarefasAtrasadas.length,
    };
  }

  /// Força recarregamento das tarefas
  @override
  Future<void> refresh() async {
    await carregarTarefas();
  }

}
