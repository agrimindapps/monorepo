import 'package:flutter/material.dart';

import '../../domain/entities/promo_content.dart';

class PromoTestimonialsSection extends StatelessWidget {
  final List<Testimonial> testimonials;

  const PromoTestimonialsSection({
    super.key,
    required this.testimonials,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Depoimentos',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Veja o que nossos usuários estão dizendo',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          if (testimonials.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'Depoimentos em breve',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else if (isMobile)
            Column(
              children: testimonials.map((testimonial) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildTestimonialCard(theme, testimonial),
                ),
              ).toList(),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 24,
              children: testimonials.map((testimonial) => 
                SizedBox(
                  width: 350,
                  child: _buildTestimonialCard(theme, testimonial),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(ThemeData theme, Testimonial testimonial) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => 
              Icon(
                index < testimonial.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Text(
            '"${testimonial.text}"',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  testimonial.authorName.isNotEmpty 
                      ? testimonial.authorName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.authorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (testimonial.authorLocation.isNotEmpty)
                      Text(
                        testimonial.authorLocation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
