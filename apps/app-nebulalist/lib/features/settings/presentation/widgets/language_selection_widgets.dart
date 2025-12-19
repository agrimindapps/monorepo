import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class LanguageDialog extends ConsumerWidget {
  final String currentLanguage;

  const LanguageDialog({
    super.key,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Escolher Idioma'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Português'),
            value: 'pt',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Español'),
            value: 'es',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class LanguageSelectionTile extends StatelessWidget {
  final String currentLanguage;
  final VoidCallback onTap;

  const LanguageSelectionTile({
    super.key,
    required this.currentLanguage,
    required this.onTap,
  });

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Português';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.language_outlined, color: Theme.of(context).colorScheme.primary),
      title: const Text('Idioma'),
      subtitle: Text(_getLanguageLabel(currentLanguage)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
