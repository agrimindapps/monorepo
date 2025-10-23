// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../core/pages/in_app_purchase_page.dart';
import '../../core/widgets/admob/ads_rewarded_widget.dart';
import '../../core/widgets/feedback_config_option_widget.dart';
import '../const/environment_const.dart';
import '../routes.dart';
import '../core/theme/theme_providers.dart';

// const PerfilWidget(),
class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 1020,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!kIsWeb) _acessarSiteGroup(),
                      _personalizacaoGroup(context, ref, isDark),
                      _configuracoesAvancadasGroup(context),
                      // _speechToTextGroup(),
                      if (!kIsWeb) _publicidadeGroup(context),
                      _sobreGroup(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ), // SafeArea
    );
  }

  Widget _acessarSiteGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
          child: Text(
            'Acessar Site',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
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
                Uri url = Uri.parse(AppEnvironment().siteApp);
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

  Widget _publicidadeGroup(BuildContext context) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: configOptionInAppPurchase(),
          ),
        ),
        const Divider(height: 0),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: RewardedAdWidget(),
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
          padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
          child: Text(
            'Mais informações',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: FeedbackConfigOptionWidget(),
          ),
        ),
        // const Divider(height: 0),
        // Card(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        //     child: configOptionSobre(context),
        //   ),
        // ),
      ],
    );
  }

  Widget _personalizacaoGroup(BuildContext context, WidgetRef ref, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
          child: Text(
            'Personalização',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('Tema'),
          subtitle: const Text('Escolha o tema do aplicativo'),
          trailing: Icon(
              !isDark ? FontAwesome.moon : FontAwesome.sun,
              size: 18),
          iconColor: !isDark
              ? Colors.grey.shade900
              : Colors.amber.shade600,
          onTap: () {
            ref.read(themeNotifierProvider.notifier).toggleTheme();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _configuracoesAvancadasGroup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
          child: Text(
            'Configurações Avançadas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: ListTile(
              title: const Text('Configurações Avançadas'),
              subtitle:
                  const Text('Lembretes, sincronização, perfil e mais opções'),
              trailing: const Icon(Icons.settings_applications, size: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.configuracoesAvancadas);
              },
            ),
          ),
        ),
      ],
    );
  }

  // TODO: Implement In-App Purchase configuration option
  Widget configOptionInAppPurchase() {
    return Builder(
      builder: (context) => ListTile(
        leading: const Icon(Icons.shopping_cart),
        title: const Text('Compras no App'),
        subtitle: const Text('Gerenciar assinaturas e compras'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InAppPurchasePage(),
            ),
          );
        },
      ),
    );
  }
}

// TODO: Implement RewardedAdWidget
class RewardedAdWidget extends StatelessWidget {
  const RewardedAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Stub implementation - will be replaced with actual ad widget
    return const SizedBox.shrink();
  }
}
