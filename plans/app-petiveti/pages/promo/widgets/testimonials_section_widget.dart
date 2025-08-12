// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/promo_content_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class TestimonialsSectionWidget extends StatelessWidget {
  final PromoController controller;
  final TestimonialsContent testimonialsContent;

  const TestimonialsSectionWidget({
    super.key,
    required this.controller,
    required this.testimonialsContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelpers.getResponsiveSectionPadding(context),
      color: PromoConstants.whiteColor,
      child: Column(
        children: [
          _buildSectionHeader(context),
          const SizedBox(height: PromoConstants.largeSpacing),
          _buildTestimonialsGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          testimonialsContent.title,
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
        
        if (testimonialsContent.subtitle.isNotEmpty) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          Text(
            testimonialsContent.subtitle,
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

  Widget _buildTestimonialsGrid(BuildContext context) {
    final columns = ResponsiveHelpers.getResponsiveGridColumns(
      context,
      mobile: PromoConstants.testimonialsGridMobile,
      tablet: PromoConstants.testimonialsGridTablet,
      desktop: PromoConstants.testimonialsGridDesktop,
      ultrawide: 4,
    );

    final spacing = ResponsiveHelpers.getResponsiveGridSpacing(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 30.0,
      ultrawide: 40.0,
    );

    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        if (breakpoint == ResponsiveBreakpoint.mobile) {
          return _buildMobileLayout(context);
        } else {
          return _buildGridLayout(context, columns, spacing);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: testimonialsContent.testimonials.map((testimonial) {
        return Padding(
          padding: const EdgeInsets.only(bottom: PromoConstants.itemSpacing),
          child: _buildTestimonialCard(context, testimonial),
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(BuildContext context, int columns, double spacing) {
    final testimonials = testimonialsContent.testimonials;
    final rows = (testimonials.length / columns).ceil();
    
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final endIndex = (startIndex + columns).clamp(0, testimonials.length);
        final rowTestimonials = testimonials.sublist(startIndex, endIndex);
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rows - 1 ? spacing : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columns, (colIndex) {
              if (colIndex < rowTestimonials.length) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: colIndex < columns - 1 ? spacing : 0,
                    ),
                    child: _buildTestimonialCard(context, rowTestimonials[colIndex]),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          ),
        );
      }),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, PromoTestimonial testimonial) {
    return MouseRegion(
      onEnter: (_) => _onTestimonialHover(testimonial, true, context),
      onExit: (_) => _onTestimonialHover(testimonial, false, context),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final isHovered = controller.hoveredTestimonial == testimonial.id;
          
          return AnimatedContainer(
            duration: PromoConstants.defaultAnimation,
            curve: PromoConstants.defaultCurve,
            height: ResponsiveHelpers.getResponsiveCardHeight(
              context,
              PromoConstants.testimonialCardHeight,
              mobileScale: 0.9,
            ),
            padding: ResponsiveHelpers.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(PromoConstants.cardPadding),
              tablet: const EdgeInsets.all(PromoConstants.cardPadding + 4),
              desktop: const EdgeInsets.all(PromoConstants.cardPadding + 8),
            ),
            decoration: _buildTestimonialCardDecoration(isHovered),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuoteIcon(context),
                const SizedBox(height: PromoConstants.itemSpacing),
                _buildTestimonialText(context, testimonial),
                const Spacer(),
                _buildTestimonialFooter(context, testimonial),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildTestimonialCardDecoration(bool isHovered) {
    return BoxDecoration(
      color: PromoConstants.whiteColor,
      borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
      boxShadow: isHovered
          ? [
              BoxShadow(
                color: PromoConstants.primaryColor.withValues(alpha: 0.2),
                spreadRadius: 3,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : PromoConstants.defaultShadow,
      border: isHovered
          ? Border.all(
              color: PromoConstants.primaryColor.withValues(alpha: 0.3),
              width: 2,
            )
          : Border.all(
              color: PromoConstants.backgroundColor.withValues(alpha: 0.5),
              width: 1,
            ),
    );
  }

  Widget _buildQuoteIcon(BuildContext context) {
    return Container(
      width: ResponsiveHelpers.getResponsiveIconSize(context, 40),
      height: ResponsiveHelpers.getResponsiveIconSize(context, 40),
      decoration: BoxDecoration(
        color: PromoConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
      ),
      child: Icon(
        Icons.format_quote,
        size: ResponsiveHelpers.getResponsiveIconSize(context, PromoConstants.testimonialQuoteIconSize),
        color: PromoConstants.primaryColor,
      ),
    );
  }

  Widget _buildTestimonialText(BuildContext context, PromoTestimonial testimonial) {
    return Expanded(
      child: Text(
        testimonial.quote,
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(
            context,
            PromoConstants.cardDescriptionFontSize,
          ),
          color: PromoConstants.textColor.withValues(alpha: 0.8),
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTestimonialFooter(BuildContext context, PromoTestimonial testimonial) {
    return Column(
      children: [
        // Rating stars
        Row(
          children: PromoHelpers.buildStarRating(
            testimonial.rating,
            size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
          ),
        ),
        
        const SizedBox(height: PromoConstants.smallSpacing),
        
        // User info
        Row(
          children: [
            _buildUserAvatar(context, testimonial),
            const SizedBox(width: PromoConstants.smallSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimonial.author,
                    style: TextStyle(
                      fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      color: PromoConstants.textColor,
                    ),
                  ),
                  if (testimonial.role.isNotEmpty) ...[
                    Text(
                      testimonial.role,
                      style: TextStyle(
                        fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                        color: PromoConstants.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Verified badge
            _buildVerifiedBadge(context),
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context, PromoTestimonial testimonial) {
    final avatarSize = ResponsiveHelpers.getResponsiveIconSize(context, PromoConstants.testimonialAvatarRadius * 2);
    
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            PromoConstants.primaryColor,
            PromoConstants.primaryColor.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: PromoConstants.primaryColor.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: testimonial.hasImage
          ? ClipOval(
              child: Image.network(
                testimonial.imageUrl!,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarFallback(context, testimonial.author);
                },
              ),
            )
          : _buildAvatarFallback(context, testimonial.author),
    );
  }

  Widget _buildAvatarFallback(BuildContext context, String userName) {
    final initials = userName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
    
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
          fontWeight: FontWeight.bold,
          color: PromoConstants.whiteColor,
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: PromoConstants.successColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: ResponsiveHelpers.getResponsiveIconSize(context, 12),
        color: PromoConstants.whiteColor,
      ),
    );
  }

  void _onTestimonialHover(PromoTestimonial testimonial, bool isHovered, BuildContext context) {
    if (ResponsiveHelpers.isDesktop(context)) {
      controller.setHoveredTestimonial(isHovered ? testimonial.id : null);
    }
  }
}
