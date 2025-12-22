import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/document_type.dart';
import '../providers/legal_providers.dart';
import '../widgets/web_legal_page_layout.dart';

/// Cookies Policy page using Riverpod and Clean Architecture
/// Web-first design following promotional page style
class CookiesPolicyPage extends ConsumerWidget {
  const CookiesPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(
      legalDocumentProvider(DocumentType.cookiesPolicy),
    );

    return documentAsync.when(
      data: (document) => WebLegalPageLayout(
        title: 'Política de Cookies',
        headerIcon: Icons.cookie_outlined,
        headerTitle: 'Política de Cookies',
        headerSubtitle:
            'Como utilizamos cookies e tecnologias similares no CantinhoVerde',
        sections: document.sections,
        lastUpdated: document.lastUpdated,
        accentColor: const Color(0xFFF59E0B), // Amber
        footerIcon: Icons.settings_outlined,
        footerTitle: 'Gerenciamento de Cookies',
        footerDescription:
            'Você pode gerenciar suas preferências de cookies nas Configurações do app. Respeitamos suas escolhas e privacidade.',
      ),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A1F14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
        ),
      ),
      error: (error, _) => Scaffold(
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
                  legalDocumentProvider(DocumentType.cookiesPolicy),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
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
