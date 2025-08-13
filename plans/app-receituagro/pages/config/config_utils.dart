// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/pages/tts_settings_page.dart';
import '../../router.dart';
import '../sobre/views/sobre_page.dart';

/// Widget para a opção de compras no aplicativo
ListTile configOptionInAppPurchase(
    BuildContext context, void Function(void Function()) setState) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.grey.shade100,
      child:
          Icon(FontAwesome.crown_solid, size: 18, color: Colors.grey.shade700),
    ),
    title: const Text('Remover anúncios'),
    subtitle:
        const Text('Apoie o desenvolvimento e aproveite o app sem publicidade'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    onTap: () async {
      await Get.toNamed(AppRoutes.premium);
      setState(() {});
    },
  );
}

/// Widget para a configuração de texto para fala
ListTile configOptionTSSPage(BuildContext context) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.grey.shade100,
      child: Icon(FontAwesome.volume_high_solid,
          size: 18, color: Colors.grey.shade700),
    ),
    title: const Text('Configurações de voz'),
    subtitle: const Text(
        'Configure as opções de texto para fala para melhor experiência'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TTsSettingsPage(),
        ),
      );
    },
  );
}



/// Widget para a página sobre
ListTile configOptionSobre(BuildContext context) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.grey.shade100,
      child: Icon(FontAwesome.circle_info_solid,
          size: 18, color: Colors.grey.shade700),
    ),
    title: const Text('Sobre o app'),
    subtitle: const Text('Informações sobre o aplicativo e versão'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SobrePage(),
        ),
      );
    },
  );
}
