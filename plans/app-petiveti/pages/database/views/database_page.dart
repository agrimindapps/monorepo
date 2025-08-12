// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import '../controllers/database_controller.dart';
import '../utils/database_helpers.dart';
import 'widgets/box_selector_widget.dart';
import 'widgets/data_table_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/search_bar_widget.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  late final DatabaseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DatabaseController();
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
          appBar: const PageHeaderWidget(
            title: 'Banco de Dados',
            icon: Icons.storage,
            showBackButton: true,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return DatabaseHelpers.buildLoadingIndicator();
    }

    if (_controller.hasError) {
      return DatabaseHelpers.buildErrorWidget(
        _controller.errorMessage!,
        _controller.refreshData,
      );
    }

    return Padding(
      padding: DatabaseHelpers.getDefaultPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxSelectorWidget(controller: _controller),
          const SizedBox(height: 12),
          if (_controller.hasSelectedBox && _controller.hasData) ...[
            SearchBarWidget(controller: _controller),
          ],
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Show empty state if no box selected, no data, or no search results
    if (!_controller.hasSelectedBox || 
        _controller.isEmpty || 
        (_controller.isFiltered && _controller.filteredRecords == 0)) {
      return DatabaseEmptyStateWidget(controller: _controller);
    }

    // Show data table
    return DataTableWidget(controller: _controller);
  }
}
