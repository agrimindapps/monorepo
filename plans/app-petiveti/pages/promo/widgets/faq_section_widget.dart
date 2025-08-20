// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/promo_content_model.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class FAQSectionWidget extends StatelessWidget {
  final PromoController controller;
  final FAQContent faqContent;

  const FAQSectionWidget({
    super.key,
    required this.controller,
    required this.faqContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelpers.getResponsiveSectionPadding(context),
      color: PromoConstants.backgroundColor,
      child: Column(
        children: [
          _buildSectionHeader(context),
          const SizedBox(height: PromoConstants.largeSpacing),
          _buildFAQList(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          faqContent.title,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.sectionTitleFontSize,
            ),
            fontWeight: PromoConstants.sectionTitleWeight,
            color: PromoConstants.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (faqContent.subtitle.isNotEmpty) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          Text(
            faqContent.subtitle,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.sectionSubtitleFontSize,
              ),
              color: PromoConstants.textColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        Container(
          margin: const EdgeInsets.symmetric(vertical: PromoConstants.itemSpacing),
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: PromoConstants.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQList(BuildContext context) {
    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        final maxWidth = ResponsiveHelpers.getResponsiveMaxWidth(context);
        
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth * 0.9),
            child: Column(
              children: faqContent.faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < faqContent.faqs.length - 1 
                        ? PromoConstants.itemSpacing 
                        : 0,
                  ),
                  child: _buildPromoFAQItem(context, faq, index),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoFAQItem(BuildContext context, PromoFAQItem faq, int index) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final isExpanded = controller.expandedFAQ == faq.id;
        
        return MouseRegion(
          onEnter: (_) => _onFAQHover(context, faq, true),
          onExit: (_) => _onFAQHover(context, faq, false),
          child: AnimatedContainer(
            duration: PromoConstants.defaultAnimation,
            curve: PromoConstants.defaultCurve,
            decoration: _buildPromoFAQItemDecoration(faq, isExpanded),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                listTileTheme: ListTileThemeData(
                  contentPadding: ResponsiveHelpers.getResponsivePadding(
                    context,
                    mobile: const EdgeInsets.symmetric(
                      horizontal: PromoConstants.faqItemPadding,
                      vertical: PromoConstants.faqItemPadding / 2,
                    ),
                    tablet: const EdgeInsets.symmetric(
                      horizontal: PromoConstants.faqItemPadding + 4,
                      vertical: PromoConstants.faqItemPadding / 2 + 2,
                    ),
                    desktop: const EdgeInsets.symmetric(
                      horizontal: PromoConstants.faqItemPadding + 8,
                      vertical: PromoConstants.faqItemPadding / 2 + 4,
                    ),
                  ),
                ),
              ),
              child: ExpansionTile(
                key: Key(faq.id),
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) => _onFAQExpansionChanged(faq, expanded),
                leading: _buildFAQIcon(context, faq, isExpanded),
                title: _buildFAQTitle(context, faq),
                trailing: _buildFAQTrailing(context, isExpanded),
                tilePadding: EdgeInsets.zero,
                childrenPadding: ResponsiveHelpers.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.only(
                    left: PromoConstants.faqItemPadding,
                    right: PromoConstants.faqItemPadding,
                    bottom: PromoConstants.faqItemPadding,
                  ),
                  tablet: const EdgeInsets.only(
                    left: PromoConstants.faqItemPadding + 4,
                    right: PromoConstants.faqItemPadding + 4,
                    bottom: PromoConstants.faqItemPadding + 4,
                  ),
                  desktop: const EdgeInsets.only(
                    left: PromoConstants.faqItemPadding + 8,
                    right: PromoConstants.faqItemPadding + 8,
                    bottom: PromoConstants.faqItemPadding + 8,
                  ),
                ),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                children: [
                  _buildFAQAnswer(context, faq),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildPromoFAQItemDecoration(PromoFAQItem faq, bool isExpanded) {
    final isHovered = controller.hoveredFAQ == faq.id;
    
    return BoxDecoration(
      color: PromoConstants.whiteColor,
      borderRadius: BorderRadius.circular(PromoConstants.faqTileRadius),
      border: Border.all(
        color: isExpanded
            ? PromoConstants.primaryColor
            : isHovered
                ? PromoConstants.primaryColor.withValues(alpha: 0.3)
                : PromoConstants.backgroundColor.withValues(alpha: 0.5),
        width: isExpanded ? 2 : 1,
      ),
      boxShadow: isExpanded || isHovered
          ? [
              BoxShadow(
                color: PromoConstants.primaryColor.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  Widget _buildFAQIcon(BuildContext context, PromoFAQItem faq, bool isExpanded) {
    return Container(
      width: ResponsiveHelpers.getResponsiveIconSize(context, 40),
      height: ResponsiveHelpers.getResponsiveIconSize(context, 40),
      decoration: BoxDecoration(
        color: isExpanded
            ? PromoConstants.primaryColor
            : PromoConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
      ),
      child: Icon(
        _getFAQCategoryIcon(faq.category),
        size: ResponsiveHelpers.getResponsiveIconSize(context, PromoConstants.faqIconSize),
        color: isExpanded
            ? PromoConstants.whiteColor
            : PromoConstants.primaryColor,
      ),
    );
  }

  Widget _buildFAQTitle(BuildContext context, PromoFAQItem faq) {
    return Text(
      faq.question,
      style: TextStyle(
        fontSize: ResponsiveHelpers.getResponsiveFontSize(
          context,
          PromoConstants.faqTitleFontSize,
        ),
        fontWeight: FontWeight.w600,
        color: PromoConstants.textColor,
        height: 1.3,
      ),
    );
  }

  Widget _buildFAQTrailing(BuildContext context, bool isExpanded) {
    return AnimatedRotation(
      turns: isExpanded ? 0.5 : 0,
      duration: PromoConstants.defaultAnimation,
      child: Container(
        width: ResponsiveHelpers.getResponsiveIconSize(context, 32),
        height: ResponsiveHelpers.getResponsiveIconSize(context, 32),
        decoration: BoxDecoration(
          color: isExpanded
              ? PromoConstants.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
        ),
        child: Icon(
          Icons.keyboard_arrow_down,
          size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
          color: PromoConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildFAQAnswer(BuildContext context, PromoFAQItem faq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Answer text
        Text(
          faq.answer,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.faqAnswerFontSize,
            ),
            color: PromoConstants.textColor.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
        
        // Additional info or actions
        if (faq.category == FAQCategory.contact) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          _buildContactActions(context),
        ],
        
        if (faq.category == FAQCategory.technical) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          _buildTechnicalActions(context),
        ],
      ],
    );
  }

  Widget _buildContactActions(BuildContext context) {
    return Wrap(
      spacing: PromoConstants.smallSpacing,
      runSpacing: PromoConstants.smallSpacing,
      children: [
        _buildActionChip(
          context,
          'Enviar Email',
          Icons.email_outlined,
          () => controller.launchService.sendSupportEmail(),
        ),
        _buildActionChip(
          context,
          'WhatsApp',
          Icons.chat,
          () => controller.launchService.sendSMS('+5511999999999'),
        ),
      ],
    );
  }

  Widget _buildTechnicalActions(BuildContext context) {
    return Wrap(
      spacing: PromoConstants.smallSpacing,
      runSpacing: PromoConstants.smallSpacing,
      children: [
        _buildActionChip(
          context,
          'Centro de Ajuda',
          Icons.help_outline,
          () => controller.launchService.openHelpPage(),
        ),
        _buildActionChip(
          context,
          'Reportar Bug',
          Icons.bug_report_outlined,
          () => controller.launchService.sendFeedbackEmail('Bug report: '),
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PromoConstants.defaultPadding,
          vertical: PromoConstants.smallSpacing,
        ),
        decoration: BoxDecoration(
          color: PromoConstants.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
          border: Border.all(
            color: PromoConstants.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
              color: PromoConstants.primaryColor,
            ),
            const SizedBox(width: PromoConstants.smallSpacing),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                color: PromoConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFAQCategoryIcon(FAQCategory category) {
    switch (category) {
      case FAQCategory.general:
        return Icons.info_outline;
      case FAQCategory.features:
        return Icons.star_outline;
      case FAQCategory.technical:
        return Icons.settings_outlined;
      case FAQCategory.billing:
        return Icons.payment_outlined;
      case FAQCategory.contact:
        return Icons.contact_support_outlined;
    }
  }

  void _onFAQHover(BuildContext context, PromoFAQItem faq, bool isHovered) {
    if (ResponsiveHelpers.isDesktop(context)) {
      controller.setHoveredFAQ(isHovered ? faq.id : null);
    }
  }

  void _onFAQExpansionChanged(PromoFAQItem faq, bool expanded) {
    controller.setExpandedFAQ(expanded ? faq.id : null);
    
    // Track analytics
    PromoHelpers.debugPrint('FAQ ${expanded ? 'expanded' : 'collapsed'}: ${faq.question}');
  }
}
