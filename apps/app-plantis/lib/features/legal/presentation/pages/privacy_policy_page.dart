import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/web_legal_page_layout.dart';

/// Privacy Policy page using Riverpod and Clean Architecture
/// Web-first design following promotional page style
class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(
      legalDocumentProvider(DocumentType.privacyPolicy),
    );

    return documentAsync.when(
      data: (document) => WebLegalPageLayout(
        title: 'Política de Privacidade',
        headerIcon: Icons.privacy_tip_outlined,
        headerTitle: 'Política de Privacidade',
        headerSubtitle:
            'Seu direito à privacidade e proteção de dados pessoais',
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        accentColor: const Color(0xFF3B82F6), // Blue
        footerIcon: Icons.verified_user_outlined,
        footerTitle: 'Sua privacidade é nossa prioridade',
        footerDescription:
            'Estamos comprometidos em proteger suas informações pessoais com os mais altos padrões de segurança e transparência, em conformidade com a LGPD e regulamentações internacionais.',
      ),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A1F14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
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
                  legalDocumentProvider(DocumentType.privacyPolicy),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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
