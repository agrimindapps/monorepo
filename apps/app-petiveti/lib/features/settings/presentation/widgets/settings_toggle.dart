import 'package:flutter/material.dart';

/// Reusable settings toggle widget with title and subtitle
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}
