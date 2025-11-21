
import '../../../../core/theme/gasometer_colors.dart';
import '../../presentation/widgets/base_legal_page.dart';

/// Service responsible for providing Privacy Policy content
/// Follows SRP by handling only privacy policy content

class PrivacyPolicyContentProvider {
  static const String _lastUpdatedDate = '2025-10-29';

  /// Get the last updated date for privacy policy
  String get lastUpdatedDate => _lastUpdatedDate;

  /// Get all sections for the privacy policy
  List<LegalSection> getSections() {
    return [
      _buildIntroductionSection(),
      _buildDataCollectionSection(),
      _buildDataUsageSection(),
      _buildStorageSection(),
      _buildSecuritySection(),
      _buildUserRightsSection(),
      _buildContactSection(),
    ];
  }

  LegalSection _buildIntroductionSection() {
    return const LegalSection(
      title: 'Nossa Política de Privacidade',
      content:
          '''O Gasometer está comprometido em proteger sua privacidade. Esta política explica como coletamos, usamos e protegemos suas informações.

Ao usar nosso aplicativo, você concorda com esta política.''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildDataCollectionSection() {
    return const LegalSection(
      title: 'Informações Coletadas',
      content: '''**Dados fornecidos por você:**
• Informações de abastecimentos (valor, litros, km)
• Dados dos veículos (modelo, placa, ano)
• Configurações e preferências

**Dados automáticos:**
• Uso do app (funcionalidades, tempo)
• Informações técnicas (versão, dispositivo)
• Dados de desempenho e crashes''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildDataUsageSection() {
    return const LegalSection(
      title: 'Uso das Informações',
      content: '''Usamos seus dados para:
• Calcular consumo e economia
• Gerar relatórios e estatísticas
• Melhorar o app
• Fornecer suporte técnico

**Nunca vendemos seus dados para terceiros.**''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildStorageSection() {
    return const LegalSection(
      title: 'Armazenamento',
      content: '''• Dados armazenados localmente no dispositivo
• Você tem controle total sobre suas informações
• Backup opcional na nuvem (criptografado)''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildSecuritySection() {
    return const LegalSection(
      title: 'Segurança',
      content: '''Implementamos:
• Criptografia de dados
• Protocolos seguros (HTTPS)
• Monitoramento de segurança
• Acesso restrito''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildUserRightsSection() {
    return const LegalSection(
      title: 'Seus Direitos',
      content: '''Você pode:
• Acessar seus dados
• Corrigir informações incorretas
• Solicitar exclusão de dados
• Exportar seus dados

Entre em contato: privacy@gasometer.app''',
      titleColor: GasometerColors.primary,
    );
  }

  LegalSection _buildContactSection() {
    return const LegalSection(
      title: 'Contato',
      content: '''Para dúvidas sobre privacidade:
• Email: privacy@gasometer.app
• Resposta em até 48 horas úteis

Legislação: LGPD (Lei 13.709/2018)''',
      titleColor: GasometerColors.primary,
      isLast: true,
    );
  }
}
