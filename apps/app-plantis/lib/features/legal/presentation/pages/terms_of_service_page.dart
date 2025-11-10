import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/legal_page_content.dart';

/// Terms of Service page using Riverpod and Clean Architecture
class TermsOfServicePage extends ConsumerWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(
      legalDocumentProvider(DocumentType.termsOfService),
    );

    return documentAsync.when(
      data: (document) => BaseLegalPageContent(
        title: 'Termos de Uso',
        headerIcon: Icons.description,
        headerTitle: 'Termos de Uso do Plantis',
        headerGradient: PlantisColors.primaryGradient,
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        scrollButtonColor: PlantisColors.primary,
        footerTitle: 'Concordância dos Termos',
        footerDescription:
            'Ao usar o Plantis, você confirma que leu, compreendeu e aceita estes Termos de Uso.',
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Termos de Uso')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Termos de Uso')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar documento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(
                  legalDocumentProvider(DocumentType.termsOfService),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
