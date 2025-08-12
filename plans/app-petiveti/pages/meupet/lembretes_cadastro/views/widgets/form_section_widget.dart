// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../constants/lembrete_form_constants.dart';

/// Widget para seção do formulário com header e conteúdo organizados
class LembreteFormSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  final bool isExpanded;

  const LembreteFormSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: LembreteFormConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LembreteFormConstants.borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LembreteFormConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            if (isExpanded) _buildSectionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LembreteFormConstants.cardPadding,
        vertical: 12.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: color.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent() {
    return Padding(
      padding: const EdgeInsets.all(LembreteFormConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
