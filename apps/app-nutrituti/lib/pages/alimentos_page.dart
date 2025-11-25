// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import '../repository/alimentos_provider.dart';

class AlimentosPage extends ConsumerStatefulWidget {
  const AlimentosPage({
    super.key,
    required this.categoria,
    this.onlyFavorites = false,
  });

  final String categoria;
  final bool onlyFavorites;

  @override
  ConsumerState<AlimentosPage> createState() => AlimentosPageState();
}

class AlimentosPageState extends ConsumerState<AlimentosPage> {
  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _pesquisaController = TextEditingController();

  List<dynamic> _listaAlimentosSearch = [];
  Map<String, dynamic> _selectItem = {};
  Map<String, dynamic> _backupSelectItem = {};

  double sliderValue = 100.0;

  @override
  void initState() {
    super.initState();
    _pesquisaController.addListener(pesquisar);
  }

  String _formatValue(dynamic value) {
    try {
      return value.toString().replaceAll('.', ',').padLeft(2, '0');
    } catch (e) {
      return value.toString();
    }
  }

  List<dynamic> createSkeletonExample() {
    return List.generate(
      9,
      (index) => {
        'descricao': 'Alimento $index',
        'proteina_g': 0,
        'fibra_alimentar_g': 0,
        'carboidrato_g': 0,
        'energia_kcal': 0,
        'umidade': 0,
        'favorito': false,
      },
    );
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    _pesquisaController.removeListener(pesquisar);
    _pesquisaController.dispose();
    super.dispose();
  }

  void pesquisar() {
    final alimentosAsync = ref.read(alimentosProvider(widget.categoria));

    alimentosAsync.whenData((alimentos) {
      final String pesquisa = _pesquisaController.text;
      if (pesquisa.isEmpty) {
        _listaAlimentosSearch = alimentos;
      } else {
        _listaAlimentosSearch = alimentos
            .where((element) => element['descricao']
                .toString()
                .toLowerCase()
                .contains(pesquisa.toLowerCase()))
            .toList();
      }
      setState(() {});
    });
  }

  // void _sort(String key) {
  //   switch (key) {
  //     case 'alimento_a_to_z':
  //       _sortAlimentoAToZ();
  //       break;
  //     case 'alimento_z_to_a':
  //       _sortAlimentoZToA();
  //       break;
  //     default:
  //       _sortByKey(key);
  //       break;
  //   }
  //   setState(() {
  //     _listaAlimentosSearch;
  //   });
  // }

  // void _sortAlimentoAToZ() {
  //   _listaAlimentosSearch
  //       .sort((a, b) => a['descricao'].compareTo(b['descricao']));
  // }

  // void _sortAlimentoZToA() {
  //   _listaAlimentosSearch
  //       .sort((a, b) => b['descricao'].compareTo(a['descricao']));
  // }

  // void _sortByKey(String key) {
  //   _listaAlimentosSearch.sort((a, b) {
  //     try {
  //       return b[key].compareTo(a[key]);
  //     } catch (e) {
  //       return 0;
  //     }
  //   });
  // }

  void favorito(Map<String, dynamic> item, int index) async {
    final repository = ref.read(alimentosRepositoryProvider);
    item['favorito'] = await repository.setFavorito(item['IdReg'].toString());
    setState(() {});
  }

  void compartilhar(Map<String, dynamic> item) {
    final repository = ref.read(alimentosRepositoryProvider);
    repository.compartilhar(item, sliderValue);
  }

  void _calcularValores() {
    final listProperties = ref.read(alimentosPropertiesProvider);
    List<dynamic> t = listProperties;
    for (var i = 0; i < t.length; i++) {
      Map<String, dynamic> item = t[i] as Map<String, dynamic>;
      if (item['value'] == 'umidade') {
        continue;
      }

      try {
        final valueStr = _backupSelectItem[item['value'] as String]?.toString() ?? '0';
        double value = double.parse(valueStr);
        _selectItem[item['value'] as String] =
            ((value * sliderValue) / 100).toStringAsFixed(2);
      } catch (e) {
        // Sem ação
      }
    }
    debugPrint('_selectItem: $_selectItem');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final alimentosAsync = ref.watch(alimentosProvider(widget.categoria));
    final listProperties = ref.watch(alimentosPropertiesProvider);

    // Initialize search list when data loads
    ref.listen(alimentosProvider(widget.categoria), (previous, next) {
      next.whenData((alimentos) {
        if (_listaAlimentosSearch.isEmpty || previous?.value != next.value) {
          _listaAlimentosSearch = alimentos;
          setState(() {});
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentos'),
      ),
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 1020,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Row(
                          children: [
                            // IconButton(
                            //   icon: const Icon(Icons.arrow_back),
                            //   onPressed: () {
                            //     Navigator.pop(context);
                            //   },
                            // ),
                            Text(
                              widget.categoria != '0'
                                  ? widget.categoria
                                  : 'Favoritos',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                        child: TextField(
                          controller: _pesquisaController,
                          decoration: const InputDecoration(
                            hintText: 'Pesquisar alimento...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      alimentosAsync.when(
                        data: (alimentos) {
                          if (widget.onlyFavorites && _listaAlimentosSearch.isEmpty) {
                            return _cardSemFavoritos();
                          }
                          return _cardAlimentoGridView(listProperties);
                        },
                        loading: () => _cardAlimentoGridView(listProperties, isLoading: true),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Erro ao carregar alimentos: $error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ref.invalidate(alimentosProvider(widget.categoria));
                                },
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ), // Fechamento do SafeArea
    );
  }

  Widget _cardAlimentoGridView(List<dynamic> listProperties, {bool isLoading = false}) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    final displayList = isLoading ? createSkeletonExample() : _listaAlimentosSearch;

    return Skeletonizer(
      enabled: isLoading,
      enableSwitchAnimation: true,
      child: StaggeredGrid.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          for (var i = 0; i < displayList.length; i++)
            Builder(
              builder: (context) {
                final item = displayList[i];
                return StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${item['descricao']} (100 Gr)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // GestureDetector(
                            //   child: Icon(
                            //     item['favorito']
                            //         ? Icons.favorite
                            //         : Icons.favorite_border,
                            //     color: Colors.grey,
                            //   ),
                            //   onTap: () => favorito(item, i),
                            // ),
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            const SizedBox(height: 10),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2,
                              ),
                              itemCount: 6,
                              itemBuilder: (context, j) {
                                final property = listProperties[j] as Map<String, dynamic>;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        '${_formatValue(item[property['value']])} ${property['med']}'),
                                    Text('${property['text']} ',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  child: const Text('Mais detalhes >>'),
                                  onTap: () {
                                    // clonar item perdendo a referência
                                    final itemMap = item as Map<String, dynamic>;
                                    _selectItem = Map<String, dynamic>.from(itemMap);
                                    _backupSelectItem = Map<String, dynamic>.from(itemMap);
                                    dialogCalculo(context);
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void dialogCalculo(BuildContext context2) {
    final listProperties = ref.read(alimentosPropertiesProvider);

    showDialog<void>(
      context: context2,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: StatefulBuilder(
            builder: ((context, setState) {
              return SizedBox(
                width: 400,
                child: Card(
                  elevation: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: 280,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: Text(
                                '${_selectItem['descricao']} (${sliderValue.toStringAsFixed(0)} Gr)',
                                style: const TextStyle(fontSize: 16),
                                maxLines: 2,
                              ),
                            ),
                          ),
                          // GestureDetector(
                          //   child: Icon(Icons.share_rounded,
                          //       color: Theme.of(context).dividerColor),
                          //   onTap: () => compartilhar(_selectItem),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 460,
                        child: SingleChildScrollView(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2,
                            ),
                            itemCount: listProperties.length,
                            itemBuilder: (context, i) {
                              final property = listProperties[i] as Map<String, dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (i < 9)
                                    Text(
                                        '${_formatValue(_selectItem[property['value']])} ${property['med']}')
                                  else
                                    // Premium content locked - TODO: Implement premium check
                                    GestureDetector(
                                      onTap: () {
                                        showDialog<void>(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: const Text('Recursos Avançados'),
                                            content: const Text(
                                                'Para aproveitar este recurso, pedimos apenas um momento do seu tempo para assistir a um breve anúncio. Saiba mais em opções.'),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext).pop();
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context2)
                                                      .pushNamed('/config/premium');
                                                },
                                                child: const Text('Acessar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.lock, color: Colors.grey),
                                    ),
                                  Text('${property['text']} ',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Slider(
                        activeColor: Colors.blueGrey.shade700,
                        inactiveColor: Colors.blueGrey.shade200,
                        value: sliderValue,
                        onChanged: (newValue) {
                          setState(() {
                            sliderValue = newValue;
                            _calcularValores();
                          });
                        },
                        min: 100,
                        max: 1000.0,
                        divisions: 18,
                        label: '$sliderValue',
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                onPressed: () {
                  sliderValue = 100.0;
                  Navigator.of(context).pop();
                },
                child: const Text('Fechar'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cardSemFavoritos() {
    return Center(
      child: Image.asset(
        'lib/core/assets/semfavoritos.png',
        width: 200,
      ),
    );
  }

  // Widget _menuFilter() {
  //   return PopupMenuButton<String>(
  //     icon: const Icon(Icons.sort_by_alpha),
  //     iconColor: Colors.white,
  //     onSelected: (value) {
  //       _sort(value);
  //     },
  //     itemBuilder: (BuildContext context) {
  //       return <PopupMenuEntry<String>>[
  //         const PopupMenuItem<String>(
  //           value: 'alimento_a_to_z',
  //           child: Text('Alimentos (A-Z)'),
  //         ),
  //         const PopupMenuItem<String>(
  //           value: 'alimento_z_to_a',
  //           child: Text('Alimentos (Z-A)'),
  //         ),
  //         const PopupMenuItem<String>(
  //           value: 'proteina_g',
  //           child: Text('Proteinas'),
  //         ),
  //         const PopupMenuItem<String>(
  //           value: 'fibra_alimentar_g',
  //           child: Text('Fibra Alimentar'),
  //         ),
  //         const PopupMenuItem<String>(
  //           value: 'carboidrato_g',
  //           child: Text('Carboidratos'),
  //         ),
  //         const PopupMenuItem<String>(
  //           value: 'energia_kcal',
  //           child: Text('Calorias'),
  //         ),
  //       ];
  //     },
  //   );
  // }
}
