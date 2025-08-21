import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _shareContent() {
    // Implementar compartilhamento se necessário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Compartilhamento disponível em breve'),
        backgroundColor: PlantisColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          'Política de Privacidade',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _shareContent,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: PlantisColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.privacy_tip,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Política de Privacidade',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Última atualização: ${_getFormattedDate()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Introduction
                _buildSection(
                  'Nossa Política de Privacidade',
                  '''O Plantis está comprometido em proteger e respeitar sua privacidade. Esta política explica como coletamos, usamos, armazenamos e protegemos suas informações pessoais.

Ao usar nosso aplicativo, você concorda com a coleta e uso de informações de acordo com esta política.''',
                  theme,
                ),

                _buildSection(
                  'Informações que Coletamos',
                  '''**Informações fornecidas diretamente por você:**
• Dados de registro (nome, email, senha)
• Informações sobre suas plantas (nome, espécie, fotos, notas)
• Configurações de lembretes e cuidados
• Comentários e feedback enviados

**Informações coletadas automaticamente:**
• Dados de uso do aplicativo (funcionalidades utilizadas, tempo de uso)
• Informações técnicas (versão do app, modelo do dispositivo, sistema operacional)
• Dados de desempenho e crashes (para melhorar o app)
• Localização aproximada (apenas se autorizada, para recursos climáticos)''',
                  theme,
                ),

                _buildSection(
                  'Como Usamos suas Informações',
                  '''Utilizamos suas informações para:
• Fornecer e manter o serviço do aplicativo
• Personalizar sua experiência com plantas
• Enviar lembretes e notificações solicitadas
• Melhorar nossos recursos e funcionalidades
• Fornecer suporte técnico quando necessário
• Comunicar sobre atualizações importantes
• Processar assinaturas premium (quando aplicável)

**Nunca usamos seus dados para:**
• Vender para terceiros
• Publicidade externa não autorizada
• Fins não relacionados ao aplicativo''',
                  theme,
                ),

                _buildSection(
                  'Armazenamento de Dados',
                  '''**Armazenamento Local:**
• Por padrão, todos os dados são armazenados localmente no seu dispositivo
• Você tem controle total sobre essas informações
• Dados locais incluem: plantas, fotos, notas, lembretes

**Sincronização na Nuvem (Premium):**
• Opcional e requer sua autorização explícita
• Dados criptografados com padrões de segurança avançados
• Sincronização entre seus dispositivos autorizados
• Backup automático para recuperação de dados''',
                  theme,
                ),

                _buildSection(
                  'Compartilhamento de Dados',
                  '''**Não compartilhamos seus dados pessoais, exceto:**

**Provedores de Serviço:**
• Serviços de armazenamento em nuvem (criptografados)
• Processamento de pagamentos (dados mínimos necessários)
• Analytics (dados anonimizados para melhorar o app)

**Requisitos Legais:**
• Quando obrigatório por lei ou ordem judicial
• Para proteger nossos direitos e segurança dos usuários
• Em casos de investigação de atividades fraudulentas

**Todos os terceiros são rigorosamente selecionados e seguem padrões de segurança equivalentes aos nossos.**''',
                  theme,
                ),

                _buildSection(
                  'Segurança dos Dados',
                  '''Implementamos medidas de segurança robustas:

**Segurança Técnica:**
• Criptografia de dados em trânsito e em repouso
• Protocolos de comunicação seguros (HTTPS/TLS)
• Autenticação multifator disponível
• Monitoramento contínuo de segurança

**Segurança Organizacional:**
• Acesso restrito aos dados dos usuários
• Treinamento regular da equipe sobre privacidade
• Auditorias regulares de segurança
• Políticas internas rigorosas de proteção de dados''',
                  theme,
                ),

                _buildSection(
                  'Seus Direitos sobre os Dados',
                  '''Você tem os seguintes direitos sobre seus dados pessoais:

**Direito de Acesso:**
• Visualizar todos os dados que mantemos sobre você
• Exportar seus dados em formato legível

**Direito de Correção:**
• Corrigir informações incorretas ou desatualizadas
• Atualizar suas preferências a qualquer momento

**Direito de Exclusão:**
• Solicitar a exclusão completa de sua conta e dados
• Exclusão imediata de dados locais pelo próprio app

**Direito de Portabilidade:**
• Exportar seus dados para usar em outros serviços
• Transferir dados entre dispositivos facilmente

**Para exercer seus direitos, entre em contato através do app ou email.**''',
                  theme,
                ),

                _buildSection(
                  'Cookies e Tecnologias Similares',
                  '''O Plantis utiliza tecnologias locais limitadas:

**Dados de Preferências:**
• Configurações do app (tema, idioma, notificações)
• Estado de funcionalidades (tutorial completado, etc.)
• Cache de imagens para melhor performance

**Analytics Limitado:**
• Dados anonimizados sobre uso do app
• Informações de crashes para correções
• Não coletamos dados pessoais identificáveis

**Você pode limpar esses dados através das configurações do app.**''',
                  theme,
                ),

                _buildSection(
                  'Retenção de Dados',
                  '''**Dados da Conta:**
• Mantidos enquanto sua conta estiver ativa
• Excluídos 30 dias após cancelamento da conta
• Backup de segurança por até 90 dias (criptografado)

**Dados Técnicos:**
• Logs de erro: 12 meses máximo
• Analytics: dados agregados por até 24 meses
• Dados de suporte: até resolução + 12 meses

**Dados Legais:**
• Mantidos apenas quando exigido por lei
• Excluídos assim que não mais necessários''',
                  theme,
                ),

                _buildSection(
                  'Transferências Internacionais',
                  '''Seus dados podem ser processados em diferentes localidades:

**Armazenamento Principal:**
• Servidores localizados no Brasil quando possível
• Provedores certificados com padrões internacionais

**Transferências Seguras:**
• Sempre com criptografia end-to-end
• Apenas para provedores com certificações adequadas
• Contratos rigorosos de proteção de dados
• Conformidade com leis locais e internacionais''',
                  theme,
                ),

                _buildSection(
                  'Menores de Idade',
                  '''**Proteção de Crianças e Adolescentes:**
• Não coletamos intencionalmente dados de menores de 13 anos
• Para usuários entre 13-18 anos, requeremos consentimento dos pais
• Recursos especiais de proteção para contas de menores
• Exclusão imediata de dados se identificarmos uso não autorizado

**Pais e Responsáveis:**
• Podem solicitar informações sobre dados de menores
• Direito de exclusão de contas de menores
• Controle sobre funcionalidades disponíveis''',
                  theme,
                ),

                _buildSection(
                  'Alterações nesta Política',
                  '''**Como mantemos você informado:**
• Notificação no app sobre mudanças importantes
• Email para alterações significativas (se cadastrado)
• Histórico de versões disponível no app
• Período de adaptação antes de mudanças entrarem em vigor

**Sua escolha:**
• Você pode aceitar as novas condições ou encerrar sua conta
• Sempre transparente sobre o que mudou
• Oportunidade de fazer perguntas sobre mudanças''',
                  theme,
                ),

                _buildSection(
                  'Contato e Suporte',
                  '''**Para questões sobre privacidade:**
• Email: privacidade@plantis.app
• Dentro do app: Menu > Configurações > Privacidade
• Central de ajuda online disponível 24/7

**Nosso compromisso:**
• Resposta em até 48 horas úteis
• Suporte completo em português
• Assistência para exercer seus direitos
• Esclarecimento de dúvidas sem burocracia

**Autoridade de Proteção de Dados:**
• ANPD (Autoridade Nacional de Proteção de Dados)
• Direito de recorrer em caso de insatisfação
• Canais oficiais disponibilizados quando necessário''',
                  theme,
                  isLast: true,
                ),

                const SizedBox(height: 32),

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: PlantisColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sua privacidade é nossa prioridade',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estamos comprometidos em proteger suas informações pessoais com os mais altos padrões de segurança e transparência.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Scroll to top button
          if (_showScrollToTopButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.small(
                onPressed: _scrollToTop,
                backgroundColor: PlantisColors.secondary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    ThemeData theme, {
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: PlantisColors.secondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  width: 4,
                  color: PlantisColors.secondary,
                ),
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${now.day} de ${months[now.month - 1]} de ${now.year}';
  }
}