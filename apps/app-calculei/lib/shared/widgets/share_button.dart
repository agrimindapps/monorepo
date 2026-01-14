import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Share button widget for sharing calculation results
class ShareButton extends StatelessWidget {
  final String text;
  final String? subject;
  final IconData icon;
  final String? tooltip;

  const ShareButton({
    super.key,
    required this.text,
    this.subject,
    this.icon = Icons.share,
    this.tooltip = 'Compartilhar',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () => _share(context),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Share FAB (Floating Action Button)
class ShareFAB extends StatelessWidget {
  final String text;
  final String? subject;
  final String? label;

  const ShareFAB({super.key, required this.text, this.subject, this.label});

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: () => _share(context),
        icon: const Icon(Icons.share),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: () => _share(context),
      child: const Icon(Icons.share),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Utility class for formatting share messages
class ShareFormatter {
  static const String _footer = '''

_________________
Calculado por Calculei
by Agrimind
https://calculei.agrimind.com.br''';

  /// Format vacation calculation for sharing
  static String formatVacationCalculation({
    required double grossSalary,
    required int vacationDays,
    required double totalGross,
    required double totalNet,
    int? dependents,
    bool? sellVacationDays,
  }) {
    return '''
📋 Cálculo de Férias - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
📅 Dias de Férias: $vacationDays
${sellVacationDays == true ? '💰 Abono Pecuniário (Venda): Sim' : ''}
${dependents != null ? '👨‍👩‍👧‍👦 Dependentes: $dependents' : ''}

✅ Total Bruto: R\$ ${totalGross.toStringAsFixed(2)}
💵 Total Líquido: R\$ ${totalNet.toStringAsFixed(2)}
$_footer''';
  }

  /// Format thirteenth salary calculation for sharing
  static String formatThirteenthSalary({
    required double grossSalary,
    required int monthsWorked,
    required double totalGross,
    required double totalNet,
    required bool isAdvance,
  }) {
    return '''
📋 Cálculo de 13º Salário - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
📅 Meses Trabalhados: $monthsWorked
${isAdvance ? '🔹 Primeira Parcela (Adiantamento)' : '🔹 Parcela Única / Segunda Parcela'}

✅ Total Bruto: R\$ ${totalGross.toStringAsFixed(2)}
💵 Total Líquido: R\$ ${totalNet.toStringAsFixed(2)}
$_footer''';
  }

  /// Format net salary calculation for sharing
  static String formatNetSalary({
    required double grossSalary,
    required double inss,
    required double ir,
    required double netSalary,
    double? discounts,
  }) {
    return '''
📋 Cálculo de Salário Líquido - Calculei App

💰 Salário Bruto: R\$ ${grossSalary.toStringAsFixed(2)}
${discounts != null && discounts > 0 ? '📉 Outros Descontos: R\$ ${discounts.toStringAsFixed(2)}' : ''}

📉 Descontos Legais:
• INSS: R\$ ${inss.toStringAsFixed(2)}
• IRRF: R\$ ${ir.toStringAsFixed(2)}

💵 Salário Líquido: R\$ ${netSalary.toStringAsFixed(2)}
$_footer''';
  }

  /// Format overtime calculation for sharing
  static String formatOvertime({
    required double grossSalary,
    required double totalOvertimeValue,
    required int weeklyHours,
  }) {
    return '''
📋 Cálculo de Horas Extras - Calculei App

💰 Salário Base: R\$ ${grossSalary.toStringAsFixed(2)}
⏱️ Jornada Semanal: ${weeklyHours}h

✅ Valor Total Horas Extras: R\$ ${totalOvertimeValue.toStringAsFixed(2)}
$_footer''';
  }

  /// Format unemployment insurance calculation for sharing
  static String formatUnemploymentInsurance({
    required double averageSalary,
    required int monthsWorked,
    required int installmentsCount,
    required double installmentValue,
  }) {
    return '''
📋 Cálculo de Seguro Desemprego - Calculei App

💰 Média Salarial: R\$ ${averageSalary.toStringAsFixed(2)}
📅 Meses Trabalhados: $monthsWorked

✅ Parcelas: $installmentsCount x R\$ ${installmentValue.toStringAsFixed(2)}
$_footer''';
  }

  /// Format emergency reserve calculation for sharing
  static String formatEmergencyReserve({
    required double monthlyExpenses,
    required int monthsToCover,
    required double totalReserve,
    double? monthlySavings,
  }) {
    return '''
📋 Reserva de Emergência - Calculei App

💸 Gastos Mensais: R\$ ${monthlyExpenses.toStringAsFixed(2)}
📅 Meses para Cobrir: $monthsToCover

✅ Valor da Reserva: R\$ ${totalReserve.toStringAsFixed(2)}
${monthlySavings != null && monthlySavings > 0 ? '💰 Investimento Mensal Sugerido: R\$ ${monthlySavings.toStringAsFixed(2)}' : ''}
$_footer''';
  }

  /// Format cash vs installment calculation for sharing
  static String formatCashVsInstallment({
    required double cashPrice,
    required double installmentPrice,
    required int installments,
    required String bestOption,
  }) {
    return '''
📋 À Vista ou Parcelado? - Calculei App

💵 Preço à Vista: R\$ ${cashPrice.toStringAsFixed(2)}
💳 Parcelado: $installments x R\$ ${installmentPrice.toStringAsFixed(2)}

✅ Melhor Opção: $bestOption
$_footer''';
  }

  /// Generic share message
  static String formatGeneric({
    required String title,
    required Map<String, String> data,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📋 $title - Calculei App\n');

    data.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln(_footer);

    return buffer.toString();
  }

  // ========== CONSTRUCTION CALCULATORS ==========

  /// Format concrete calculation for sharing
  static String formatConcreteCalculation({
    required double volume,
    required int cementBags,
    required double sandCubicMeters,
    required double gravelCubicMeters,
    required int waterLiters,
    required String concreteType,
    required String concreteStrength,
  }) {
    return '''
📋 Cálculo de Concreto - Calculei App

📏 Volume Total: ${volume.toStringAsFixed(2)} m³
🏗️ Tipo: $concreteType - $concreteStrength

📦 Materiais Necessários:
• Cimento: $cementBags sacos (50kg)
• Areia: ${sandCubicMeters.toStringAsFixed(2)} m³
• Brita: ${gravelCubicMeters.toStringAsFixed(2)} m³
• Água: $waterLiters litros
$_footer''';
  }

  /// Format plumbing calculation for sharing
  static String formatPlumbingCalculation({
    required String systemType,
    required String pipeDiameter,
    required double totalLength,
    required int pipeCount,
    required int glueAmount,
    required int numberOfElbows,
    required int numberOfTees,
    required int numberOfCouplings,
  }) {
    final connectionsText = StringBuffer();
    if (numberOfElbows > 0 || numberOfTees > 0 || numberOfCouplings > 0) {
      connectionsText.writeln();
      connectionsText.writeln('🔧 Conexões:');
      if (numberOfElbows > 0) {
        connectionsText.writeln('• Joelhos 90°: $numberOfElbows un');
      }
      if (numberOfTees > 0) {
        connectionsText.writeln('• Ts (Junções): $numberOfTees un');
      }
      if (numberOfCouplings > 0) {
        connectionsText.writeln('• Luvas: $numberOfCouplings un');
      }
    }

    return '''
📋 Cálculo de Tubulação - Calculei App

🚰 Sistema: $systemType
📏 Diâmetro: $pipeDiameter
📐 Comprimento Total: ${totalLength.toStringAsFixed(1)} m

📦 Materiais Necessários:
• Tubos PVC: $pipeCount unidades (6m)
• Cola PVC: $glueAmount ml$connectionsText
$_footer''';
  }

  /// Format roof calculation for sharing
  static String formatRoofCalculation({
    required double roofArea,
    required int numberOfTiles,
    required int ridgeTilesCount,
    required double woodFrameMeters,
    required String roofType,
    required double roofSlope,
  }) {
    return '''
📋 Cálculo de Telhado - Calculei App

📏 Área do Telhado: ${roofArea.toStringAsFixed(2)} m²
🏠 Tipo de Telha: $roofType
📐 Inclinação: ${roofSlope.toStringAsFixed(0)}%

📦 Materiais Necessários:
• Telhas: $numberOfTiles unidades
• Cumeeiras: $ridgeTilesCount unidades
• Madeiramento Total: ${woodFrameMeters.toStringAsFixed(2)} m
$_footer''';
  }

  /// Format drywall calculation for sharing
  static String formatDrywallCalculation({
    required double wallArea,
    required int numberOfPanels,
    required double profilesMeters,
    required int screwsCount,
    required double jointTapeMeters,
    required double jointCompoundKg,
    required String wallType,
  }) {
    return '''
📋 Cálculo de Drywall - Calculei App

📏 Área da Parede: ${wallArea.toStringAsFixed(2)} m²
🏗️ Tipo: Parede $wallType

📦 Materiais Necessários:
• Placas (1.20×2.40m): $numberOfPanels unidades
• Perfis Metálicos: ${profilesMeters.toStringAsFixed(1)} metros
• Parafusos: $screwsCount unidades
• Fita de Junção: ${jointTapeMeters.toStringAsFixed(1)} metros
• Massa Corrida: ${jointCompoundKg.toStringAsFixed(1)} kg
$_footer''';
  }

  /// Format electrical calculation for sharing
  static String formatElectricalCalculation({
    required double totalPower,
    required double voltage,
    required String circuitType,
    required double totalCurrent,
    required double wireGauge,
    required int breakerSize,
    required double cableLength,
    required int numberOfCircuits,
    double? voltageDrop,
  }) {
    final voltageDropText = voltageDrop != null 
        ? '\n⚡ Queda de Tensão: ${voltageDrop.toStringAsFixed(2)}%' 
        : '';
    
    return '''
📋 Cálculo Elétrico - Calculei App

⚡ Potência Total: ${totalPower.toStringAsFixed(0)} W
🔌 Tensão: ${voltage.toInt()}V - $circuitType
⚡ Corrente Total: ${totalCurrent.toStringAsFixed(2)} A$voltageDropText

🔧 Especificações Recomendadas:
• Bitola do Cabo: ${wireGauge.toStringAsFixed(1)} mm²
• Disjuntor: $breakerSize A
• Comprimento: ${cableLength.toStringAsFixed(1)} m
• Circuitos: $numberOfCircuits
$_footer''';
  }

  /// Format slab calculation for sharing
  static String formatSlabCalculation({
    required String slabType,
    required double concreteVolume,
    required int cementBags,
    required double sandCubicMeters,
    required double gravelCubicMeters,
    required int steelWeight,
    required int numberOfBlocks,
    required int waterLiters,
  }) {
    final blocksText = numberOfBlocks > 0
        ? '\n• Blocos: $numberOfBlocks unidades'
        : '';

    return '''
📋 Cálculo de Laje - Calculei App

🏗️ Tipo: Laje $slabType
📏 Volume de Concreto: ${concreteVolume.toStringAsFixed(2)} m³

📦 Materiais Necessários:
• Cimento: $cementBags sacos (50kg)
• Areia: ${sandCubicMeters.toStringAsFixed(2)} m³
• Brita: ${gravelCubicMeters.toStringAsFixed(2)} m³
• Água: $waterLiters litros
• Aço/Ferro: $steelWeight kg$blocksText
$_footer''';
  }

  /// Format glass calculation for sharing
  static String formatGlassCalculation({
    required double totalArea,
    required double estimatedWeight,
    required String glassType,
    required int glassThickness,
    required int numberOfPanels,
  }) {
    return '''
📋 Cálculo de Vidros - Calculei App

📏 Área Total: ${totalArea.toStringAsFixed(2)} m²
🪟 Painéis: $numberOfPanels unidades
🏗️ Tipo: Vidro $glassType - ${glassThickness}mm

⚖️ Especificações:
• Peso total: ${estimatedWeight.toStringAsFixed(1)} kg
• Peso por painel: ${(estimatedWeight / numberOfPanels).toStringAsFixed(1)} kg

💡 Considere instalação profissional para segurança.
$_footer''';
  }

  /// Format mortar calculation for sharing
  static String formatMortarCalculation({
    required double area,
    required double thickness,
    required double volume,
    required int cementBags,
    required double sandCubicMeters,
    required int waterLiters,
    required String mortarType,
  }) {
    return '''
📋 Cálculo de Argamassa - Calculei App

📏 Área: ${area.toStringAsFixed(1)} m²
📐 Espessura: ${thickness.toStringAsFixed(1)} cm
📦 Volume Total: ${volume.toStringAsFixed(2)} m³
🏗️ Tipo: Argamassa para $mortarType

📦 Materiais Necessários:
• Cimento: $cementBags sacos (50kg)
• Areia: ${sandCubicMeters.toStringAsFixed(2)} m³
• Água: $waterLiters litros
$_footer''';
  }

  /// Format paint calculation for sharing
  static String formatPaintCalculation({
    required double paintLiters,
    required double netArea,
    required String paintType,
    required int coats,
    required String recommendedOption,
  }) {
    return '''
📋 Cálculo de Tinta - Calculei App

🎨 Tinta Necessária: ${paintLiters.toStringAsFixed(1)} litros
📏 Área Líquida: ${netArea.toStringAsFixed(1)} m²
🖌️ Tipo: $paintType
🔄 Demãos: $coats

💡 Recomendação: $recommendedOption
$_footer''';
  }

  /// Format flooring calculation for sharing
  static String formatFlooringCalculation({
    required int boxesNeeded,
    required int tilesWithWaste,
    required int tilesNeeded,
    required double roomArea,
    required double groutKg,
    required double mortarKg,
    required String flooringType,
    required int wastePercentage,
  }) {
    return '''
📋 Cálculo de Piso - Calculei App

📦 Caixas Necessárias: $boxesNeeded
🔲 Peças: $tilesWithWaste (com $wastePercentage% de perda)
📏 Área: ${roomArea.toStringAsFixed(1)} m²
🏠 Tipo: $flooringType

🛠️ Materiais Complementares:
• Rejunte: ${groutKg.toStringAsFixed(1)} kg
• Argamassa: ${mortarKg.toStringAsFixed(1)} kg

ℹ️ Peças sem perda: $tilesNeeded
$_footer''';
  }

  /// Format brick calculation for sharing
  static String formatBrickCalculation({
    required int bricksWithWaste,
    required int bricksNeeded,
    required double netArea,
    required String brickTypeName,
    required int mortarBags,
    required double sandCubicMeters,
    required int cementBags,
    required int wastePercentage,
  }) {
    return '''
📋 Cálculo de Tijolos - Calculei App

🧱 Total de $brickTypeName: $bricksWithWaste unidades
   (com $wastePercentage% de perda)
📏 Área Líquida: ${netArea.toStringAsFixed(1)} m²

🏗️ Materiais para Argamassa:
• Argamassa: $mortarBags sacos (20kg)
• Areia: ${sandCubicMeters.toStringAsFixed(2)} m³
• Cimento: $cementBags sacos (50kg)

ℹ️ Tijolos sem perda: $bricksNeeded
$_footer''';
  }

  /// Format rebar calculation for sharing
  static String formatRebarCalculation({
    required String structureType,
    required double concreteVolume,
    required String rebarDiameter,
    required double totalWeight,
    required double totalLength,
    required int numberOfBars,
    required double steelRate,
  }) {
    return '''
📋 Cálculo de Ferragem - Calculei App

🏗️ Tipo de Estrutura: $structureType
📏 Volume de Concreto: ${concreteVolume.toStringAsFixed(2)} m³
⚙️ Taxa de Aço: ${steelRate.toStringAsFixed(0)} kg/m³

🔩 Ferragem Necessária:
• Peso Total: ${totalWeight.toStringAsFixed(1)} kg
• Comprimento Total: ${totalLength.toStringAsFixed(1)} m
• Diâmetro: $rebarDiameter
• Barras de 12m: $numberOfBars unidades

💡 Considere 5-10% de perda no corte e amarração
$_footer''';
  }

  /// Format BMI calculation for sharing
  static String formatBmiCalculation({
    required double bmi,
    required String classification,
    required double minIdealWeight,
    required double maxIdealWeight,
  }) {
    return '''
📋 Cálculo de IMC - Calculei App

📊 Seu IMC: ${bmi.toStringAsFixed(1)}
🏷️ Classificação: $classification

⚖️ Faixa de Peso Ideal:
• Mínimo: ${minIdealWeight.toStringAsFixed(1)} kg
• Máximo: ${maxIdealWeight.toStringAsFixed(1)} kg

ℹ️ O IMC é uma referência inicial. Consulte um profissional para avaliação completa.
$_footer''';
  }

  /// Format BMR calculation for sharing
  static String formatBmrCalculation({
    required double bmr,
    required double tdee,
    required String activityLevel,
    required double caloriesForWeightLoss,
    required double caloriesForWeightGain,
  }) {
    return '''
📋 Cálculo de TMB - Calculei App

🔥 Taxa Metabólica Basal: ${bmr.toStringAsFixed(0)} kcal/dia
⚡ Gasto Energético Total: ${tdee.toStringAsFixed(0)} kcal/dia
🏃 Nível de atividade: $activityLevel

🎯 Metas Calóricas:
• Para emagrecer: ${caloriesForWeightLoss.toStringAsFixed(0)} kcal/dia
• Para manter: ${tdee.toStringAsFixed(0)} kcal/dia
• Para ganhar peso: ${caloriesForWeightGain.toStringAsFixed(0)} kcal/dia

ℹ️ Déficit de 500 kcal/dia ≈ perda de 0.5kg/semana
$_footer''';
  }

  /// Format water intake calculation for sharing
  static String formatWaterIntakeCalculation({
    required double baseLiters,
    required double adjustedLiters,
    required int glasses,
    required int bottles,
  }) {
    return '''
📋 Cálculo de Hidratação - Calculei App

💧 Consumo Recomendado: ${adjustedLiters.toStringAsFixed(1)} litros/dia

📊 Equivalências:
• 🥤 $glasses copos de 250ml
• 🍶 $bottles garrafas de 500ml

📈 Consumo base: ${baseLiters.toStringAsFixed(1)}L (ajustado por atividade e clima)

💡 Dicas:
• Distribua ao longo do dia
• Beba um copo ao acordar
• Frutas e vegetais também hidratam
$_footer''';
  }

  /// Format ideal weight calculation for sharing
  static String formatIdealWeightCalculation({
    required double averageWeight,
    required double minRange,
    required double maxRange,
    required double devineWeight,
    required double robinsonWeight,
    required double millerWeight,
    required double hamwiWeight,
  }) {
    return '''
📋 Cálculo de Peso Ideal - Calculei App

⚖️ Peso Ideal (média): ${averageWeight.toStringAsFixed(1)} kg
📏 Faixa saudável: ${minRange.toStringAsFixed(1)} - ${maxRange.toStringAsFixed(1)} kg

📊 Por Fórmula:
• Devine: ${devineWeight.toStringAsFixed(1)} kg
• Robinson: ${robinsonWeight.toStringAsFixed(1)} kg
• Miller: ${millerWeight.toStringAsFixed(1)} kg
• Hamwi: ${hamwiWeight.toStringAsFixed(1)} kg

ℹ️ Valores são estimativas. Composição corporal e saúde geral também importam.
$_footer''';
  }

  /// Format body fat calculation for sharing
  static String formatBodyFatCalculation({
    required double bodyFatPercentage,
    required String category,
    required double fatMassKg,
    required double leanMassKg,
  }) {
    return '''
📋 Cálculo de Gordura Corporal - Calculei App

📊 Percentual de Gordura: ${bodyFatPercentage.toStringAsFixed(1)}%
🏷️ Classificação: $category

⚖️ Composição Corporal:
• Massa gorda: ${fatMassKg.toStringAsFixed(1)} kg
• Massa magra: ${leanMassKg.toStringAsFixed(1)} kg

ℹ️ Método US Navy (circunferências). Para maior precisão, consulte um profissional.
$_footer''';
  }

  /// Format macronutrients calculation for sharing
  static String formatMacronutrientsCalculation({
    required double totalCalories,
    required double carbsGrams,
    required int carbsPercent,
    required double proteinGrams,
    required int proteinPercent,
    required double fatGrams,
    required int fatPercent,
    required String goal,
  }) {
    return '''
📋 Cálculo de Macronutrientes - Calculei App

🎯 Objetivo: $goal
🔥 Calorias diárias: ${totalCalories.toStringAsFixed(0)} kcal

📊 Distribuição:
🍞 Carboidratos: ${carbsGrams.toStringAsFixed(0)}g ($carbsPercent%)
🥩 Proteínas: ${proteinGrams.toStringAsFixed(0)}g ($proteinPercent%)
🥑 Gorduras: ${fatGrams.toStringAsFixed(0)}g ($fatPercent%)

💡 Dica: Distribua as proteínas ao longo do dia para melhor absorção.
$_footer''';
  }

  /// Format daily protein calculation for sharing
  static String formatProteinasDiariasCalculation({
    required double weight,
    required String activityLevel,
    required double minProtein,
    required double maxProtein,
  }) {
    return '''
📋 Cálculo de Proteínas Diárias - Calculei App

⚖️ Peso: ${weight.toStringAsFixed(1)} kg
🏃 Nível de atividade: $activityLevel

🥩 Consumo Recomendado de Proteínas:
• Mínimo: ${minProtein.toStringAsFixed(0)}g/dia
• Máximo: ${maxProtein.toStringAsFixed(0)}g/dia

💡 Distribua a ingestão ao longo do dia (20-40g por refeição).
$_footer''';
  }

  /// Format exercise calories calculation for sharing
  static String formatCaloriasExercicioCalculation({
    required String exercise,
    required int duration,
    required double caloriesBurned,
    required double metValue,
  }) {
    return '''
📋 Cálculo de Calorias por Exercício - Calculei App

🏋️ Exercício: $exercise
⏱️ Duração: $duration minutos
🔥 MET: ${metValue.toStringAsFixed(1)}

📊 Resultado:
• Calorias queimadas: ${caloriesBurned.toStringAsFixed(0)} kcal

💡 O gasto real pode variar conforme intensidade e peso corporal.
$_footer''';
  }

  /// Format waist-hip ratio calculation for sharing
  static String formatCinturaQuadrilCalculation({
    required double waist,
    required double hip,
    required double ratio,
    required String classification,
    required String gender,
  }) {
    return '''
📋 Cálculo Relação Cintura-Quadril - Calculei App

👤 Gênero: $gender
📏 Cintura: ${waist.toStringAsFixed(1)} cm
📏 Quadril: ${hip.toStringAsFixed(1)} cm

📊 Resultado:
• RCQ: ${ratio.toStringAsFixed(2)}
• Classificação: $classification

💡 A RCQ é um indicador de risco cardiovascular.
$_footer''';
  }

  /// Format blood alcohol calculation for sharing
  static String formatAlcoolSangueCalculation({
    required double weight,
    required int drinks,
    required double hours,
    required double bac,
    required String status,
  }) {
    return '''
📋 Cálculo de Álcool no Sangue - Calculei App

⚖️ Peso: ${weight.toStringAsFixed(1)} kg
🍺 Doses: $drinks
⏱️ Tempo decorrido: ${hours.toStringAsFixed(1)} horas

📊 Resultado:
• Concentração (BAC): ${bac.toStringAsFixed(3)} g/L
• Status: $status

⚠️ Não dirija após consumir álcool. Este cálculo é apenas estimativo.
$_footer''';
  }

  /// Format blood volume calculation for sharing
  static String formatVolumeSanguineoCalculation({
    required double weight,
    required double height,
    required String gender,
    required double volumeLiters,
    required double volumeMl,
  }) {
    return '''
📋 Cálculo de Volume Sanguíneo - Calculei App

👤 Gênero: $gender
⚖️ Peso: ${weight.toStringAsFixed(1)} kg
📏 Altura: ${height.toStringAsFixed(0)} cm

📊 Resultado:
• Volume total: ${volumeLiters.toStringAsFixed(2)} litros
• Volume total: ${volumeMl.toStringAsFixed(0)} ml

ℹ️ Calculado pela fórmula de Nadler.
$_footer''';
  }

  /// Format caloric deficit/surplus calculation for sharing
  static String formatDeficitSuperavitCalculation({
    required double currentWeight,
    required double targetWeight,
    required int weeks,
    required double tdee,
    required double dailyCalories,
    required double weeklyChange,
  }) {
    final isDeficit = targetWeight < currentWeight;
    final changeKg = (currentWeight - targetWeight).abs();
    
    return '''
📋 Cálculo de ${isDeficit ? 'Déficit' : 'Superávit'} Calórico - Calculei App

⚖️ Peso atual: ${currentWeight.toStringAsFixed(1)} kg
🎯 Meta: ${targetWeight.toStringAsFixed(1)} kg
📅 Prazo: $weeks semanas

📊 Resultado:
• TDEE: ${tdee.toStringAsFixed(0)} kcal/dia
• Meta calórica: ${dailyCalories.toStringAsFixed(0)} kcal/dia
• Mudança semanal: ${weeklyChange.toStringAsFixed(2)} kg
• Total a ${isDeficit ? 'perder' : 'ganhar'}: ${changeKg.toStringAsFixed(1)} kg

💡 ${isDeficit ? 'Déficit máximo recomendado: 500-1000 kcal/dia' : 'Superávit moderado: 300-500 kcal/dia'}
$_footer''';
  }

  /// Format animal age calculation for sharing
  static String formatAnimalAgeCalculation({
    required double petAge,
    required int humanAge,
    required String species,
    required String lifeStage,
  }) {
    return '''
📋 Cálculo de Idade do Pet - Calculei App

🐾 Espécie: $species
📅 Idade do pet: ${petAge.toStringAsFixed(1)} anos
👤 Idade humana equivalente: $humanAge anos
🏷️ Fase da vida: $lifeStage

ℹ️ A conversão considera a espécie e o porte do animal.
$_footer''';
  }

  /// Format pregnancy calculation for sharing
  static String formatPregnancyCalculation({
    required String species,
    required int gestationDays,
    required String dueDate,
    required int daysRemaining,
    required String stage,
  }) {
    return '''
📋 Acompanhamento de Gestação - Calculei App

🐾 Espécie: $species
📅 Dias de gestação: $gestationDays dias
🏷️ Estágio atual: $stage
📆 Data prevista do parto: $dueDate
⏳ Dias restantes: $daysRemaining

💡 Mantenha acompanhamento veterinário regular durante a gestação.
$_footer''';
  }

  /// Format body condition score calculation for sharing
  static String formatBodyConditionCalculation({
    required String species,
    required int bcsScore,
    required String classification,
    required String recommendation,
  }) {
    return '''
📋 Avaliação de Condição Corporal - Calculei App

🐾 Espécie: $species
📊 BCS Score: $bcsScore/9
🏷️ Classificação: $classification

💡 Recomendação: $recommendation

⚠️ Esta é uma estimativa. Consulte um veterinário para avaliação completa.
$_footer''';
  }

  /// Format caloric needs calculation for sharing
  static String formatCaloricNeedsCalculation({
    required String species,
    required double weight,
    required double rer,
    required double der,
    required int foodGrams,
  }) {
    return '''
📋 Necessidades Calóricas do Pet - Calculei App

🐾 Espécie: $species
⚖️ Peso: ${weight.toStringAsFixed(1)} kg

📊 Resultados:
• RER (Repouso): ${rer.toStringAsFixed(0)} kcal/dia
• DER (Diário): ${der.toStringAsFixed(0)} kcal/dia
• Ração: ~$foodGrams g/dia

💡 Divida em 2-3 refeições diárias.
$_footer''';
  }

  /// Format medication dosage calculation for sharing
  static String formatMedicationDosageCalculation({
    required String medication,
    required double weight,
    required double dosePerAdmin,
    required double dailyDose,
    required String unit,
    required String frequency,
  }) {
    return '''
📋 Dosagem de Medicamento - Calculei App

💊 Medicamento: $medication
⚖️ Peso: ${weight.toStringAsFixed(1)} kg
🕐 Frequência: $frequency

📊 Dosagem:
• Por administração: ${dosePerAdmin.toStringAsFixed(1)} $unit
• Dose diária: ${dailyDose.toStringAsFixed(1)} $unit

⚠️ IMPORTANTE: Siga orientação do veterinário.
$_footer''';
  }

  /// Format fluid therapy calculation for sharing
  static String formatFluidTherapyCalculation({
    required double weight,
    required double dehydration,
    required double maintenanceMl,
    required double deficitMl,
    required double totalMl,
    required double hourlyRate,
  }) {
    return '''
📋 Fluidoterapia - Calculei App

⚖️ Peso: ${weight.toStringAsFixed(1)} kg
💧 Desidratação: ${dehydration.toStringAsFixed(0)}%

📊 Volumes:
• Manutenção: ${maintenanceMl.toStringAsFixed(0)} ml/dia
• Déficit: ${deficitMl.toStringAsFixed(0)} ml
• Total 24h: ${totalMl.toStringAsFixed(0)} ml
• Taxa horária: ${hourlyRate.toStringAsFixed(1)} ml/h

⚠️ Uso exclusivo sob supervisão veterinária.
$_footer''';
  }

  /// Format pet ideal weight calculation for sharing
  static String formatPetIdealWeightCalculation({
    required String species,
    required double currentWeight,
    required double idealWeight,
    required double difference,
    required String recommendation,
  }) {
    final action = difference > 0 ? 'perder' : 'ganhar';
    return '''
📋 Peso Ideal do Pet - Calculei App

🐾 Espécie: $species
⚖️ Peso atual: ${currentWeight.toStringAsFixed(1)} kg
🎯 Peso ideal: ${idealWeight.toStringAsFixed(1)} kg
📉 Diferença: ${difference.abs().toStringAsFixed(1)} kg a $action

💡 $recommendation
$_footer''';
  }

  /// Format unit conversion calculation for sharing
  static String formatUnitConversionCalculation({
    required double fromValue,
    required String fromUnit,
    required double toValue,
    required String toUnit,
  }) {
    return '''
📋 Conversão de Unidades - Calculei App

📊 Resultado:
${fromValue.toStringAsFixed(2)} $fromUnit = ${toValue.toStringAsFixed(2)} $toUnit

🔄 Conversão realizada com precisão padrão.
$_footer''';
  }

  /// Format NPK calculation for sharing
  static String formatNpkCalculation({
    required String crop,
    required double nitrogenKgHa,
    required double phosphorusKgHa,
    required double potassiumKgHa,
    required double totalCost,
  }) {
    return '''
📋 Cálculo de Adubação NPK - Calculei App

🌱 Cultura: $crop

🧪 Necessidade de Nutrientes (kg/ha):
• Nitrogênio (N): ${nitrogenKgHa.toStringAsFixed(1)} kg/ha
• Fósforo (P₂O₅): ${phosphorusKgHa.toStringAsFixed(1)} kg/ha
• Potássio (K₂O): ${potassiumKgHa.toStringAsFixed(1)} kg/ha

💰 Custo estimado: R\$ ${totalCost.toStringAsFixed(2)}

💡 Considere análise de solo e recomendação agronômica para maior precisão.
$_footer''';
  }

  /// Format seed rate calculation for sharing
  static String formatSeedRateCalculation({
    required String crop,
    required int seedsPerHa,
    required double weightKgHa,
    required double totalWeightKg,
    required double efficiency,
  }) {
    return '''
📋 Cálculo de Taxa de Semeadura - Calculei App

🌾 Cultura: $crop

📊 Resultados:
• Sementes por hectare: $seedsPerHa sementes/ha
• Peso por hectare: ${weightKgHa.toStringAsFixed(1)} kg/ha
• Peso total: ${totalWeightKg.toStringAsFixed(1)} kg
• Eficiência de estabelecimento: ${efficiency.toStringAsFixed(1)}%

💡 Ajuste conforme condições locais e recomendações do fabricante.
$_footer''';
  }

  /// Format irrigation calculation for sharing
  static String formatIrrigationCalculation({
    required String crop,
    required String stage,
    required double etcMmDay,
    required double dailyVolumeM3,
    required double irrigationTimeHours,
    required int frequencyDays,
  }) {
    return '''
📋 Cálculo de Irrigação - Calculei App

🌾 Cultura: $crop
📅 Estágio: $stage

💧 Necessidade Hídrica:
• ETc: ${etcMmDay.toStringAsFixed(1)} mm/dia
• Volume diário: ${dailyVolumeM3.toStringAsFixed(1)} m³/dia
• Tempo de irrigação: ${irrigationTimeHours.toStringAsFixed(1)} horas
• Frequência: a cada $frequencyDays dias

💡 Monitore a umidade do solo e condições climáticas para ajustes.
$_footer''';
  }

  /// Format fertilizer dosing calculation for sharing
  static String formatFertilizerDosingCalculation({
    required String fertilizerType,
    required double areaHa,
    required double productKg,
    required double cost,
  }) {
    return '''
📋 Dosagem de Fertilizante - Calculei App

🌱 Fertilizante: $fertilizerType
📏 Área: ${areaHa.toStringAsFixed(1)} ha

📊 Resultado:
• Quantidade: ${productKg.toStringAsFixed(0)} kg
• Custo estimado: R\$ ${cost.toStringAsFixed(2)}

💡 Aplique de forma uniforme na área.
$_footer''';
  }

  /// Format soil pH calculation for sharing
  static String formatSoilPhCalculation({
    required double currentPh,
    required double targetPh,
    required double areaHa,
    required double limeKg,
  }) {
    return '''
📋 Correção de pH do Solo - Calculei App

🧪 pH atual: ${currentPh.toStringAsFixed(1)}
🎯 pH alvo: ${targetPh.toStringAsFixed(1)}
📏 Área: ${areaHa.toStringAsFixed(1)} ha

📊 Resultado:
• Calcário necessário: ${limeKg.toStringAsFixed(0)} kg

💡 Aplique 2-3 meses antes do plantio para melhor incorporação.
$_footer''';
  }

  /// Format planting density calculation for sharing
  static String formatPlantingDensityCalculation({
    required double rowSpacing,
    required double plantSpacing,
    required double areaHa,
    required int plantsPerHa,
    required int totalPlants,
  }) {
    return '''
📋 Densidade de Plantio - Calculei App

📏 Espaçamento: ${rowSpacing.toStringAsFixed(2)}m × ${plantSpacing.toStringAsFixed(2)}m
🌾 Área: ${areaHa.toStringAsFixed(1)} ha

📊 Resultado:
• Plantas/ha: $plantsPerHa
• Total de plantas: $totalPlants

💡 Ajuste conforme recomendação para sua cultivar.
$_footer''';
  }

  /// Format yield prediction calculation for sharing
  static String formatYieldPredictionCalculation({
    required String cropType,
    required double areaHa,
    required double grossYield,
    required double netYield,
    required double marketValue,
  }) {
    return '''
📋 Previsão de Produtividade - Calculei App

🌾 Cultura: $cropType
📏 Área: ${areaHa.toStringAsFixed(1)} ha

📊 Resultado:
• Produção bruta: ${grossYield.toStringAsFixed(0)} kg
• Produção líquida: ${netYield.toStringAsFixed(0)} kg
• Valor de mercado: R\$ ${marketValue.toStringAsFixed(2)}

💡 Valores estimados - considere fatores climáticos e de manejo.
$_footer''';
  }

  /// Format feed calculator for sharing
  static String formatFeedCalculation({
    required String animalType,
    required int numAnimals,
    required double dailyFeed,
    required double totalFeed,
    required double cost,
  }) {
    return '''
📋 Cálculo de Ração - Calculei App

🐄 Animal: $animalType
📊 Quantidade: $numAnimals animais

📊 Resultado:
• Consumo diário: ${dailyFeed.toStringAsFixed(1)} kg/dia
• Total necessário: ${totalFeed.toStringAsFixed(0)} kg
• Custo estimado: R\$ ${cost.toStringAsFixed(2)}

💡 Ajuste conforme fase de produção e qualidade do alimento.
$_footer''';
  }

  /// Format weight gain calculation for sharing
  static String formatWeightGainCalculation({
    required String animalType,
    required double initialWeight,
    required double targetWeight,
    required int daysNeeded,
    required double totalFeed,
  }) {
    return '''
📋 Ganho de Peso - Calculei App

🐄 Animal: $animalType
⚖️ Peso inicial: ${initialWeight.toStringAsFixed(1)} kg
🎯 Peso meta: ${targetWeight.toStringAsFixed(1)} kg

📊 Resultado:
• Dias até a meta: $daysNeeded dias
• Ração estimada: ${totalFeed.toStringAsFixed(0)} kg

💡 Monitore peso semanalmente para ajustar manejo.
$_footer''';
  }

  /// Format breeding cycle calculation for sharing
  static String formatBreedingCycleCalculation({
    required String species,
    required String breedingDate,
    required String expectedBirth,
    required int gestationDays,
    required int daysRemaining,
  }) {
    return '''
📋 Ciclo Reprodutivo - Calculei App

🐄 Espécie: $species
📅 Cobertura: $breedingDate
📅 Parto previsto: $expectedBirth

📊 Gestação:
• Duração média: $gestationDays dias
• Dias restantes: $daysRemaining

💡 Prepare instalações e monitore sinais de parto.
$_footer''';
  }

  /// Format evapotranspiration calculation for sharing
  static String formatEvapotranspirationCalculation({
    required double temperature,
    required double humidity,
    required double etoMmDay,
    required double weeklyWater,
  }) {
    return '''
📋 Evapotranspiração - Calculei App

🌡️ Temperatura: ${temperature.toStringAsFixed(1)}°C
💧 Umidade: ${humidity.toStringAsFixed(0)}%

📊 Resultado:
• ETo diário: ${etoMmDay.toStringAsFixed(2)} mm/dia
• Necessidade semanal: ${weeklyWater.toStringAsFixed(1)} mm

💡 Use para planejamento de irrigação.
$_footer''';
  }

  /// Format water tank calculation for sharing
  static String formatWaterTankCalculation({
    required int numberOfPeople,
    required double dailyConsumption,
    required int reserveDays,
    required double totalCapacity,
    required int recommendedTankSize,
    required String tankType,
  }) {
    final totalDaily = (numberOfPeople * dailyConsumption).toInt();
    
    return '''
📋 Cálculo de Caixa d'Água - Calculei App

👥 Número de Pessoas: $numberOfPeople
💧 Consumo Diário: ${dailyConsumption.toInt()} L/pessoa/dia
📅 Dias de Reserva: $reserveDays ${reserveDays == 1 ? 'dia' : 'dias'}

📊 Resultado:
• Consumo total diário: $totalDaily litros
• Capacidade mínima: ${totalCapacity.toInt()} litros
• Caixa recomendada: $recommendedTankSize litros
• Material: $tankType

💡 Considere margem de segurança de 20% para variações.
$_footer''';
  }
}
