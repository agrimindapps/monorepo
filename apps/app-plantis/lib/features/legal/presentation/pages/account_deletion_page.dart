import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/web_legal_page_layout.dart';

/// Página de Política de Exclusão de Contas usando Riverpod e Clean Architecture
/// Web-first design following promotional page style
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
      data: (document) => WebLegalPageLayout(
        title: 'Exclusão de Conta',
        headerIcon: Icons.delete_forever_outlined,
        headerTitle: 'Política de Exclusão de Contas',
        headerSubtitle:
            'Informações sobre o processo de exclusão permanente de conta e dados',
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        accentColor: const Color(0xFFEF4444), // Red
        footerIcon: Icons.warning_amber_outlined,
        footerTitle: 'Atenção: Processo Irreversível',
        footerDescription:
            'Uma vez excluída, sua conta e todos os dados associados não poderão ser recuperados. Este processo segue as diretrizes das lojas de aplicativos e legislações de privacidade (LGPD, GDPR).',
      ),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A1F14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFEF4444)),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF0A1F14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar documento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(
                  legalDocumentProvider(DocumentType.accountDeletion),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
