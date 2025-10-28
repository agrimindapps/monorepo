import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DesenvolvimentoPage extends StatefulWidget {
  const DesenvolvimentoPage({super.key});

  @override
  State<DesenvolvimentoPage> createState() => _DesenvolvimentoPageState();
}

class _DesenvolvimentoPageState extends State<DesenvolvimentoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180, // Ajuste conforme necessário
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('lib/assets/receituagro_logo.webp'),
                  fit: BoxFit.cover,
                ),
                borderRadius:
                    BorderRadius.circular(40), // Raio das bordas arredondadas
              ),
            ),
            const SizedBox(height: 20),
            const Text('ReceituAgro: Seu app Agro',
                style: TextStyle(fontSize: 24)),
            Text('Agricultura do seu dia a dia',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            SizedBox(
              width: 600,
              child: Text(
                'Estamos criando uma nova experiencia web para você consultar defensivos agrícolas, pragas e doenças, com informações atualizadas e de qualidade.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 600,
              child: Text(
                'No momento, aproveite nossa versão mobile para Android e iOS.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Image.asset(
                      'lib/assets/download_app_store.png',
                      width: 170,
                    ),
                    onTap: () async {
                      Uri url = Uri.parse(
                          'https://apps.apple.com/br/app/receituagro-seu-app-agro/id967785485?platform=iphone');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Image.asset(
                      'lib/assets/download_play_store.png',
                      width: 170,
                    ),
                    onTap: () async {
                      Uri url = Uri.parse(
                          'https://play.google.com/store/apps/details?id=br.com.agrimind.pragassoja');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
