import 'package:flutter/material.dart';

import '../../domain/entities/promo_content.dart';

class PromoFaqSection extends StatelessWidget {
  final List<FAQ> faqs;
  final ValueChanged<String> onToggleFaq;

  const PromoFaqSection({
    super.key,
    required this.faqs,
    required this.onToggleFaq,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Perguntas Frequentes',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Tire suas dúvidas sobre o PetiVeti',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          if (faqs.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'FAQ em breve',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: faqs.map((faq) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildFaqItem(theme, faq),
                  ),
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(ThemeData theme, FAQ faq) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        key: Key(faq.id),
        initiallyExpanded: faq.isExpanded,
        onExpansionChanged: (_) => onToggleFaq(faq.id),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        title: Text(
          faq.question,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              faq.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
