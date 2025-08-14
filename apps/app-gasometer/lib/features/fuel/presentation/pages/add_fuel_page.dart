import 'package:flutter/material.dart';
import '../../../../core/theme/gasometer_theme.dart';

class AddFuelPage extends StatelessWidget {
  const AddFuelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Text(
          'Add Fuel Page - Em desenvolvimento',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
