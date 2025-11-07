import 'package:flutter/material.dart';

import '../interfaces/i_connectivity_service.dart';
import 'connectivity_indicator.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';

/// Enhanced scaffold with built-in connectivity and sync indicators
/// Provides consistent UX patterns across all pages
class EnhancedAppScaffold extends StatelessWidget {
  const EnhancedAppScaffold({
    super.key,
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
    this.connectivityService,
    this.showConnectivityBanner = true,
    this.showSyncStatus = true,
    this.showFloatingSyncIndicator = false,
    this.onSyncTap,
  });
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
  final IConnectivityService? connectivityService;
  final bool showConnectivityBanner;
  final bool showSyncStatus;
  final bool showFloatingSyncIndicator;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    final Widget scaffoldBody = body;

    final Widget scaffold = Scaffold(
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
  const EnhancedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.connectivityService,
    this.showSyncIndicator = true,
    this.showConnectivityIndicator = true,
    this.onSyncTap,
  });
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final IConnectivityService? connectivityService;
  final bool showSyncIndicator;
  final bool showConnectivityIndicator;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    final enhancedActions = <Widget>[
      if (showConnectivityIndicator && connectivityService != null)
        ConnectivityIndicator(
          connectivityService: connectivityService!,
          margin: const EdgeInsets.only(right: 8.0),
        ),
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
  const EnhancedPageWrapper({
    super.key,
    required this.child,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyWidget,
    this.connectivityService,
  });
  final Widget child;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget? emptyWidget;
  final IConnectivityService? connectivityService;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return ErrorStateWidget.dataLoading(
        onRetry: onRetry,
        customMessage: errorMessage,
      );
    }
    if (isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    return child;
  }
}

/// Enhanced list widget with offline indicators
class EnhancedListView<T> extends StatelessWidget {
  const EnhancedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.isItemUnsynced,
    this.emptyWidget,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
  });
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final bool Function(T)? isItemUnsynced;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

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
        if (isUnsynced) {
          listItem = Stack(
            children: [
              listItem,
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
    required IConnectivityService connectivityService,
    required List<dynamic> expenses,
    required bool isLoading,
    String? errorMessage,
    VoidCallback? onRetry,
    VoidCallback? onAddExpense,
  }) {
    return EnhancedAppScaffold(
      connectivityService: connectivityService,
      appBar: EnhancedAppBar(
        title: 'Expenses',
        connectivityService: connectivityService,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: onAddExpense),
        ],
      ),
      body: EnhancedPageWrapper(
        isLoading: isLoading,
        errorMessage: errorMessage,
        onRetry: onRetry,
        isEmpty: expenses.isEmpty,
        emptyWidget: EmptyStateWidget.expenses(onAddExpense: onAddExpense),
        connectivityService: connectivityService,
        child: EnhancedListView(
          items: expenses,
          itemBuilder: (context, expense, index) {
            return ListTile(title: Text('Expense ${expense.toString()}'));
          },
          isItemUnsynced: (expense) {
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
