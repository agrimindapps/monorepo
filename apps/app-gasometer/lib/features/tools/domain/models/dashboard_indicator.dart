import 'package:flutter/material.dart';

/// Severity levels for dashboard indicators
enum IndicatorSeverity {
  critical, // Vermelho - Pare imediatamente
  warning, // Amarelo/Laranja - Atenção necessária
  information, // Azul/Verde - Informativo
}

/// Dashboard indicator (warning light) model
class DashboardIndicator {
  const DashboardIndicator({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    required this.color,
    required this.icon,
    required this.whatToDo,
    required this.canDrive,
    this.possibleCauses,
    this.relatedSystems,
  });

  final String id;
  final String name;
  final String description;
  final IndicatorSeverity severity;
  final Color color;
  final IconData icon;
  final String whatToDo;
  final bool canDrive; // Se pode continuar dirigindo
  final List<String>? possibleCauses;
  final List<String>? relatedSystems;

  String get severityLabel {
    switch (severity) {
      case IndicatorSeverity.critical:
        return 'CRÍTICO';
      case IndicatorSeverity.warning:
        return 'ATENÇÃO';
      case IndicatorSeverity.information:
        return 'INFORMATIVO';
    }
  }

  Color get severityColor {
    switch (severity) {
      case IndicatorSeverity.critical:
        return Colors.red;
      case IndicatorSeverity.warning:
        return Colors.orange;
      case IndicatorSeverity.information:
        return Colors.blue;
    }
  }
}

/// Database of common dashboard indicators
class DashboardIndicatorDatabase {
  static const List<DashboardIndicator> indicators = [
    // CRITICAL - Red lights
    DashboardIndicator(
      id: 'oil_pressure',
      name: 'Pressão do Óleo',
      description: 'Indica pressão baixa ou ausência de óleo no motor',
      severity: IndicatorSeverity.critical,
      color: Colors.red,
      icon: Icons.oil_barrel,
      canDrive: false,
      whatToDo: 'PARE IMEDIATAMENTE em local seguro e desligue o motor. Verifique o nível de óleo. Se estiver baixo, complete. Se estiver normal, não ligue o motor e chame guincho. Dirigir sem óleo pode destruir o motor.',
      possibleCauses: [
        'Nível de óleo baixo',
        'Vazamento de óleo',
        'Bomba de óleo com defeito',
        'Sensor de pressão com defeito',
      ],
      relatedSystems: ['Motor', 'Lubrificação'],
    ),
    DashboardIndicator(
      id: 'engine_temperature',
      name: 'Temperatura do Motor',
      description: 'Motor está superaquecendo',
      severity: IndicatorSeverity.critical,
      color: Colors.red,
      icon: Icons.thermostat,
      canDrive: false,
      whatToDo: 'PARE imediatamente em local seguro. Desligue o motor e aguarde esfriar (15-30 min). Verifique nível de água do radiador (APENAS COM MOTOR FRIO). Se precisar continuar, ligue o ar quente no máximo e dirija devagar até oficina mais próxima.',
      possibleCauses: [
        'Falta de água no radiador',
        'Vazamento no sistema de arrefecimento',
        'Válvula termostática travada',
        'Ventoinha com defeito',
        'Bomba d\'água com defeito',
      ],
      relatedSystems: ['Motor', 'Arrefecimento'],
    ),
    DashboardIndicator(
      id: 'brake_system',
      name: 'Sistema de Freios',
      description: 'Problema no sistema de freios',
      severity: IndicatorSeverity.critical,
      color: Colors.red,
      icon: Icons.directions_car,
      canDrive: false,
      whatToDo: 'PARE com cuidado em local seguro. Verifique o nível do fluido de freio. Se estiver baixo, NÃO dirija. Chame guincho. O sistema de freios é crítico para sua segurança.',
      possibleCauses: [
        'Fluido de freio baixo',
        'Vazamento no sistema',
        'Pastilhas gastas',
        'Freio de mão acionado',
        'Problema no ABS',
      ],
      relatedSystems: ['Freios', 'Segurança'],
    ),
    DashboardIndicator(
      id: 'battery_charging',
      name: 'Sistema de Carga',
      description: 'Bateria não está sendo carregada',
      severity: IndicatorSeverity.critical,
      color: Colors.red,
      icon: Icons.battery_alert,
      canDrive: true,
      whatToDo: 'Você pode dirigir, mas por tempo limitado (a bateria vai descarregar). Desligue equipamentos não essenciais (ar, som, luzes extras). Vá direto para oficina. Se o carro morrer, não conseguirá ligar novamente.',
      possibleCauses: [
        'Alternador com defeito',
        'Correia do alternador partida/frouxa',
        'Bateria com defeito',
        'Conexões soltas',
      ],
      relatedSystems: ['Elétrica', 'Bateria'],
    ),
    DashboardIndicator(
      id: 'airbag',
      name: 'Airbag',
      description: 'Problema no sistema de airbag',
      severity: IndicatorSeverity.critical,
      color: Colors.red,
      icon: Icons.safety_check,
      canDrive: true,
      whatToDo: 'Você pode dirigir, mas o airbag pode não funcionar em caso de acidente. Leve à oficina especializada o quanto antes para diagnóstico.',
      possibleCauses: [
        'Sensor de impacto com defeito',
        'Módulo do airbag com problema',
        'Fiação danificada',
        'Airbag já acionado anteriormente',
      ],
      relatedSystems: ['Segurança', 'Airbag'],
    ),

    // WARNING - Yellow/Orange lights
    DashboardIndicator(
      id: 'check_engine',
      name: 'Check Engine (Injeção)',
      description: 'Problema detectado no sistema de injeção/motor',
      severity: IndicatorSeverity.warning,
      color: Colors.orange,
      icon: Icons.engineering,
      canDrive: true,
      whatToDo: 'Você pode dirigir com cuidado. Se o motor estiver funcionando normalmente, leve à oficina para leitura do código de erro. Se o motor estiver falhando, consumindo muito ou com perda de potência, evite usar e leve logo à oficina.',
      possibleCauses: [
        'Problema nos sensores',
        'Falha na combustão',
        'Sistema de emissões',
        'Sonda lambda com defeito',
        'Velas ou cabos com problema',
        'Catalisador saturado',
      ],
      relatedSystems: ['Motor', 'Injeção Eletrônica'],
    ),
    DashboardIndicator(
      id: 'abs',
      name: 'ABS',
      description: 'Sistema ABS desativado ou com problema',
      severity: IndicatorSeverity.warning,
      color: Colors.orange,
      icon: Icons.settings_backup_restore,
      canDrive: true,
      whatToDo: 'Você pode dirigir, mas o ABS não funcionará. Tenha cuidado especial em frenagens bruscas e pistas molhadas. Leve à oficina para diagnóstico.',
      possibleCauses: [
        'Sensor de roda com defeito',
        'Módulo ABS com problema',
        'Fluido de freio baixo',
        'Fiação danificada',
      ],
      relatedSystems: ['Freios', 'ABS', 'Segurança'],
    ),
    DashboardIndicator(
      id: 'tire_pressure',
      name: 'Pressão dos Pneus',
      description: 'Um ou mais pneus com pressão incorreta',
      severity: IndicatorSeverity.warning,
      color: Colors.orange,
      icon: Icons.tire_repair,
      canDrive: true,
      whatToDo: 'Pare assim que possível e verifique a pressão de todos os pneus (incluindo estepe). Calibre conforme especificação do manual. Se encontrar pneu muito baixo ou furado, troque pelo estepe.',
      possibleCauses: [
        'Pneu furado ou murcho',
        'Variação de temperatura',
        'Pneu perdendo ar lentamente',
        'Sensor TPMS com defeito',
      ],
      relatedSystems: ['Pneus', 'Segurança'],
    ),
    DashboardIndicator(
      id: 'traction_control',
      name: 'Controle de Tração',
      description: 'Sistema de controle de tração desativado ou com problema',
      severity: IndicatorSeverity.warning,
      color: Colors.orange,
      icon: Icons.car_crash,
      canDrive: true,
      whatToDo: 'Você pode dirigir, mas tenha cuidado extra em curvas e acelerações, especialmente em piso molhado. Verifique se não desativou acidentalmente. Se acender sozinho, leve à oficina.',
      possibleCauses: [
        'Sistema desativado manualmente',
        'Sensor de velocidade com defeito',
        'Problema no módulo de controle',
        'Relacionado a problema no ABS',
      ],
      relatedSystems: ['Tração', 'Estabilidade', 'Segurança'],
    ),
    DashboardIndicator(
      id: 'fuel_low',
      name: 'Combustível Baixo',
      description: 'Nível de combustível está baixo',
      severity: IndicatorSeverity.warning,
      color: Colors.orange,
      icon: Icons.local_gas_station,
      canDrive: true,
      whatToDo: 'Abasteça o quanto antes. Evite rodar com tanque muito baixo, pois pode sugar impurezas do fundo do tanque e danificar o sistema de injeção. Normalmente acende com 5-8 litros restantes.',
      possibleCauses: [
        'Combustível realmente baixo',
        'Sensor de nível com defeito (raro)',
      ],
      relatedSystems: ['Combustível'],
    ),

    // INFORMATION - Blue/Green lights
    DashboardIndicator(
      id: 'high_beam',
      name: 'Farol Alto',
      description: 'Farol alto acionado',
      severity: IndicatorSeverity.information,
      color: Colors.blue,
      icon: Icons.light_mode,
      canDrive: true,
      whatToDo: 'Esta luz indica que o farol alto está ligado. Abaixe ao cruzar com outros veículos para não ofuscar os motoristas. É multa grave manter farol alto em área urbana ou ao cruzar com outros veículos.',
      possibleCauses: [
        'Farol alto acionado normalmente',
      ],
      relatedSystems: ['Iluminação'],
    ),
    DashboardIndicator(
      id: 'fog_lights',
      name: 'Farol de Neblina',
      description: 'Farol de neblina acionado',
      severity: IndicatorSeverity.information,
      color: Colors.green,
      icon: Icons.foggy,
      canDrive: true,
      whatToDo: 'Indica que o farol de neblina está ligado. Use apenas em condições de neblina, chuva forte ou neve. Desligue quando não necessário.',
      possibleCauses: [
        'Farol de neblina acionado normalmente',
      ],
      relatedSystems: ['Iluminação'],
    ),
    DashboardIndicator(
      id: 'cruise_control',
      name: 'Piloto Automático',
      description: 'Sistema de piloto automático ativado',
      severity: IndicatorSeverity.information,
      color: Colors.green,
      icon: Icons.speed,
      canDrive: true,
      whatToDo: 'Indica que o controle de cruzeiro (piloto automático) está ativo. O carro manterá a velocidade automaticamente. Pisar no freio ou embreagem desativa. Use apenas em rodovias com tráfego leve.',
      possibleCauses: [
        'Piloto automático acionado normalmente',
      ],
      relatedSystems: ['Piloto Automático', 'Assistência'],
    ),
    DashboardIndicator(
      id: 'eco_mode',
      name: 'Modo Econômico',
      description: 'Modo de condução econômica ativado',
      severity: IndicatorSeverity.information,
      color: Colors.green,
      icon: Icons.eco,
      canDrive: true,
      whatToDo: 'Indica que o modo ECO está ativo. O motor terá resposta mais suave e economia de combustível otimizada. Desative se precisar de mais potência.',
      possibleCauses: [
        'Modo ECO acionado normalmente',
      ],
      relatedSystems: ['Motor', 'Gerenciamento'],
    ),
  ];

  /// Get indicator by ID
  static DashboardIndicator? getById(String id) {
    try {
      return indicators.firstWhere((indicator) => indicator.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get indicators by severity
  static List<DashboardIndicator> getBySeverity(IndicatorSeverity severity) {
    return indicators.where((indicator) => indicator.severity == severity).toList();
  }

  /// Search indicators by name or description
  static List<DashboardIndicator> search(String query) {
    final lowerQuery = query.toLowerCase();
    return indicators.where((indicator) {
      return indicator.name.toLowerCase().contains(lowerQuery) ||
          indicator.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
