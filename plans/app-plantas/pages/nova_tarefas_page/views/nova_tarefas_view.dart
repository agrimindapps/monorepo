// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../widgets/app_bottom_nav_widget.dart';
import '../controller/nova_tarefas_controller.dart';
import '../widgets/tarefa_card_widget.dart';

class NovaTarefasView extends GetView<NovaTarefasController> {
  const NovaTarefasView({super.key});

  @override
  Widget build(BuildContext context) {
    // Defensive check to ensure controller is available
    if (!Get.isRegistered<NovaTarefasController>()) {
      return Scaffold(
        backgroundColor: PlantasColors.backgroundColor,
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Obx(() => Scaffold(
          backgroundColor: PlantasColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildToggleButtons(context),
                Expanded(
                  child: Obx(() => _buildTasksList(context)),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavWidget(
            currentPage: BottomNavPage.tarefas,
          ),
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tarefas',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: PlantasColors.textColor,
              ),
            ),
          ),
          Obx(() {
            final taskCount = _getTaskCount();
            if (taskCount > 0) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PlantasColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PlantasColors.primaryColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  '$taskCount ${taskCount == 1 ? 'tarefa' : 'tarefas'}',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: PlantasColors.primaryColor,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  int _getTaskCount() {
    try {
      // Defensive check to ensure controller is available and initialized
      if (!Get.isRegistered<NovaTarefasController>()) {
        return 0;
      }

      final ctrl = Get.find<NovaTarefasController>();
      if (ctrl.viewMode.value == 'hoje') {
        return ctrl.tarefasHoje.length;
      } else {
        return ctrl.tarefasProximas.length;
      }
    } catch (e) {
      debugPrint('⚠️ NovaTarefasView: Erro ao obter contagem de tarefas: $e');
      return 0;
    }
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(() => GestureDetector(
                onTap: () => controller.setViewMode('hoje'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: controller.viewMode.value == 'hoje'
                      ? BoxDecoration(
                          color: PlantasColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Para hoje',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: controller.viewMode.value == 'hoje'
                              ? PlantasColors.textColor
                              : PlantasColors.subtitleColor,
                        ),
                      ),
                      _buildTabBadge(context, controller.tarefasHoje.length,
                          controller.viewMode.value == 'hoje'),
                    ],
                  ),
                ),
              )),
          const SizedBox(width: 32),
          Obx(() => GestureDetector(
                onTap: () => controller.setViewMode('proximas'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: controller.viewMode.value == 'proximas'
                      ? BoxDecoration(
                          color: PlantasColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Próximas',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: controller.viewMode.value == 'proximas'
                              ? PlantasColors.textColor
                              : PlantasColors.subtitleColor,
                        ),
                      ),
                      _buildTabBadge(context, controller.tarefasProximas.length,
                          controller.viewMode.value == 'proximas'),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    if (controller.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PlantasColors.primaryColor),
        ),
      );
    }

    if (controller.viewMode.value == 'hoje') {
      // Para a aba "hoje", combinar tarefas pendentes e concluídas
      final tarefasPendentes = controller.tarefasHoje;
      final tarefasConcluidas = controller.tarefasConcluidasHoje;

      if (tarefasPendentes.isEmpty && tarefasConcluidas.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: PlantasColors.subtitleColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma tarefa para hoje! 🎉',
                style: TextStyle(
                  fontSize: 16,
                  color: PlantasColors.subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return _buildTodayTasksList(context, tarefasPendentes, tarefasConcluidas);
    } else {
      // Para outras abas, usar lógica original
      final tasks = controller.tarefasProximas;

      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: PlantasColors.subtitleColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma tarefa próxima 📅',
                style: TextStyle(
                  fontSize: 16,
                  color: PlantasColors.subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return _buildGroupedTasks(context, tasks);
    }
  }

  Widget _buildTodayTasksList(
      BuildContext context, RxList tarefasPendentes, RxList tarefasConcluidas) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: PlantasColors.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção de tarefas pendentes
          if (tarefasPendentes.isNotEmpty) ...[
            _buildSectionHeader(
                context, 'Tarefas pendentes', tarefasPendentes.length),
            const SizedBox(height: 16),
            ...tarefasPendentes.map((task) => TarefaCardWidget(
                  tarefa: task,
                  controller: controller,
                )),
          ],

          // Espaçamento entre seções
          if (tarefasPendentes.isNotEmpty && tarefasConcluidas.isNotEmpty)
            const SizedBox(height: 32),

          // Seção de tarefas concluídas
          if (tarefasConcluidas.isNotEmpty) ...[
            _buildSectionHeader(
                context, 'Tarefas concluídas', tarefasConcluidas.length),
            const SizedBox(height: 16),
            ...tarefasConcluidas.map((task) => TarefaCardWidget(
                  tarefa: task,
                  controller: controller,
                  isCompleted: true,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: PlantasColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: PlantasColors.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: PlantasColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: PlantasColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedTasks(BuildContext context, RxList tasks) {
    // Group tasks by date
    Map<String, List> groupedTasks = {};

    for (var task in tasks) {
      final dateKey = _getDateString(task.dataExecucao);
      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }
      groupedTasks[dateKey]!.add(task);
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: PlantasColors.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (int index = 0; index < groupedTasks.length; index++) ...[
            if (index > 0) const SizedBox(height: 32),
            _buildDateHeader(context, groupedTasks.keys.elementAt(index)),
            const SizedBox(height: 16),
            ...groupedTasks[groupedTasks.keys.elementAt(index)]!
                .map((task) => TarefaCardWidget(
                      tarefa: task,
                      controller: controller,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String dateKey) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: PlantasColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          dateKey,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: PlantasColors.textColor,
          ),
        ),
      ],
    );
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje, ${date.day} de ${_getMonthName(date.month)}';
    } else if (taskDate == tomorrow) {
      return 'Amanhã, ${date.day} de ${_getMonthName(date.month)}';
    } else {
      return '${_getWeekdayName(date.weekday)}, ${date.day} de ${_getMonthName(date.month)}';
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '';
    }
  }

  Widget _buildTabBadge(BuildContext context, int count, bool isActiveTab) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActiveTab
            ? PlantasColors.textColor.withValues(alpha: 0.2)
            : PlantasColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActiveTab
              ? PlantasColors.textColor.withValues(alpha: 0.3)
              : PlantasColors.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActiveTab
              ? PlantasColors.textColor
              : PlantasColors.primaryColor,
        ),
      ),
    );
  }
}
