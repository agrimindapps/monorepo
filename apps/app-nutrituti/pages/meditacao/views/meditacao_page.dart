// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../controllers/meditacao_controller.dart';
import '../widgets/meditacao_achievement_widget.dart';
import '../widgets/meditacao_calendar_widget.dart';
import '../widgets/meditacao_history_widget.dart';
import '../widgets/meditacao_mood_widget.dart';
import '../widgets/meditacao_notification_widget.dart';
import '../widgets/meditacao_progress_chart_widget.dart';
import '../widgets/meditacao_stats_widget.dart';
import '../widgets/meditacao_timer_widget.dart';
import '../widgets/meditacao_tipos_widget.dart';

class MeditacaoPage extends StatelessWidget {
  final MeditacaoController controller = Get.put(MeditacaoController());

  MeditacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditação'),
        elevation: MeditacaoConstants.elevacaoPadrao,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingState();
        }

        return _buildMainContent();
      }),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: MeditacaoConstants.larguraMaxContainer * 2.55,
          child: Padding(
            padding: const EdgeInsets.all(MeditacaoConstants.paddingPequeno),
            child: Column(
              children: [
                MeditacaoNotificationWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoTimerWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoTiposWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoMoodWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoStatsWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoCalendarWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoProgressChartWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoAchievementWidget(controller: controller),
                const SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoHistoryWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
