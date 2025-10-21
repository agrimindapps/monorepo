// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../providers/meditacao_provider.dart';

class MeditacaoTimerWidget extends ConsumerWidget {
  const MeditacaoTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Card(
      elevation: MeditacaoConstants.elevacaoPadrao,
      child: Padding(
        padding: EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Column(
          children: [
            _TimerTitle(),
            SizedBox(height: MeditacaoConstants.paddingGrande),
            _DurationButtons(),
            SizedBox(height: MeditacaoConstants.paddingGrande),
            _TimerDisplay(),
            SizedBox(height: MeditacaoConstants.paddingGrande),
            _TimerControlButton(),
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

class _DurationButtons extends ConsumerWidget {
  const _DurationButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: MeditacaoConstants.duracoesPadrao
          .map((duration) => _DurationButton(duration: duration))
          .toList(),
    );
  }
}

class _DurationButton extends ConsumerWidget {
  final int duration;

  const _DurationButton({required this.duration});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duracaoSelecionada = ref.watch(
      meditacaoNotifierProvider.select((state) => state.duracaoSelecionada),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: duracaoSelecionada == duration
              ? Colors.blue
              : Colors.grey[200],
          fixedSize: const Size.fromHeight(MeditacaoConstants.alturaBot),
        ),
        onPressed: () {
          ref.read(meditacaoNotifierProvider.notifier).selecionarDuracao(duration);
        },
        child: Text('$duration min'),
      ),
    );
  }
}

class _TimerDisplay extends ConsumerWidget {
  const _TimerDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempoRestante = ref.watch(
      meditacaoNotifierProvider.select((state) => state.tempoRestante),
    );
    final duracaoSelecionada = ref.watch(
      meditacaoNotifierProvider.select((state) => state.duracaoSelecionada),
    );
    final emMeditacao = ref.watch(
      meditacaoNotifierProvider.select((state) => state.emMeditacao),
    );

    final duracaoTotal = duracaoSelecionada * 60;
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
            value: emMeditacao ? progress : 1.0,
            strokeWidth: MeditacaoConstants.espessuraLinhaTimer,
          ),
          Text(
            '${_twoDigits(minutes)}:${_twoDigits(seconds)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

class _TimerControlButton extends ConsumerWidget {
  const _TimerControlButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emMeditacao = ref.watch(
      meditacaoNotifierProvider.select((state) => state.emMeditacao),
    );

    return ElevatedButton.icon(
      onPressed: () {
        ref.read(meditacaoNotifierProvider.notifier).alternarTimer(context);
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromHeight(MeditacaoConstants.alturaBot),
      ),
      icon: Icon(emMeditacao ? Icons.pause : Icons.play_arrow),
      label: Text(emMeditacao ? 'Pausar' : 'Iniciar'),
    );
  }
}
