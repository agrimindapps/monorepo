import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firebase_analytics_service.dart';
import '../repository/defensivos_repository.dart';
import '../core/utils/responsive_helper.dart';
import '../services/feedback_service.dart';

class DefensivosListarPage extends StatefulWidget {
  const DefensivosListarPage({super.key});

  @override
  State<DefensivosListarPage> createState() => _DefensivosListarPageState();
}

class _DefensivosListarPageState extends State<DefensivosListarPage> {
  String search = '';

  @override
  void initState() {
    super.initState();
    testeSupabase();
  }

  void testeSupabase() async {
    // Usar cache para evitar fetching desnecessário
    await DefensivosRepository().fetchAllDefensivos(forceRefresh: false);
  }

  void buscarDefensivos() async {
    if (search.length < 3) {
      FeedbackService.showWarning(
        'Informe pelo menos 3 caracteres para realizar a busca',
      );

      return;
    } else {
      FeedbackService.showLoadingDialog('Buscando defensivos...');

      try {
        await DefensivosRepository().buscaDefensivos(search);
        FeedbackService.hideLoadingDialog();

        final totalResults = DefensivosRepository().filteredDefensivos.length;
        if (totalResults == 0) {
          FeedbackService.showInfo(
              'Nenhum resultado encontrado para "$search"');
        } else {
          FeedbackService.showSuccess('$totalResults resultados encontrados');
        }
      } catch (e) {
        FeedbackService.hideLoadingDialog();
        FeedbackService.showError('Erro ao buscar defensivos');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 70,
      //   backgroundColor: Colors.white.withValues(alpha: 0.7), // Cor com transparência
      //   title: SizedBox(
      //     width: 1120,
      //     child: rowOpcoesMenuSuperior(),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _menuPromo(),
                const SizedBox(height: 30),
                _columnTituloDescricao(),
                const SizedBox(height: 30),
                _rowPesquisar(),
                const SizedBox(height: 30),
                _todosOsDefensivos(),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 15),
                _gridDefensivos(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _columnTituloDescricao() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 800,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Tudo o que você precisa saber sobre defensivos agrícolas está na palma da sua mão!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gridDefensivos() {
    return Column(
      children: [
        const _DefensivosGrid(),
        const SizedBox(height: 15),
        _buttonsNavigation(),
        const _TotalRegistros(),
      ],
    );
  }

  Widget _buttonsNavigation() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        if (DefensivosRepository().filteredDefensivos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: DefensivosRepository().firstPage,
              icon: const Icon(Icons.first_page),
            ),
            IconButton(
              onPressed: DefensivosRepository().previousPage,
              icon: const Icon(Icons.chevron_left),
            ),
            ...DefensivosRepository().pageNumbers.map((page) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        page == DefensivosRepository().currentPage.value
                            ? Colors.green
                            : Colors.grey,
                  ),
                  onPressed: () {
                    DefensivosRepository().currentPage.value = page;
                    DefensivosRepository().currentItems();
                  },
                  child: Text((page + 1).toString()),
                ),
              );
            }),
            IconButton(
              onPressed: DefensivosRepository().nextPage,
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              onPressed: DefensivosRepository().lastPage,
              icon: const Icon(Icons.last_page),
            ),
          ],
        );
      }),
    );
  }

  // Widget _rowOpcoesFiltrar() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const SizedBox(
  //         width: 1,
  //         height: 60,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
  //         child: TextButton(
  //           style: ButtonStyle(
  //             backgroundColor: WidgetStateProperty.all(Colors.transparent),
  //             foregroundColor: WidgetStateProperty.all(Colors.green),
  //           ),
  //           onPressed: () {
  //             DefensivosRepository().carregaDados('fabricantes', '');
  //             Navigator.pushNamed(context, '/defensivos/listar');
  //           },
  //           child: const Text(
  //             'Fabricantes',
  //             style: TextStyle(color: Colors.black),
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
  //         child: TextButton(
  //           style: ButtonStyle(
  //             backgroundColor: WidgetStateProperty.all(Colors.transparent),
  //             foregroundColor: WidgetStateProperty.all(Colors.green),
  //           ),
  //           onPressed: () {
  //             DefensivosRepository().carregaDados('classeAgronomica', '');
  //             Navigator.of(context).pushNamed('/defensivos/listar');
  //           },
  //           child: const Text(
  //             'Classe Agronomica',
  //             style: TextStyle(color: Colors.black),
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
  //         child: TextButton(
  //           style: ButtonStyle(
  //             backgroundColor: WidgetStateProperty.all(Colors.transparent),
  //             foregroundColor: WidgetStateProperty.all(Colors.green),
  //           ),
  //           onPressed: () {
  //             DefensivosRepository().carregaDados('ingredienteAtivo', '');
  //             Navigator.of(context).pushNamed('/defensivos/listar');
  //           },
  //           child: const Text(
  //             'Ingrediente Ativo',
  //             style: TextStyle(color: Colors.black),
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
  //         child: TextButton(
  //           style: ButtonStyle(
  //             backgroundColor: WidgetStateProperty.all(Colors.transparent),
  //             foregroundColor: WidgetStateProperty.all(Colors.green),
  //           ),
  //           onPressed: () {
  //             DefensivosRepository().carregaDados('modoAcao', '');
  //             Navigator.of(context).pushNamed('/defensivos/listar');
  //           },
  //           child: const Text(
  //             'Modo de Ação',
  //             style: TextStyle(color: Colors.black),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _todosOsDefensivos() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          setState(() {
            search = '';
          });
          DefensivosRepository().todosOsDefensivos();
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.green,
          backgroundColor: Colors.transparent,
        ),
        child: const Text('Todos os Defensivos'),
      ),
    );
  }

  Widget _rowPesquisar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.shouldUseColumnLayout) {
          // Layout para telas menores (smartphones)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSearchField(constraints),
              SizedBox(
                  height: context.responsiveSpacing(type: SpacingType.small)),
              _buildSearchButton(),
            ],
          );
        } else {
          // Layout para telas maiores (tablets, desktops)
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchField(constraints),
              SizedBox(
                  width: context.responsiveSpacing(type: SpacingType.small)),
              _buildSearchButton(),
            ],
          );
        }
      },
    );
  }

  Widget _buildSearchField(BoxConstraints constraints) {
    return LayoutBuilder(
      builder: (context, _) {
        final maxWidth = context.isMobile ? constraints.maxWidth : 600.0;

        return SizedBox(
          width: maxWidth,
          child: Padding(
            padding: context.responsivePadding(type: PaddingType.small),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Digite o nome do defensivo, ingrediente ativo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton() {
    return LayoutBuilder(
      builder: (context, _) {
        return Padding(
          padding: context.responsivePadding(type: PaddingType.small),
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                buscarDefensivos();
              },
              child: const Text('Pesquisar'),
            ),
          ),
        );
      },
    );
  }

  // Widget _cardBotoesCategorias() {
  //   return Card(
  //     child: Container(
  //       padding: const EdgeInsets.all(8.0),
  //       width: double.infinity,
  //       child: Column(
  //         children: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               TextButtonTopIcon(
  //                 iconText: DefensivosRepository()
  //                     .homePage
  //                     .value
  //                     .fabricantes
  //                     .toString(),
  //                 title: 'Fabricantes',
  //                 width: MediaQuery.of(context).size.width / 2.3,
  //                 onPress: () {
  //                   DefensivosRepository().carregaDados('fabricantes', '');
  //                   Navigator.pushNamed(context, '/defensivos/listar');
  //                 },
  //               ),
  //               TextButtonTopIcon(
  //                 iconText: DefensivosRepository()
  //                     .homePage
  //                     .value
  //                     .classeAgronomica
  //                     .toString(),
  //                 title: 'Classe Agronomica',
  //                 width: MediaQuery.of(context).size.width / 2.3,
  //                 onPress: () {
  //                   DefensivosRepository().carregaDados('classeAgronomica', '');
  //                   Navigator.of(context).pushNamed('/defensivos/listar');
  //                 },
  //               ),
  //             ],
  //           ),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               TextButtonTopIcon(
  //                 iconText: DefensivosRepository()
  //                     .homePage
  //                     .value
  //                     .ingredienteAtivo
  //                     .toString(),
  //                 title: 'Ingrediente Ativo',
  //                 width: MediaQuery.of(context).size.width / 2.3,
  //                 onPress: () {
  //                   DefensivosRepository().carregaDados('ingredienteAtivo', '');
  //                   Navigator.of(context).pushNamed('/defensivos/listar');
  //                 },
  //               ),
  //               TextButtonTopIcon(
  //                 iconText:
  //                     DefensivosRepository().homePage.value.modoAcao.toString(),
  //                 title: 'Modo de Ação',
  //                 width: MediaQuery.of(context).size.width / 2.3,
  //                 onPress: () {
  //                   DefensivosRepository().carregaDados('modoAcao', '');
  //                   Navigator.of(context).pushNamed('/defensivos/listar');
  //                 },
  //               ),
  //             ],
  //           ),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               TextButtonTopIcon(
  //                 iconText: DefensivosRepository()
  //                     .homePage
  //                     .value
  //                     .defensivos
  //                     .toString(),
  //                 title: 'Defensivos',
  //                 width: MediaQuery.of(context).size.width / 1.12,
  //                 onPress: () {
  //                   DefensivosRepository().carregaDados('defensivos', '');
  //                   Navigator.of(context).pushNamed('/defensivos/listar');
  //                 },
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _menuPromo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.shouldUseColumnLayout) {
          return _buildColumnLayout();
        } else {
          return _buildRowLayout();
        }
      },
    );
  }

  Widget _buildColumnLayout() {
    return LayoutBuilder(
      builder: (context, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogo(),
            SizedBox(
                height: context.responsiveSpacing(type: SpacingType.normal)),
            Text(
              'ReceituAgro: Seu app Agro',
              style: TextStyle(
                fontSize:
                    context.responsiveFontSize(type: FontSizeType.heading),
              ),
            ),
            Text(
              'Agricultura do seu dia a dia',
              style: TextStyle(
                fontSize: context.responsiveFontSize(type: FontSizeType.body),
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(
                height: context.responsiveSpacing(type: SpacingType.large)),
            _buildDownloadButtons(),
          ],
        );
      },
    );
  }

  Widget _buildRowLayout() {
    return LayoutBuilder(
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogo(),
            SizedBox(
                width: context.responsiveSpacing(type: SpacingType.normal)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height:
                        context.responsiveSpacing(type: SpacingType.normal)),
                Text(
                  'ReceituAgro: Seu app Agro',
                  style: TextStyle(
                    fontSize:
                        context.responsiveFontSize(type: FontSizeType.heading),
                  ),
                ),
                Text(
                  'Agricultura do seu dia a dia',
                  style: TextStyle(
                    fontSize:
                        context.responsiveFontSize(type: FontSizeType.body),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(
                    height: context.responsiveSpacing(type: SpacingType.large)),
                _buildDownloadButtons(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return LayoutBuilder(
      builder: (context, _) {
        final logoSize = context.isMobile ? 100.0 : 130.0;

        return Padding(
          padding: context.responsivePadding(type: PaddingType.container),
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('lib/assets/receituagro_logo.webp'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadButtons() {
    return LayoutBuilder(
      builder: (context, _) {
        final buttonWidth = context.isMobile ? 120.0 : 140.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Image.asset(
                  'lib/assets/download_play_store.png',
                  width: buttonWidth,
                ),
                onTap: () async {
                  Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=br.com.agrimind.pragassoja');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                    await GAnalyticsService.logCustomEvent(
                      'button_click',
                      parameters: {
                        'button_name': 'download_play_store',
                      },
                    );
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ),
            SizedBox(
                width: context.responsiveSpacing(type: SpacingType.normal)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Image.asset(
                  'lib/assets/download_app_store.png',
                  width: buttonWidth,
                ),
                onTap: () async {
                  Uri url = Uri.parse(
                      'https://apps.apple.com/br/app/receituagro-seu-app-agro/id967785485?platform=iphone');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                    await GAnalyticsService.logCustomEvent(
                      'button_click',
                      parameters: {
                        'button_name': 'download_app_store',
                      },
                    );
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget separado para grid de defensivos - otimizado para rebuilds
class _DefensivosGrid extends StatelessWidget {
  const _DefensivosGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final repository = DefensivosRepository();

      // Usar ResponsiveHelper para obter crossAxisCount
      final crossAxisCount = context.crossAxisCount(type: GridType.card);
      final mainAxisSpacing =
          context.responsiveSpacing(type: SpacingType.small);
      final crossAxisSpacing =
          context.responsiveSpacing(type: SpacingType.small) / 2;

      return MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: repository.isLoading.value
            ? 12
            : repository.defensivosOnScreen.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        itemBuilder: (context, index) {
          Map item = {};

          if (!repository.isLoading.value) {
            item = repository.defensivosOnScreen[index];
          }

          return _DefensivoCard(
            item: item,
            isLoading: repository.isLoading.value,
          );
        },
      );
    });
  }
}

/// Widget separado para card de defensivo - const para melhor performance
class _DefensivoCard extends StatelessWidget {
  final Map item;
  final bool isLoading;

  const _DefensivoCard({
    required this.item,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      enableSwitchAnimation: true,
      child: Padding(
        padding: context.responsivePadding(type: PaddingType.small),
        child: Card(
          elevation: 1,
          child: Padding(
            padding: context.responsivePadding(type: PaddingType.container),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nomecomum'] ?? 'Nome do defensivo',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize:
                        context.responsiveFontSize(type: FontSizeType.title),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height: context.responsiveSpacing(type: SpacingType.small)),
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 16,
                    ),
                    SizedBox(
                        width:
                            context.responsiveSpacing(type: SpacingType.small) /
                                2),
                    Expanded(
                      child: Text(
                        item['fabricante'] ?? 'Nome do Fabricante',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                              type: FontSizeType.body),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height:
                        context.responsiveSpacing(type: SpacingType.normal)),
                Row(
                  children: [
                    const Icon(
                      Icons.local_drink,
                      size: 16,
                    ),
                    SizedBox(
                        width:
                            context.responsiveSpacing(type: SpacingType.small) /
                                2),
                    Expanded(
                      child: Text(
                        item['ingredienteativo'] ?? 'Nome do Ingrediente Ativo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                              type: FontSizeType.body),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height:
                        context.responsiveSpacing(type: SpacingType.normal)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/defensivo',
                        arguments: {
                          'id': item['id'],
                        },
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text('Mais Detalhes ->'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget separado para total de registros
class _TotalRegistros extends StatelessWidget {
  const _TotalRegistros();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Text(
        'Total de registros: ${DefensivosRepository().filteredDefensivos.length}',
        style: const TextStyle(fontSize: 16),
      );
    });
  }
}
