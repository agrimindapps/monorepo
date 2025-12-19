import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class DefaultViewDialog extends ConsumerWidget {
  final String currentView;

  const DefaultViewDialog({
    super.key,
    required this.currentView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Visualização Padrão'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('Lista'),
            value: 'list',
            groupValue: currentView,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateDefaultView(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Grade'),
            value: 'grid',
            groupValue: currentView,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateDefaultView(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Kanban'),
            value: 'kanban',
            groupValue: currentView,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateDefaultView(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DefaultViewSelectionTile extends StatelessWidget {
  final String currentView;
  final VoidCallback onTap;

  const DefaultViewSelectionTile({
    super.key,
    required this.currentView,
    required this.onTap,
  });

  String _getViewLabel(String view) {
    switch (view) {
      case 'list':
        return 'Lista';
      case 'grid':
        return 'Grade';
      case 'kanban':
        return 'Kanban';
      default:
        return 'Lista';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.view_list_outlined, color: Theme.of(context).colorScheme.primary),
      title: const Text('Visualização Padrão'),
      subtitle: Text(_getViewLabel(currentView)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
