// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/bovino_class.dart';
import '../repository/bovinos_repository.dart';
import '../services/rss_service.dart';
import '../widgets/page_header_widget.dart';
import 'bovinos/detalhes/index.dart';
import 'bovinos/lista/index.dart';
import 'noticias/noticias_pecuaria_page.dart';

class PecuariaHomepage extends StatefulWidget {
  const PecuariaHomepage({super.key});

  @override
  State<PecuariaHomepage> createState() => _PecuariaHomepageState();
}

class _PecuariaHomepageState extends State<PecuariaHomepage> {
  final _repository = BovinosRepository();
  List<BovinoClass> _bovinos = [];
  bool _isLoadingBovinos = false;

  String formatStringRss(String text, int width) {
    return text.length > width ~/ 4
        ? '${text.substring(0, width ~/ 4)}...'
        : text;
  }

  @override
  void initState() {
    super.initState();
    _loadBovinos();
    if (RSSService().itemsPecuaria.isEmpty) RSSService().carregaPecuariaRSS();
  }

  Future<void> _loadBovinos() async {
    setState(() => _isLoadingBovinos = true);
    try {
      final bovinos = await _repository.getAll();
      setState(() => _bovinos = bovinos);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoadingBovinos = false);
    }
  }

  Widget _buildBovinosList() {
    if (_isLoadingBovinos) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_bovinos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Nenhum registro encontrado!'),
        ),
      );
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(height: 1),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _bovinos.length > 5 ? 5 : _bovinos.length,
      itemBuilder: (context, index) {
        final bovino = _bovinos[index];
        return ListTile(
          title: Text(bovino.nomeComum),
          subtitle: Text(bovino.tipoAnimal),
          visualDensity: VisualDensity.compact,
          leading: bovino.miniatura == ''
              ? const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.pets, color: Colors.white),
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(bovino.miniatura!),
                ),
          onTap: () {
            Get.to(
              () => const BovinosDetalhesPage(),
              arguments: {'idReg': bovino.idReg},
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: PageHeaderWidget(
                title: 'Pecuária',
                subtitle: 'Gestão Pecuária',
                icon: Icons.pets,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // const CalculosPecuariaPage(),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Últimas Notícias',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Obx(
                            () => RSSService().itemsPecuaria.isEmpty
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
                                        padding: const EdgeInsets.all(8.0),
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
                                                          .itemsPecuaria
                                                          .length >
                                                      4
                                                  ? 4
                                                  : RSSService()
                                                      .itemsPecuaria
                                                      .length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  contentPadding:
                                                      const EdgeInsets.all(4),
                                                  title: Text(formatStringRss(
                                                      RSSService()
                                                          .itemsPecuaria[index]
                                                          .title,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width
                                                          .toInt())),
                                                  subtitle: Column(
                                                    children: [
                                                      Text(formatStringRss(
                                                          RSSService()
                                                              .itemsPecuaria[
                                                                  index]
                                                              .description,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .toInt())),
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
                                                                    .itemsPecuaria[
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
                                                                    .itemsPecuaria[
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
                                                  dense: true,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onTap: () => RSSService()
                                                      .abrirLinkExterno(
                                                          RSSService()
                                                              .itemsPecuaria[
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
                                                              const NoticiasPecuariasPage(),
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
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Text(
                              'Raças de Equinos e Bovinos',
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
                                  children: [
                                    _buildBovinosList(),
                                    const Divider(height: 1),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const BovinosListaPage(),
                                              ),
                                            );
                                          },
                                          child: const Text('Ver mais'),
                                        ),
                                      ],
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
