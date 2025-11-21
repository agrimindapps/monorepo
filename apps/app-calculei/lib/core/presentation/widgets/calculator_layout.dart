import 'package:flutter/material.dart';

/// A reusable layout for calculator pages.
///
/// Adapts to screen size:
/// - Desktop (> 900px): Split view (Input Form | Result Card)
/// - Tablet/Mobile: Vertical scroll (Input Form -> Result Card)
class CalculatorLayout extends StatelessWidget {
  const CalculatorLayout({
    super.key,
    required this.title,
    required this.inputForm,
    required this.resultCard,
    this.actions,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final Widget inputForm;
  final Widget resultCard;
  final List<Widget>? actions;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            // Desktop Layout: Split View
            return Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Form (Left)
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: inputForm,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Result Card (Right)
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: resultCard,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Mobile/Tablet Layout: Vertical Scroll
            return SingleChildScrollView(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  inputForm,
                  const SizedBox(height: 24),
                  resultCard,
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
