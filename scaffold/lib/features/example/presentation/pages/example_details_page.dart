import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_spacing.dart';

/// Example details page
/// Displays details of a single example
class ExampleDetailsPage extends ConsumerWidget {
  const ExampleDetailsPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement with actual provider
    // final exampleAsync = ref.watch(exampleByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 64),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Detalhes do exemplo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('ID: $id'),
              const SizedBox(height: AppSpacing.xxl),
              const Text(
                'TODO: Implementar com provider específico',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
