// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/equinos_repository.dart';

class EquinoImageCard extends StatelessWidget {
  const EquinoImageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 280,
        color: Colors.blueGrey.shade200,
        child: Obx(() {
          final equino = EquinoRepository().mapEquinos.value;
          return equino.imagens == null || equino.imagens!.isEmpty
              ? const Center(child: Icon(Icons.image_not_supported))
              : Image.network(equino.imagens![0], fit: BoxFit.cover);
        }),
      ),
    );
  }
}
