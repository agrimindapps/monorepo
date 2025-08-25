/// Header animado para páginas do módulo AgriHurbi
/// 
/// Widget que cria um cabeçalho com animações suaves para melhorar
/// a percepção visual das páginas principais.

library;

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'animations.dart';

class AnimatedPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final IconData? actionIcon;

  const AnimatedPageHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.onActionPressed,
    this.actionLabel,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final fgColor = foregroundColor ?? theme.colorScheme.onPrimary;

    return AnimatedFadeIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null)
                    AnimatedScaleIn(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: fgColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: fgColor,
                        ),
                      ),
                    ),
                  if (icon != null) const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedFadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: fgColor,
                            ),
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          AnimatedFadeIn(
                            delay: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: fgColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onActionPressed != null)
                    AnimatedScaleIn(
                      delay: const Duration(milliseconds: 400),
                      child: ElevatedButton.icon(
                        onPressed: onActionPressed,
                        icon: Icon(
                          actionIcon ?? FontAwesome.plus_solid,
                          size: 16,
                        ),
                        label: Text(actionLabel ?? 'Ação'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fgColor,
                          foregroundColor: bgColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card animado para exibir estatísticas ou métricas
class AnimatedStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const AnimatedStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;

    return AnimatedScaleIn(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AnimationDurations.normal,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardColor.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedFadeIn(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedScaleIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: cardColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ),
              if (subtitle != null)
                AnimatedFadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista animada de cards com staggered animation
class AnimatedCardList extends StatelessWidget {
  final List<Widget> cards;
  final Duration staggerDelay;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AnimatedCardList({
    super.key,
    required this.cards,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return AnimatedFadeIn(
          delay: staggerDelay * index,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: index == cards.length - 1 ? 0 : 8,
            ),
            child: cards[index],
          ),
        );
      },
    );
  }
}