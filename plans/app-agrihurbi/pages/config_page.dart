// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../core/widgets/admob/ads_rewarded_widget.dart';
import '../../app-receituagro/pages/config/config_utils.dart' as config_utils;
import '../../core/services/app_rating_service.dart';
import '../../core/themes/manager.dart';
import '../../core/widgets/feedback_config_option_widget.dart';
import '../../intermediate.dart';

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
      appBar: AppBar(
        title: const Text('Opções'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!GetPlatform.isWeb) _acessarSiteGroup(),
                _personalizacaoGroup(),
                // _speechToTextGroup(),
                if (!GetPlatform.isWeb) _publicidadeGroup(),
                _sobreGroup(),
              ],
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
            'Acesso Externo',
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
                  'Acessar todas as funcionalidades do aplicativo no seu computador. Confira!'),
              trailing: Icon(
                FontAwesome.link_solid,
                size: 18,
                color: ThemeManager().isDark.value
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () async {
                Uri url = Uri.parse(GlobalEnvironment().siteApp);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launchUrl $url';
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
            child: config_utils.configOptionInAppPurchase(context, setState),
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
            child:
                RewardedAdWidget(adUnitId: GlobalEnvironment().admobPremiado),
          ),
        ),
      ],
    );
  }

  // Widget _speechToTextGroup() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
  //         child: Text(
  //           'Transcrição para Voz',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       Card(
  //         elevation: 0,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
  //           child: ConfigOptionTSSPage(context),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: FeedbackConfigOptionWidget(),
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
            child: ListTile(
              title: const Text('Avaliar o App'),
              subtitle: const Text('Avalie nossa experiência na loja'),
              leading: Icon(
                Icons.star_rate_outlined,
                color: ThemeManager().isDark.value
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: _handleAppRating,
            ),
          ),
        ),
        // const Divider(height: 0),
        // Card(
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        //     child: configOptionSobre(context),
        //   ),
        // ),
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

  /// Lida com a solicitação de avaliação do app
  Future<void> _handleAppRating() async {
    try {
      final success = await AppRatingService.instance.requestRating();
      if (!success) {
        // Se não conseguir mostrar o diálogo nativo, abre a loja diretamente
        await AppRatingService.instance.openStoreListing();
      }
    } catch (e) {
      // Em caso de erro, tenta abrir a loja como fallback
      try {
        await AppRatingService.instance.openStoreListing();
      } catch (fallbackError) {
        // Log do erro mas não interrompe a experiência do usuário
        print('Erro ao abrir avaliação do app: $fallbackError');
      }
    }
  }
}
