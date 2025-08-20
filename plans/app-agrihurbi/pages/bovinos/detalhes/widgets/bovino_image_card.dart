// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/bovino_class.dart';

class BovinoImageCard extends StatelessWidget {
  final BovinoClass? bovino;

  const BovinoImageCard({
    super.key,
    required this.bovino,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 240,
        color: Colors.blueGrey.shade200,
        child: bovino?.imagens == null || bovino!.imagens!.isEmpty
            ? const Center(child: Icon(Icons.add_a_photo))
            : Image.network(bovino!.imagens![0], fit: BoxFit.cover),
      ),
    );
  }
}
