import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/pages/in_app_purchase_page.dart';
import '../../core/pages/sobre.dart';
import '../../core/pages/tts_settings_page.dart';
import '../../core/themes/manager.dart';
import '../../core/widgets/admob/ads_rewarded_widget.dart';
import '../../core/widgets/appbar.dart';
import '../const/environment_const.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigState();
}

class _ConfigState extends State<ConfigPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      // appBar: AppBar(
      //   title: const Text('Opções'),
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   actions: const [],
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!GetPlatform.isWeb) _acessarSiteGroup(),
                    _personalizacaoGroup(),
                    _speechToTextGroup(),
                    if (!GetPlatform.isWeb) _publicidadeGroup(),
                    _sobreGroup(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _acessarSiteGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 0, 8),
          child: Text(
            'Acessar Site',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: ListTile(
              title: const Text('App na Web'),
              subtitle: const Text(
                  'Agora você pode acessar todas as funcionalidades do aplicativo no seu navegador. Confira!'),
              trailing: Icon(FontAwesome.link_solid,
                  size: 18, color: Colors.grey.shade900),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () async {
                Uri url = Uri.parse(Environment().siteApp);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _publicidadeGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 0, 8),
          child: Text(
            'Contribuições',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: configOptionInAppPurchase(context, setState),
          ),
        ),
        const Divider(height: 0),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: RewardedAdWidget(adUnitId: Environment.admobPremiado),
          ),
        ),
      ],
    );
  }

  Widget _speechToTextGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 0, 8),
          child: Text(
            'Transcrição para Voz',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        configOptionTSSPage(context),
      ],
    );
  }

  Widget _sobreGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 0, 8),
          child: Text(
            'Mais informações',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        configOptionSobre(context),
      ],
    );
  }

  Widget _personalizacaoGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 0, 8),
          child: Text(
            'Personalização',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('Tema'),
          subtitle: const Text('Escolha o tema do aplicativo'),
          trailing: Icon(
              !ThemeManager().isDark.value ? FontAwesome.moon : FontAwesome.sun,
              size: 18),
          iconColor: !ThemeManager().isDark.value
              ? Colors.grey.shade900
              : Colors.amber.shade600,
          onTap: () {
            ThemeManager().toggleTheme();
            setState(() {});
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
