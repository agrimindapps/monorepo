import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
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
          'Termos de Uso',
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
                    gradient: PlantisColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Termos de Uso do Plantis',
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
                  'Introdução',
                  '''Bem-vindo ao Plantis! Estes Termos de Uso governam seu relacionamento com o aplicativo Plantis, operado pela nossa equipe.

Ao acessar ou usar nosso serviço, você concorda em estar vinculado por estes termos. Se você discordar de qualquer parte destes termos, não deverá usar nosso aplicativo.''',
                  theme,
                ),

                _buildSection(
                  'Definições',
                  '''• **Aplicativo**: refere-se ao Plantis, aplicativo de gerenciamento de plantas
• **Serviço**: refere-se ao aplicativo e todos os recursos relacionados
• **Usuário**: refere-se a qualquer indivíduo que acessa ou usa o aplicativo
• **Conteúdo**: inclui todas as informações sobre plantas, fotos, notas e dados inseridos''',
                  theme,
                ),

                _buildSection(
                  'Aceitação dos Termos',
                  '''Ao utilizar o Plantis, você declara que:
• Tem pelo menos 13 anos de idade
• Possui capacidade legal para aceitar estes termos
• Utilizará o aplicativo de acordo com as leis aplicáveis
• Fornecerá informações verdadeiras e precisas''',
                  theme,
                ),

                _buildSection(
                  'Uso do Aplicativo',
                  '''O Plantis permite que você:
• Cadastre e gerencie informações sobre suas plantas
• Configure lembretes para cuidados com plantas
• Armazene fotos e notas sobre suas plantas
• Sincronize dados entre dispositivos (recursos premium)

Você se compromete a usar o aplicativo apenas para fins pessoais e não comerciais.''',
                  theme,
                ),

                _buildSection(
                  'Conta do Usuário',
                  '''Para acessar certas funcionalidades, você pode precisar criar uma conta. Você é responsável por:
• Manter a confidencialidade de suas credenciais
• Todas as atividades que ocorrem em sua conta
• Notificar-nos imediatamente sobre uso não autorizado
• Manter suas informações de contato atualizadas''',
                  theme,
                ),

                _buildSection(
                  'Privacidade e Dados',
                  '''Respeitamos sua privacidade e estamos comprometidos em proteger seus dados pessoais:
• Coletamos apenas dados necessários para fornecer o serviço
• Suas informações de plantas são armazenadas localmente por padrão
• Dados sincronizados na nuvem são criptografados
• Nunca vendemos ou compartilhamos seus dados pessoais

Para mais detalhes, consulte nossa Política de Privacidade.''',
                  theme,
                ),

                _buildSection(
                  'Recursos Premium',
                  '''O Plantis oferece recursos premium mediante assinatura:
• Sincronização automática na nuvem
• Backup ilimitado de dados
• Relatórios avançados de cuidados
• Lembretes personalizados avançados

As assinaturas são cobradas conforme o plano escolhido e podem ser canceladas a qualquer momento.''',
                  theme,
                ),

                _buildSection(
                  'Responsabilidades',
                  '''**Suas responsabilidades:**
• Usar o aplicativo de forma legal e ética
• Não interferir no funcionamento do serviço
• Não tentar acessar dados de outros usuários
• Respeitar direitos de propriedade intelectual

**Nossas responsabilidades:**
• Fornecer o serviço conforme descrito
• Proteger seus dados pessoais
• Manter a disponibilidade do serviço
• Oferecer suporte técnico adequado''',
                  theme,
                ),

                _buildSection(
                  'Limitações de Responsabilidade',
                  '''O Plantis é fornecido "como está". Não garantimos:
• Disponibilidade ininterrupta do serviço
• Ausência de erros ou falhas
• Compatibilidade com todos os dispositivos
• Resultados específicos no cuidado com plantas

Nossa responsabilidade é limitada ao valor pago pelos serviços premium, se aplicável.''',
                  theme,
                ),

                _buildSection(
                  'Propriedade Intelectual',
                  '''• O aplicativo e seu conteúdo são protegidos por direitos autorais
• Você mantém a propriedade dos dados que insere no aplicativo
• Concede-nos licença para processar seus dados conforme necessário para fornecer o serviço
• Não é permitido reproduzir, distribuir ou criar obras derivadas sem autorização''',
                  theme,
                ),

                _buildSection(
                  'Cancelamento',
                  '''Você pode cancelar sua conta a qualquer momento. Nós podemos cancelar contas que:
• Violem estes termos de uso
• Sejam usadas para atividades ilegais
• Permaneçam inativas por período prolongado
• Representem risco de segurança

Após o cancelamento, seus dados podem ser mantidos conforme nossa política de retenção.''',
                  theme,
                ),

                _buildSection(
                  'Modificações dos Termos',
                  '''Reservamo-nos o direito de modificar estes termos a qualquer momento. Mudanças significativas serão comunicadas através do aplicativo ou por email.

O uso continuado do aplicativo após as modificações constitui aceitação dos novos termos.''',
                  theme,
                ),

                _buildSection(
                  'Lei Aplicável',
                  '''Estes termos são governados pelas leis brasileiras. Disputas serão resolvidas nos tribunais competentes do Brasil.

Para questões relacionadas a direitos do consumidor, aplicam-se as disposições do Código de Defesa do Consumidor.''',
                  theme,
                ),

                _buildSection(
                  'Contato',
                  '''Para dúvidas sobre estes Termos de Uso:
• Email: suporte@plantis.app
• Dentro do aplicativo: Menu > Ajuda > Contato

Responderemos suas questões dentro de 48 horas úteis.''',
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
                  child: Text(
                    'Ao usar o Plantis, você confirma que leu, compreendeu e aceita estes Termos de Uso.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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
                backgroundColor: PlantisColors.primary,
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
              color: PlantisColors.primary,
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
                  color: PlantisColors.primary,
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