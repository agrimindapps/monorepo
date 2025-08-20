// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../controllers/meditacao_controller.dart';

class MeditacaoTimerWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoTimerWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: MeditacaoConstants.elevacaoPadrao,
      child: Padding(
        padding: const EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Column(
          children: [
            const _TimerTitle(),
            const SizedBox(height: MeditacaoConstants.paddingGrande),
            _DurationButtons(controller: controller),
            const SizedBox(height: MeditacaoConstants.paddingGrande),
            _TimerDisplay(controller: controller),
            const SizedBox(height: MeditacaoConstants.paddingGrande),
            _TimerControlButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _TimerTitle extends StatelessWidget {
  const _TimerTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Timer de Meditação',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class _DurationButtons extends StatelessWidget {
  final MeditacaoController controller;

  const _DurationButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: MeditacaoConstants.duracoesPadrao
          .map((duration) => _DurationButton(
                duration: duration,
                controller: controller,
              ))
          .toList(),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final int duration;
  final MeditacaoController controller;

  const _DurationButton({
    required this.duration,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.duracaoSelecionada.value == duration
                  ? Colors.blue
                  : Colors.grey[200],
              fixedSize: const Size.fromHeight(MeditacaoConstants.alturaBot),
            ),
            onPressed: () => controller.selecionarDuracao(duration),
            child: Text('$duration min'),
          ),
        ));
  }
}

class _TimerDisplay extends StatelessWidget {
  final MeditacaoController controller;

  const _TimerDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tempoRestante = controller.tempoRestante.value;
      final duracaoTotal = controller.duracaoSelecionada.value * 60;
      
      final minutes = tempoRestante ~/ 60;
      final seconds = tempoRestante % 60;
      final progress = tempoRestante > 0 ? 1 - (tempoRestante / duracaoTotal) : 0.0;

      return SizedBox(
        width: MeditacaoConstants.larguraTimer,
        height: MeditacaoConstants.alturaTimer,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: controller.emMeditacao.value ? progress : 1.0,
              strokeWidth: MeditacaoConstants.espessuraLinhaTimer,
            ),
            Text(
              '${_twoDigits(minutes)}:${_twoDigits(seconds)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

class _TimerControlButton extends StatelessWidget {
  final MeditacaoController controller;

  const _TimerControlButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final emMeditacao = controller.emMeditacao.value;
      return ElevatedButton.icon(
        onPressed: controller.alternarTimer,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size.fromHeight(MeditacaoConstants.alturaBot),
        ),
        icon: Icon(emMeditacao ? Icons.pause : Icons.play_arrow),
        label: Text(emMeditacao ? 'Pausar' : 'Iniciar'),
      );
    });
  }
}
