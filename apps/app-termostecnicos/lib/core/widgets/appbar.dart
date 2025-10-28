import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../intermediate.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: AppBar(
          titleSpacing: 0,
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white.withOpacity(0.7),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              logo(),
              const Spacer(),
              menuOpcoes(context),
              const Spacer(),
              loginUser()
            ],
          ),
        ),
      ),
    );
  }

  Widget menuOpcoes(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: GlobalEnvironment().itensMenuBottom.map((item) {
        return _buildTextButton(
          context: context,
          icon: item['icon'],
          label: item['label'],
          onPressed: () {
            Navigator.pushReplacementNamed(context, item['page']);
          },
        );
      }).toList(),
    );
  }

  Widget loginUser() {
    // return SizedBox(
    //   width: 60,
    // );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: PopupMenuButton<String>(
        onSelected: (String result) {
          switch (result) {
            case 'theme':
              break;
            case 'settings':
              break;
          }
        },
        position: PopupMenuPosition.under,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'theme',
            child: Text('Trocar Tema'),
          ),
          const PopupMenuItem<String>(
            value: 'settings',
            child: Text('Configurações'),
          ),
        ],
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 60, // Ajuste a largura conforme necessário
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      'lib/core/assets/avatar.png',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget logo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = MediaQuery.of(context).size.width < 600;
        return SizedBox(
          width: isSmallScreen ? 70 : 120,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                Uri url = Uri.parse(GlobalEnvironment().siteApp);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                child: Image.asset(
                  isSmallScreen
                      ? 'lib/core/assets/logo_min.png'
                      : 'lib/core/assets/logo.png',
                  width: isSmallScreen ? 30 : 120,
                  height: isSmallScreen ? 30 : 120,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);

  Widget _buildTextButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 1000;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          isSmallScreen ? 2 : 10, 12, isSmallScreen ? 2 : 10, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = MediaQuery.of(context).size.width < 1000;
          return SizedBox(
            height: 48,
            width: isSmallScreen ? 60 : 137,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                foregroundColor: WidgetStateProperty.all(Colors.green),
                overlayColor: WidgetStateProperty.all(Colors.grey.shade300),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.black),
                  if (!isSmallScreen) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
