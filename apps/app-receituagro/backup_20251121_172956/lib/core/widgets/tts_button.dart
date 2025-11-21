import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../features/settings/domain/services/i_tts_service.dart';
import '../../features/settings/presentation/providers/tts_notifier.dart';

/// Reusable TTS button that can be placed anywhere to read text aloud
///
/// Features:
/// - Shows different icons based on TTS state (idle/speaking/paused)
/// - Automatically disabled when TTS is turned off in settings
/// - Handles play/pause/resume logic automatically
class TTSButton extends ConsumerWidget {
  /// The text to be read aloud when button is pressed
  final String text;

  /// Optional title for analytics/logging purposes
  final String? title;

  /// Size of the icon (default: 24)
  final double iconSize;

  /// Custom icon color (optional, defaults to theme colors)
  final Color? iconColor;

  const TTSButton({
    required this.text,
    this.title,
    this.iconSize = 24,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(ttsNotifierProvider);
    final stateAsync = ref.watch(ttsStateStreamProvider);

    final settings = settingsAsync.value;
    final state = stateAsync.value ?? TTSSpeechState.idle;

    // If TTS is disabled, show disabled button
    final isEnabled = settings?.enabled ?? false;

    return IconButton(
      icon: Icon(_getIcon(state)),
      iconSize: iconSize,
      color: _getColor(context, state, isEnabled),
      onPressed: isEnabled ? () => _handleTap(ref, state) : null,
      tooltip: _getTooltip(state, isEnabled),
    );
  }

  IconData _getIcon(TTSSpeechState state) {
    switch (state) {
      case TTSSpeechState.idle:
      case TTSSpeechState.stopped:
        return Icons.volume_up;
      case TTSSpeechState.speaking:
        return Icons.pause;
      case TTSSpeechState.paused:
        return Icons.play_arrow;
    }
  }

  Color? _getColor(BuildContext context, TTSSpeechState state, bool isEnabled) {
    if (!isEnabled) {
      return Colors.grey.shade400;
    }

    if (iconColor != null) {
      return iconColor;
    }

    switch (state) {
      case TTSSpeechState.idle:
      case TTSSpeechState.stopped:
        return Theme.of(context).colorScheme.primary;
      case TTSSpeechState.speaking:
        return Colors.green;
      case TTSSpeechState.paused:
        return Colors.orange;
    }
  }

  String _getTooltip(TTSSpeechState state, bool isEnabled) {
    if (!isEnabled) {
      return 'Leitura de voz desabilitada';
    }

    switch (state) {
      case TTSSpeechState.idle:
      case TTSSpeechState.stopped:
        return 'Ouvir texto';
      case TTSSpeechState.speaking:
        return 'Pausar leitura';
      case TTSSpeechState.paused:
        return 'Continuar leitura';
    }
  }

  void _handleTap(WidgetRef ref, TTSSpeechState state) {
    final notifier = ref.read(ttsNotifierProvider.notifier);

    switch (state) {
      case TTSSpeechState.idle:
      case TTSSpeechState.stopped:
        // Start speaking
        notifier.speak(text);
      case TTSSpeechState.speaking:
        // Pause
        notifier.pause();
      case TTSSpeechState.paused:
        // Resume
        notifier.resume();
    }
  }
}
