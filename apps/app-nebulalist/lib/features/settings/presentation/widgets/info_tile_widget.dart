import 'package:flutter/material.dart';

class InfoTileWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
