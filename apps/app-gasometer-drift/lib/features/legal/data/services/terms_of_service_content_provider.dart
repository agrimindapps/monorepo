import 'package:injectable/injectable.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../presentation/widgets/base_legal_page.dart';

/// Service responsible for providing Terms of Service content
/// Follows SRP by handling only terms of service content
@lazySingleton
class TermsOfServiceContentProvider {
  static const String _lastUpdatedDate = '2025-10-29';

  /// Get the last updated date for terms of service
  String get lastUpdatedDate => _lastUpdatedDate;

  /// Get all sections for the terms of service
  List<LegalSection> getSections() {
    return [
      _buildIntroductionSection(),
      _buildAppUsageSection(),
      _buildResponsibilitiesSection(),
      _buildLimitationsSection(),
      _buildIntellectualPropertySection(),
      _buildModificationsSection(),
      _buildTerminationSection(),
      _buildContactSection(),
    ];
  }

  LegalSection _buildIntroductionSection() {
    return const LegalSection(
      title: 'Termos de Uso',
      content:
          '''Bem-vindo ao Gasometer! Estes termos regulam o uso do aplicativo. Ao usar o Gasometer, você concorda com estes termos.''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildAppUsageSection() {
    return const LegalSection(
      title: 'Uso do Aplicativo',
      content: '''**Você pode:**
• Registrar abastecimentos e despesas
• Gerenciar múltiplos veículos
• Gerar relatórios
• Usar todos os recursos disponíveis

**Você não pode:**
• Usar para fins ilegais
• Tentar burlar sistemas de segurança
• Copiar ou modificar o app
• Usar para spam ou fraude''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildResponsibilitiesSection() {
    return const LegalSection(
      title: 'Responsabilidades',
      content: '''**Do Usuário:**
• Fornecer informações precisas
• Manter senha segura
• Usar de forma apropriada
• Respeitar outros usuários

**Do Gasometer:**
• Fornecer serviço de qualidade
• Proteger seus dados
• Manter app atualizado
• Oferecer suporte técnico''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildLimitationsSection() {
    return const LegalSection(
      title: 'Limitações',
      content: '''O Gasometer é fornecido "como está". Não garantimos:
• Funcionamento ininterrupto
• Ausência total de erros
• Compatibilidade com todos dispositivos

Nos esforçamos para melhor experiência possível.''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildIntellectualPropertySection() {
    return const LegalSection(
      title: 'Propriedade Intelectual',
      content: '''Todos os direitos reservados:
• Código-fonte
• Design e interface
• Marca e logo
• Conteúdo do app

Uso não autorizado é proibido.''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildModificationsSection() {
    return const LegalSection(
      title: 'Modificações',
      content: '''Podemos atualizar estes termos:
• Notificaremos mudanças significativas
• Uso contínuo = aceitação das mudanças
• Versão mais recente sempre disponível no app''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildTerminationSection() {
    return const LegalSection(
      title: 'Encerramento',
      content: '''Você pode:
• Parar de usar a qualquer momento
• Solicitar exclusão de dados

Podemos suspender conta por:
• Violação dos termos
• Uso inadequado
• Atividade fraudulenta''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildContactSection() {
    return const LegalSection(
      title: 'Contato',
      content: '''Dúvidas sobre os termos:
• Email: legal@gasometer.app
• Resposta em até 48 horas úteis

Lei Aplicável: Legislação Brasileira
Foro: Comarca do usuário''',
      titleColor: GasometerColors.primary,
      isLast: true,
    );
  }
}
