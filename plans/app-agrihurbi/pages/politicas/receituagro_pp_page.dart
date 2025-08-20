// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

class ReceituagroPoliticaPage extends StatefulWidget {
  const ReceituagroPoliticaPage({super.key});

  @override
  State<ReceituagroPoliticaPage> createState() =>
      _ReceituagroPoliticaPageState();
}

class _ReceituagroPoliticaPageState extends State<ReceituagroPoliticaPage> {
  final scrollController = ScrollController();

  // Referências para as seções para navegação
  final GlobalKey _introSection = GlobalKey();
  final GlobalKey _coletaSection = GlobalKey();
  final GlobalKey _logDataSection = GlobalKey();
  final GlobalKey _cookiesSection = GlobalKey();
  final GlobalKey _providersSection = GlobalKey();
  final GlobalKey _securitySection = GlobalKey();
  final GlobalKey _linksSection = GlobalKey();
  final GlobalKey _childrenSection = GlobalKey();
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

                // Coleta e uso de informações
                _buildInfoCollection(),

                // Log Data
                _buildLogData(),

                // Cookies
                _buildCookies(),

                // Provedores de serviço
                _buildServiceProviders(),

                // Segurança
                _buildSecurity(),

                // Links para outros sites
                _buildLinks(),

                // Privacidade das crianças
                _buildChildrenPrivacy(),

                // Alterações na política
                _buildPolicyChanges(),

                // Contato
                _buildContact(),

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
            Colors.green.shade800,
            Colors.green.shade600,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 70), // Espaço para a barra de navegação
          const Text(
            'Política de Privacidade',
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
            'Receituagro App',
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
                    Icons.agriculture,
                    color: Colors.green.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Receituagro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
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
                      case 'coleta':
                        _scrollToSection(_coletaSection);
                        break;
                      case 'logdata':
                        _scrollToSection(_logDataSection);
                        break;
                      case 'cookies':
                        _scrollToSection(_cookiesSection);
                        break;
                      case 'providers':
                        _scrollToSection(_providersSection);
                        break;
                      case 'security':
                        _scrollToSection(_securitySection);
                        break;
                      case 'links':
                        _scrollToSection(_linksSection);
                        break;
                      case 'children':
                        _scrollToSection(_childrenSection);
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
                        value: 'coleta',
                        child: Text('Coleta de Informações'),
                      ),
                      const PopupMenuItem(
                        value: 'logdata',
                        child: Text('Log Data'),
                      ),
                      const PopupMenuItem(
                        value: 'cookies',
                        child: Text('Cookies'),
                      ),
                      const PopupMenuItem(
                        value: 'providers',
                        child: Text('Provedores de Serviço'),
                      ),
                      const PopupMenuItem(
                        value: 'security',
                        child: Text('Segurança'),
                      ),
                      const PopupMenuItem(
                        value: 'links',
                        child: Text('Links'),
                      ),
                      const PopupMenuItem(
                        value: 'children',
                        child: Text('Privacidade Infantil'),
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
                        'Coleta', () => _scrollToSection(_coletaSection)),
                    _navBarButton(
                        'Log Data', () => _scrollToSection(_logDataSection)),
                    _navBarButton(
                        'Cookies', () => _scrollToSection(_cookiesSection)),
                    _navBarButton('Provedores',
                        () => _scrollToSection(_providersSection)),
                    _navBarButton(
                        'Segurança', () => _scrollToSection(_securitySection)),
                    _navBarButton(
                        'Links', () => _scrollToSection(_linksSection)),
                    _navBarButton(
                        'Crianças', () => _scrollToSection(_childrenSection)),
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
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'A Agrimind Apps construiu o aplicativo Receituagro como um aplicativo suportado por anúncios. Este SERVIÇO é fornecido pela Agrimind Apps sem custo e destina-se ao uso como está.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Esta página é usada para informar os visitantes sobre minhas políticas de coleta, uso e divulgação de Informações Pessoais se alguém decidir usar meu Serviço.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Se você optar por usar meu Serviço, concorda com a coleta e uso de informações em relação a esta política. As Informações Pessoais que eu coleto são usadas para fornecer e melhorar o Serviço. Não usarei ou compartilharei suas informações com ninguém, exceto conforme descrito nesta Política de Privacidade.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Os termos utilizados nesta Política de Privacidade têm os mesmos significados que em nossos Termos e Condições, que são acessíveis em Receituagro, salvo definição em contrário nesta Política de Privacidade.'),
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

  Widget _buildInfoCollection() {
    return Container(
      key: _coletaSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coleta e Uso de Informações',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Para uma melhor experiência, ao usar nosso Serviço, posso exigir que você nos forneça determinadas informações de identificação pessoal, incluindo, entre outras, informações que não podem ser usadas para identificar um indivíduo, dados anônimos, número de registro de uma empresa. As informações que eu solicitar serão retidas no seu dispositivo e não serão coletadas por mim de forma alguma.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'O aplicativo usa serviços de terceiros que podem coletar informações usadas para identificá-lo.'),
              const SizedBox(height: 20),
              const Text(
                'Link para a política de privacidade de provedores de serviços terceirizados usados pelo aplicativo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceLink('Serviços do Google Play',
                  'https://policies.google.com/privacy'),
              _buildServiceLink(
                  'AdMob', 'https://support.google.com/admob/answer/6128543'),
              _buildServiceLink('Google Analytics para Firebase',
                  'https://firebase.google.com/policies/analytics'),
              _buildServiceLink('Firebase Crashlytics',
                  'https://firebase.google.com/support/privacy'),
              _buildServiceLink(
                  'Facebook', 'https://www.facebook.com/policy.php'),
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
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(url)),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogData() {
    return Container(
      key: _logDataSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Data',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Quero informar que sempre que você usar meu Serviço, em caso de erro no aplicativo, coleto dados e informações (através de produtos de terceiros) em seu telefone chamado Log Data. Esses Dados de Registro podem incluir informações como o endereço do Protocolo de Internet ("IP") do seu dispositivo, nome do dispositivo, versão do sistema operacional, a configuração do aplicativo ao utilizar meu Serviço, a hora e a data de seu uso do Serviço e outras estatísticas.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCookies() {
    return Container(
      key: _cookiesSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cookies',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Cookies são arquivos com uma pequena quantidade de dados que são comumente usados como identificadores exclusivos anônimos. Eles são enviados para o seu navegador a partir dos sites que você visita e são armazenados na memória interna do seu dispositivo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Este Serviço não usa esses "cookies" explicitamente. No entanto, o aplicativo pode usar código de terceiros e bibliotecas que usam "cookies" para coletar informações e melhorar seus serviços. Você tem a opção de aceitar ou recusar esses cookies e saber quando um cookie está sendo enviado ao seu dispositivo. Se você optar por recusar nossos cookies, talvez não consiga usar algumas partes deste Serviço.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceProviders() {
    return Container(
      key: _providersSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provedores de Serviço',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Posso empregar empresas e indivíduos terceirizados pelos seguintes motivos:'),
              const SizedBox(height: 16),
              _buildBulletPoint('Para facilitar nosso Serviço;'),
              _buildBulletPoint('Para fornecer o Serviço em nosso nome;'),
              _buildBulletPoint(
                  'Executar serviços relacionados ao Serviço; ou'),
              _buildBulletPoint(
                  'Para nos ajudar a analisar como nosso Serviço é usado.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Quero informar aos usuários deste Serviço que esses terceiros têm acesso às suas Informações Pessoais. O motivo é realizar as tarefas atribuídas a eles em nosso nome. No entanto, eles são obrigados a não divulgar ou usar as informações para qualquer outra finalidade.'),
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

  Widget _buildSecurity() {
    return Container(
      key: _securitySection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Segurança',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Eu valorizo sua confiança em nos fornecer suas informações pessoais, portanto, estamos nos esforçando para usar meios comercialmente aceitáveis de protegê-las. Mas lembre-se que nenhum método de transmissão pela internet, ou método de armazenamento eletrônico é 100% seguro e confiável, e não posso garantir sua segurança absoluta.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinks() {
    return Container(
      key: _linksSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Links para Outros Sites',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Este Serviço pode conter links para outros sites. Se você clicar em um link de terceiros, será direcionado para esse site. Observe que esses sites externos não são operados por mim. Portanto, aconselho vivamente a rever a Política de Privacidade desses sites. Não tenho controle e não assumo responsabilidade pelo conteúdo, políticas de privacidade ou práticas de sites ou serviços de terceiros.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenPrivacy() {
    return Container(
      key: _childrenSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacidade das Crianças',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Esses Serviços não se dirigem a menores de 13 anos. Não coleto intencionalmente informações de identificação pessoal de crianças menores de 13 anos. No caso de eu descobrir que uma criança menor de 13 anos me forneceu informações pessoais, eu imediatamente as excluo de nossos servidores. Se você é pai ou responsável e está ciente de que seu filho nos forneceu informações pessoais, entre em contato comigo para que eu possa tomar as medidas necessárias.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyChanges() {
    return Container(
      key: _changesSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alterações nesta Política de Privacidade',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Posso atualizar nossa Política de Privacidade de tempos em tempos. Assim, recomendamos que você revise esta página periodicamente para quaisquer alterações. Vou notificá-lo sobre quaisquer alterações publicando a nova Política de Privacidade nesta página.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Esta política está em vigor a partir de 30/08/2022'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContact() {
    return Container(
      key: _contactSection,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
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
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Se você tiver alguma dúvida ou sugestão sobre minha Política de Privacidade, não hesite em me contatar pelo e-mail:'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    launchUrl(Uri.parse('mailto:agrimind.br@gmail.com')),
                child: Text(
                  'agrimind.br@gmail.com',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.green.shade900,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Receituagro',
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
