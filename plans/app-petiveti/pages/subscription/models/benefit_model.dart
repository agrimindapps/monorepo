// Flutter imports:
import 'package:flutter/material.dart';

class Benefit {
  final String title;
  final String description;
  final String iconName;
  final bool isHighlight;
  final BenefitCategory category;

  const Benefit({
    required this.title,
    required this.description,
    required this.iconName,
    this.isHighlight = false,
    this.category = BenefitCategory.feature,
  });

  IconData get icon {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate;
      case 'medical_services':
        return Icons.medical_services;
      case 'notifications':
        return Icons.notifications;
      case 'trending_up':
        return Icons.trending_up;
      case 'cloud_sync':
        return Icons.cloud_sync;
      case 'block':
        return Icons.block;
      case 'security':
        return Icons.security;
      case 'support':
        return Icons.support_agent;
      case 'backup':
        return Icons.backup;
      case 'analytics':
        return Icons.analytics;
      case 'premium':
        return Icons.workspace_premium;
      case 'sync':
        return Icons.sync;
      case 'pets':
        return Icons.pets;
      case 'veterinary':
        return Icons.local_hospital;
      case 'calendar':
        return Icons.calendar_today;
      case 'chart':
        return Icons.bar_chart;
      default:
        return Icons.star;
    }
  }

  Color get categoryColor {
    switch (category) {
      case BenefitCategory.feature:
        return const Color(0xFF4A90E2);
      case BenefitCategory.professional:
        return const Color(0xFF7B68EE);
      case BenefitCategory.convenience:
        return const Color(0xFF50C878);
      case BenefitCategory.support:
        return const Color(0xFFFF6B35);
    }
  }

  static Benefit fromMap(Map<String, dynamic> map) {
    return Benefit(
      title: map['titulo'] ?? map['title'] ?? '',
      description: map['descricao'] ?? map['description'] ?? '',
      iconName: map['icone'] ?? map['icon'] ?? 'star',
      isHighlight: map['isHighlight'] ?? false,
      category: BenefitCategory.values.firstWhere(
        (c) => c.name == (map['category'] ?? 'feature'),
        orElse: () => BenefitCategory.feature,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'iconName': iconName,
      'isHighlight': isHighlight,
      'category': category.name,
    };
  }
}

enum BenefitCategory {
  feature,      // Funcionalidades principais
  professional, // Recursos profissionais
  convenience,  // Conveniências
  support,      // Suporte e ajuda
}

class BenefitRepository {
  static List<Benefit> getDefaultBenefits() {
    return const [
      Benefit(
        title: 'Calculadoras Veterinárias Avançadas',
        description: 'Acesso completo a todas as calculadoras profissionais',
        iconName: 'calculate',
        category: BenefitCategory.professional,
        isHighlight: true,
      ),
      Benefit(
        title: 'Prontuário Veterinário Completo',
        description: 'Gestão completa de consultas, medicações e vacinas',
        iconName: 'medical_services',
        category: BenefitCategory.professional,
        isHighlight: true,
      ),
      Benefit(
        title: 'Lembretes Inteligentes',
        description: 'Notificações personalizadas para cuidados do pet',
        iconName: 'notifications',
        category: BenefitCategory.convenience,
      ),
      Benefit(
        title: 'Histórico Médico Detalhado',
        description: 'Controle completo do peso e desenvolvimento',
        iconName: 'trending_up',
        category: BenefitCategory.feature,
      ),
      Benefit(
        title: 'Sincronização Segura',
        description: 'Dados sempre seguros e acessíveis',
        iconName: 'cloud_sync',
        category: BenefitCategory.feature,
      ),
      Benefit(
        title: 'Sem Anúncios',
        description: 'Experiência profissional sem interrupções',
        iconName: 'block',
        category: BenefitCategory.convenience,
      ),
      Benefit(
        title: 'Backup Automático',
        description: 'Seus dados protegidos automaticamente',
        iconName: 'backup',
        category: BenefitCategory.feature,
      ),
      Benefit(
        title: 'Suporte Prioritário',
        description: 'Atendimento especializado e prioritário',
        iconName: 'support',
        category: BenefitCategory.support,
      ),
    ];
  }

  static List<Benefit> parseFromService(List<Map<String, dynamic>> benefitsData) {
    if (benefitsData.isEmpty) {
      return getDefaultBenefits();
    }
    
    return benefitsData.map((data) => Benefit.fromMap(data)).toList();
  }

  static List<Benefit> filterByCategory(List<Benefit> benefits, BenefitCategory category) {
    return benefits.where((benefit) => benefit.category == category).toList();
  }

  static List<Benefit> getHighlightBenefits(List<Benefit> benefits) {
    return benefits.where((benefit) => benefit.isHighlight).toList();
  }

  static Map<BenefitCategory, List<Benefit>> groupByCategory(List<Benefit> benefits) {
    final Map<BenefitCategory, List<Benefit>> grouped = {};
    
    for (final benefit in benefits) {
      grouped.putIfAbsent(benefit.category, () => []).add(benefit);
    }
    
    return grouped;
  }

  static String getCategoryDisplayName(BenefitCategory category) {
    switch (category) {
      case BenefitCategory.feature:
        return 'Funcionalidades';
      case BenefitCategory.professional:
        return 'Recursos Profissionais';
      case BenefitCategory.convenience:
        return 'Conveniências';
      case BenefitCategory.support:
        return 'Suporte';
    }
  }

  static IconData getCategoryIcon(BenefitCategory category) {
    switch (category) {
      case BenefitCategory.feature:
        return Icons.featured_play_list;
      case BenefitCategory.professional:
        return Icons.work;
      case BenefitCategory.convenience:
        return Icons.touch_app;
      case BenefitCategory.support:
        return Icons.support_agent;
    }
  }

  static List<Benefit> sortBenefits(List<Benefit> benefits) {
    final sorted = List<Benefit>.from(benefits);
    
    // Sort by: highlights first, then by category priority
    sorted.sort((a, b) {
      // Highlights first
      if (a.isHighlight && !b.isHighlight) return -1;
      if (!a.isHighlight && b.isHighlight) return 1;
      
      // Then by category priority
      final categoryPriority = {
        BenefitCategory.professional: 1,
        BenefitCategory.feature: 2,
        BenefitCategory.convenience: 3,
        BenefitCategory.support: 4,
      };
      
      final aPriority = categoryPriority[a.category] ?? 99;
      final bPriority = categoryPriority[b.category] ?? 99;
      
      return aPriority.compareTo(bPriority);
    });
    
    return sorted;
  }

  static int getBenefitCount(List<Benefit> benefits) {
    return benefits.length;
  }

  static int getHighlightCount(List<Benefit> benefits) {
    return benefits.where((b) => b.isHighlight).length;
  }

  static Map<String, int> getBenefitStatistics(List<Benefit> benefits) {
    final stats = <String, int>{};
    
    for (final category in BenefitCategory.values) {
      final count = benefits.where((b) => b.category == category).length;
      stats[category.name] = count;
    }
    
    stats['total'] = benefits.length;
    stats['highlights'] = getHighlightCount(benefits);
    
    return stats;
  }
}
