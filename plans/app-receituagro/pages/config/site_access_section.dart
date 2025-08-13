// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../const/environment_const.dart';
import '../../widgets/section_title_widget.dart';

class SiteAccessSection extends StatelessWidget {
  const SiteAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Acessar Site',
          icon: FontAwesome.globe_solid,
        ),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('App na Web'),
              subtitle: const Text('receituagro.agrimind.com.br'),
              trailing: Icon(FontAwesome.link_solid,
                  size: 18, color: Colors.grey.shade700),
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
}
