import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/web_legal_page_layout.dart';

/// Terms of Service page using Riverpod and Clean Architecture
/// Web-first design following promotional page style
class TermsOfServicePage extends ConsumerWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(
      legalDocumentProvider(DocumentType.termsOfService),
    );

    return documentAsync.when(
      data: (document) => WebLegalPageLayout(
        title: 'Termos de Uso',
        headerIcon: Icons.description_outlined,
        headerTitle: 'Termos de Uso',
        headerSubtitle:
            'Diretrizes e condições para uso do aplicativo CantinhoVerde',
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        accentColor: const Color(0xFF10B981), // Emerald
        footerIcon: Icons.handshake_outlined,
        footerTitle: 'Concordância dos Termos',
        footerDescription:
            'Ao usar o CantinhoVerde, você confirma que leu, compreendeu e aceita estes Termos de Uso. Estamos comprometidos em fornecer a melhor experiência no cuidado de suas plantas.',
      ),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A1F14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
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
                  legalDocumentProvider(DocumentType.termsOfService),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
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
