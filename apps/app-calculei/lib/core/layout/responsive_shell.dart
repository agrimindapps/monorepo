import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A responsive shell without navigation bar
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
    );
  }
}
