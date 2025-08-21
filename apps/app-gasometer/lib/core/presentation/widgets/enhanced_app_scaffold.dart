import 'package:flutter/material.dart';
import '../../interfaces/i_sync_service.dart';
import '../../interfaces/i_connectivity_service.dart';
import 'connectivity_indicator.dart';
import 'real_time_sync_status.dart';
import 'sync_status_indicator.dart';
import 'error_state_widget.dart';
import 'empty_state_widget.dart';

/// Enhanced scaffold with built-in connectivity and sync indicators
/// Provides consistent UX patterns across all pages
class EnhancedAppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  
  // Enhanced features
  final ISyncService? syncService;
  final IConnectivityService? connectivityService;
  final bool showConnectivityBanner;
  final bool showSyncStatus;
  final bool showFloatingSyncIndicator;
  final VoidCallback? onSyncTap;

  const EnhancedAppScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.syncService,
    this.connectivityService,
    this.showConnectivityBanner = true,
    this.showSyncStatus = true,
    this.showFloatingSyncIndicator = false,
    this.onSyncTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget scaffoldBody = body;

    // Wrap body with sync status if enabled
    if (showSyncStatus && syncService != null && connectivityService != null) {
      scaffoldBody = Stack(
        children: [
          body,
          if (showFloatingSyncIndicator)
            FloatingSyncIndicator(
              syncService: syncService!,
              onTap: onSyncTap,
            ),
          // Add real-time sync status at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RealTimeSyncStatus(
              syncService: syncService!,
              connectivityService: connectivityService!,
              onTap: onSyncTap,
            ),
          ),
        ],
      );
    }

    Widget scaffold = Scaffold(
      appBar: _buildEnhancedAppBar(),
      body: scaffoldBody,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );

    return scaffold;
  }

  PreferredSizeWidget? _buildEnhancedAppBar() {
    if (appBar == null) return null;

    // Add connectivity banner if enabled
    if (showConnectivityBanner && connectivityService != null) {
      return AppBarConnectivityIndicator(
        connectivityService: connectivityService!,
        appBar: appBar!,
      );
    }

    return appBar;
  }
}

/// Enhanced app bar with sync and connectivity indicators
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  
  // Enhanced features
  final ISyncService? syncService;
  final IConnectivityService? connectivityService;
  final bool showSyncIndicator;
  final bool showConnectivityIndicator;
  final VoidCallback? onSyncTap;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.syncService,
    this.connectivityService,
    this.showSyncIndicator = true,
    this.showConnectivityIndicator = true,
    this.onSyncTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enhancedActions = <Widget>[
      // Add connectivity indicator
      if (showConnectivityIndicator && connectivityService != null)
        ConnectivityIndicator(
          connectivityService: connectivityService!,
          margin: const EdgeInsets.only(right: 8.0),
        ),
      
      // Add sync indicator
      if (showSyncIndicator && syncService != null)
        SyncStatusIndicator(
          syncService: syncService!,
          onTap: onSyncTap,
          style: const SyncIndicatorStyle(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),
      
      // Add existing actions
      ...?actions,
    ];

    return AppBar(
      title: Text(title),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: enhancedActions.isNotEmpty ? enhancedActions : null,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Enhanced page wrapper with common patterns
class EnhancedPageWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget? emptyWidget;
  final ISyncService? syncService;
  final IConnectivityService? connectivityService;

  const EnhancedPageWrapper({
    Key? key,
    required this.child,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyWidget,
    this.syncService,
    this.connectivityService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error state
    if (errorMessage != null) {
      return ErrorStateWidget.dataLoading(
        onRetry: onRetry,
        customMessage: errorMessage,
      );
    }

    // Show empty state
    if (isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    // Show sync progress if syncing
    Widget body = child;
    if (syncService != null && connectivityService != null) {
      body = Stack(
        children: [
          child,
          SyncProgressIndicator(syncService: syncService!),
        ],
      );
    }

    return body;
  }
}

/// Enhanced list widget with offline indicators
class EnhancedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final bool Function(T)? isItemUnsynced;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const EnhancedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.isItemUnsynced,
    this.emptyWidget,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isUnsynced = isItemUnsynced?.call(item) ?? false;

        Widget listItem = itemBuilder(context, item, index);

        // Add unsynced indicator if needed
        if (isUnsynced) {
          listItem = Stack(
            children: [
              listItem,
              Positioned(
                top: 8.0,
                right: 8.0,
                child: UnsyncedItemIndicator(isUnsynced: true),
              ),
            ],
          );
        }

        return listItem;
      },
    );
  }
}

/// Example usage helper
class ExampleUsage {
  static Widget buildExpensesPage({
    required ISyncService syncService,
    required IConnectivityService connectivityService,
    required List<dynamic> expenses,
    required bool isLoading,
    String? errorMessage,
    VoidCallback? onRetry,
    VoidCallback? onAddExpense,
  }) {
    return EnhancedAppScaffold(
      syncService: syncService,
      connectivityService: connectivityService,
      appBar: EnhancedAppBar(
        title: 'Expenses',
        syncService: syncService,
        connectivityService: connectivityService,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddExpense,
          ),
        ],
      ),
      body: EnhancedPageWrapper(
        isLoading: isLoading,
        errorMessage: errorMessage,
        onRetry: onRetry,
        isEmpty: expenses.isEmpty,
        emptyWidget: EmptyStateWidget.expenses(
          onAddExpense: onAddExpense,
        ),
        syncService: syncService,
        connectivityService: connectivityService,
        child: EnhancedListView(
          items: expenses,
          itemBuilder: (context, expense, index) {
            // Return your expense list tile widget
            return ListTile(
              title: Text('Expense ${expense.toString()}'),
            );
          },
          isItemUnsynced: (expense) {
            // Return true if expense is not synced
            return false; // Replace with actual logic
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}