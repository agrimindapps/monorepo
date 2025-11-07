import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final scrollController = ScrollController();
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
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
                _buildHeader(),
                _buildIntroduction(),
                _buildInfoCollection(),
                _buildLogData(),
                _buildCookies(),
                _buildServiceProviders(),
                _buildSecurity(),
                _buildLinks(),
                _buildChildrenPrivacy(),
                _buildPolicyChanges(),
                _buildContact(),
                _buildFooter(),
              ],
            ),
          ),
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.privacy_tip,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Política de Privacidade',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'GasOMeter - Última atualização: 01/01/2025',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'A Agrimind Apps construiu o aplicativo GasOMeter como um aplicativo suportado por anúncios. Este SERVIÇO é fornecido pela Agrimind Apps sem custo e destina-se ao uso como está.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Esta página é usada para informar os visitantes sobre nossas políticas de coleta, uso e divulgação de Informações Pessoais se alguém decidir usar nosso Serviço.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Se você optar por usar nosso Serviço, concorda com a coleta e uso de informações em relação a esta política. As Informações Pessoais que coletamos são usadas para fornecer e melhorar o Serviço. Não usaremos ou compartilharemos suas informações com ninguém, exceto conforme descrito nesta Política de Privacidade.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Os termos utilizados nesta Política de Privacidade têm os mesmos significados que em nossos Termos e Condições, que são acessíveis no GasOMeter, salvo definição em contrário nesta Política de Privacidade.'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Para uma melhor experiência, ao usar nosso Serviço, podemos exigir que você nos forneça determinadas informações de identificação pessoal, incluindo, entre outras, dados de abastecimento, quilometragem, despesas relacionadas ao veículo, informações sobre manutenções e odômetro. As informações que solicitamos serão retidas no seu dispositivo e podem ser sincronizadas com nossos servidores para backup e sincronização entre dispositivos.'),
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
              _buildServiceLink('Firebase Cloud Storage',
                  'https://firebase.google.com/support/privacy'),
              _buildServiceLink('RevenueCat', 
                  'https://www.revenuecat.com/privacy'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Queremos informar que sempre que você usar nosso Serviço, em caso de erro no aplicativo, coletamos dados e informações (através de produtos de terceiros) em seu telefone chamado Log Data. Esses Dados de Registro podem incluir informações como o endereço do Protocolo de Internet ("IP") do seu dispositivo, nome do dispositivo, versão do sistema operacional, a configuração do aplicativo ao utilizar nosso Serviço, a hora e a data de seu uso do Serviço e outras estatísticas.'),
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
                color: Colors.blue.shade700,
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Podemos empregar empresas e indivíduos terceirizados pelos seguintes motivos:'),
              const SizedBox(height: 16),
              _buildBulletPoint('Para facilitar nosso Serviço;'),
              _buildBulletPoint('Para fornecer o Serviço em nosso nome;'),
              _buildBulletPoint(
                  'Executar serviços relacionados ao Serviço; ou'),
              _buildBulletPoint(
                  'Para nos ajudar a analisar como nosso Serviço é usado.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Utilizamos especificamente os seguintes provedores de serviço:'),
              const SizedBox(height: 12),
              _buildBulletPoint('RevenueCat: Utilizado para gerenciamento de assinaturas premium e compras dentro do aplicativo. A RevenueCat pode coletar e processar informações sobre suas transações e uso de funcionalidades premium.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Queremos informar aos usuários deste Serviço que esses terceiros têm acesso às suas Informações Pessoais. O motivo é realizar as tarefas atribuídas a eles em nosso nome. No entanto, eles são obrigados a não divulgar ou usar as informações para qualquer outra finalidade.'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Valorizamos sua confiança em nos fornecer suas informações pessoais, portanto, estamos nos esforçando para usar meios comercialmente aceitáveis de protegê-las. Mas lembre-se que nenhum método de transmissão pela internet, ou método de armazenamento eletrônico é 100% seguro e confiável, e não podemos garantir sua segurança absoluta.'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Este Serviço pode conter links para outros sites. Se você clicar em um link de terceiros, será direcionado para esse site. Observe que esses sites externos não são operados por nós. Portanto, aconselhamos vivamente a rever a Política de Privacidade desses sites. Não temos controle e não assumimos responsabilidade pelo conteúdo, políticas de privacidade ou práticas de sites ou serviços de terceiros.'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Esses Serviços não se dirigem a menores de 13 anos. Não coletamos intencionalmente informações de identificação pessoal de crianças menores de 13 anos. No caso de descobrirmos que uma criança menor de 13 anos nos forneceu informações pessoais, nós imediatamente as excluímos de nossos servidores. Se você é pai ou responsável e está ciente de que seu filho nos forneceu informações pessoais, entre em contato conosco para que possamos tomar as medidas necessárias.'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Podemos atualizar nossa Política de Privacidade de tempos em tempos. Assim, recomendamos que você revise esta página periodicamente para quaisquer alterações. Vamos notificá-lo sobre quaisquer alterações publicando a nova Política de Privacidade nesta página.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Esta política está em vigor a partir de 01/01/2025'),
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
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Se você tiver alguma dúvida ou sugestão sobre nossa Política de Privacidade, não hesite em nos contatar pelo e-mail:'),
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
              const SizedBox(height: 20),
              _buildParagraph(
                  'Para solicitar a exclusão completa de sua conta e dados pessoais, acesse nossa página de Exclusão de Conta ou entre em contato conosco.'),
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
                _footerLink('Política de Privacidade', () {}),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Termos de Uso', () => context.go('/terms')),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Exclusão de Conta', () => context.go('/account-deletion')),
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
