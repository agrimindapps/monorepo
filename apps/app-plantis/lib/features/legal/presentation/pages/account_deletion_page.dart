import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/legal_page_content.dart';

/// Página de Política de Exclusão de Contas usando Riverpod e Clean Architecture
///
/// Esta página apresenta as informações obrigatórias sobre:
/// - Como solicitar exclusão de conta
/// - Quais dados serão excluídos/retidos
/// - Prazo para conclusão da exclusão
/// - Consequências da exclusão
/// - Alternativas à exclusão
///
/// Conforme requisitos das lojas de aplicativos (Google Play Store e Apple App Store)
class AccountDeletionPage extends ConsumerWidget {
  const AccountDeletionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(
      legalDocumentProvider(DocumentType.accountDeletion),
    );

    return documentAsync.when(
      data: (document) => BaseLegalPageContent(
        title: 'Exclusão de Conta',
        headerIcon: Icons.delete_outline,
        headerTitle: 'Política de Exclusão de Contas',
        headerGradient: PlantisColors.errorGradient,
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        scrollButtonColor: PlantisColors.error,
        footerIcon: Icons.warning_amber,
        footerTitle: 'Atenção: Processo Irreversível',
        footerDescription:
            'Uma vez excluída, sua conta e todos os dados associados não poderão ser recuperados. Este processo segue as diretrizes das lojas de aplicativos e legislações de privacidade.',
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Exclusão de Conta')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Exclusão de Conta')),
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
                  legalDocumentProvider(DocumentType.accountDeletion),
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
