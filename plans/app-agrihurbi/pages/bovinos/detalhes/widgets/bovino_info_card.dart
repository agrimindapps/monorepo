// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/bovino_class.dart';

class BovinoInfoCard extends StatelessWidget {
  final BovinoClass bovino;

  const BovinoInfoCard({
    super.key,
    required this.bovino,
  });

  Widget _buildInfoItem({
    required String title,
    required String content,
    bool showDivider = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10, width: double.infinity),
        Text(content, style: const TextStyle(fontSize: 16)),
        if (showDivider) const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildInfoItem(
              title: 'Raça',
              content: bovino.nomeComum,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  title: 'Tipo',
                  content: bovino.tipoAnimal,
                  showDivider: true,
                ),
                _buildInfoItem(
                  title: 'Origem',
                  content: bovino.origem,
                  showDivider: true,
                ),
                _buildInfoItem(
                  title: 'Características',
                  content: bovino.caracteristicas,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
