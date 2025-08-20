// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/atualizacoes_controller.dart';
import '../utils/atualizacoes_constants.dart';
import '../utils/atualizacoes_helpers.dart';
import 'widgets/atualizacoes_list_widget.dart';
import 'widgets/empty_atualizacoes_widget.dart';
import 'widgets/search_filter_widget.dart';
import 'widgets/version_header_widget.dart';

class AtualizacoesPage extends StatefulWidget {
  const AtualizacoesPage({super.key});

  @override
  State<AtualizacoesPage> createState() => _AtualizacoesPageState();
}

class _AtualizacoesPageState extends State<AtualizacoesPage> {
  late final AtualizacoesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtualizacoesController();
    _controller.initialize();
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
          backgroundColor: AtualizacoesHelpers.getBackgroundColor(),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return AtualizacoesHelpers.buildLoadingIndicator();
    }

    if (_controller.hasError) {
      return AtualizacoesHelpers.buildErrorWidget(
        _controller.errorMessage!,
        _controller.refresh,
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: AtualizacoesHelpers.getResponsiveWidth(context),
          child: Padding(
            padding: AtualizacoesHelpers.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VersionHeaderWidget(controller: _controller),
                if (_controller.hasAtualizacoes) ...[
                  const SizedBox(height: 16),
                  SearchFilterWidget(controller: _controller),
                ],
                const SizedBox(height: 16),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isEmpty || 
        (_controller.isFiltered && _controller.filteredCount == 0)) {
      return EmptyAtualizacoesWidget(controller: _controller);
    }

    return Card(
      elevation: AtualizacoesConstants.cardElevation,
      color: AtualizacoesHelpers.getCardBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: AtualizacoesHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: AtualizacoesHelpers.getCardPadding(),
        child: AtualizacoesListWidget(controller: _controller),
      ),
    );
  }
}
