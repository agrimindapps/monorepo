// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/lista_medicamento_controller.dart';
import '../utils/medicamento_lista_constants.dart';
import '../utils/medicamento_lista_helpers.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/medicamento_app_bar_widget.dart';
import 'widgets/medicamento_card_widget.dart';
import 'widgets/medicamento_filter_chips_widget.dart';
import 'widgets/medicamento_grid_item_widget.dart';
import 'widgets/medicamento_search_bar_widget.dart';

class ListaMedicamentoPage extends StatefulWidget {
  const ListaMedicamentoPage({super.key});

  @override
  State<ListaMedicamentoPage> createState() => _ListaMedicamentoPageState();
}

class _ListaMedicamentoPageState extends State<ListaMedicamentoPage> {
  late final ListaMedicamentoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ListaMedicamentoController();
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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1120,
                  child: Column(
                    children: [
                      MedicamentoAppBarWidget(controller: _controller),
                      MedicamentoSearchBarWidget(controller: _controller),
                      MedicamentoFilterChipsWidget(controller: _controller),
                      _buildResultsHeader(),
                      _buildMedicamentosList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _controller.navigateToAdicionar(context),
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            MedicamentoListaHelpers.formatResultCount(
              _controller.filteredMedicamentos.length,
            ),
            style: MedicamentoListaHelpers.getResultCountTextStyle(),
          ),
          IconButton(
            icon: Icon(
              _controller.isGridView ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: _controller.toggleViewMode,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentosList() {
    final medicamentos = _controller.filteredMedicamentos;

    return SizedBox(
      height: MedicamentoListaHelpers.getListHeight(context),
      child: medicamentos.isEmpty
          ? const EmptyStateWidget()
          : AnimatedSwitcher(
              duration: MedicamentoListaConstants.animationDuration,
              child: _controller.isGridView
                  ? _buildGridView(medicamentos)
                  : _buildListView(medicamentos),
            ),
    );
  }

  Widget _buildGridView(medicamentos) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MedicamentoListaConstants.gridCrossAxisCount,
        childAspectRatio: MedicamentoListaConstants.gridChildAspectRatio,
        crossAxisSpacing: MedicamentoListaConstants.gridCrossAxisSpacing,
        mainAxisSpacing: MedicamentoListaConstants.gridMainAxisSpacing,
      ),
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        return MedicamentoGridItemWidget(
          medicamento: medicamentos[index],
          controller: _controller,
        );
      },
    );
  }

  Widget _buildListView(medicamentos) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        return MedicamentoCardWidget(
          medicamento: medicamentos[index],
          controller: _controller,
        );
      },
    );
  }
}
