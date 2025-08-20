// Flutter imports:
import 'package:flutter/material.dart';

class ImplementoEmptyState extends StatelessWidget {
  const ImplementoEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Nenhum registro encontrado!'),
      ),
    );
  }
}
