import '../../../core/theme/gasometer_colors.dart';
import '../presentation/widgets/base_legal_page.dart';

/// Service providing legal content for Gasometer
class LegalContentService {
  static const String _lastUpdatedDate = '2025-10-29';

  static List<LegalSection> getPrivacyPolicySections() {
    return const [
      LegalSection(
        title: 'Nossa Política de Privacidade',
        content:
            '''O Gasometer está comprometido em proteger sua privacidade. Esta política explica como coletamos, usamos e protegemos suas informações.

Ao usar nosso aplicativo, você concorda com esta política.''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
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
      ),
      LegalSection(
        title: 'Uso das Informações',
        content: '''Usamos seus dados para:
• Calcular consumo e economia
• Gerar relatórios e estatísticas
• Melhorar o app
• Fornecer suporte técnico

**Nunca vendemos seus dados para terceiros.**''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Armazenamento',
        content: '''• Dados armazenados localmente no dispositivo
• Você tem controle total sobre suas informações
• Backup opcional na nuvem (criptografado)''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Segurança',
        content: '''Implementamos:
• Criptografia de dados
• Protocolos seguros (HTTPS)
• Monitoramento de segurança
• Acesso restrito''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Seus Direitos',
        content: '''Você pode:
• Acessar seus dados
• Corrigir informações incorretas
• Solicitar exclusão de dados
• Exportar seus dados

Entre em contato: privacy@gasometer.app''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Contato',
        content: '''Para dúvidas sobre privacidade:
• Email: privacy@gasometer.app
• Resposta em até 48 horas úteis

Legislação: LGPD (Lei 13.709/2018)''',
        titleColor: GasometerColors.primary,
        isLast: true,
      ),
    ];
  }

  static List<LegalSection> getTermsOfServiceSections() {
    return const [
      LegalSection(
        title: 'Termos de Uso',
        content:
            '''Bem-vindo ao Gasometer! Estes termos regulam o uso do aplicativo. Ao usar o Gasometer, você concorda com estes termos.''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
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
      ),
      LegalSection(
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
      ),
      LegalSection(
        title: 'Limitações',
        content: '''O Gasometer é fornecido "como está". Não garantimos:
• Funcionamento ininterrupto
• Ausência total de erros
• Compatibilidade com todos dispositivos

Nos esforçamos para melhor experiência possível.''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Propriedade Intelectual',
        content: '''Todos os direitos reservados:
• Código-fonte
• Design e interface
• Marca e logo
• Conteúdo do app

Uso não autorizado é proibido.''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Modificações',
        content: '''Podemos atualizar estes termos:
• Notificaremos mudanças significativas
• Uso contínuo = aceitação das mudanças
• Versão mais recente sempre disponível no app''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Encerramento',
        content: '''Você pode:
• Parar de usar a qualquer momento
• Solicitar exclusão de dados

Podemos suspender conta por:
• Violação dos termos
• Uso inadequado
• Atividade fraudulenta''',
        titleColor: GasometerColors.primary,
      ),
      LegalSection(
        title: 'Contato',
        content: '''Dúvidas sobre os termos:
• Email: legal@gasometer.app
• Resposta em até 48 horas úteis

Lei Aplicável: Legislação Brasileira
Foro: Comarca do usuário''',
        titleColor: GasometerColors.primary,
        isLast: true,
      ),
    ];
  }
}
