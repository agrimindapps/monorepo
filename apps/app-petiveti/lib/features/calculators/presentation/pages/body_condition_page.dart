import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/body_condition_provider.dart';
import '../widgets/bcs_guide_sheet.dart';
import '../widgets/body_condition_history_panel.dart';
import '../widgets/body_condition_input_form.dart';
import '../widgets/body_condition_menu_handler.dart';
import '../widgets/body_condition_result_card.dart';
import '../widgets/body_condition_state_indicator.dart';
import '../widgets/body_condition_tab_controller.dart';
import '../../../../shared/constants/body_condition_constants.dart';

/// Refactored Body Condition Calculator page following Clean Architecture
/// 
/// Responsibilities:
/// - Page layout and structure
/// - Coordinate between specialized handlers
/// - Manage widget lifecycle
/// - Separate concerns properly
class BodyConditionPage extends ConsumerStatefulWidget {
  const BodyConditionPage({super.key});

  @override
  ConsumerState<BodyConditionPage> createState() => _BodyConditionPageState();
}

class _BodyConditionPageState extends ConsumerState<BodyConditionPage>
    with SingleTickerProviderStateMixin {
  
  // Specialized handlers for different concerns
  late TabController _tabController;
  late BodyConditionTabController _tabHandler;
  late BodyConditionMenuHandler _menuHandler;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    // Initialize tab controller
    _tabController = TabController(length: BodyConditionConstants.tabCount, vsync: this);
    
    // Initialize tab handler
    _tabHandler = BodyConditionTabController(
      tabController: _tabController,
      ref: ref,
    );
    
    // Initialize menu handler
    _menuHandler = BodyConditionMenuHandler(
      context: context,
      ref: ref,
      tabController: _tabHandler,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabHandler.dispose();
    _menuHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyConditionProvider);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const BodyConditionStateIndicator(),
          Expanded(
            child: _tabHandler.getTabBarView(
              inputTab: _buildInputTab(),
              resultTab: _buildResultTab(),
              historyTab: _buildHistoryTab(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(state),
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(BodyConditionConstants.appBarTitle),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(BodyConditionIcons.backIcon),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(BodyConditionIcons.helpIcon),
          onPressed: _showBcsGuide,
          tooltip: BodyConditionConstants.helpTooltip,
        ),
        PopupMenuButton<String>(
          onSelected: _menuHandler.handleMenuAction,
          itemBuilder: (context) => _menuHandler.getMenuItems(),
        ),
      ],
      bottom: _tabHandler.getTabBar(),
    );
  }

  /// Build the input tab
  Widget _buildInputTab() {
    return const SingleChildScrollView(
      padding: BodyConditionConstants.tabPadding,
      child: BodyConditionInputForm(),
    );
  }

  /// Build the result tab
  Widget _buildResultTab() {
    return Consumer(
      builder: (context, ref, child) {
        final output = ref.watch(bodyConditionOutputProvider);
        
        if (output == null) {
          return _buildEmptyResultState();
        }

        return SingleChildScrollView(
          padding: BodyConditionConstants.tabPadding,
          child: BodyConditionResultCard(result: output),
        );
      },
    );
  }

  /// Build the history tab
  Widget _buildHistoryTab() {
    return Consumer(
      builder: (context, ref, child) {
        final history = ref.watch(bodyConditionHistoryProvider);
        
        if (history.isEmpty) {
          return _buildEmptyHistoryState();
        }

        return BodyConditionHistoryPanel(history: history);
      },
    );
  }

  /// Build empty result state
  Widget _buildEmptyResultState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            BodyConditionIcons.emptyResultIcon, 
            size: BodyConditionConstants.emptyStateIconSize, 
            color: BodyConditionConstants.emptyStateIconColor
          ),
          SizedBox(height: BodyConditionConstants.emptyStateIconSpacing),
          Text(
            BodyConditionConstants.emptyResultTitle,
            style: TextStyle(
              fontSize: BodyConditionConstants.emptyStateTitleFontSize, 
              fontWeight: BodyConditionConstants.emptyStateTitleWeight
            ),
          ),
          SizedBox(height: BodyConditionConstants.emptyStateTitleSpacing),
          Text(
            BodyConditionConstants.emptyResultDescription,
            textAlign: BodyConditionTextAlign.centerAlign,
            style: TextStyle(color: BodyConditionConstants.emptyStateDescriptionColor),
          ),
        ],
      ),
    );
  }

  /// Build empty history state
  Widget _buildEmptyHistoryState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            BodyConditionIcons.emptyHistoryIcon, 
            size: BodyConditionConstants.emptyStateIconSize, 
            color: BodyConditionConstants.emptyStateIconColor
          ),
          SizedBox(height: BodyConditionConstants.emptyStateIconSpacing),
          Text(
            BodyConditionConstants.emptyHistoryTitle,
            style: TextStyle(
              fontSize: BodyConditionConstants.emptyStateTitleFontSize, 
              fontWeight: BodyConditionConstants.emptyStateTitleWeight
            ),
          ),
          SizedBox(height: BodyConditionConstants.emptyStateTitleSpacing),
          Text(
            BodyConditionConstants.emptyHistoryDescription,
            style: TextStyle(color: BodyConditionConstants.emptyStateDescriptionColor),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget? _buildFloatingActionButton(dynamic state) {
    // Show FAB only on input tab
    if (!_tabHandler.isInputTab) return null;

    return FloatingActionButton.extended(
      onPressed: state.canCalculate
          ? () {
              ref.read(bodyConditionProvider.notifier).calculate();
              _tabHandler.calculateAndNavigateToResult();
            }
          : null,
      backgroundColor: state.canCalculate ? null : BodyConditionColors.fabDisabled,
      icon: state.isLoading
          ? const SizedBox(
              width: BodyConditionConstants.fabLoadingIndicatorSize,
              height: BodyConditionConstants.fabLoadingIndicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: BodyConditionConstants.fabLoadingStrokeWidth,
                color: BodyConditionConstants.fabLoadingColor,
              ),
            )
          : const Icon(BodyConditionIcons.calculateIcon),
      label: Text(state.isLoading 
          ? BodyConditionConstants.calculatingButtonText 
          : BodyConditionConstants.calculateButtonText),
    );
  }

  /// Show BCS guide sheet
  void _showBcsGuide() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: BodyConditionLayout.isScrollControlled,
      backgroundColor: BodyConditionColors.modalBackground,
      builder: (context) => const BcsGuideSheet(),
    );
  }
}