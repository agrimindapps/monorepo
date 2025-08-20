// Flutter imports:
import 'package:flutter/material.dart';

class EquinoLoadingWidget extends StatelessWidget {
  const EquinoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
