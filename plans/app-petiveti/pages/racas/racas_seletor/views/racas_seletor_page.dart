// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/racas_seletor_controller.dart';
import '../utils/racas_seletor_constants.dart';
import '../utils/racas_seletor_helpers.dart';
import 'widgets/especies_grid_widget.dart';
import 'widgets/racas_seletor_app_bar_widget.dart';

class RacasSeletorPage extends StatefulWidget {
  const RacasSeletorPage({super.key});

  @override
  State<RacasSeletorPage> createState() => _RacasSeletorPageState();
}

class _RacasSeletorPageState extends State<RacasSeletorPage> {
  late final RacasSeletorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RacasSeletorController();
    _controller.inicializar();
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
            child: Center(
              child: SizedBox(
                width: RacasSeletorConstants.maxWidth,
                child: Column(
                  children: [
                    RacasSeletorAppBarWidget(controller: _controller),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return RacasSeletorHelpers.buildLoadingIndicator();
    }

    if (_controller.hasError) {
      return RacasSeletorHelpers.buildErrorWidget(
        _controller.errorMessage!,
        _controller.recarregar,
      );
    }

    return EspeciesGridWidget(
      especies: _controller.especies,
      controller: _controller,
    );
  }
}
