import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/legal_page_content.dart';

/// Privacy Policy page using Riverpod and Clean Architecture
class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(
      legalDocumentProvider(DocumentType.privacyPolicy),
    );

    return documentAsync.when(
      data: (document) => BaseLegalPageContent(
        title: 'Política de Privacidade',
        headerIcon: Icons.privacy_tip,
        headerTitle: 'Política de Privacidade',
        headerGradient: PlantisColors.secondaryGradient,
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        scrollButtonColor: PlantisColors.secondary,
        footerIcon: Icons.verified_user,
        footerTitle: 'Sua privacidade é nossa prioridade',
        footerDescription:
            'Estamos comprometidos em proteger suas informações pessoais com os mais altos padrões de segurança e transparência.',
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Política de Privacidade')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Política de Privacidade')),
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
                  legalDocumentProvider(DocumentType.privacyPolicy),
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
