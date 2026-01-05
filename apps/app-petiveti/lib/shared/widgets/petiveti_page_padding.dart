import 'package:flutter/material.dart';

/// Standard padding wrapper for Petiveti pages
/// 
/// Ensures consistent 8px horizontal padding across all pages.
/// Use this to wrap the main content of pages (after SafeArea).
/// 
/// Example:
/// ```dart
/// Scaffold(
///   body: SafeArea(
///     child: Column(
///       children: [
///         PetivetiPagePadding(child: YourHeader()),
///         Expanded(child: YourContent()),
///       ],
///     ),
///   ),
/// )
/// ```
class PetivetiPagePadding extends StatelessWidget {
  const PetivetiPagePadding({
    super.key,
    required this.child,
    this.horizontal = 8.0,
    this.vertical = 8.0,
    this.top,
    this.bottom,
  });

  final Widget child;
  final double horizontal;
  final double vertical;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        top ?? vertical,
        horizontal,
        bottom ?? vertical,
      ),
      child: child,
    );
  }
}

/// Padding wrapper specifically for page headers
/// Uses 8px padding on all sides by default
class PetivetiHeaderPadding extends StatelessWidget {
  const PetivetiHeaderPadding({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PetivetiPagePadding(
      horizontal: 8.0,
      vertical: 8.0,
      child: child,
    );
  }
}

/// Padding wrapper for content sections
/// Uses 8px horizontal padding with customizable vertical
class PetivetiContentPadding extends StatelessWidget {
  const PetivetiContentPadding({
    super.key,
    required this.child,
    this.vertical = 8.0,
  });

  final Widget child;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return PetivetiPagePadding(
      horizontal: 8.0,
      vertical: vertical,
      child: child,
    );
  }
}
