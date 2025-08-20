// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/racas_lista_controller.dart';
import '../utils/racas_lista_constants.dart';
import 'widgets/compare_fab_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/especie_header_widget.dart';
import 'widgets/filter_modal_widget.dart';
import 'widgets/quick_filters_widget.dart';
import 'widgets/raca_card_widget.dart';
import 'widgets/raca_grid_item_widget.dart';
import 'widgets/raca_search_bar_widget.dart';
import 'widgets/racas_app_bar_widget.dart';

class RacasListaPage extends StatefulWidget {
  const RacasListaPage({super.key});

  @override
  State<RacasListaPage> createState() => _RacasListaPageState();
}

class _RacasListaPageState extends State<RacasListaPage> {
  late final RacasListaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RacasListaController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _controller.inicializarEspecie(args);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: RacasAppBarWidget(
            controller: _controller,
            especie: _controller.especieAtual,
            onFilterPressed: () => _showFilterModal(context),
          ),
          body: Column(
            children: [
              if (_controller.especieAtual != null)
                EspecieHeaderWidget(
                  especie: _controller.especieAtual!,
                  totalRacasFiltradas: _controller.racasFiltradas.length,
                ),
              RacaSearchBarWidget(controller: _controller),
              QuickFiltersWidget(controller: _controller),
              Expanded(
                child: _buildRacasList(),
              ),
            ],
          ),
          floatingActionButton: CompareFabWidget(controller: _controller),
        );
      },
    );
  }

  Widget _buildRacasList() {
    final racasFiltradas = _controller.racasFiltradas;

    if (racasFiltradas.isEmpty) {
      return EmptyStateWidget(controller: _controller);
    }

    return AnimatedSwitcher(
      duration: RacasListaConstants.animationDuration,
      child: _controller.isGridView
          ? _buildGridView(racasFiltradas)
          : _buildListView(racasFiltradas),
    );
  }

  Widget _buildGridView(List racasFiltradas) {
    return GridView.builder(
      key: const ValueKey<String>('grid_view'),
      padding: RacasListaConstants.gridPadding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: RacasListaConstants.gridCrossAxisCount,
        childAspectRatio: RacasListaConstants.gridChildAspectRatio,
        crossAxisSpacing: RacasListaConstants.gridSpacing,
        mainAxisSpacing: RacasListaConstants.gridSpacing,
      ),
      itemCount: racasFiltradas.length,
      itemBuilder: (context, index) {
        return RacaGridItemWidget(
          raca: racasFiltradas[index],
          controller: _controller,
        );
      },
    );
  }

  Widget _buildListView(List racasFiltradas) {
    return ListView.builder(
      key: const ValueKey<String>('list_view'),
      padding: RacasListaConstants.listPadding,
      itemCount: racasFiltradas.length,
      itemBuilder: (context, index) {
        return RacaCardWidget(
          raca: racasFiltradas[index],
          controller: _controller,
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: RacasListaConstants.modalBorderRadius,
      ),
      builder: (context) => FilterModalWidget(controller: _controller),
    );
  }
}
