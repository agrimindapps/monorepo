import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  final scrollController = ScrollController();

  // Referências para as seções para navegação
  final GlobalKey _introSection = GlobalKey();
  final GlobalKey _usageSection = GlobalKey();
  final GlobalKey _thirdPartySection = GlobalKey();
  final GlobalKey _responsibilitiesSection = GlobalKey();
  final GlobalKey _updatesSection = GlobalKey();
  final GlobalKey _changesSection = GlobalKey();
  final GlobalKey _contactSection = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                _buildHeader(),

                // Introdução
                _buildIntroduction(),

                // Uso do App e Propriedade Intelectual
                _buildUsageSection(),

                // Serviços de Terceiros
                _buildThirdPartySection(),

                // Responsabilidades e Limitações
                _buildResponsibilitiesSection(),

                // Atualizações do App
                _buildUpdatesSection(),

                // Alterações nos Termos
                _buildChangesSection(),

                // Contato
                _buildContactSection(),

                // Rodapé
                _buildFooter(),
              ],
            ),
          ),
          // Menu de navegação fixo
          _buildNavBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade600,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 70), // Espaço para a barra de navegação
          const Text(
            'Termos e Condições',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 4,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            'GasOMeter',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Última atualização: 01/01/2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = MediaQuery.of(context).size.width < 800;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              GestureDetector(
                onTap: () => context.go('/promo'),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_gas_station,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GasOMeter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu items
              if (isMobile)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) {
                    switch (value) {
                      case 'intro':
                        _scrollToSection(_introSection);
                        break;
                      case 'usage':
                        _scrollToSection(_usageSection);
                        break;
                      case 'thirdparty':
                        _scrollToSection(_thirdPartySection);
                        break;
                      case 'responsibilities':
                        _scrollToSection(_responsibilitiesSection);
                        break;
                      case 'updates':
                        _scrollToSection(_updatesSection);
                        break;
                      case 'changes':
                        _scrollToSection(_changesSection);
                        break;
                      case 'contact':
                        _scrollToSection(_contactSection);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'intro',
                        child: Text('Introdução'),
                      ),
                      const PopupMenuItem(
                        value: 'usage',
                        child: Text('Uso do App'),
                      ),
                      const PopupMenuItem(
                        value: 'thirdparty',
                        child: Text('Serviços de Terceiros'),
                      ),
                      const PopupMenuItem(
                        value: 'responsibilities',
                        child: Text('Responsabilidades'),
                      ),
                      const PopupMenuItem(
                        value: 'updates',
                        child: Text('Atualizações'),
                      ),
                      const PopupMenuItem(
                        value: 'changes',
                        child: Text('Alterações'),
                      ),
                      const PopupMenuItem(
                        value: 'contact',
                        child: Text('Contato'),
                      ),
                    ];
                  },
                )
              else
                Row(
                  children: [
                    _navBarButton(
                        'Introdução', () => _scrollToSection(_introSection)),
                    _navBarButton('Uso', () => _scrollToSection(_usageSection)),
                    _navBarButton('Terceiros',
                        () => _scrollToSection(_thirdPartySection)),
                    _navBarButton('Responsabilidades',
                        () => _scrollToSection(_responsibilitiesSection)),
                    _navBarButton('Atualizações',
                        () => _scrollToSection(_updatesSection)),
                    _navBarButton(
                        'Alterações', () => _scrollToSection(_changesSection)),
                    _navBarButton(
                        'Contato', () => _scrollToSection(_contactSection)),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _navBarButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      key: _introSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Introdução',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Bem-vindo ao GasOMeter! Estes Termos e Condições ("Termos") regem o uso do nosso aplicativo móvel GasOMeter ("Serviço") operado pela Agrimind Apps ("nós", "nosso" ou "nos").'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Ao baixar ou usar nosso aplicativo, estes termos serão automaticamente aplicados a você - portanto, certifique-se de lê-los cuidadosamente antes de usar o aplicativo. Você não tem permissão para copiar ou modificar o aplicativo, qualquer parte do aplicativo ou nossas marcas registradas de forma alguma.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'O GasOMeter é destinado ao controle e monitoramento de consumo de combustível, despesas de veículos e gerenciamento de manutenções automotivas.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildUsageSection() {
    return Container(
      key: _usageSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uso do App e Propriedade Intelectual',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'A Agrimind Apps está empenhada em garantir que o aplicativo seja o mais útil e eficiente possível. Por esse motivo, reservamo-nos o direito de fazer alterações no aplicativo ou cobrar por seus serviços, a qualquer momento e por qualquer motivo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'O aplicativo GasOMeter armazena e processa dados pessoais que você nos forneceu, para fornecer nosso Serviço. É sua responsabilidade manter seu telefone e o acesso ao aplicativo seguros.'),
              const SizedBox(height: 16),
              _buildParagraph('Você é responsável por:'),
              const SizedBox(height: 12),
              _buildBulletPoint(
                  'Manter a precisão dos dados de consumo e despesas do seu veículo;'),
              _buildBulletPoint(
                  'Usar o aplicativo de acordo com suas funcionalidades pretendidas;'),
              _buildBulletPoint(
                  'Não usar o aplicativo para fins ilegais ou não autorizados;'),
              _buildBulletPoint(
                  'Respeitar os direitos de propriedade intelectual do aplicativo.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartySection() {
    return Container(
      key: _thirdPartySection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Serviços de Terceiros',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'O aplicativo usa serviços de terceiros que declaram seus próprios Termos e Condições.'),
              const SizedBox(height: 16),
              const Text(
                'Link para os Termos e Condições de provedores de serviços terceirizados usados pelo aplicativo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceLink('Serviços do Google Play',
                  'https://policies.google.com/terms'),
              _buildServiceLink(
                  'AdMob', 'https://developers.google.com/admob/terms'),
              _buildServiceLink('Google Analytics para Firebase',
                  'https://firebase.google.com/terms/analytics'),
              _buildServiceLink(
                  'Firebase', 'https://firebase.google.com/terms/'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Observe que a Agrimind Apps não assume responsabilidade pelas práticas de privacidade ou conteúdo desses serviços de terceiros.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilitiesSection() {
    return Container(
      key: _responsibilitiesSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Responsabilidades e Limitações',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Em nenhum momento a Agrimind Apps será responsável por qualquer perda ou dano, direto ou indireto, resultante do uso ou da incapacidade de usar este aplicativo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'O GasOMeter fornece ferramentas para controle de consumo e despesas automotivas, mas não garante economia específica de combustível ou redução de custos. É sua responsabilidade:'),
              const SizedBox(height: 12),
              _buildBulletPoint(
                  'Inserir dados precisos sobre abastecimentos e despesas;'),
              _buildBulletPoint(
                  'Verificar informações de manutenção com mecânicos qualificados;'),
              _buildBulletPoint(
                  'Usar o aplicativo como uma ferramenta auxiliar de controle;'),
              _buildBulletPoint(
                  'Tomar decisões informadas sobre manutenção do veículo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'A Agrimind Apps não se responsabiliza por danos ao veículo ou perdas financeiras resultantes do uso das informações fornecidas pelo aplicativo.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesSection() {
    return Container(
      key: _updatesSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Atualizações do App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'A Agrimind Apps pode atualizar o aplicativo periodicamente. O aplicativo está atualmente disponível para Android e iOS - os requisitos para ambos os sistemas (e para quaisquer sistemas adicionais que decidirmos estender a disponibilidade do aplicativo) podem mudar, e você precisará baixar as atualizações se quiser continuar usando o aplicativo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'A Agrimind Apps não promete que sempre atualizará o aplicativo para que seja relevante para você e/ou funcione com a versão do Android ou iOS que você instalou em seu dispositivo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'No entanto, você promete sempre aceitar atualizações do aplicativo quando oferecidas a você. Também podemos desejar parar de fornecer o aplicativo e poderemos encerrar o uso dele a qualquer momento sem fornecer aviso de rescisão para você.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangesSection() {
    return Container(
      key: _changesSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alterações nestes Termos e Condições',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Podemos atualizar nossos Termos e Condições de tempos em tempos. Assim, recomendamos que você revise esta página periodicamente para quaisquer alterações.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Notificaremos você sobre quaisquer alterações publicando os novos Termos e Condições nesta página. Essas alterações entram em vigor imediatamente após serem publicadas nesta página.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Estes termos e condições estão em vigor a partir de 01/01/2025.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      key: _contactSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contate-nos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Se você tiver alguma dúvida ou sugestão sobre nossos Termos e Condições, não hesite em nos contatar pelo e-mail:'),
              const SizedBox(height: 16),
              Text(
                'agrimind.br@gmail.com',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.blue.shade900,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'GasOMeter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© ${DateTime.now().year} Agrimind Apps. Todos os direitos reservados.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _footerLink('Política de Privacidade', () => context.go('/privacy')),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Termos de Uso', () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}