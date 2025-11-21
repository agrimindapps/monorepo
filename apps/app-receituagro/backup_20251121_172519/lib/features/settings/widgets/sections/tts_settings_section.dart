import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../pages/tts_settings_page.dart';
import '../../presentation/providers/tts_notifier.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// TTS (Text-to-Speech) settings section
/// Clickable tile that navigates to dedicated TTS settings page
class TtsSettingsSection extends ConsumerWidget {
  const TtsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsSettingsAsync = ref.watch(ttsNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Acessibilidade',
          icon: Icons.accessibility_new,
          showIcon: false,
        ),
        SettingsCard(
          child: ttsSettingsAsync.when(
            data: (settings) => SettingsListTile(
              leadingIcon: Icons.record_voice_over,
              title: 'Leitura de Voz (TTS)',
              subtitle: settings.enabled
                  ? 'Leitura de texto habilitada'
                  : 'Leitura de texto desabilitada',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (settings.enabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ativo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              onTap: () => _openTtsSettings(context),
            ),
            loading: () => SettingsListTile(
              leadingIcon: Icons.record_voice_over,
              title: 'Leitura de Voz (TTS)',
              subtitle: 'Carregando...',
              trailing: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              onTap: () => _openTtsSettings(context),
            ),
            error: (_, __) => SettingsListTile(
              leadingIcon: Icons.record_voice_over,
              title: 'Leitura de Voz (TTS)',
              subtitle: 'Toque para configurar',
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: () => _openTtsSettings(context),
            ),
          ),
        ),
      ],
    );
  }

  void _openTtsSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const TtsSettingsPage(),
      ),
    );
  }
}
