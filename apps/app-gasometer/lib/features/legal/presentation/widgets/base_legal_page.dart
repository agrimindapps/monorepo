import 'package:flutter/material.dart';

import '../../../../core/theme/gasometer_colors.dart';
import '../../data/services/legal_date_formatter.dart';
import '../services/legal_scroll_controller_manager.dart';

/// Base component for legal pages with common functionality
abstract class BaseLegalPage extends StatefulWidget {

  const BaseLegalPage({
    super.key,
    required this.title,
    required this.headerIcon,
    required this.headerTitle,
    required this.headerGradient,
    required this.footerMessage,
  });
  final String title;
  final IconData headerIcon;
  final String headerTitle;
  final Gradient headerGradient;
  final String footerMessage;

  List<LegalSection> buildSections(BuildContext context, ThemeData theme);
}

class LegalSection {

  const LegalSection({
    required this.title,
    required this.content,
    required this.titleColor,
    this.isLast = false,
  });
  final String title;
  final String content;
  final Color titleColor;
  final bool isLast;
}

abstract class BaseLegalPageState<T extends BaseLegalPage> extends State<T> {
  late final LegalScrollControllerManager _scrollManager;
  final LegalDateFormatter _dateFormatter = LegalDateFormatter();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollManager = LegalScrollControllerManager(
      onScrollThresholdReached: _updateScrollButtonVisibility,
    );
    _scrollManager.startListening();
  }

  void _updateScrollButtonVisibility() {
    final shouldShow = _scrollManager.shouldShowScrollButton();
    if (shouldShow != _showScrollToTopButton) {
      setState(() => _showScrollToTopButton = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = widget.buildSections(context, theme);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollManager.controller,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                ...sections.map((s) => _buildSection(s, theme)),
                const SizedBox(height: 32),
                _buildFooter(theme),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_showScrollToTopButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.small(
                onPressed: () => _scrollManager.scrollToTop(),
                backgroundColor: GasometerColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.headerGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(widget.headerIcon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            widget.headerTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Última atualização: ${_dateFormatter.formatCurrentDate()}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(LegalSection section, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: section.isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              color: section.titleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(width: 4, color: section.titleColor),
              ),
            ),
            child: Text(
              section.content,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.footerMessage,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
