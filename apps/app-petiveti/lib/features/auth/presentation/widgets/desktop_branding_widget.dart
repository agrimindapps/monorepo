import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';

/// Desktop branding side widget following SRP
/// 
/// Single responsibility: Display branding and feature highlights for desktop layout
class DesktopBrandingWidget extends StatelessWidget {
  const DesktopBrandingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: SplashColors.heroGradient,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppLogo(),
              SizedBox(height: 40),
              _BrandingTitle(),
              SizedBox(height: 24),
              _BrandingDescription(),
              SizedBox(height: 40),
              _FeatureHighlights(),
              SizedBox(height: 20),
              _SecurityBadge(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          SplashConstants.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _BrandingTitle extends StatelessWidget {
  const _BrandingTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portal do Gestor',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _BrandingDescription extends StatelessWidget {
  const _BrandingDescription();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Acesse o sistema para gerenciar todas as informações sobre os cuidados com os pets.',
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}

class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights();

  static const features = [
    {'icon': Icons.pets, 'text': 'Gestão Completa de Pets'},
    {'icon': Icons.calendar_month, 'text': 'Agendamentos Inteligentes'},
    {'icon': Icons.analytics, 'text': 'Relatórios Detalhados'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              feature['icon'] as IconData,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              feature['text'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.security,
          color: Colors.white.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          'Área restrita - Acesso seguro',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}