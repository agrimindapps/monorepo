import 'package:flutter/material.dart';

class PromoAppBar extends StatefulWidget {
  final VoidCallback onFeaturesPressed;
  final VoidCallback onScreenshotsPressed;
  final VoidCallback onTestimonialsPressed;
  final VoidCallback onFaqPressed;
  final VoidCallback onLoginPressed;

  const PromoAppBar({
    super.key,
    required this.onFeaturesPressed,
    required this.onScreenshotsPressed,
    required this.onTestimonialsPressed,
    required this.onFaqPressed,
    required this.onLoginPressed,
  });

  @override
  State<PromoAppBar> createState() => _PromoAppBarState();
}

class _PromoAppBarState extends State<PromoAppBar> {
  final bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PetiVeti',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  if (!isMobile) ...[
                    _buildNavButton('Recursos', widget.onFeaturesPressed),
                    _buildNavButton('Screenshots', widget.onScreenshotsPressed),
                    _buildNavButton(
                      'Depoimentos',
                      widget.onTestimonialsPressed,
                    ),
                    _buildNavButton('FAQ', widget.onFaqPressed),
                    const SizedBox(width: 16),
                  ],
                  OutlinedButton(
                    onPressed: widget.onLoginPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Já tenho conta'),
                  ),
                  if (isMobile) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showMobileMenu(context),
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMobileMenuItem('Recursos', widget.onFeaturesPressed),
                _buildMobileMenuItem(
                  'Screenshots',
                  widget.onScreenshotsPressed,
                ),
                _buildMobileMenuItem(
                  'Depoimentos',
                  widget.onTestimonialsPressed,
                ),
                _buildMobileMenuItem('FAQ', widget.onFaqPressed),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildMobileMenuItem(String text, VoidCallback onPressed) {
    return ListTile(
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        onPressed();
      },
    );
  }
}
