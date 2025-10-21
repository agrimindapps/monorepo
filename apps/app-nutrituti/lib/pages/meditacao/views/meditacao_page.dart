// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../widgets/meditacao_achievement_widget.dart';
import '../widgets/meditacao_calendar_widget.dart';
import '../widgets/meditacao_history_widget.dart';
import '../widgets/meditacao_mood_widget.dart';
import '../widgets/meditacao_notification_widget.dart';
import '../widgets/meditacao_progress_chart_widget.dart';
import '../widgets/meditacao_stats_widget.dart';
import '../widgets/meditacao_timer_widget.dart';
import '../widgets/meditacao_tipos_widget.dart';

class MeditacaoPage extends ConsumerWidget {
  const MeditacaoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditação'),
        elevation: MeditacaoConstants.elevacaoPadrao,
      ),
      body: const _MeditacaoPageBody(),
    );
  }
}

class _MeditacaoPageBody extends ConsumerWidget {
  const _MeditacaoPageBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: MeditacaoConstants.larguraMaxContainer * 2.55,
          child: const Padding(
            padding: EdgeInsets.all(MeditacaoConstants.paddingPequeno),
            child: Column(
              children: [
                MeditacaoNotificationWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoTimerWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoTiposWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoMoodWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoStatsWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoCalendarWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoProgressChartWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoAchievementWidget(),
                SizedBox(height: MeditacaoConstants.paddingPadrao),
                MeditacaoHistoryWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
