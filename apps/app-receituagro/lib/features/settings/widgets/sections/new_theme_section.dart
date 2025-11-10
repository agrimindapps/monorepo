import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../presentation/providers/index.dart';
import '../shared/settings_card.dart';
import '../shared/section_header.dart';

/// Theme Settings Section
/// Allows users to toggle dark mode and select language preferences
class NewThemeSection extends ConsumerWidget {
  const NewThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);

    return Column(
      children: [
        SectionHeader(title: 'Aparência'),
        SettingsCard(
          child: Column(
            children: [
              _buildDarkModeToggle(context, ref, themeState),
              const Divider(height: 1),
              _buildLanguageSelector(context, ref, themeState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo Escuro',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Use tema escuro para melhor conforto visual',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: themeState.settings.isDarkTheme,
            onChanged: (value) {
              ref.read(themeNotifierProvider.notifier).toggleDarkMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Idioma',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: themeState.settings.language,
              isExpanded: true,
              underline: const SizedBox(),
              items: _buildLanguageItems(),
              onChanged: (language) {
                if (language != null) {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setLanguage(language);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            themeState.settings.isRtlLanguage
                ? 'Layout de direita para esquerda'
                : 'Layout de esquerda para direita',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildLanguageItems() {
    const languages = [
      'pt-BR',
      'en-US',
      'es-ES',
      'fr-FR',
      'de-DE',
      'it-IT',
      'ja-JP',
      'zh-CN',
      'ko-KR',
      'ar-SA',
      'hi-IN',
      'ru-RU',
    ];

    const languageNames = {
      'pt-BR': 'Português (Brasil)',
      'en-US': 'English (USA)',
      'es-ES': 'Español',
      'fr-FR': 'Français',
      'de-DE': 'Deutsch',
      'it-IT': 'Italiano',
      'ja-JP': '日本語',
      'zh-CN': '中文',
      'ko-KR': '한국어',
      'ar-SA': 'العربية',
      'hi-IN': 'हिन्दी',
      'ru-RU': 'Русский',
    };

    return languages.map((language) {
      return DropdownMenuItem(
        value: language,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(languageNames[language] ?? language),
        ),
      );
    }).toList();
  }
}
