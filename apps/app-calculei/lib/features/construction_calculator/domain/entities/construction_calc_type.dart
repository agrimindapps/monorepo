/// Types of construction calculations available
enum ConstructionCalcType {
  materialsQuantity(
    'Quantidades de Materiais',
    'Calcule a quantidade de areia, cimento, blocos e outros materiais',
    'material_quantity',
  ),
  costPerSquareMeter(
    'Custo por m²',
    'Calcule o custo total baseado no valor por metro quadrado',
    'cost_sqm',
  ),
  paintConsumption(
    'Consumo de Tinta',
    'Calcule a quantidade de tinta necessária para sua obra',
    'paint',
  ),
  flooring(
    'Piso/Revestimento',
    'Calcule a quantidade de peças para piso ou revestimento',
    'flooring',
  ),
  concrete(
    'Concreto',
    'Calcule os materiais necessários para produzir concreto',
    'concrete',
  );

  const ConstructionCalcType(this.label, this.description, this.id);

  final String label;
  final String description;
  final String id;

  String get route {
    switch (this) {
      case ConstructionCalcType.materialsQuantity:
        return '/calculators/construction/materials-quantity';
      case ConstructionCalcType.costPerSquareMeter:
        return '/calculators/construction/cost-per-sqm';
      case ConstructionCalcType.paintConsumption:
        return '/calculators/construction/paint-consumption';
      case ConstructionCalcType.flooring:
        return '/calculators/construction/flooring';
      case ConstructionCalcType.concrete:
        return '/calculators/construction/concrete';
    }
  }
}
