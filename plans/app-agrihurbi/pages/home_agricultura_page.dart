// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../services/rss_service.dart';
import '../widgets/commodity_improved_widget.dart';
import '../widgets/page_header_widget.dart';
import '../widgets/weather_improved_widget.dart';
import 'bulas/lista/index.dart';
import 'calc/calculos_page.dart';
import 'implementos/lista/index.dart';
import 'noticias/noticias_agricultura_page.dart';
import 'pluviometro/home_page.dart';
import 'settings_page.dart';

class AgriculturaHomepage extends StatelessWidget {
  const AgriculturaHomepage({super.key});

  void carregaRSS() async {
    if (RSSService().itemsAgricultura.isEmpty) {
      RSSService().carregaAgroRSS();
    }
  }

  String formatStringRss(String text, int width) {
    return text.length > width ~/ 4
        ? '${text.substring(0, width ~/ 4)}...'
        : text;
  }

  void _abrirLojaApp() async {
    final Uri toLaunch = Uri.parse(GetPlatform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=br.com.agrimind.pragassoja'
        : 'https://apps.apple.com/br/app/receituagro/id967785485');

    if (await canLaunchUrl(toLaunch)) {
      await launchUrl(toLaunch);
    } else {
      throw 'Não foi possível abrir o email';
    }
  }

  @override
  Widget build(BuildContext context) {
    carregaRSS();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PageHeaderWidget(
                title: 'Agricultura',
                subtitle: 'Gestão Agrícola',
                icon: Icons.agriculture,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                    tooltip: 'Configurações',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WeatherImprovedWidget(),

                          const CommodityImprovedWidget(),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Acessos Rápidos',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: const SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calculate_outlined),
                                        SizedBox(height: 4),
                                        Text('Calculos'),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CalculosPage(),
                                    ),
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ImplementosAgListaPage(),
                                    ),
                                  );
                                },
                                child: const SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.article),
                                        SizedBox(height: 4),
                                        Text('Implementos'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PluviometriaHome(),
                                    ),
                                  );
                                },
                                child: const SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.wb_sunny),
                                        SizedBox(height: 4),
                                        Text('Pluviometro'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // const CalculosAgricolasPage(),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Últimas Notícias',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Obx(
                            () => RSSService().itemsAgricultura.isEmpty
                                ? const SizedBox(
                                    width: double.infinity,
                                    height: 450,
                                    child: Card(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 8, 8, 8),
                                        child: Column(
                                          children: [
                                            ListView.separated(
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Divider(height: 1),
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: RSSService()
                                                          .itemsAgricultura
                                                          .length >
                                                      4
                                                  ? 4
                                                  : RSSService()
                                                      .itemsAgricultura
                                                      .length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                      const EdgeInsets.all(4),
                                                  title: Text(formatStringRss(
                                                      RSSService()
                                                          .itemsAgricultura[
                                                              index]
                                                          .title,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width
                                                          .toInt())),
                                                  subtitle: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 4, 0, 0),
                                                        child: Text(formatStringRss(
                                                            RSSService()
                                                                .itemsAgricultura[
                                                                    index]
                                                                .description,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width
                                                                .toInt())),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 4, 0, 0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                RSSService()
                                                                    .itemsAgricultura[
                                                                        index]
                                                                    .channelName,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Text(
                                                                RSSService()
                                                                    .itemsAgricultura[
                                                                        index]
                                                                    .pubDate,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  leading: Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: RSSService()
                                                                .itemsAgricultura[
                                                                    index]
                                                                .media !=
                                                            ''
                                                        ? BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            image:
                                                                DecorationImage(
                                                              image: NetworkImage(
                                                                  RSSService()
                                                                      .itemsAgricultura[
                                                                          index]
                                                                      .media),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: Colors
                                                                .grey.shade300,
                                                          ),
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onTap: () => RSSService()
                                                      .abrirLinkExterno(
                                                          RSSService()
                                                              .itemsAgricultura[
                                                                  index]
                                                              .link),
                                                );
                                              },
                                            ),
                                            const Divider(height: 1),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const NoticiasAgricolassPage(),
                                                        ),
                                                      );
                                                    },
                                                    child:
                                                        const Text('Ver mais'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Implementos Agrícolas',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text('Colheitadeira $index'),
                                          subtitle: const Text('Valtra'),
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          leading: const Icon(Icons.article),
                                        );
                                      },
                                    ),
                                    const Divider(height: 1),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImplementosAgListaPage(),
                                                ),
                                              );
                                            },
                                            child: const Text('Ver mais'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Produtos e Serviços',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          SizedBox(
                            height: 90,
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImplementosAgListaPage(),
                                          ),
                                        );
                                      },
                                      child: const Text('Implementos'),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BulasListaPage(),
                                          ),
                                        );
                                      },
                                      child: const Text('Bulas'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Ferramentas e Calculadoras',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(
                            height: 170,
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Pecuária Homepage'),
                              ),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Defensivos Agrícolas',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              _abrirLojaApp();
                            },
                            child: SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: Card(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 75,
                                      height: 75,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                      ),
                                      child: Image.asset(
                                        'assets/imagens/others/agrihurbi_icon.png',
                                        width: 75,
                                        height: 75,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              1120
                                          ? 1020 // Se a tela for maior que 1120px, limita a largura
                                          : MediaQuery.of(context).size.width -
                                              130,
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 8, 0, 8),
                                        child: Text(
                                            'Temos um aplicativo desenvolvido para ajudar você a encontrar o defensivo agrícola correto para sua lavoura. Clique aqui para saber mais'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
