import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firebase_analytics_service.dart';
import '../../widgets/appbar_widget.dart';
import '../../app-site/repository/defensivos_repository.dart';

class DefenivosListarPage extends StatefulWidget {
  const DefenivosListarPage({super.key});

  @override
  State<DefenivosListarPage> createState() => _DefenivosListarPageState();
}

class _DefenivosListarPageState extends State<DefenivosListarPage> {
  String search = '';

  @override
  void initState() {
    super.initState();
    testeSupabase();
  }

  void testeSupabase() async {
    await DefensivosRepository().fetchAllDefensivos();
  }

  void buscarDefensivos() {
    if (search.length < 3) {
      // snackbar
      Get.snackbar(
        'Pesquisa inválida',
        'Informe pelo menos 3 caracteres para realizar a busca',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        backgroundGradient: const LinearGradient(
          colors: [Colors.redAccent, Colors.red],
        ),
        dismissDirection: DismissDirection.horizontal,
        barBlur: 20,
        colorText: Colors.white,
        maxWidth: 300,
        margin: EdgeInsets.only(
          top: 15,
          left: MediaQuery.of(context).size.width - 320,
        ),
      );

      return;
    } else {
      DefensivosRepository().buscaDefensivos(search);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white.withOpacity(0.7), // Cor com transparência
        title: SizedBox(width: 1120, child: rowOpcoesMenuSuperior()),
      ),
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
                Divider(height: 1, thickness: 1, color: Colors.grey.shade400),
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
        Obx(() {
          // if (DefensivosRepository().isLoading.value) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }

          // if (DefensivosRepository().filteredDefensivos.isEmpty) {
          //   return const Center(
          //     child: Text('Nenhum defensivo encontrado'),
          //   );
          // }

          // Obtém a largura da tela
          final screenWidth = MediaQuery.of(context).size.width;

          // Define o crossAxisCount com base na largura da tela
          int crossAxisCount;
          if (screenWidth < 600) {
            crossAxisCount = 1; // Para smartphones
          } else if (screenWidth < 900) {
            crossAxisCount = 2; // Para tablets ou telas pequenas
          } else {
            crossAxisCount = 3; // Para telas médias
          }

          return MasonryGridView.builder(
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
            ),
            itemCount: DefensivosRepository().isLoading.value
                ? 12
                : DefensivosRepository().defensivosOnScreen.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 4,
            itemBuilder: (context, index) {
              Map item = {};

              if (!DefensivosRepository().isLoading.value) {
                item = DefensivosRepository().defensivosOnScreen[index];
              }

              return Skeletonizer(
                enabled: DefensivosRepository().isLoading.value,
                enableSwitchAnimation: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nomecomum'] ?? 'Nome do defensivo',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.business, size: 16),
                              const SizedBox(
                                width: 4, // Espaço entre o ícone e o texto
                              ),
                              Expanded(
                                child: Text(
                                  item['fabricante'] ?? 'Nome do Fabriante',
                                  maxLines: 1,
                                  overflow: TextOverflow
                                      .ellipsis, // Adiciona reticências se o texto for muito longo
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_drink, // Ícone de frasco
                                size: 16,
                              ),
                              const SizedBox(
                                width: 4, // Espaço entre o ícone e o texto
                              ),
                              Expanded(
                                child: Text(
                                  item['ingredienteativo'] ??
                                      'Nome do Ingrediente Ativo',
                                  maxLines: 1,
                                  overflow: TextOverflow
                                      .ellipsis, // Adiciona reticências se o texto for muito longo
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/defensivo',
                                  arguments: {'id': item['id']},
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                                backgroundColor: Colors.transparent,
                              ),
                              child: const Text('Mais Detalhes ->'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 15),
        _buttonsNavigation(),
        // total de registros
        Obx(() {
          return Text(
            'Total de registros: ${DefensivosRepository().filteredDefensivos.length}',
            style: const TextStyle(fontSize: 16),
          );
        }),
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
        if (constraints.maxWidth < 600) {
          // Layout para telas menores (smartphones)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildSearchField(constraints), _buildSearchButton()],
          );
        } else {
          // Layout para telas maiores (tablets, desktops)
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [_buildSearchField(constraints), _buildSearchButton()],
          );
        }
      },
    );
  }

  Widget _buildSearchField(BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth < 600 ? constraints.maxWidth : 600,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: SizedBox(
        height: 42, // Defina a altura desejada
        child: ElevatedButton(
          onPressed: () {
            buscarDefensivos();
          },
          child: const Text('Pesquisar'),
        ),
      ),
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
        if (constraints.maxWidth < 600) {
          return _buildColumnLayout();
        } else {
          return _buildRowLayout();
        }
      },
    );
  }

  Widget _buildColumnLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 20),
        const Text('ReceituAgro: Seu app Agro', style: TextStyle(fontSize: 24)),
        Text(
          'Agricultura do seu dia a dia',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),
        _buildDownloadButtons(),
      ],
    );
  }

  Widget _buildRowLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'ReceituAgro: Seu app Agro',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Agricultura do seu dia a dia',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            _buildDownloadButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 20, 4),
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('lib/assets/receituagro_logo.webp'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  Widget _buildDownloadButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Image.asset(
              'lib/assets/download_play_store.png',
              width: 140,
            ),
            onTap: () async {
              Uri url = Uri.parse(
                'https://play.google.com/store/apps/details?id=br.com.agrimind.pragassoja',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                await GAnalyticsService.logCustomEvent(
                  'button_click',
                  parameters: {'button_name': 'download_play_store'},
                );
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
            child: Image.asset('lib/assets/download_app_store.png', width: 140),
            onTap: () async {
              Uri url = Uri.parse(
                'https://apps.apple.com/br/app/receituagro-seu-app-agro/id967785485?platform=iphone',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                await GAnalyticsService.logCustomEvent(
                  'button_click',
                  parameters: {'button_name': 'download_app_store'},
                );
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
      ],
    );
  }
}
