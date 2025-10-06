import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';

/// Base component for legal pages with common functionality like scroll-to-top,
/// section building, and consistent layout structure.
abstract class BaseLegalPage extends StatefulWidget {
  /// The title displayed in the app bar
  final String title;

  /// The icon displayed in the header
  final IconData headerIcon;

  /// The header title (can be different from app bar title)
  final String headerTitle;

  /// The gradient used in the header
  final Gradient headerGradient;

  /// Footer message displayed at the bottom
  final String footerMessage;

  /// Footer icon (optional)
  final IconData? footerIcon;

  /// Footer title (optional)
  final String? footerTitle;

  /// Footer description (optional)
  final String? footerDescription;

  const BaseLegalPage({
    super.key,
    required this.title,
    required this.headerIcon,
    required this.headerTitle,
    required this.headerGradient,
    required this.footerMessage,
    this.footerIcon,
    this.footerTitle,
    this.footerDescription,
  });

  /// Override this method to provide the content sections
  List<LegalSection> buildSections(BuildContext context, ThemeData theme);
}

/// Data class representing a legal section
class LegalSection {
  final String title;
  final String content;
  final Color titleColor;
  final bool isLast;

  const LegalSection({
    required this.title,
    required this.content,
    required this.titleColor,
    this.isLast = false,
  });
}

/// Abstract state class for legal pages with common functionality
abstract class BaseLegalPageState<T extends BaseLegalPage> extends State<T> {
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
    final sections = widget.buildSections(context, theme);

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
                ...sections.map(
                  (section) => _buildSection(
                    section.title,
                    section.content,
                    theme,
                    titleColor: section.titleColor,
                    isLast: section.isLast,
                  ),
                ),

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
                backgroundColor: getScrollButtonColor(),
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
            'Última atualização: ${_getFormattedDate()}',
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
    required Color titleColor,
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
              color: titleColor,
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
              border: Border(left: BorderSide(width: 4, color: titleColor)),
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
      child:
          widget.footerIcon != null && widget.footerTitle != null
              ? Column(
                children: [
                  Icon(
                    widget.footerIcon,
                    color: PlantisColors.primary,
                    size: 32,
                  ),
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
              : Text(
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

  String _getFormattedDate() {
    final now = DateTime.now();
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
    return '${now.day} de ${months[now.month - 1]} de ${now.year}';
  }

  /// Override this method to customize the scroll button color
  @protected
  Color getScrollButtonColor() {
    return PlantisColors.primary;
  }
}
