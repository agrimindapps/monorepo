import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../intermediate.dart';
import '../themes/manager.dart';
import '../widgets/appbar.dart';

class SobrePage extends StatefulWidget {
  const SobrePage({super.key});

  @override
  SobrePageState createState() => SobrePageState();
}

class SobrePageState extends State<SobrePage> {
  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  void _abrirLinkExterno(String url, String path) async {
    final Uri toLaunch = Uri(scheme: 'https', host: url, path: path);

    if (await canLaunchUrl(toLaunch)) {
      await launchUrl(toLaunch);
    } else {
      throw 'Não foi possível abrir o link $url';
    }
  }

  void _abrirEmail() async {
    String appEmailContato = GlobalEnvironment().iAppEmailContato;
    String appName = GlobalEnvironment().iAppName;
    String appVersion = GlobalEnvironment().iAppVersion;

    final Uri toLaunch = Uri.parse(
      'mailto:$appEmailContato?subject=$appName%20-%20$appVersion%20|%20Problemas%20/%20Melhorias%20/%20Duvidas&body=Descreva%20aqui%20sua%20mensagem\n\n',
    );

    if (await canLaunchUrl(toLaunch)) {
      await launchUrl(toLaunch);
    } else {
      throw 'Não foi possível abrir o email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBars(title: 'Sobre'),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      'lib/core/assets/logo_menu.png',
                      width: 150,
                    ),
                  ),
                  Card(
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ListTile(
                          title: Center(
                            child: Text(GlobalEnvironment().atualizacoesText[0]
                                ['versao']!),
                          ),
                          subtitle: const Center(
                            child: Text('Informações da Versão'),
                          ),
                          titleAlignment: ListTileTitleAlignment.top,
                          visualDensity: VisualDensity.compact,
                          onTap: () {
                            Navigator.of(context).pushNamed('/atualizacao');
                          },
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Contato',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: const Color(0xFFF5F5F5),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(FontAwesome.envelope),
                          title: const Text('E-mail'),
                          onTap: () {
                            _abrirEmail();
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesome.facebook_brand),
                          title: const Text('Fabebook'),
                          onTap: () {
                            _abrirLinkExterno('m.facebook.com', 'agrimind.br');
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesome.instagram_brand),
                          title: const Text('Instagram'),
                          onTap: () {
                            _abrirLinkExterno(
                              'www.instagram.com',
                              'agrimind.br',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: Text(
                      'Copyright @ Agrimind',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Todos os Direitos Reservados',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget configOptionSobre(BuildContext context) {
  return ListTile(
    title: const Text('Sobre'),
    subtitle: const Text(
      'Informações sobre o aplicativo, como contato e nota de atualização da versão',
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: ThemeManager().isDark.value
          ? Colors.grey.shade300
          : Colors.grey.shade600,
    ),
    onTap: () {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SobrePage()));
    },
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
    ),
  );
}
