import 'package:flutter/material.dart';

/// Calculator category enumeration
enum CalculatorCategoryType {
  financial,
  construction,
  health,
  pet,
  agriculture,
  livestock,
}

/// Extension to provide metadata for each category
extension CalculatorCategoryTypeExtension on CalculatorCategoryType {
  String get label {
    return switch (this) {
      CalculatorCategoryType.financial => 'Financeiro',
      CalculatorCategoryType.construction => 'Construção',
      CalculatorCategoryType.health => 'Saúde',
      CalculatorCategoryType.pet => 'Pet',
      CalculatorCategoryType.agriculture => 'Agricultura',
      CalculatorCategoryType.livestock => 'Pecuária',
    };
  }

  String get routeParam {
    return switch (this) {
      CalculatorCategoryType.financial => 'financeiro',
      CalculatorCategoryType.construction => 'construcao',
      CalculatorCategoryType.health => 'saude',
      CalculatorCategoryType.pet => 'pet',
      CalculatorCategoryType.agriculture => 'agricultura',
      CalculatorCategoryType.livestock => 'pecuaria',
    };
  }

  IconData get icon {
    return switch (this) {
      CalculatorCategoryType.financial => Icons.account_balance_wallet,
      CalculatorCategoryType.construction => Icons.construction,
      CalculatorCategoryType.health => Icons.favorite_border,
      CalculatorCategoryType.pet => Icons.pets,
      CalculatorCategoryType.agriculture => Icons.grass,
      CalculatorCategoryType.livestock => Icons.agriculture,
    };
  }

  Color get color {
    return switch (this) {
      CalculatorCategoryType.financial => Colors.blue,
      CalculatorCategoryType.construction => Colors.orange,
      CalculatorCategoryType.health => Colors.pink,
      CalculatorCategoryType.pet => Colors.brown,
      CalculatorCategoryType.agriculture => Colors.lightGreen,
      CalculatorCategoryType.livestock => Colors.deepOrange,
    };
  }
}

/// Calculator item data model
class CalculatorItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final CalculatorCategoryType category;
  final List<String> tags;
  final bool isPopular;

  const CalculatorItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.category,
    this.tags = const [],
    this.isPopular = false,
  });
}

/// Single source of truth for all calculators
class CalculatorRegistry {
  CalculatorRegistry._();

  /// Complete list of all calculators (42 total)
  static const List<CalculatorItem> all = [
    // ═══════════════════════════════════════════════════════════════════════
    // FINANCEIRO (7)
    // ═══════════════════════════════════════════════════════════════════════
    CalculatorItem(
      id: 'thirteenth-salary',
      title: '13º Salário',
      description: 'Calcule seu 13º salário líquido e bruto',
      icon: Icons.card_giftcard,
      color: Colors.green,
      route: '/calculators/financial/thirteenth-salary',
      category: CalculatorCategoryType.financial,
      tags: ['CLT', 'Trabalhista'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'vacation',
      title: 'Férias',
      description: 'Descubra quanto você vai receber de férias',
      icon: Icons.beach_access,
      color: Colors.blue,
      route: '/calculators/financial/vacation',
      category: CalculatorCategoryType.financial,
      tags: ['CLT', 'Trabalhista'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'net-salary',
      title: 'Salário Líquido',
      description: 'Descubra seu salário após descontos',
      icon: Icons.monetization_on,
      color: Colors.orange,
      route: '/calculators/financial/net-salary',
      category: CalculatorCategoryType.financial,
      tags: ['CLT', 'INSS', 'IR'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'overtime',
      title: 'Horas Extras',
      description: 'Calcule o valor das suas horas extras',
      icon: Icons.access_time,
      color: Colors.purple,
      route: '/calculators/financial/overtime',
      category: CalculatorCategoryType.financial,
      tags: ['CLT', 'Trabalhista'],
    ),
    CalculatorItem(
      id: 'emergency-reserve',
      title: 'Reserva de Emergência',
      description: 'Planeje sua reserva financeira ideal',
      icon: Icons.savings,
      color: Colors.teal,
      route: '/calculators/financial/emergency-reserve',
      category: CalculatorCategoryType.financial,
      tags: ['Investimento', 'Planejamento'],
    ),
    CalculatorItem(
      id: 'cash-vs-installment',
      title: 'À vista ou Parcelado',
      description: 'Compare e decida a melhor forma de pagamento',
      icon: Icons.payment,
      color: Colors.indigo,
      route: '/calculators/financial/cash-vs-installment',
      category: CalculatorCategoryType.financial,
      tags: ['Compras', 'Juros'],
    ),
    CalculatorItem(
      id: 'unemployment-insurance',
      title: 'Seguro Desemprego',
      description: 'Calcule o valor do seu seguro desemprego',
      icon: Icons.work_off,
      color: Colors.red,
      route: '/calculators/financial/unemployment-insurance',
      category: CalculatorCategoryType.financial,
      tags: ['CLT', 'Trabalhista'],
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CONSTRUÇÃO (5)
    // ═══════════════════════════════════════════════════════════════════════
    CalculatorItem(
      id: 'concrete',
      title: 'Concreto',
      description: 'Calcule volume e materiais para concreto',
      icon: Icons.layers,
      color: Colors.grey,
      route: '/calculators/construction/concrete',
      category: CalculatorCategoryType.construction,
      tags: ['Cimento', 'Areia', 'Brita'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'electrical',
      title: 'Elétrica',
      description: 'Dimensionamento de instalação elétrica',
      icon: Icons.bolt,
      color: Colors.amber,
      route: '/calculators/construction/electrical',
      category: CalculatorCategoryType.construction,
      tags: ['Disjuntor', 'Cabo', 'Corrente'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'paint',
      title: 'Tinta',
      description: 'Quantidade de tinta para pintura',
      icon: Icons.format_paint,
      color: Colors.orange,
      route: '/calculators/construction/paint',
      category: CalculatorCategoryType.construction,
      tags: ['Parede', 'Litros'],
    ),
    CalculatorItem(
      id: 'flooring',
      title: 'Piso e Revestimento',
      description: 'Peças, caixas e rejunte necessários',
      icon: Icons.grid_on,
      color: Colors.brown,
      route: '/calculators/construction/flooring',
      category: CalculatorCategoryType.construction,
      tags: ['Cerâmica', 'Porcelanato'],
    ),
    CalculatorItem(
      id: 'brick',
      title: 'Tijolos e Blocos',
      description: 'Tijolos e argamassa para alvenaria',
      icon: Icons.crop_square,
      color: Colors.red,
      route: '/calculators/construction/brick',
      category: CalculatorCategoryType.construction,
      tags: ['Alvenaria', 'Parede'],
    ),
    CalculatorItem(
      id: 'mortar',
      title: 'Argamassa',
      description: 'Quantidade para reboco e assentamento',
      icon: Icons.texture,
      color: Colors.brown,
      route: '/calculators/construction/mortar',
      category: CalculatorCategoryType.construction,
      tags: ['Reboco', 'Chapisco', 'Contrapiso'],
    ),
    CalculatorItem(
      id: 'glass',
      title: 'Vidro e Esquadrias',
      description: 'Área e peso de vidros',
      icon: Icons.window,
      color: Colors.lightBlue,
      route: '/calculators/construction/glass',
      category: CalculatorCategoryType.construction,
      tags: ['Janela', 'Temperado', 'Laminado'],
    ),
    CalculatorItem(
      id: 'rebar',
      title: 'Ferragem',
      description: 'Armadura para estruturas de concreto',
      icon: Icons.grid_4x4,
      color: Colors.blueGrey,
      route: '/calculators/construction/rebar',
      category: CalculatorCategoryType.construction,
      tags: ['Aço', 'Vergalhão', 'Armadura'],
    ),
    CalculatorItem(
      id: 'slab',
      title: 'Laje',
      description: 'Materiais para laje maciça ou treliçada',
      icon: Icons.view_agenda,
      color: Colors.grey,
      route: '/calculators/construction/slab',
      category: CalculatorCategoryType.construction,
      tags: ['Treliçada', 'Maciça', 'Pré-moldada'],
    ),
    CalculatorItem(
      id: 'water_tank',
      title: 'Caixa d\'Água',
      description: 'Dimensionamento de reservatório',
      icon: Icons.water_drop,
      color: Colors.blue,
      route: '/calculators/construction/water-tank',
      category: CalculatorCategoryType.construction,
      tags: ['Reservatório', 'Capacidade'],
    ),
    CalculatorItem(
      id: 'drywall',
      title: 'Drywall e Gesso',
      description: 'Placas e perfis para paredes secas',
      icon: Icons.view_compact,
      color: Colors.white70,
      route: '/calculators/construction/drywall',
      category: CalculatorCategoryType.construction,
      tags: ['Gesso', 'Parede Seca'],
    ),
    CalculatorItem(
      id: 'roof',
      title: 'Telhado',
      description: 'Telhas e madeiramento',
      icon: Icons.roofing,
      color: Colors.deepOrange,
      route: '/calculators/construction/roof',
      category: CalculatorCategoryType.construction,
      tags: ['Telha', 'Madeira', 'Cobertura'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'earthwork',
      title: 'Terraplenagem',
      description: 'Volume de aterro e escavação',
      icon: Icons.landscape,
      color: Colors.brown,
      route: '/calculators/construction/earthwork',
      category: CalculatorCategoryType.construction,
      tags: ['Aterro', 'Escavação', 'Terra'],
    ),
    CalculatorItem(
      id: 'plumbing',
      title: 'Tubulação PVC',
      description: 'Tubos e conexões hidráulicas',
      icon: Icons.plumbing,
      color: Colors.indigo,
      route: '/calculators/construction/plumbing',
      category: CalculatorCategoryType.construction,
      tags: ['Hidráulica', 'Esgoto', 'Água'],
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // SAÚDE (12)
    // ═══════════════════════════════════════════════════════════════════════
    CalculatorItem(
      id: 'bmi',
      title: 'IMC',
      description: 'Índice de Massa Corporal',
      icon: Icons.monitor_weight_outlined,
      color: Colors.green,
      route: '/calculators/health/bmi',
      category: CalculatorCategoryType.health,
      tags: ['Peso', 'Altura', 'Saúde'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'bmr',
      title: 'Taxa Metabólica',
      description: 'Calorias diárias necessárias',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      route: '/calculators/health/bmr',
      category: CalculatorCategoryType.health,
      tags: ['Calorias', 'Metabolismo'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'water',
      title: 'Necessidade Hídrica',
      description: 'Quantidade ideal de água por dia',
      icon: Icons.water_drop,
      color: Colors.blue,
      route: '/calculators/health/water',
      category: CalculatorCategoryType.health,
      tags: ['Água', 'Hidratação'],
    ),
    CalculatorItem(
      id: 'ideal-weight',
      title: 'Peso Ideal',
      description: '4 fórmulas científicas',
      icon: Icons.accessibility_new,
      color: Colors.teal,
      route: '/calculators/health/ideal-weight',
      category: CalculatorCategoryType.health,
      tags: ['Peso', 'Altura'],
    ),
    CalculatorItem(
      id: 'body-fat',
      title: 'Gordura Corporal',
      description: 'Percentual de gordura (US Navy)',
      icon: Icons.pie_chart,
      color: Colors.purple,
      route: '/calculators/health/body-fat',
      category: CalculatorCategoryType.health,
      tags: ['Composição', 'Medidas'],
    ),
    CalculatorItem(
      id: 'macros',
      title: 'Macronutrientes',
      description: 'Carboidratos, proteínas e gorduras',
      icon: Icons.pie_chart_outline,
      color: Colors.amber,
      route: '/calculators/health/macros',
      category: CalculatorCategoryType.health,
      tags: ['Dieta', 'Nutrição'],
    ),
    CalculatorItem(
      id: 'protein',
      title: 'Proteínas Diárias',
      description: 'Necessidade proteica por peso',
      icon: Icons.restaurant,
      color: Colors.red,
      route: '/calculators/health/protein',
      category: CalculatorCategoryType.health,
      tags: ['Proteína', 'Dieta', 'Músculo'],
    ),
    CalculatorItem(
      id: 'exercise-calories',
      title: 'Calorias Exercício',
      description: 'Gasto calórico por atividade',
      icon: Icons.directions_run,
      color: Colors.deepOrange,
      route: '/calculators/health/exercise-calories',
      category: CalculatorCategoryType.health,
      tags: ['Exercício', 'Calorias', 'Treino'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'waist-hip',
      title: 'Cintura-Quadril',
      description: 'Risco cardiovascular (RCQ)',
      icon: Icons.straighten,
      color: Colors.pink,
      route: '/calculators/health/waist-hip',
      category: CalculatorCategoryType.health,
      tags: ['Medidas', 'Risco', 'Saúde'],
    ),
    CalculatorItem(
      id: 'blood-alcohol',
      title: 'Álcool no Sangue',
      description: 'Concentração alcoólica (BAC)',
      icon: Icons.local_bar,
      color: Colors.brown,
      route: '/calculators/health/blood-alcohol',
      category: CalculatorCategoryType.health,
      tags: ['Álcool', 'BAC', 'Segurança'],
    ),
    CalculatorItem(
      id: 'blood-volume',
      title: 'Volume Sanguíneo',
      description: 'Estimativa por peso e altura',
      icon: Icons.bloodtype,
      color: Colors.red,
      route: '/calculators/health/blood-volume',
      category: CalculatorCategoryType.health,
      tags: ['Sangue', 'Volume', 'Corpo'],
    ),
    CalculatorItem(
      id: 'caloric-deficit',
      title: 'Déficit Calórico',
      description: 'Meta para perda ou ganho de peso',
      icon: Icons.trending_down,
      color: Colors.indigo,
      route: '/calculators/health/caloric-deficit',
      category: CalculatorCategoryType.health,
      tags: ['Dieta', 'Emagrecimento', 'Meta'],
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // PET (8)
    // ═══════════════════════════════════════════════════════════════════════
    CalculatorItem(
      id: 'pet-age',
      title: 'Idade do Pet',
      description: 'Idade em anos humanos',
      icon: Icons.pets,
      color: Colors.blue,
      route: '/calculators/pet/age',
      category: CalculatorCategoryType.pet,
      tags: ['Cachorro', 'Gato', 'Idade'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'pet-pregnancy',
      title: 'Gestação Pet',
      description: 'Acompanhe a gravidez',
      icon: Icons.child_friendly,
      color: Colors.pink,
      route: '/calculators/pet/pregnancy',
      category: CalculatorCategoryType.pet,
      tags: ['Gravidez', 'Parto', 'Filhotes'],
    ),
    CalculatorItem(
      id: 'pet-body-condition',
      title: 'Condição Corporal',
      description: 'BCS - Escore de condição física',
      icon: Icons.fitness_center,
      color: Colors.orange,
      route: '/calculators/pet/body-condition',
      category: CalculatorCategoryType.pet,
      tags: ['BCS', 'Peso', 'Nutrição'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'pet-caloric-needs',
      title: 'Calorias Pet',
      description: 'Necessidade calórica diária',
      icon: Icons.restaurant,
      color: Colors.green,
      route: '/calculators/pet/caloric-needs',
      category: CalculatorCategoryType.pet,
      tags: ['Ração', 'Alimentação', 'Calorias'],
    ),
    CalculatorItem(
      id: 'pet-medication',
      title: 'Dosagem Medicamento',
      description: 'Dose por peso do animal',
      icon: Icons.medication,
      color: Colors.red,
      route: '/calculators/pet/medication',
      category: CalculatorCategoryType.pet,
      tags: ['Remédio', 'Veterinário', 'Dose'],
    ),
    CalculatorItem(
      id: 'pet-fluid-therapy',
      title: 'Fluidoterapia',
      description: 'Volume de fluidos IV',
      icon: Icons.water_drop,
      color: Colors.cyan,
      route: '/calculators/pet/fluid-therapy',
      category: CalculatorCategoryType.pet,
      tags: ['Soro', 'Desidratação', 'IV'],
    ),
    CalculatorItem(
      id: 'pet-ideal-weight',
      title: 'Peso Ideal Pet',
      description: 'Meta de peso saudável',
      icon: Icons.monitor_weight,
      color: Colors.purple,
      route: '/calculators/pet/ideal-weight',
      category: CalculatorCategoryType.pet,
      tags: ['Peso', 'Obesidade', 'Dieta'],
    ),
    CalculatorItem(
      id: 'pet-unit-conversion',
      title: 'Conversão Unidades',
      description: 'kg↔lb, °C↔°F e mais',
      icon: Icons.swap_horiz,
      color: Colors.grey,
      route: '/calculators/pet/unit-conversion',
      category: CalculatorCategoryType.pet,
      tags: ['Converter', 'Medidas', 'Unidades'],
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // AGRICULTURA (18)
    // ═══════════════════════════════════════════════════════════════════════
    CalculatorItem(
      id: 'npk',
      title: 'Adubação NPK',
      description: 'Calcule a necessidade de nutrientes',
      icon: Icons.grass,
      color: Colors.green,
      route: '/calculators/agriculture/npk',
      category: CalculatorCategoryType.agriculture,
      tags: ['Fertilizante', 'Nutrientes', 'Solo'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'seed-rate',
      title: 'Taxa de Semeadura',
      description: 'Quantidade de sementes por hectare',
      icon: Icons.agriculture,
      color: Colors.amber,
      route: '/calculators/agriculture/seed-rate',
      category: CalculatorCategoryType.agriculture,
      tags: ['Sementes', 'Plantio', 'Lavoura'],
    ),
    CalculatorItem(
      id: 'irrigation',
      title: 'Irrigação',
      description: 'Volume de água e tempo de irrigação',
      icon: Icons.water,
      color: Colors.blue,
      route: '/calculators/agriculture/irrigation',
      category: CalculatorCategoryType.agriculture,
      tags: ['Água', 'Pivô', 'Gotejo'],
    ),
    CalculatorItem(
      id: 'fertilizer-dosing',
      title: 'Dosagem Fertilizante',
      description: 'Quantidade de adubo por área',
      icon: Icons.science,
      color: Colors.purple,
      route: '/calculators/agriculture/fertilizer-dosing',
      category: CalculatorCategoryType.agriculture,
      tags: ['Adubo', 'Dosagem', 'Aplicação'],
    ),
    CalculatorItem(
      id: 'soil-ph',
      title: 'Correção pH Solo',
      description: 'Calcário necessário para correção',
      icon: Icons.landscape,
      color: Colors.brown,
      route: '/calculators/agriculture/soil-ph',
      category: CalculatorCategoryType.agriculture,
      tags: ['Calcário', 'pH', 'Acidez'],
    ),
    CalculatorItem(
      id: 'planting-density',
      title: 'Densidade Plantio',
      description: 'Plantas por hectare',
      icon: Icons.grid_on,
      color: Colors.lightGreen,
      route: '/calculators/agriculture/planting-density',
      category: CalculatorCategoryType.agriculture,
      tags: ['Espaçamento', 'Plantas', 'Estande'],
    ),
    CalculatorItem(
      id: 'yield-prediction',
      title: 'Previsão Produtividade',
      description: 'Estimativa de colheita',
      icon: Icons.trending_up,
      color: Colors.orange,
      route: '/calculators/agriculture/yield-prediction',
      category: CalculatorCategoryType.agriculture,
      tags: ['Colheita', 'Produção', 'Safra'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'evapotranspiration',
      title: 'Evapotranspiração',
      description: 'ETo e necessidade hídrica',
      icon: Icons.wb_sunny,
      color: Colors.cyan,
      route: '/calculators/agriculture/evapotranspiration',
      category: CalculatorCategoryType.agriculture,
      tags: ['ETo', 'Clima', 'Água'],
    ),
    CalculatorItem(
      id: 'tractor-power',
      title: 'Potência do Trator',
      description: 'HP necessário para implementos',
      icon: Icons.precision_manufacturing,
      color: Colors.green,
      route: '/calculators/agriculture/tractor-power',
      category: CalculatorCategoryType.agriculture,
      tags: ['Trator', 'Potência', 'Implemento'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'fuel-consumption',
      title: 'Consumo Combustível',
      description: 'Litros por hora e hectare',
      icon: Icons.local_gas_station,
      color: Colors.amber,
      route: '/calculators/agriculture/fuel-consumption',
      category: CalculatorCategoryType.agriculture,
      tags: ['Diesel', 'Combustível', 'Custo'],
    ),
    CalculatorItem(
      id: 'spray-mix',
      title: 'Calda Pulverização',
      description: 'Preparo de tanques e dosagens',
      icon: Icons.water_drop,
      color: Colors.teal,
      route: '/calculators/agriculture/spray-mix',
      category: CalculatorCategoryType.agriculture,
      tags: ['Pulverizador', 'Defensivo', 'Calda'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'nozzle-flow',
      title: 'Vazão de Bicos',
      description: 'Vazão e seleção de pontas',
      icon: Icons.shower,
      color: Colors.blue,
      route: '/calculators/agriculture/nozzle-flow',
      category: CalculatorCategoryType.agriculture,
      tags: ['Bico', 'Vazão', 'Ponta'],
    ),
    CalculatorItem(
      id: 'field-capacity',
      title: 'Capacidade de Campo',
      description: 'Hectares por hora',
      icon: Icons.speed,
      color: Colors.deepOrange,
      route: '/calculators/agriculture/field-capacity',
      category: CalculatorCategoryType.agriculture,
      tags: ['Rendimento', 'Operação', 'Eficiência'],
    ),
    CalculatorItem(
      id: 'planter-setup',
      title: 'Regulagem Plantadeira',
      description: 'Sementes por metro e população',
      icon: Icons.settings,
      color: Colors.lightGreen,
      route: '/calculators/agriculture/planter-setup',
      category: CalculatorCategoryType.agriculture,
      tags: ['Plantadeira', 'Semeadura', 'Regulagem'],
    ),
    CalculatorItem(
      id: 'tractor-ballast',
      title: 'Lastro do Trator',
      description: 'Distribuição de peso ideal',
      icon: Icons.balance,
      color: Colors.blueGrey,
      route: '/calculators/agriculture/tractor-ballast',
      category: CalculatorCategoryType.agriculture,
      tags: ['Lastro', 'Peso', 'Tração'],
    ),
    CalculatorItem(
      id: 'tire-pressure',
      title: 'Pressão de Pneus',
      description: 'Pressão ideal por operação',
      icon: Icons.tire_repair,
      color: Colors.grey,
      route: '/calculators/agriculture/tire-pressure',
      category: CalculatorCategoryType.agriculture,
      tags: ['Pneu', 'Pressão', 'Tração'],
    ),
    CalculatorItem(
      id: 'operational-cost',
      title: 'Custo Operacional',
      description: 'Reais por hectare da operação',
      icon: Icons.attach_money,
      color: Colors.green,
      route: '/calculators/agriculture/operational-cost',
      category: CalculatorCategoryType.agriculture,
      tags: ['Custo', 'Operação', 'Economia'],
      isPopular: true,
    ),
    CalculatorItem(
      id: 'harvester-setup',
      title: 'Regulagem Colhedora',
      description: 'Configurações e perdas',
      icon: Icons.agriculture,
      color: Colors.orange,
      route: '/calculators/agriculture/harvester-setup',
      category: CalculatorCategoryType.agriculture,
      tags: ['Colhedora', 'Perdas', 'Regulagem'],
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // PECUÁRIA (3)
    // ═══════════════════════════════════════════════════════════════════════
    CalculatorItem(
      id: 'feed',
      title: 'Ração Animal',
      description: 'Consumo diário de ração',
      icon: Icons.pets,
      color: Colors.red,
      route: '/calculators/agriculture/feed',
      category: CalculatorCategoryType.livestock,
      tags: ['Gado', 'Suíno', 'Frango', 'Alimentação'],
    ),
    CalculatorItem(
      id: 'weight-gain',
      title: 'Ganho de Peso',
      description: 'Tempo para atingir peso meta',
      icon: Icons.monitor_weight,
      color: Colors.teal,
      route: '/calculators/agriculture/weight-gain',
      category: CalculatorCategoryType.livestock,
      tags: ['Engorda', 'Gado', 'Pecuária'],
    ),
    CalculatorItem(
      id: 'breeding-cycle',
      title: 'Ciclo Reprodutivo',
      description: 'Gestação e parto de animais',
      icon: Icons.child_friendly,
      color: Colors.pink,
      route: '/calculators/agriculture/breeding-cycle',
      category: CalculatorCategoryType.livestock,
      tags: ['Gestação', 'Parto', 'Reprodução'],
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get calculators by category
  static List<CalculatorItem> byCategory(CalculatorCategoryType category) {
    return all.where((c) => c.category == category).toList();
  }

  /// Get count by category
  static int countByCategory(CalculatorCategoryType category) {
    return all.where((c) => c.category == category).length;
  }

  /// Get all counts as a map
  static Map<CalculatorCategoryType, int> getAllCounts() {
    return {
      for (var cat in CalculatorCategoryType.values) cat: countByCategory(cat),
    };
  }

  /// Get total count
  static int get totalCount => all.length;

  /// Get popular calculators
  static List<CalculatorItem> get popular {
    return all.where((c) => c.isPopular).toList();
  }

  /// Get popular count
  static int get popularCount => popular.length;

  /// Search calculators by query (title, description, tags)
  static List<CalculatorItem> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      return all;
    }

    return all.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  /// Get calculator by ID
  static CalculatorItem? byId(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get calculator by route
  static CalculatorItem? byRoute(String route) {
    try {
      return all.firstWhere((c) => c.route == route);
    } catch (_) {
      return null;
    }
  }

  /// Financial calculators
  static List<CalculatorItem> get financial =>
      byCategory(CalculatorCategoryType.financial);

  /// Construction calculators
  static List<CalculatorItem> get construction =>
      byCategory(CalculatorCategoryType.construction);

  /// Health calculators
  static List<CalculatorItem> get health =>
      byCategory(CalculatorCategoryType.health);

  /// Pet calculators
  static List<CalculatorItem> get pet =>
      byCategory(CalculatorCategoryType.pet);

  /// Agriculture calculators
  static List<CalculatorItem> get agriculture =>
      byCategory(CalculatorCategoryType.agriculture);

  /// Livestock calculators
  static List<CalculatorItem> get livestock =>
      byCategory(CalculatorCategoryType.livestock);
}
