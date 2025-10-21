// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../const/environment_const.dart';

/// Abre o site do aplicativo
Future<void> openAppSite() async {
  Uri url = Uri.parse(Environment().siteApp);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

/// Widget para o botão de abrir site
Widget btnOpenSite() {
  return const IconButton(
    icon: Icon(FontAwesome.link_solid, size: 18),
    color: Colors.white,
    onPressed: openAppSite,
  );
}

/// Lança uma URL
Future<void> launchURL(String urlString) async {
  Uri url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
