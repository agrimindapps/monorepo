// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

class NutriTutiTermosPage extends StatefulWidget {
  const NutriTutiTermosPage({super.key});

  @override
  State<NutriTutiTermosPage> createState() => _NutriTutiTermosPageState();
}

class _NutriTutiTermosPageState extends State<NutriTutiTermosPage> {
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
            Colors.purple.shade800,
            Colors.purple.shade600,
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
            'NutriTuti App',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Última atualização: 30/08/2022',
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
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.purple.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NutriTuti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ],
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
                    _navBarButton(
                        'Uso do App', () => _scrollToSection(_usageSection)),
                    _navBarButton('Serviços de Terceiros',
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
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Ao baixar ou usar o aplicativo, esses termos se aplicarão automaticamente a você – portanto, certifique-se de lê-los atentamente antes de usar o aplicativo. Você não tem permissão para copiar ou modificar o aplicativo, qualquer parte do aplicativo ou nossas marcas registradas de forma alguma. Você não tem permissão para tentar extrair o código-fonte do aplicativo e também não deve tentar traduzir o aplicativo para outros idiomas ou fazer versões derivadas. O aplicativo em si e todas as marcas registradas, direitos autorais, direitos de banco de dados e outros direitos de propriedade intelectual relacionados a ele ainda pertencem ao Agrimind Apps.'),
            ],
          ),
        ),
      ),
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
                'Uso do Aplicativo e Propriedade Intelectual',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'A Agrimind Apps está empenhada em garantir que o aplicativo seja o mais útil e eficiente possível. Por esse motivo, nos reservamos o direito de fazer alterações no aplicativo ou cobrar por seus serviços, a qualquer momento e por qualquer motivo. Nunca cobraremos pelo aplicativo ou seus serviços sem deixar bem claro para você exatamente pelo que está pagando.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'O aplicativo NutriTuti armazena e processa dados pessoais que você nos forneceu, para fornecer meu Serviço. É sua responsabilidade manter seu telefone e o acesso ao aplicativo seguros. Portanto, recomendamos que você não faça o jailbreak ou root no seu telefone, que é o processo de remoção de restrições e limitações de software impostas pelo sistema operacional oficial do seu dispositivo. Isso pode tornar seu telefone vulnerável a malware/vírus/programas maliciosos, comprometer os recursos de segurança do seu telefone e pode significar que o aplicativo NutriTuti não funcionará corretamente ou não funcionará.'),
            ],
          ),
        ),
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
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'O aplicativo usa serviços de terceiros que declaram seus Termos e Condições.'),
              const SizedBox(height: 20),
              const Text(
                'Link para Termos e Condições de provedores de serviços terceirizados usados pelo aplicativo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceLink('Serviços do Google Play',
                  'https://policies.google.com/terms'),
              _buildServiceLink(
                  'AdMob', 'https://support.google.com/admob/answer/6128543'),
              _buildServiceLink('Google Analytics para Firebase',
                  'https://firebase.google.com/terms/analytics'),
              _buildServiceLink(
                  'Firebase Crashlytics', 'https://firebase.google.com/terms'),
              _buildServiceLink(
                  'Facebook', 'https://www.facebook.com/terms.php'),
            ],
          ),
        ),
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
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Você deve estar ciente de que há certas coisas pelas quais o Agrimind Apps não se responsabiliza. Certas funções do aplicativo exigirão que o aplicativo tenha uma conexão ativa com a Internet. A conexão pode ser Wi-Fi ou fornecida pelo seu provedor de rede móvel, mas a Agrimind Apps não pode se responsabilizar pelo aplicativo não funcionar com funcionalidade total se você não tiver acesso ao Wi-Fi e não tiver nenhum de seus permissão de dados restante.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Se você estiver usando o aplicativo fora de uma área com Wi-Fi, lembre-se de que os termos do contrato com seu provedor de rede móvel ainda se aplicam. Como resultado, você pode ser cobrado pela sua operadora de celular pelo custo dos dados pela duração da conexão durante o acesso ao aplicativo ou outras cobranças de terceiros. Ao usar o aplicativo, você aceita a responsabilidade por tais cobranças, incluindo cobranças de dados de roaming se você usar o aplicativo fora de seu território (ou seja, região ou país) sem desativar o roaming de dados. Se você não for o pagador de contas do dispositivo em que está usando o aplicativo, saiba que presumimos que você recebeu permissão do pagador de contas para usar o aplicativo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Na mesma linha, o Agrimind Apps nem sempre pode se responsabilizar pela maneira como você usa o aplicativo, ou seja, você precisa garantir que seu dispositivo permaneça carregado - se ficar sem bateria e você não puder ligá-lo para aproveitar o Serviço, Agrimind Os aplicativos não podem aceitar responsabilidade.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Com relação à responsabilidade da Agrimind Apps pelo uso do aplicativo, quando você estiver usando o aplicativo, é importante ter em mente que, embora nos esforcemos para garantir que ele esteja sempre atualizado e correto, contamos com terceiros para nos fornecer informações para que possamos disponibilizá-las para você. A Agrimind Apps não se responsabiliza por qualquer perda, direta ou indireta, que você experimente como resultado de confiar totalmente nesta funcionalidade do aplicativo.'),
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
                'Atualizações do Aplicativo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Em algum momento, podemos querer atualizar o aplicativo. O aplicativo está atualmente disponível para Android e iOS – os requisitos para ambos os sistemas (e para quaisquer sistemas adicionais para os quais decidirmos estender a disponibilidade do aplicativo) podem mudar, e você precisará baixar as atualizações se quiser manter usando o aplicativo. A Agrimind Apps não promete que sempre atualizará o aplicativo para que seja relevante para você e/ou funcione com a versão Android e iOS que você instalou no seu dispositivo. No entanto, você promete sempre aceitar as atualizações do aplicativo quando oferecidas a você. Também podemos desejar interromper o fornecimento do aplicativo e encerrar o uso dele a qualquer momento sem aviso de rescisão a você. A menos que lhe digamos o contrário, após qualquer rescisão, (a) os direitos e licenças concedidos a você nestes termos terminarão; (b) você deve parar de usar o aplicativo e (se necessário) excluí-lo do seu dispositivo.'),
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
                'Alterações a estes Termos e Condições',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Posso atualizar nossos Termos e Condições de tempos em tempos. Assim, recomendamos que você revise esta página periodicamente para quaisquer alterações. Vou notificá-lo sobre quaisquer alterações publicando os novos Termos e Condições nesta página.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Estes termos e condições estão em vigor a partir de 30/08/2022'),
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
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Se você tiver alguma dúvida ou sugestão sobre meus Termos e Condições, não hesite em me contatar em:'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    launchUrl(Uri.parse('mailto:agrimind.br@gmail.com')),
                child: Text(
                  'agrimind.br@gmail.com',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
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

  Widget _buildServiceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(url)),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.purple.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.purple.shade900,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'NutriTuti',
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
                _footerLink('Política de Privacidade', () {}),
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
