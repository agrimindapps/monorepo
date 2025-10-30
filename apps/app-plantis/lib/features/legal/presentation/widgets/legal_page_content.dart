import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/legal_section.dart';

/// Stateless widget for displaying legal document content
/// Compatible with Riverpod and functional programming
class BaseLegalPageContent extends StatefulWidget {
  final String title;
  final IconData headerIcon;
  final String headerTitle;
  final Gradient headerGradient;
  final List<LegalSection> sections;
  final DateTime lastUpdated;
  final Color scrollButtonColor;
  final IconData? footerIcon;
  final String? footerTitle;
  final String? footerDescription;

  const BaseLegalPageContent({
    super.key,
    required this.title,
    required this.headerIcon,
    required this.headerTitle,
    required this.headerGradient,
    required this.sections,
    required this.lastUpdated,
    this.scrollButtonColor = PlantisColors.primary,
    this.footerIcon,
    this.footerTitle,
    this.footerDescription,
  });

  @override
  State<BaseLegalPageContent> createState() => _BaseLegalPageContentState();
}

class _BaseLegalPageContentState extends State<BaseLegalPageContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _shareContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartilhamento disponível em breve'),
        backgroundColor: PlantisColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          widget.title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
            onPressed: _shareContent,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                ...widget.sections.asMap().entries.map((entry) {
                  final isLast = entry.key == widget.sections.length - 1;
                  final section = entry.value;
                  return _buildSection(
                    section.title,
                    section.content,
                    theme,
                    isLast: isLast,
                  );
                }),
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
                onPressed: _scrollToTop,
                backgroundColor: widget.scrollButtonColor,
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
            'Última atualização: ${_getFormattedDate(widget.lastUpdated)}',
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

  Widget _buildSection(
    String title,
    String content,
    ThemeData theme, {
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.headerGradient.colors.first,
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
                left: BorderSide(
                  width: 4,
                  color: widget.headerGradient.colors.first,
                ),
              ),
            ),
            child: Text(
              content,
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
      child: widget.footerIcon != null && widget.footerTitle != null
          ? Column(
              children: [
                Icon(widget.footerIcon, color: PlantisColors.primary, size: 32),
                const SizedBox(height: 8),
                Text(
                  widget.footerTitle!,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.footerDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.footerDescription!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
