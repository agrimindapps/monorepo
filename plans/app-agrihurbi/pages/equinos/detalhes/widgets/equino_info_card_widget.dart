// Flutter imports:
import 'package:flutter/material.dart';

class EquinoInfoSection extends StatelessWidget {
  const EquinoInfoSection({
    super.key,
    required this.label,
    required this.content,
    this.showDivider = true,
  });

  final String label;
  final String content;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 16)),
        if (showDivider) const Divider(),
      ],
    );
  }
}

class EquinoInfoCard extends StatelessWidget {
  const EquinoInfoCard({
    super.key,
    required this.sections,
    this.padding = const EdgeInsets.all(12.0),
  });

  final List<Widget> sections;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections,
        ),
      ),
    );
  }
}
