import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class ThemeDialog extends ConsumerWidget {
  final String currentTheme;

  const ThemeDialog({
    super.key,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Escolher Tema'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Claro'),
            value: 'light',
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Escuro'),
            value: 'dark',
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Sistema'),
            value: 'system',
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ThemeSelectionTile extends StatelessWidget {
  final String currentTheme;
  final VoidCallback onTap;

  const ThemeSelectionTile({
    super.key,
    required this.currentTheme,
    required this.onTap,
  });

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Escuro';
      case 'system':
      default:
        return 'Sistema';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
      title: const Text('Tema'),
      subtitle: Text(_getThemeLabel(currentTheme)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
